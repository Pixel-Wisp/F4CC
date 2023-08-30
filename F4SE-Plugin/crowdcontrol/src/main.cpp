// Based on code by Superxwolf, originally licensed under the MIT License.
// Copyright (c) 2023 kmrkle.tv community. All rights reserved.
//
// Licensed under the MIT License. See LICENSE in the project root for license information.

#include "common/IPrefix.h"
#include "common/ITypes.h"
#include "simpleini/SimpleIni.h"

#include <windows.h>
#include <ShlObj.h>  // CSIDL_MYDOCUMENTS
#include <stdexcept>
#include <sstream>
#include <stdexcept>
#include <unordered_map>
#include <string>
#include <regex>

#include "version.h"  // VERSION_VERSTRING, VERSION_MAJOR

#include "f4se/PluginAPI.h"
#include "f4se/PapyrusGame.h"
#include "f4se/GameTypes.h"

#include "f4se/PapyrusVM.h"
#include "f4se/PapyrusNativeFunctions.h"
#include "f4se/GameEvents.h"
#include "f4se/PapyrusEvents.h"
#include "f4se/GameMenus.h"
#include "f4se/ScaleformAPI.h"

#include "f4se_common/f4se_version.h"

#include "Connector.h"

#define CC_VERSION "2.0"
#define CC_VERSION_MAJOR 2
#define CC_IP "127.0.0.1"
#define CC_PORT "5420"

static Connector* connector = NULL;

PluginHandle				g_pluginHandle;
F4SEMessagingInterface*		g_messaging;
F4SEPapyrusInterface*		g_papyrus;
F4SEScaleformInterface*		g_scaleform;

class F4SEOpenCloseHandler : public BSTEventSink<MenuOpenCloseEvent>
{
public:
	virtual ~F4SEOpenCloseHandler() { };
	virtual	EventResult	ReceiveEvent(MenuOpenCloseEvent* evn, void* dispatcher) override
	{
		bool isOpen = 
			(*g_ui)->IsMenuOpen("PauseMenu") || 
			(*g_ui)->IsMenuOpen("PipboyMenu") ||
			(*g_ui)->IsMenuOpen("TerminalMenu") || 
			(*g_ui)->IsMenuOpen("CookingMenu") || 
			(*g_ui)->IsMenuOpen("ContainerMenu") || 
			(*g_ui)->IsMenuOpen("DialogueMenu") || 
			(*g_ui)->IsMenuOpen("CreationClubMenu") || 
			(*g_ui)->IsMenuOpen("LockpickingMenu") || 
			(*g_ui)->IsMenuOpen("ExamineMenu") || 
			(*g_ui)->IsMenuOpen("WorkshopMenu") || 
			(*g_ui)->IsMenuOpen("BarterMenu") || 
			(*g_ui)->IsMenuOpen("VATSMenu") || 
			(*g_ui)->IsMenuOpen("LevelUpMenu") || 
			(*g_ui)->IsMenuOpen("BookMenu");
		
		_DMESSAGE("[Main] Menu: %s", isOpen ? "Open" : "Closed");

		if (connector != NULL)
		{
			connector->OnMenu(isOpen);
		}	

		return kEvent_Continue;
	};
};

F4SEOpenCloseHandler g_menuOpenCloseHandler;

BSFixedString CrowdControlVersion(StaticFunctionTag*)
{
	return BSFixedString(CC_VERSION);
}

bool _logConnected = false;

BSFixedString CrowdControlState(StaticFunctionTag*)
{
	if (connector == NULL)
	{
		_DMESSAGE("[Main] CrowdControlState() = uninitialized");

		return BSFixedString("uninitialized");
	}
	else if (!connector->IsConnected())
	{
		_DMESSAGE("[Main] CrowdControlState() = disconnected");

		return BSFixedString("disconnected");
	}
	else if (!connector->IsRunning())
	{
		_DMESSAGE("[Main] CrowdControlState() = stopped");

		return BSFixedString("stopped");
	}
	else
	{
		_DMESSAGE("[Main] CrowdControlState() = running");

		if (_logConnected) {
			_logConnected = false;

			_MESSAGE("[Main] Connected");
		}

		return BSFixedString("running");
	}
}

