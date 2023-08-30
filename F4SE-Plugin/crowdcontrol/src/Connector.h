// Based on code by Superxwolf, originally licensed under the MIT License.
// Copyright (c) 2023 kmrkle.tv community. All rights reserved.
//
// Licensed under the MIT License. See LICENSE in the project root for license information.

#pragma once
#define DEFAULT_BUFLEN 512

#include <winsock2.h>
#include <vector>
#include <mutex>
#include <future>
#include <thread>
#include <array>
#include <map>
#include "f4se/GameTypes.h"

template <class value_type>
class value_lock
{
private:
	value_type* value;
	value_type unlock_value;

	bool locked = false;

public:
	value_lock(value_type* value, value_type lock_value, value_type unlock_value)
	{
		this->value = value;
		this->unlock_value = unlock_value;

		*value = lock_value;
		locked = true;
	}

	~value_lock()
	{
		if (locked)
		{
			*value = unlock_value;
			locked = false;
		}
	}

	void Unlock()
	{
		if (locked)
		{
			*value = unlock_value;
			locked = false;
		}
	}
};

struct Command
{
public:
	UINT id = 0;
	bool processing = false;
	std::string command;
	std::string viewer;

	/// <summary>
	/// 1 = Normal command
	/// 2 = Executing command with a timer
	/// </summary>
	int type = 0;
	long long time = 0;

	/// <summary>
	/// The duration of the effect in milliseconds.
	/// </summary>
	int durationMS = 0;

	/// <summary>
	/// Optional parameters, not compatible with CrowdControl.
	/// </summary>
	std::vector<std::string> parameters;
};

class Connector
{
	SOCKET m_socket = INVALID_SOCKET;
	int iResult = 0;

	bool hasError = false;
	char error[100];

	std::mutex m_mutex;
	std::map<UINT, std::shared_ptr<Command>> command_map;
	std::map<std::string, std::shared_ptr<Command>> timer_map;

	std::future<void> run_thread;
	std::future<void> command_check_thread;
	std::future<bool> connect_thread;
	std::future<void> papyrus_check;

	std::chrono::steady_clock::time_point start_time = std::chrono::steady_clock::now();
	std::chrono::steady_clock::time_point last_update = std::chrono::steady_clock::now();

	long long GetElapsedTime();
	long long GetElapsedTime(std::chrono::steady_clock::time_point time);

	void _RunTimer();
	void _Run();

	std::string socketBuffer = "";
	std::vector<std::string> BufferSocketResponse(const char* buf, size_t buf_size);

	bool running = false;
	bool connecting = false;
	bool checking = false;
	bool menuOpened = false;

public:

	Connector();
	~Connector();

	void ResetError();
	const char* GetError();
	bool HasError();
	bool IsConnected();
	bool IsConnecting();
	bool IsRunning();

	void OnMenu(bool isOpen);

	int GetCommandCount();
	std::shared_ptr<Command> GetLatestCommand();

	void NewTimer(UINT command_id, int miliseconds);
	void ExtendTimer(UINT command_id, int miliseconds);
	bool HasTimer(UINT command_id);
	bool HasTimer(std::string command_name);
	void ClearTimers();

	void ConnectAsync(const char* port);
	bool Connect(const char* port);

	/// <summary>
	/// Send response for a command.
	/// </summary>
	/// 0 = Success
	/// 1 = Temporary failure
	/// 2 = Permanent failure
	/// 3 = Retry soon
	/// 4 = Success, and start a timer for milliseconds
	/// </param>
	/// <param name="message"></param>
	void Respond(SInt32 id, SInt32 status, BSFixedString message, int miliseconds);
	void Respond(SInt32 id, SInt32 status, BSFixedString message);

	void Run();
};

