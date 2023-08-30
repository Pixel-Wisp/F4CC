// Based on code by Superxwolf, originally licensed under the MIT License.
// Copyright (c) 2023 kmrkle.tv community. All rights reserved.
//
// Licensed under the MIT License. See LICENSE in the project root for license information.

#include "common/IPrefix.h"

#include "Connector.h"

#include <ws2tcpip.h>
#include <stdio.h>
#include <iostream>
#include <functional>
#include <chrono>
#include <memory>
#include <mutex>
#include <sstream>
#include <string>
#include <regex>

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#include "f4se/PapyrusEvents.h"
#include "f4se/GameUtilities.h"
#include "f4se/gamethreads.h"
#include "f4se/GameAPI.h"
#pragma comment(lib, "Ws2_32.lib")


Connector::Connector()
	: error{ "An error occurred" },
	m_socket(INVALID_SOCKET),
	iResult(0)
{
	WORD wVersionRequested = MAKEWORD(2, 2);
	WSADATA wsaData = { 0 };

	int err = WSAStartup(wVersionRequested, &wsaData);
}

Connector::~Connector()
{
	if (m_socket != INVALID_SOCKET)
	{
		closesocket(m_socket);
		m_socket = INVALID_SOCKET;
	}

	WSACleanup();
}

bool Connector::HasError()
{
	return hasError;
}

const char* Connector::GetError()
{
	return (const char*)error;
}

void Connector::ResetError()
{
	hasError = false;
	ZeroMemory(&error, sizeof(error));
}

bool Connector::IsConnected()
{
	return m_socket != INVALID_SOCKET && !connecting;
}

bool Connector::IsConnecting()
{
	return connecting;
}

bool Connector::IsRunning()
{
	return running && checking;
}

void Connector::OnMenu(bool isOpen)
{
	std::lock_guard<std::mutex> guard(m_mutex);
	menuOpened = isOpen;
}

int Connector::GetCommandCount()
{
	std::lock_guard<std::mutex> guard(m_mutex);
	return command_map.size();
}

std::shared_ptr<Command> Connector::GetLatestCommand()
{
	try
	{
		std::lock_guard<std::mutex> guard(m_mutex);
		if (command_map.size() > 0)
		{
			auto iter = command_map.begin();
			auto last = iter->second;
			last->processing = true;
			return last;
		}
	}
	catch (std::exception e)
	{
		_ERROR("[Connector::Connect] %s", e.what());
	}

	return NULL;
}

void Connector::NewTimer(UINT command_id, int miliseconds)
{
	std::lock_guard<std::mutex> guard(m_mutex);
	auto c = command_map[command_id];
	c->type = 2;
	c->time = GetElapsedTime() + (long long)miliseconds;
	timer_map.insert({ c->command, c });
}

void Connector::ExtendTimer(UINT command_id, int miliseconds)
{
	std::lock_guard<std::mutex> guard(m_mutex);
	auto c = command_map[command_id];
	c->time += miliseconds;
}

bool Connector::HasTimer(UINT command_id)
{
	try
	{
		std::lock_guard<std::mutex> guard(m_mutex);
		auto c = command_map[command_id];
		return HasTimer(c->command);
	}
	catch (std::exception e)
	{
		_ERROR("[Connector::HasTimer] %s", e.what());
	}

	return false;
}

bool Connector::HasTimer(std::string command_name)
{
	return timer_map.find(command_name) != timer_map.end();
}

void Connector::ClearTimers()
{
	std::lock_guard<std::mutex> lock(m_mutex);
	timer_map.clear();
}

void Connector::ConnectAsync(const char* port)
{
	if (IsConnected()) return;
	if (connect_thread.valid())
	{
		auto status = connect_thread.wait_for(std::chrono::milliseconds::zero());
		if (status == std::future_status::ready)
		{
			bool result = connect_thread.get();

			if (!result)
				connect_thread = std::async(&Connector::Connect, this, port);

			else
				connect_thread = std::future<bool>();
		}
	}
	else
	{
		connect_thread = std::async(&Connector::Connect, this, port);
	}
}