void CrowdControlReconnect(StaticFunctionTag*)
{
	_MESSAGE("[Main] CrowdControlReconnect()");

	if (connector == NULL)
	{
		connector = new Connector();
	}

	if (!connector->IsConnected())
	{
		if (!connector->IsConnecting()) {
			_MESSAGE("[Main] Connecting...");

			_logConnected = true;

			connector->ConnectAsync(CC_PORT);
		}
		else {
			_MESSAGE("[Main] Still connecting...");
		}
	}
	else if (!connector->IsRunning())
	{
		_MESSAGE("[Main] Run");

		connector->Run();
	}
	else
	{
		_MESSAGE("[Reconnect] Already connected");
	}
}

void CrowdControlRun(StaticFunctionTag*)
{
	_MESSAGE("[Main] CrowdControlRun()");

	connector->Run();
}

void CrowdControlRespond(StaticFunctionTag*, SInt32 id, SInt32 status, BSFixedString message, SInt32 milliseconds = 0)
{
	if (connector != NULL)
	{
		connector->Respond(id, status, message, milliseconds);
	}
}

SInt32 CrowdControlCommandCount(StaticFunctionTag*)
{
	if (connector == NULL) return 0;

	return connector->GetCommandCount();
}

DECLARE_STRUCT(CrowdControlCommand, "CrowdControlApi")

CrowdControlCommand CrowdControlGetCommand(StaticFunctionTag*)
{
	CrowdControlCommand ccCommand;
	
	if (connector == NULL || connector->GetCommandCount() == 0) {
		ccCommand.SetNone(true);

		return ccCommand;
	}

	std::shared_ptr<Command> command = connector->GetLatestCommand();

	ccCommand.Set<UInt32>("id", command->id);
	ccCommand.Set<BSFixedString>("command", BSFixedString(command->command.c_str()));
	ccCommand.Set<BSFixedString>("viewer", BSFixedString(command->viewer.c_str()));
	ccCommand.Set<SInt32>("type", command->type);
	ccCommand.Set<SInt32>("durationMS", command->durationMS);

	int i = 0;
	for (const std::string& param : command->parameters) {
		std::string paramName = "param" + std::to_string(i);
		ccCommand.Set<BSFixedString>(paramName.c_str(), BSFixedString(param.c_str()));
		i++;
	}

	_MESSAGE("[Main] CrowdControlGetCommand(): %s", command->command.c_str());

	return ccCommand;
}

SInt32 CrowdControlHasTimer(StaticFunctionTag*, BSFixedString command_name)
{
	if (connector != NULL)
	{
		return connector->HasTimer(command_name.c_str()) ? 1 : 0;
	}
	return 0;
}

void CrowdControlClearTimers(StaticFunctionTag*)
{
	if (connector != NULL)
	{
		connector->ClearTimers();
	}
}

VMArray<BSFixedString> CrowdControlStringSplit(StaticFunctionTag*, BSFixedString text, BSFixedString splitCharacter)
{
	VMArray<BSFixedString> r;

	_DMESSAGE("CrowdControlStringSplit(): '%s' (%s)", text.c_str(), splitCharacter.c_str());

	auto textC = text.c_str();
	auto splitCharacterC = splitCharacter.c_str();

	// Splitting
	std::istringstream iss(textC);
	std::string segment;
	while (std::getline(iss, segment, *splitCharacterC)) {
		_DMESSAGE("  %s", segment.c_str());
		r.Push(&BSFixedString(segment.c_str()));
	}

	return r;
}

bool CrowdControlStringContains(StaticFunctionTag*, BSFixedString text, BSFixedString toFind)
{
	_DMESSAGE("CrowdControlStringContains(): '%s' (%s)", text.c_str(), toFind.c_str());

	std::string textS(text.c_str());

	return textS.find(std::string(toFind)) != std::string::npos;
}

