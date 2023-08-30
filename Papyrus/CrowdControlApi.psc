; Copyright (c) 2023 kmrkle.tv community. All rights reserved.
; Licensed under the MIT License. See LICENSE in the project root for license information.

Scriptname CrowdControlApi Hidden native

String Function Version() Global Native
String Function GetCrowdControlState() Global Native

Function Run() Global Native
Function Reconnect() Global Native
Function Respond(int id, int status, string message, int milliseconds = 0) Global Native

struct CrowdControlCommand
	int id
	string viewer
	int type
    int durationMS

    string command
    
    string param0
    string param1
    string param2
    string param3
    string param4
    string param5
    string param6
    string param7
    string param8
    string param9
    string param10
    string param11
EndStruct

int Function GetCommandCount() Global Native
CrowdControlCommand Function GetCommand() Global Native

int Function HasTimer(string command_name) Global Native
Function ClearTimers() Global Native
int Function GetIntSetting(string section, string key) Global Native
float Function GetFloatSetting(string section, string key) Global Native

string[] Function StringSplit(string text, string delimiter) Global Native
bool Function StringContains(string text, string delimiter) Global Native
string Function GetNameId(int formId) Global Native
string Function GetName(string id) Global Native
string Function NormalizeDataFileName(string fileName) Global Native