bool Connector::Connect(const char* port)
{
	value_lock<bool> connect_lock(&connecting, true, false);

	try
	{
		int iFamily = AF_INET;
		int iType = SOCK_STREAM;
		int iProtocol = IPPROTO_TCP;

		struct addrinfo* result = NULL,
			* ptr = NULL,
			hints;

		ZeroMemory(&hints, sizeof(hints));

		iResult = getaddrinfo("127.0.0.1", port, &hints, &result);

		if (iResult != 0)
		{
			hasError = true;
			snprintf(error, sizeof(error), "getaddrinfo error: %d", iResult);

			return false;
		}

		ptr = result;

		m_socket = socket(ptr->ai_family, ptr->ai_socktype, ptr->ai_protocol);

		if (m_socket == INVALID_SOCKET)
		{
			hasError = true;
			snprintf(error, sizeof(error), "Socket creation failed: %d", WSAGetLastError());

			return false;
		}

		iResult = connect(m_socket, ptr->ai_addr, (int)ptr->ai_addrlen);
		if (iResult == SOCKET_ERROR)
		{
			hasError = true;

			m_socket = INVALID_SOCKET;
			snprintf(error, sizeof(error), "Error connecting to CrowdControl");

			return false;
		}

		ResetError();
		connecting = false;
		Run();

		return true;
	}
	catch (std::exception e)
	{
		_ERROR("[Connector::Connect] %s", e.what());
		if (m_socket != INVALID_SOCKET)
		{
			closesocket(m_socket);
			m_socket = INVALID_SOCKET;
		}
	}

	return false;
}

void Connector::Respond(SInt32 id, SInt32 status, BSFixedString message, int milliseconds)
{
	try
	{
		std::shared_ptr<Command> c;
		{
			std::lock_guard<std::mutex> lock(m_mutex);
			auto iter = command_map.find((UINT)id);
			if (iter == command_map.end())
				return;
			c = iter->second;
		}

		bool timer_created = false;
		if (status == 4)
		{
			timer_created = true;
			status = 0;
			if (!HasTimer(id))
			{
				NewTimer(id, milliseconds);
			}
			else
			{
				_MESSAGE("Extending timer for %s", c->command.c_str());
				ExtendTimer(id, milliseconds);
			}
		}

		if (c->type == 1 || timer_created)
			Respond(id, status, message);

		std::lock_guard<std::mutex> lock(m_mutex);
		command_map.erase(c->id);
	}
	catch (std::exception e)
	{
		_ERROR("[Connector::Respond] %s", e.what());
	}
}

void Connector::Respond(SInt32 id, SInt32 status, BSFixedString message)
{
	try
	{
		rapidjson::Document data;
		data.SetObject();

		rapidjson::Document::AllocatorType& allocator = data.GetAllocator();
		size_t sz = allocator.Size();

		data.AddMember("id", id, allocator);
		data.AddMember("status", status, allocator);

		rapidjson::Value val(rapidjson::kStringType);

		if (strlen(message.c_str()) > 0)
		{
			val.SetString(message.c_str(), static_cast<rapidjson::SizeType>(strlen(message.c_str())), allocator);
			data.AddMember("message", val, allocator);
		}

		rapidjson::StringBuffer buf;
		rapidjson::Writer<rapidjson::StringBuffer> writer(buf);

		data.Accept(writer);
		buf.Put('\0');

		send(m_socket, buf.GetString(), buf.GetLength(), 0);
	}
	catch (std::exception e)
	{
		_ERROR("[Connector::Respond 2] %s", e.what());
	}
}

void Connector::Run()
{
	if (!IsConnected()) return;
	if (run_thread.valid())
	{
		auto status = run_thread.wait_for(std::chrono::milliseconds::zero());

		if (status == std::future_status::ready)
		{
			run_thread = std::async(&Connector::_Run, this);
		}
	}
	else
	{
		run_thread = std::async(&Connector::_Run, this);
	}

	if (command_check_thread.valid())
	{
		auto status = command_check_thread.wait_for(std::chrono::milliseconds::zero());

		if (status == std::future_status::ready)
		{
			command_check_thread = std::async(&Connector::_RunTimer, this);
		}
	}
	else
	{
		command_check_thread = std::async(&Connector::_RunTimer, this);
	}
}

long long Connector::GetElapsedTime()
{
	return GetElapsedTime(start_time);
}

long long Connector::GetElapsedTime(std::chrono::steady_clock::time_point time)
{
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - time).count();
}

void Connector::_RunTimer()
{
	value_lock<bool> check_lock(&checking, true, false);
	while (true)
	{
		Sleep(500);
		try
		{
			std::lock_guard<std::mutex> guard(m_mutex);

			long long delta_time = 0;
			if (menuOpened)
			{
				delta_time = GetElapsedTime(last_update);
			}

			long long cur_timer = GetElapsedTime();

			auto iter = command_map.begin();
			while (iter != command_map.end())
			{
				if (!iter->second->processing && iter->second->type == 1 && cur_timer - iter->second->time > 2000)
				{
					Respond((int)iter->first, (int)3, "");
					iter = command_map.erase(iter);
				}
				else iter++;
			}

			auto timer_iter = timer_map.begin();
			while (timer_iter != timer_map.end())
			{
				timer_iter->second->time += delta_time;
				auto c = timer_iter->second;
				if (cur_timer > c->time)
				{
					command_map.insert({ c->id, c });
					timer_iter = timer_map.erase(timer_iter);
				}
				else timer_iter++;
			}

			last_update = std::chrono::steady_clock::now();
		}
		catch (std::exception e)
		{
			_ERROR("[Connector::_RunTimer] %s", e.what());
		}
	}
}