std::unordered_map<UInt32, std::string> formIdToNameMap = {
	{15, "Caps"},
	{588968, "Bobby Pin Box"},
	{483300, "Fusion Core"},

	{0x001BF72E, "Adhesive"},
	{0x0006907A, "Aluminum"},
	{0x00069081, "Screws"},
	{0x000731A4, "Steel"},
	{0x0006907C, "Copper"},
	{0x001BF732, "Oil"},
	{0x0006907B, "Circuitry"},
	{0x00069086, "Nuclear Material"},
	{0x00069087, "Fiber Optics"},
	{0x0006907D, "Crystal"},
	{0x001BF72D, "Acid"},
	{0x001BF72F, "Antiseptic"},
	{0x000AEC5B, "Ballistic Fiber"},
	{0x000AEC5D, "Bone"},
	{0x000AEC5E, "Ceramic"},
	{0x000AEC5F, "Cloth"},
	{0x00106D99, "Concrete"},
	{0x000AEC60, "Cork"},
	{0x001BF730, "Fertilizer"},
	{0x000AEC61, "Fiberglass"},
	{0x0006907E, "Gears"},
	{0x00069085, "Glass"},
	{0x000AEC62, "Gold"},
	{0x000AEC63, "Lead"},
	{0x000AEC64, "Leather"},
	{0x0006907F, "Plastic"},
	{0x00106D98, "Rubber"},
	{0x000AEC66, "Silver"},
	{0x00069082, "Spring"},
	{0x000731A3, "Wood"},

	{0x459C5, "Addictol"},
	{145206, "Stimpack"},
	{145206, "Stim-plosion"},
	{145218, "RadAway"},
	{145218, "RadAway-plosion"},
	{147543, "Rad-X"},
	{0x58AA7, "Calmex"},
	{363176, "Psycho Jet"},
	{1378036, "X-Cell"},
	{324774, "Stealth Boy"},
	{1729430, "Perfect Pie-plosion"},
	{0x4835D, "Nuka Cola-plosion"},
	{0x4835F, "Nuka Cola Quantum-plosion"},
	{0x0009DCC4, "Tato-plosion"},
	{0x000FAFEB, "Melon-plosion"},

	{1159990, "Furious Power Fist"},
	{1589197, "Grognak's Axe"},
	{2056678, "Wastelander's Friend"},
	{1046933, "Alien Blaster"},
	{2254587, "Lorenzo's Artifact"},
	{2056681, "Experiment 18-A"},
	{2274819, "The Last Minute"},
	{1608302, "Broadsider"},
	{2056679, "Overseer's Guardian"},
	{2251454, "Final Judgment"},
	{2041134, "Ashmaker"},
	{2251113, "Death From Above"},
	{2056675, "Spray n' Pray"},
	{2204990, "Big Boy"},
	{775535, "Experimental MIRV"},

	{1058218, "Alien Blaster Round"},
	{127606, "10mm"},
	{128618, ".45"},
	{1616863, "2mm EC"},
	{128620, "5mm"},
	{121783, "Plasma Cartridge"},
	{0x000C1897, "Fusion Cell"},
	{914041, "Gamma Round"},
	{830371, "Missile"},
	{1036572, "Cannonball"},
	{944942, "Mini Nuke"},
	{977901, "Fragmentation Grenade"},
	{1045023, "Pulse Grenade"},

	{0x001F599A, "Bathrobe"},
	{0x001F599A, "Agatha's Dress"},
	{0x001236AD, "Institute Division Head Coat"},
	{0x001B350D, "Institute Lab Coat"},
	{0x001E8CAB, "Cabot's Lab Coat"},
	{0x001BDDF8, "Clean Black Suit"},
	{0x00115AEB, "Cleanroom Suit"},
	{0x000316D4, "Colonial Duster"},
	{0x001921D6, "Corset"},
	{0x0012A332, "Courser Uniform"},
	{0x0014FBD0, "Father's Lab Coat"},
	{0x001B5F1B, "Feathered Dress"},
	{0x0023CAA4, "Geneva's Ensemble"},
	{0x1828CC, "Grognak Costume"},
	{0x000CEAC4, "Hazmat Suit"},
	{0x002075BF, "Pink Dress"},
	{0x0005E76C, "Red Rocket Mechanic Jumpsuit"},
	{0x00146174, "Postman Uniform"},
	{0x000FD9A8, "Red Dress"},
	{0x0011A27B, "Sequin Dress"},
	{0x0014E58E, "Silver Shroud Costume"},
	{0x0014941A, "Summer Shorts"},
	{0x0014B019, "T-shirt and Slacks"},
	{0x000FC395, "Tuxedo"},
	{0x00068CF3, "Vault-Tec Lab Coat"},
	{0x000DF457, "Yellow Trench Coat"},

	{0x0011e2c8, "Combat Armor"},
	{0x0022e2ed, "Synth Armor"},
	{0x17FB09, "T-45 Power Armor"},
	{0x108EA0, "T-51 Power Armor"},
	{0x17FB0A, "T-60 Power Armor"},
	{0x1681E2, "X-01 Power Armor"},

	{ 0xEFBB4, "Eye Bot" },
	{ 0x90E57, "Radstag" },
	{ 0x01006332, "House Cat" },
	{ 0x00020480, "Brahmin" },

	{ 1075975, "Protectron" },
	{ 480055, "Feral Ghoul" },
	{ 866799, "Glowing One" },
	{ 0x00184C51, "Alien" },
	{ 0x001423B2, "Glowing Bloatfly" },
	{ 1463670, "Legendary Glowing One" },
	{ 166283, "Raider" },
	{ 911721, "Gunner" },
	{ 480058, "Synth" },
	{ 1452270, "Courser" },
	{ 955027, "Mr. Gutsy" },
	{ 480053, "Super Mutant" },
	{ 1355352, "Super Mutant Suicider" },
	{ 1442143, "Brotherhood of Steel" },
	{ 1695193, "Mirelurk" },
	{ 736638, "Yao Guai" },
	{ 134024, "Rad Scorpion" },
	{ 1017367, "Sentry Bot" },
	{ 480056, "Deathclaw" },
	{ 1227134, "Behemoth" },

	{ 981940, "Eye Bots" },
	{ 1075975, "Protectron" },
	{ 480055, "Feral Ghoul" },
	{ 166283, "Raider" },
	{ 911721, "Gunner" },
	{ 480058, "Synth" },
	{ 1452270, "Courser" },
	{ 955027, "Mr. Gutsy" },
	{ 480053, "Super Mutant" },
	{ 1442143, "Brotherhood of Steel" },
	{ 1695193, "Mirelurk" },
	{ 736638, "Yao Guai" },
	{ 134024, "Rad Scorpion" },
	{ 1017367, "Sentry Bot" },
	{ 480056, "Deathclaw" },
	{ 1227134, "Behemoth" },

	{ 2398662, "Assaultron" },
	{ 0x16015F, "Brotherhood of Steel" },
	{ 1452270, "Courser" },
	{ 2398644, "Mr. Gutsy" },
	{ 1017367, "Sentry Bot" },
	{ 0x117d85, "Super Mutant" },

	{ 469576, "Sanctuary Hills" },
	{ 532792, "Concord" },
	{ 117461, "Diamond City" },
	{ 140840, "Goodneighbor" },
	{ 179365, "The Castle" },
	{ 252598, "Cambridge Police Station" },
	{ 178304, "Bunker Hill" },
	{ 651890, "Vault 111" },
	{ 292432, "Vault 81" },
	{ 151450, "Fort Hagen" },
	{ 2211691, "Boston Airport" },
	{ 712073, "The Glowing Sea (Atom's Glow)" },
	{ 738900, "The Glowing Sea (Virgil's Laboratory)" },
	{ 178238, "Mass Fusion" },
	{ 456148, "Abernathy Farm" },
	{ 0x2CF9E, "Spectacle Island" },

	{ 177450, "Clear" },
	{ 1848435, "Foggy" },
	{ 2056609, "Dusty" },
	{ 1877988, "Rain" },
	{ 1850718, "Rad Storm" },
	{ 2011903, "Polluted" },

	{ 0x01005B99, "an Alcohol addiction" },
	{ 0x01005B9B, "a Buffout addiction" },
	{ 0x01007265, "a Jet addiction" },
	{ 0x01005B9D, "a Med-X addiction" },
	{ 0x01005B9F, "a Mentats addiction" },
	{ 0x01005BA1, "a Psycho addiction" },
};