void Connector::_Run()
{
	value_lock<bool> run_lock(&running, true, false);
	while (true)
	{
		try
		{
			ResetError();
			int last_error = 0;
			int recvbuflen = DEFAULT_BUFLEN;
			char recvbuf[DEFAULT_BUFLEN];
			ZeroMemory(&recvbuf, sizeof(recvbuf));

			iResult = recv(m_socket, recvbuf, recvbuflen, 0);
			if (iResult > 0)
			{

				auto commands = BufferSocketResponse(recvbuf, iResult);

				for (auto c : commands)
				{
					if (c.length() == 0) continue;
					
					_MESSAGE("Got message: %s", c.c_str());

					rapidjson::Document data;
					data.Parse(c.c_str());
					
					if (data.HasParseError()) {
						rapidjson::ParseErrorCode errorCode = data.GetParseError();
						size_t errorOffset = data.GetErrorOffset();

						std::stringstream errorMsg;
						errorMsg << "JSON parse error: " << errorCode
							<< " at offset " << errorOffset;

						_WARNING("Parse command: %s", errorMsg.str().c_str());

						continue;
					}

					if (data.IsObject())
					{
						std::string command;
						std::vector<std::string> parameters;
						
						if (!data.HasMember("id") || !data["id"].IsUint() || 
							!data.HasMember("viewer") || !data["viewer"].IsString()) {
							_WARNING("Received invalid command (missing or invalid type: id, viewer).");

							continue;
						}

						UINT command_id = data["id"].GetUint();
						std::string command_viewer = data["viewer"].GetString();
						
						if (data.HasMember("code") && data["code"].IsString()) {
							// V1 API
							// {"id":1,"code":"spawndragon_white3","viewer":"sdk","type":1}\0

							std::string command_code = data["code"].GetString();

							command_code = std::regex_replace(command_code, std::regex("____"), "|");
							command_code = std::regex_replace(command_code, std::regex("___"), "~");
							command_code = std::regex_replace(command_code, std::regex("__"), "-");

							_MESSAGE("  command code: %s", command_code.c_str());

							std::istringstream iss(command_code);
							std::vector<std::string> tokens;
							std::string token;

							while (std::getline(iss, token, '_')) {
								tokens.push_back(token);
							}

							if (!tokens.empty()) {
								command = tokens[0];
								parameters.assign(tokens.begin() + 1, tokens.end());
							}
						}
						else if (data.HasMember("command") && data["command"].IsString() &&
								 data.HasMember("parameters") && data["parameters"].IsArray()) {
							// V2 API
							// { id: 1, command: "SpawnDragon", viewer: "ViewerName", parameters: ["WhiteDragon3"]}\0

							command = data["command"].GetString();

							_MESSAGE("V2 Command: %s", command.c_str());

							const rapidjson::Value& param_array = data["parameters"];
							for (rapidjson::SizeType i = 0; i < param_array.Size(); i++) {
								parameters.push_back(param_array[i].GetString());
							}
						}
						else {
							_WARNING("Cannot parse command. Unknown format. (id=%u)", command_id);
							continue;
						}

						int command_type = 1;
						if (data.HasMember("type") && data["type"].IsInt()) {
							command_type = data["type"].GetInt();
						}

						int duration = 0;
						if (data.HasMember("duration") && data["duration"].IsInt()) {
							duration = data["duration"].GetInt();
						}

						std::lock_guard<std::mutex> lock(m_mutex);
						command_map.insert({ command_id,
							std::make_shared<Command>(Command{
								command_id,
								false,
								command,
								command_viewer,
								command_type,
								GetElapsedTime(),
								duration,
								parameters
							}) });
					}
				}
			}

			else if (iResult == 0)
			{
				hasError = true;
				snprintf(error, sizeof(error), "Connection closed");
				m_socket = INVALID_SOCKET;
				break;
			}

			else
			{
				last_error = WSAGetLastError();
				if (last_error != (int)WSAEWOULDBLOCK)
				{
					hasError = true;
					snprintf(error, sizeof(error), "recv failed: %d\n", last_error);
					m_socket = INVALID_SOCKET;
					break;
				}
			}
		}
		catch (std::exception e)
		{
			_ERROR("[Connector::_Run] %s", e.what());
		}
	}
}

std::vector<std::string> Connector::BufferSocketResponse(const char* buf, size_t buf_size)
{
	socketBuffer.append(buf, buf_size);
	std::vector<std::string> buffer_array;

	size_t index = socketBuffer.find('\0');
	while (index != std::string::npos)
	{
		buffer_array.push_back(socketBuffer.substr(0, index));
		socketBuffer = socketBuffer.substr(index+1);
		index = socketBuffer.find('\0');
	}

	return buffer_array;
}