auto format_key = [](const std::string& prefix, int value, const std::string& suffix = "") {
	std::ostringstream ss;
	ss << prefix << "-" << value;
	if (!suffix.empty()) {
		ss << "-" << suffix;
	}
	return ss.str();
};

std::unordered_map<std::string, std::string> idToNameMap = {
	{format_key("fallout4", 0x0014A349), "Armored Bathrobe"},
	{format_key("fallout4", 0x000F15CF), "Armored Agatha's Dress"},
	{format_key("fallout4", 0x001E8CAB), "Armored Cabot's Lab Coat"},
	{format_key("fallout4", 0x001BDDF8), "Armored Clean Black Suit"},
	{format_key("fallout4", 0x0012A332), "Armored Courser Uniform"},
	{format_key("fallout4", 0x0014FBD0), "Armored Father's Lab Coat"},
	{format_key("fallout4", 0x001B5F1B), "Armored Feathered Dress"},
	{format_key("fallout4", 0x0023CAA4), "Armored Geneva's Ensemble"},
	{format_key("fallout4", 0x002075BF), "Armored Pink Dress"},
	{format_key("fallout4", 0x0005E76C), "Armored Mechanic Jumpsuit"},
	{format_key("fallout4", 0x00146174), "Armored Postman Uniform"},
	{format_key("fallout4", 0x000FD9A8), "Armored Red Dress"},
	{format_key("fallout4", 0x0011A27B), "Armored Sequin Dress"},
	{format_key("fallout4", 0x0014941A), "Armored Summer Shorts"},
	{format_key("fallout4", 0x0014B019), "Armored T-shirt and Slacks"},
	{format_key("fallout4", 0x000FC395), "Armored Tuxedo"},
	{format_key("fallout4", 0x000DF455), "Armored Yellow Trench Coat"},
	{format_key("fallout4", 0x00023431), "Armored Army Fatigues"},
	{format_key("fallout4", 0x002223E3), "BOS uniform"},

	{format_key("fallout4", 0x0CAC78), "Flamer Fuel"},

	{format_key("crowdcontrol", 0x006332), "House Cat"},

	{format_key("dlcnukaworld", 0x0502C6, "plosion"), "Ice cold Nuka-Love-plosion"},
	{format_key("dlcnukaworld", 0x0502B4, "plosion"), "Ice cold Nuka-Cide-plosion"},
	{format_key("dlcnukaworld", 0x0502BD, "plosion"), "Ice cold Nuka-Frutti-plosion"},
	{format_key("dlcnukaworld", 0x0502C9, "plosion"), "Ice cold Nuka-Power-plosion"},

	{format_key("fallout4", 0xBD56F, "nukanuke"), "Nuka-nuke Launcher"},
	{format_key("dlcnukaworld", 0x007BC8, "thirstzapper"), "Thirst Zapper"},
	{format_key("dlcnukaworld", 0x007BC8, "quantumthirstzapper"), "Quantum Thirst Zapper"},

	{format_key("dlcnukaworld", 0x1B039), "Nuka-nuke"},
	{format_key("dlcnukaworld", 0x00A6C6), "Weaponized Nuka-Cola Quantum"},

	{format_key("dlcnukaworld", 0x029C0B), "Cowhide Western Outfit"},
	{format_key("dlcnukaworld", 0x03407C), "Armored Magician's Tuxedo"},
	{format_key("dlcnukaworld", 0x029C0D), "Nuka-Girl Rocketsuit"},
	{format_key("dlcnukaworld", 0x029C09), "Western Outfit & Chaps"},
	{format_key("dlcnukaworld", 0x00D2AE), "Spacesuit Costume"},
	{format_key("dlcnukaworld", 0x0392AE), "Wildman Rags"},

	{format_key("dlcnukaworld", 0x31723), "Quantum X-01 Power Armor"},

	{format_key("dlcnukaworld", 0x00D35B), "Gazelle"},
	{format_key("dlcnukaworld", 0x00D353), "Brahmiluff Longhorn"},
	{format_key("dlcnukaworld", 0x00D347), "Ghoulrilla"},

	{format_key("dlcnukaworld", 0x0201EC), "Rad-rat"},
	{format_key("dlcnukaworld", 0x03B8A6), "Plagued Rad-rat"},
	{format_key("dlcnukaworld", 0x00D357), "Gatorclaw"},
	{format_key("dlcnukaworld", 0x0201EA), "Soldier Ant"},
	{format_key("dlcnukaworld", 0x0201EB), "Glowing Ant"},
	{format_key("dlcnukaworld", 0x03B57D), "Flying Glowing Ants"},
	{format_key("dlcnukaworld", 0x0201E5), "Cave Cricket"},
	{format_key("dlcnukaworld", 0x3d661), "Nukalurk Queen"},
	{format_key("dlcnukaworld", 0xa1a7), "Bloodworm"},
	{format_key("dlcnukaworld", 0x01F5F9), "Nukatron"},
	{format_key("dlcnukaworld", 0x03290A), "Galactron"},
	{format_key("dlcnukaworld", 0x01FAF4), "Astro-Gutsy"},
	{format_key("dlcnukaworld", 0x01F5FE), "Space Sentry Bot"},
	{format_key("dlcnukaworld", 0x01FAF8), "Novatron"},

	{format_key("dlcrobot", 0x08B8E), "Assaultron Blade"},
	{format_key("dlcrobot", 0x0100B7), "Salvaged Assaultron Head"},
	{format_key("dlcrobot", 0x003E07), "Tesla Rifle"},

	{format_key("dlcrobot", 0x00863F), "Robot Armor"},
	{format_key("dlcrobot", 0x008BC1), "Mechanist's Armor"},
	{format_key("dlcrobot", 0x00C579), "Tesla T-60 Power Armor"},

	{format_key("dlcrobot", 0x007843), "Turretbot"},
	{format_key("dlcrobot", 0x007844), "Duelbot"},
	{format_key("dlcrobot", 0x00444F), "Robobrain"},
	{format_key("dlcrobot", 0x0026EC), "Swarmbot"},
	{format_key("dlcrobot", 0x0026EE), "Tankbot"},
	{format_key("dlcrobot", 0x0026ED), "Junkbot"},
	{format_key("dlcrobot", 0x0036CA), "Scrapbot"},
	{format_key("dlcrobot", 0x005050), "Rust Devil"},
	{format_key("dlcrobot", 0x004387), "Rust Devil Bot"},

	{format_key("dlccoast", 0x04B9B1), "Armored Legend of the Harbor"},
	{format_key("dlccoast", 0x046027), "Armored Hunter's Long Coat"},
	{format_key("dlccoast", 0x03A556), "Marine Wetsuit"},

	{format_key("dlccoast", 0x056F80), "Assault Marine Armor"},
	{format_key("dlccoast", 0x04FA7D), "Rescue Diver Suit"},

	{format_key("dlccoast", 0x03DDE2), "Rad Rabbit"},
	{format_key("dlccoast", 0x03FD6A), "Rad Chicken"},

	{format_key("dlccoast", 0x010B80), "Harpoon"},
	{format_key("dlccoast", 0x02740E), "Modified Bowling Ball"},

	{format_key("dlccoast", 0x03A388), "Atom's Judgement"},
	{format_key("dlccoast", 0x05158B), "Admiral's Friend"},
	{format_key("dlccoast", 0x05158E), "Kiloton Radium Rifle"},
	{format_key("dlccoast", 0x051599), "Sergeant Ash"},
	{format_key("dlccoast", 0x031702), "The Striker"},

	{format_key("dlccoast", 0x054282, "plosion"), "Ice cold Vim-plosion (Captain's blend)"},

	{format_key("dlccoast", 0x0140F8), "Wolf"},
	{format_key("dlccoast", 0x009590), "Angler"},
	{format_key("dlccoast", 0x02793A), "Gulper"},
	{format_key("dlccoast", 0x00A2D4), "Fog Crawler"},
	{format_key("dlccoast", 0x04B34F), "Hermit Crab"},
};

void LoadIdToNameMap() {
	for (const auto& item : formIdToNameMap) {
		UInt32 formId = item.first;
		const std::string& name = item.second;

		// Convert formId to string
		std::string formIdStr = std::to_string(formId);

		// Insert into idToNameMap
		if (idToNameMap.find(formIdStr) == idToNameMap.end()) {
			// Key does not exist, insert into idToNameMap
			idToNameMap[formIdStr] = name;
		}
	}
}

BSFixedString CrowdControlGetName(StaticFunctionTag*, BSFixedString id)
{
	std::string idStr = id.c_str();

	// Find the position of "~"
	size_t pos = idStr.find("~");

	// If "~" is found, get the substring before "~"
	if (pos != std::string::npos) {
		idStr = idStr.substr(0, pos);
	}

	// Look up the ID in the map
	auto it = idToNameMap.find(idStr);

	// If ID is found, return the corresponding name
	if (it != idToNameMap.end()) {
		return BSFixedString(it->second.c_str());
	}

	// If form ID not found, return a default string
	return BSFixedString("an item");
}

BSFixedString CrowdControlGetNameId(StaticFunctionTag*, SInt32 id)
{
	// Look up the form ID in the map
	auto it = formIdToNameMap.find(id);

	// If form ID is found, return the corresponding name
	if (it != formIdToNameMap.end()) {
		return BSFixedString(it->second.c_str());
	}

	// If form ID not found, return a default string
	return BSFixedString("an item");
}


static CSimpleIniA ini;
static bool iniLoaded = false;
static bool iniLoadTried = false;
bool LoadIni()
{
	if (!iniLoaded && !iniLoadTried)
	{
		_DMESSAGE("Loading INI, looking for Documents...");

		iniLoadTried = true;

		try
		{
			char path[MAX_PATH];
			HRESULT error = SHGetFolderPath(NULL, CSIDL_MYDOCUMENTS | CSIDL_FLAG_CREATE, NULL, SHGFP_TYPE_CURRENT, path);
			if (SUCCEEDED(error))
			{
				strcat_s(path, sizeof(path), "\\My Games\\Fallout4\\CrowdControl.ini");

				if (GetFileAttributes(path) == INVALID_FILE_ATTRIBUTES)
				{
					_DMESSAGE("The INI file does not exist or there was an error accessing it: %s (lasterr = 0x%08X)", path, GetLastError());
					return false;
				}
				
				_DMESSAGE("Found Documents folder, loading INI (%s)...", path);
				
				auto error = ini.LoadFile(path);
				if (error < 0)
				{
					_ERROR("Loading CrowdControl ini failed: %s", error);
					return false;
				}

				_DMESSAGE("INI loaded.");

				iniLoaded = true;
			}
			else
			{
				_ERROR("Getting path to CrowdControl ini failed (result = 0x%08X lasterr = 0x%08X)", error, GetLastError());
				return false;
			}
		}
		catch (std::exception e)
		{
			_ERROR("[Main] Error loading INI. %s", e.what());
			return false;
		}
	}

	return iniLoaded;
}

SInt32 GetIntSetting(StaticFunctionTag*, BSFixedString section, BSFixedString key)
{
	if (!LoadIni()) return -1;
	return ini.GetLongValue(section, key, 0);
}

float GetFloatSetting(StaticFunctionTag*, BSFixedString section, BSFixedString key)
{
	if (!LoadIni()) return -1;
	return ini.GetDoubleValue(section, key, 0);
}


bool RegisterFuncs(VirtualMachine * a_registry)
{
	a_registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, BSFixedString>("Version", "CrowdControlApi", CrowdControlVersion, a_registry));
	a_registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, BSFixedString>("GetCrowdControlState", "CrowdControlApi", CrowdControlState, a_registry));
	a_registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, void>("Reconnect", "CrowdControlApi", CrowdControlReconnect, a_registry));
	a_registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, void>("Run", "CrowdControlApi", CrowdControlRun, a_registry));
	a_registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, SInt32>("GetCommandCount", "CrowdControlApi", CrowdControlCommandCount, a_registry));
	a_registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, CrowdControlCommand>("GetCommand", "CrowdControlApi", CrowdControlGetCommand, a_registry));
	a_registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, void, SInt32, SInt32, BSFixedString, SInt32>("Respond", "CrowdControlApi", CrowdControlRespond, a_registry));
	a_registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, SInt32, BSFixedString>("HasTimer", "CrowdControlApi", CrowdControlHasTimer, a_registry));
	a_registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, void>("ClearTimers", "CrowdControlApi", CrowdControlClearTimers, a_registry));
	a_registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, SInt32, BSFixedString, BSFixedString>("GetIntSetting", "CrowdControlApi", GetIntSetting, a_registry));
	a_registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, float, BSFixedString, BSFixedString>("GetFloatSetting", "CrowdControlApi", GetFloatSetting, a_registry));

	a_registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, VMArray<BSFixedString>, BSFixedString, BSFixedString>("StringSplit", "CrowdControlApi", CrowdControlStringSplit, a_registry));
	a_registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, bool, BSFixedString, BSFixedString>("StringContains", "CrowdControlApi", CrowdControlStringContains, a_registry));
	a_registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("GetName", "CrowdControlApi", CrowdControlGetName, a_registry));
	a_registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, SInt32>("GetNameId", "CrowdControlApi", CrowdControlGetNameId, a_registry));

	return true;
}

void OnF4SEMessage(F4SEMessagingInterface::Message* msg) {
	switch (msg->type) {
		case F4SEMessagingInterface::kMessage_GameLoaded:
			_MESSAGE("Game loaded.");

			if (*g_ui)
			{
				(*g_ui)->menuOpenCloseEventSource.AddEventSink(&g_menuOpenCloseHandler);

				_MESSAGE("Menu event sink registered.");
			}
			break;
	}
}

extern "C" {
	bool F4SEPlugin_Query(const F4SEInterface* f4se, PluginInfo* a_info)
	{
		gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Fallout4\\F4SE\\CrowdControl.log");
		gLog.SetPrintLevel(IDebugLog::kLevel_DebugMessage);
#if DEBUG
		gLog.SetLogLevel(IDebugLog::kLevel_DebugMessage);
#else
		gLog.SetLogLevel(IDebugLog::kLevel_Message);
#endif
		

		_MESSAGE("CrowdControl Plugin v%s", CC_VERSION);

		a_info->infoVersion = PluginInfo::kInfoVersion;
		a_info->name = "CrowdControlPlugin";
		a_info->version = CC_VERSION_MAJOR;

		if (f4se->isEditor) {
			_FATALERROR("[FATAL ERROR] Loaded in editor, marking as incompatible!\n");
			return false;
		} else if (f4se->runtimeVersion < RUNTIME_VERSION_1_10_163) {
			_FATALERROR("[FATAL ERROR] Unsupported runtime version %08X!\n", f4se->runtimeVersion);
			return false;
		}

		g_pluginHandle = f4se->GetPluginHandle();

		// Get the messaging interface
		g_messaging = (F4SEMessagingInterface*)f4se->QueryInterface(kInterface_Messaging);
		if (!g_messaging) {
			_FATALERROR("couldn't get messaging interface");
			return false;
		}

		g_papyrus = (F4SEPapyrusInterface*)f4se->QueryInterface(kInterface_Papyrus);
		if (!g_papyrus) {
			_FATALERROR("couldn't get papyrus interface");
			return false;
		}

		g_scaleform = (F4SEScaleformInterface*)f4se->QueryInterface(kInterface_Scaleform);
		if (!g_scaleform) {
			_FATALERROR("couldn't get scaleform interface");
			return false;
		}

		return true;
	}

	bool F4SEPlugin_Load(const F4SEInterface* a_f4se)
	{
		_MESSAGE("Plugin loaded");

		try
		{
			LoadIdToNameMap();

			connector = new Connector();

			if (g_papyrus) {
				g_papyrus->Register(RegisterFuncs);
			}

			if (g_messaging) {
				g_messaging->RegisterListener(g_pluginHandle, "F4SE", OnF4SEMessage);
			}
		}
		catch (std::exception e)
		{
			_ERROR("[F4SEPlugin_Load] %s", e.what());
		}

		return true;
	}
};