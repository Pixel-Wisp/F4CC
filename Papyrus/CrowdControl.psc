; Copyright (c) 2023 kmrkle.tv community. All rights reserved.
; Licensed under the MIT License. See LICENSE in the project root for license information.

Scriptname CrowdControl extends ReferenceAlias

string lastState = ""

Int lastCommandId = -1
Int lastCommandType = -1

InputEnableLayer inputControl
Actor player = None
Faction playerFaction = None
Faction playerEnemyFaction = None
Faction playerAllyFaction = None
Form launchMarker = None
Keyword keywordActorFriendlyNpc = None
Quest QuestMQ102 = None
GlobalVariable GameHour = None
ObjectReference containerAutoEquipStorage

Int updateTimerId = 10
Int updateTimerKeepAliveId = 11
float LastCellLoadAt = 0.0

bool F4SEFound

Event OnInit()
    Debug.Trace("CrowdControl OnInit.")

    activeCooldowns = new ActiveCooldown[0]
    followerStates = new FollowerState[0]
	lastCommandId = -1
	lastCommandType = -1
    lastState = ""
    toEquipCount = 0
    isPlayerInWorkshop = false
   
    inputControl = InputEnableLayer.Create()
    player = Game.GetPlayer()
    InitVars()
   
    string[] ccTest = CrowdControlApi.StringSplit("1~2", "~")
   
    if ccTest.length == 2
        F4SEFound = true
        StartTimer(2.0, updateTimerId)
        StartTimer(15.0, updateTimerKeepAliveId)
        PingUpdateTimer()
    else
        StartTimer(10.0, updateTimerId)
    endif
EndEvent

Function InitVars()
    if launchMarker == None
		launchMarker = FindFormId(0x00000034)
	endif
    
    if playerFaction == None
        playerFaction = Game.GetFormFromFile(0x1C21C, "Fallout4.esm") as Faction
    endif
   
    if playerEnemyFaction == None 
        playerEnemyFaction = Game.GetFormFromFile(0x106c2f, "Fallout4.esm") as Faction
    endif
    
    if playerAllyFaction == None 
        playerAllyFaction = Game.GetFormFromFile(0x106c30, "Fallout4.esm") as Faction
    endif
    
    if keywordActorFriendlyNpc == None
        keywordActorFriendlyNpc = Game.GetFormFromFile(0x10053FF, "CrowdControl.esp") as Keyword
    endif
    
    if QuestMQ102 == None
        QuestMQ102 = Game.GetFormFromFile(0x1CC2A, "Fallout4.esm") as Quest
    endif
    
    if GameHour == None
        GameHour = Game.GetFormFromFile(0x38, "Fallout4.esm") as GlobalVariable
    endif
   
    if containerAutoEquipStorage == None
        ; Create a new container object
        containerAutoEquipStorage = player.PlaceAtMe(Game.GetFormFromFile(0x01006AD6, "CrowdControl.esp"))
        
        ; Make the container invisible and inaccessible
        containerAutoEquipStorage.Disable()
        containerAutoEquipStorage.Lock()
    endif
    
    ; Get rid of Billy
    ReferenceAlias ra = GetAlias(7)
    Actor a = ra.GetActorReference()
    if a
        ra.Clear()
        a.Disable()
        a.Delete()
    endif
    
    LastCellLoadAt = 0.0

EndFunction

Event OnCellLoad()
  LastCellLoadAt = Utility.GetCurrentRealTime()
endEvent

; This event is called when the player loads a game
Event OnPlayerLoadGame()
    InitVars()   
    
    ; Reset all state
    activeCooldowns = new ActiveCooldown[0]
    lastCommandId = -1
	lastCommandType = -1
    lastState = ""
    toEquipCount = 0
    isPlayerInWorkshop = false
   
    if followerStates == None
        followerStates = new FollowerState[0]
    endif
    
    ; Clear all effect timers, in case player died or reloaded.
	CrowdControlApi.ClearTimers()
   
    ; Reset state
    inputControl.EnableSprinting(true)
    inputControl.EnableJumping(true)
    inputControl.EnableRunning(true)
    inputControl.EnableVATS(true)
    inputControl.EnableMenu(true)
    inputControl.EnableFastTravel(true)
    
    ; Start new timers
    CancelTimer(updateTimerId)
    CancelTimer(updateTimerKeepAliveId)
    if F4SEFound
        StartTimer(2.0, updateTimerId)
        StartTimer(15.0, updateTimerKeepAliveId)
        PingUpdateTimer()
    endif
EndEvent

float LastUpdateTimerPing = 0.0

function PingUpdateTimer()
    LastUpdateTimerPing = Utility.GetCurrentRealTime()
endfunction

Event OnTimer(Int aiTimerID)
    If aiTimerID == updateTimerKeepAliveId
        ; This timer ensures that the main timer is restarted if it stops running for any reason
        if Utility.GetCurrentRealTime() - LastUpdateTimerPing >= 30
            Debug.Trace("Halt detected. Restarting update timer.")
            
            CancelTimer(updateTimerId)
            StartTimer(1.0, updateTimerId)
            PingUpdateTimer()
        endif
        
        StartTimer(15.0, updateTimerKeepAliveId)
        
    elseif aiTimerID == updateTimerId
        PingUpdateTimer()
        
        if !F4SEFound
            Debug.Notification("CrowdControl disabled: F4SE not found.")
            
            return
        endif
    
        string newState = CrowdControlApi.GetCrowdControlState()

        if lastState == ""
            Debug.Notification("CrowdControl v" + CrowdControlApi.Version())
            
            if newState != lastState
                if newState == "disconnected"
                    Debug.Notification("CrowdControl is connecting...")
                else
                    Debug.Notification("CrowdControl is " + newState)
                endif
            endif
        else
            if newState != lastState
                Debug.Notification("CrowdControl is " + newState)
            endif
        endif
        
        lastState = newState

        if newState == "running"
            if RunCommands()
                PingUpdateTimer()
                StartTimer(0.5, updateTimerId)
            else
                StartTimer(1, updateTimerId)
            endif
            
        elseif newState == "stopped"
            CrowdControlApi.Run()
            
            StartTimer(1, updateTimerId)
        else
            CrowdControlApi.Reconnect()
            
            StartTimer(1, updateTimerId)
        endif
   EndIf
EndEvent

int ShouldShowNotifications = -1

Function PrintMessage(string _message)
	if ShouldShowNotifications < 0
        int iniSetting = CrowdControlApi.GetIntSetting("General", "bEnableCommandNotify")
        
        if iniSetting == 1 || iniSetting < 0
            Debug.Notification(_message)
        endif
    elseif ShouldShowNotifications == 1
        Debug.Notification(_message)
	endif
EndFunction

bool Function ShouldNotifyCommand()
    ; Effect notifications can be toggled with this INI setting
	return CrowdControlApi.GetIntSetting("General", "bEnableCommandNotify") == 1
endFunction

Function Respond(int id, int status, string _message = "", int milliseconds = 0)
	CrowdControlApi.Respond(id, status, _message, milliseconds)
EndFunction

bool Function CanRunCommands()
    Actor playerDialogTarget = player.GetDialogueTarget()
    
    if playerDialogTarget != None
        if playerDialogTarget.IsInDialogueWithPlayer()
            Debug.Trace("    is in dialog with player")
            
            return false
        endif
    endif
   
    if !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled()
        Debug.Trace("    looking or moving is disabled")
        return false
    endif
    
    if Utility.IsInMenuMode()
        Debug.Trace("    menu mode enabled")
        return false
    endIf

    if LastCellLoadAt > 0.0 && Utility.GetCurrentRealTime() - LastCellLoadAt < 4
        Debug.Trace("    just loaded recently")
        return false
    endif
    
    return true
endFunction

bool Function RunCommands()
    Debug.Trace("RunCommands()")
    
	if player.IsDead() || !CanRunCommands()
        Debug.Trace("  can't run commands!")
        
		return false
	endif
    
    int commandCount = CrowdControlApi.GetCommandCount()
    Debug.Trace("  commandCount=" + commandCount)
    
	CrowdControlApi:CrowdControlCommand command = CrowdControlApi.GetCommand()
    
	if command != None
        if lastCommandId == command.id && lastCommandType == command.type
			if command.type == 1
				Respond(command.id, 1, command.viewer + " invalid command (1) \"" + command.command + "\"")
			else
				PrintMessage(command.viewer + " invalid command (2) \"" + command.command  + "\"")
				Respond(command.id, 0, "")
			endif
		else
			lastCommandId = command.id
			lastCommandType = command.type
			
            ProcessCommand(command)
		endif
	endif
    
    return commandCount > 1
EndFunction

; Define a custom struct to store the parsed values
Struct ParsedCommand
    String command
    String id
    Int quantity
    String param0
    String param1
    String param2
    String param3
    String param4
    String param5
    String param6
    String param7
    String param8
    String param9
EndStruct

; Define a custom function to parse the command string and return a ParsedCommand struct
ParsedCommand Function ParseCrowdControlCommand(CrowdControlApi:CrowdControlCommand ccCommand)
    ParsedCommand r = new ParsedCommand
   
    r.command = ccCommand.command
    r.id = ccCommand.param0
    r.quantity = ccCommand.param1 as int

    if ccCommand.durationMS > 0
        r.quantity = ccCommand.durationMS / 1000
    endif
    
    r.param0 = ccCommand.param2
    r.param1 = ccCommand.param3
    r.param2 = ccCommand.param4
    r.param3 = ccCommand.param5
    r.param4 = ccCommand.param6
    r.param5 = ccCommand.param7
    r.param6 = ccCommand.param8
    r.param7 = ccCommand.param9
    r.param8 = ccCommand.param10
    r.param9 = ccCommand.param11
   
    Debug.Trace("CC Command: " + ccCommand.id)
    Debug.Trace("  command: " + r.command)
    Debug.Trace("  id: " + r.id)
    Debug.Trace("  quantity: " + r.quantity)
    Debug.Trace("  params: " + r.param0 + ", " + r.param1 + ", " + r.param2 + ", " + r.param3 + ", " + r.param4 + ", " + r.param5 + ", " + r.param6 + ", " + r.param7 + ", " + r.param8 + ", " + r.param9)

    return r
endfunction

ReferenceAlias Function GetAlias(int index)
    ReferenceAlias ra = GetOwningQuest().GetAlias(index) as ReferenceAlias
    Actor a = ra.GetActorReference()
    if a != None
      ; Clear alias for any dead followers
      if a.IsDead()
        ra.Clear()
        a = None
      endif
    endif
    
    return ra
endFunction

Form Function FindFormId(int id)
    Form foundForm = Game.GetFormFromFile(id, "Fallout4.esm") as Form
            
    if foundForm != None
        return foundForm
    endif

    return Game.GetFormFromFile(id, "CrowdControl.esp") as Form
endfunction

string Function NormalizeDataFileName(string fileName)
    if fileName == "fallout4"
		return "Fallout4.esm"
	elseif fileName == "dlcrobot"
		return "DLCRobot.esm"
	elseif fileName == "dlcworkshop01"
		return "DLCworkshop01.esm"
	elseif fileName == "dlcworkshop02"
		return "DLCworkshop02.esm"
	elseif fileName == "dlcworkshop03"
		return "DLCworkshop03.esm"
	elseif fileName == "dlccoast"
		return "DLCCoast.esm"
	elseif fileName == "dlcnukaworld"
		return "DLCNukaWorld.esm"
	elseif fileName == "crowdcontrol"
		return "CrowdControl.esp"
	endif
    
    return fileName
endfunction

Form Function FindForm(String id)
    if id == ""
        return None
    endif

    if CrowdControlApi.StringContains(id, "-")
        string[] parts = CrowdControlApi.StringSplit(id, "-")
       
        string fileName = NormalizeDataFileName(parts[0])
        int formId = parts[1] as int
        
        Form r = Game.GetFormFromFile(formId, fileName) as Form    
       
        return r
    else
        int formId = id as int
    
        Form foundForm = Game.GetFormFromFile(formId, "Fallout4.esm") as Form
        
        if foundForm != None
            return foundForm
        endif
        
        Form r = Game.GetFormFromFile(formId, "CrowdControl.esp") as Form
        
        return r
    endif
endFunction

int toEquipCount = 0

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if aiItemCount == 1 && toEquipCount > 0
        player.EquipItem(akBaseItem, abSilent = true)
        PlayerInventoryRestore()
        toEquipCount -= 1
        
        if toEquipCount == 0
            RemoveAllInventoryEventFilters()
        endif
    endif
endEvent

Function PlayerInventoryRestore()
    containerAutoEquipStorage.RemoveAllItems(player)
endfunction

Function PlayerInventoryRemoveAllItems(Form akBaseItem, bool moveToTempStorage = false)
    int itemCount = player.GetItemCount(akBaseItem)

    while itemCount > 0
        if moveToTempStorage
            player.RemoveItem(akBaseItem, 1, true, containerAutoEquipStorage)
        else
            player.RemoveItem(akBaseItem, 1, true)
        endif
        
        itemCount -= 1
    endWhile
endfunction

Function AutoEquipAddedItem()
    if toEquipCount == 0
        AddInventoryEventFilter(None)
    endif

    toEquipCount += 1
EndFunction

Function StopFriendlyCombatWith(Actor theActor)
    ObjectReference[] kActors = player.FindAllReferencesWithKeyword(keywordActorFriendlyNpc, 2048.0)
    
    int i = 0
    while (i < kActors.Length)
        Actor kActor = kActors[i] as Actor
        
        int combatState = kActor.GetCombatState()
        
        if combatState == 1
            Actor aTarget = kActor.GetCombatTarget()
            if aTarget == theActor || aTarget.HasKeyword(keywordActorFriendlyNpc) || aTarget.IsInFaction(playerFaction) || aTarget.IsInFaction(playerAllyFaction)
                kActor.StopCombat()
            endif
            
        elseif combatState == 2
            kActor.StopCombat()
        endif
        
        i += 1
    endWhile
endFunction

Function StopFriendlyCombat(Actor theActor)
    if theActor.GetCombatState() == 1
        Actor aTarget = theActor.GetCombatTarget()
        if aTarget.HasKeyword(keywordActorFriendlyNpc) || aTarget.IsInFaction(playerFaction) || aTarget.IsInFaction(playerAllyFaction)
            aTarget.StopCombat()
        endif
    endif
endFunction

Function AttachMod(ObjectReference spawnedItem, string modFormId)
    ObjectMod theMod = FindForm(modFormId) as ObjectMod
    
    if theMod
        spawnedItem.AttachMod(theMod)
    else
        Debug.Trace("Cannot find MOD with id '" + modFormId + "'")
    
        Debug.Notification("Cannot find MOD with id '" + modFormId + "'")
    endif
endfunction

Function ProcessCommand(CrowdControlApi:CrowdControlCommand ccCommand)
    ParsedCommand command = ParseCrowdControlCommand(ccCommand)
   
    if command == None
        Debug.Notification("Invalid command format received.")
        return
    endif
   
    int id = ccCommand.id
    string viewer = ccCommand.viewer
    string status
    int type = ccCommand.type
   
    if QuestMQ102.GetStage() < 10
        status = viewer + ", cannot run effects at this time. The player must first exit Vault 111."

		Respond(id, 1, status)
        PrintMessage(status)
        
        return
    endif
   
	if command.command == "playeradditem"
        Form theForm = FindForm(command.id)
		player.AddItem(theForm, command.quantity, abSilent = true)

        status = viewer + " gave you: " + CrowdControlApi.GetName(command.id) + " (" + command.quantity + ")"

		Respond(id, 0, status)
        PrintMessage(status)
       
    elseif command.command == "placeatme"
        Form theForm = FindForm(command.id)
       
        if command.quantity <= 0
            status = "Command 'placeatme' quantity must be > 0"
            
            Debug.Trace(status, 1)
            Respond(id, 1, status)
            
            return
        endif
        
        int i = 0
        while i < command.quantity
            PingUpdateTimer()
            
            ObjectReference spawnedItem = player.PlaceAtMe(theForm)
            
            spawnedItem.SetAngle(0.0, spawnedItem.GetAngleY(), spawnedItem.GetAngleZ())
          
            if command.param1 != "" && command.param1 as int > 0
                spawnedItem.setScale(command.param1 as int)
            endif   
            
            ; Make the item fly away from the player with a given force
            if command.Param0 != "" && command.Param0 as int > 0
                ; Define the maximum and minimum distance for the spawned items
                float maxDistance = 50
                float minDistance = 10

                float randomAngle
                ; Check if the player is in first person view
                bool isPlayerInFirstPerson = player.GetAnimationVariableBool("IsFirstPerson")
                if isPlayerInFirstPerson
                    ; If in first person, align the random angle with the player's facing angle
                    float playerAngle = GetPlayerAngle()
                    randomAngle = playerAngle + ((Utility.RandomFloat() * 90.0) - 45.0)
                else
                    ; If in third person, use a completely random angle
                    randomAngle = Utility.RandomFloat() * 360.0
                endif

                ; Calculate a random distance within the defined range
                float randomDistance = minDistance + Utility.RandomFloat() * (maxDistance - minDistance)

                ; Calculate the offset position for the spawned item using the random angle and distance
                float offsetX = Math.Cos(randomAngle) * randomDistance
                float offsetY = Math.Sin(randomAngle) * randomDistance

                ; Move the spawned item to the offset position relative to the player
                spawnedItem.MoveTo(player, offsetX, offsetY, Utility.RandomFloat(50.0, 100.0), false)
                            
                ; Create a random direction for the impulse
                float xDirection = Math.Cos(randomAngle)
                float yDirection = Math.Sin(randomAngle)
                float zDirection = Utility.RandomFloat(2.0, 5.0)  ; make this greater than the magnitude of x and y

                ; Apply the impulse to the spawned item
                spawnedItem.ApplyHavokImpulse(xDirection, yDirection, zDirection, command.Param0 as float)
                
                ; Play a "plooop" sound
                PlaySound(0x20A0B9)
            endif

            if i == 0
                status = viewer + " gave you: " + CrowdControlApi.GetName(command.id) + " (" + command.quantity + ")"

                Respond(id, 0, status)
                PrintMessage(status)
            endif
            
            i += 1
        endwhile
        
    elseif command.command == "playergiveweapon"
        ; Add weapon
        Form theForm = FindForm(command.id)
        Form theActualForm = theForm
        
        if command.param1 != "" && command.param1 as int > 0
            theActualForm = FindForm(command.param1)
        endif
       
        ObjectReference spawnedWeapon = player.PlaceAtMe(theForm)

        if command.param2 != "" && command.param2 as int > 0
            AttachMod(spawnedWeapon, command.param2)
        endif
        
        if command.param3 != "" && command.param3 as int > 0
            AttachMod(spawnedWeapon, command.param3)
        endif
        
        if command.param4 != "" && command.param4 as int > 0
            AttachMod(spawnedWeapon, command.param4)
        endif
        
        if command.param5 != "" && command.param5 as int > 0
            AttachMod(spawnedWeapon, command.param5)
        endif
        
        if command.param6 != "" && command.param6 as int > 0
            AttachMod(spawnedWeapon, command.param6)
        endif
        
        if command.param7 != "" && command.param7 as int > 0
            AttachMod(spawnedWeapon, command.param7)
        endif
        
        if command.param8 != "" && command.param8 as int > 0
            AttachMod(spawnedWeapon, command.param8)
        endif
        
        if command.param9 != "" && command.param9 as int > 0
            AttachMod(spawnedWeapon, command.param9)
        endif
        
        Form baseObject = spawnedWeapon.GetBaseObject()
        
        PlayerInventoryRemoveAllItems(baseObject, true)
        AutoEquipAddedItem()
        player.AddItem(spawnedWeapon, 1, abSilent = true)
        player.DrawWeapon()

        status = viewer + " equipped you with: " + CrowdControlApi.GetName(command.id) + " (" + command.quantity + " ammo)"
        
		Respond(id, 0, status)
        PrintMessage(status)
        
        ; Add ammo
        if command.Param0 as int > 0
            theForm = FindForm(command.Param0)
            player.AddItem(theForm, command.quantity, abSilent = true)
        endif
        
    elseif command.command == "playergiveweapon2"
        ; Add weapon
        Form theForm = FindForm(command.id)
       
        ObjectReference spawnedWeapon = player.PlaceAtMe(theForm)

        if command.param1 != ""
            AttachMod(spawnedWeapon, command.param1)
        endif
        
        if command.param2 != ""
            AttachMod(spawnedWeapon, command.param2)
        endif
        
        if command.param3 != ""
            AttachMod(spawnedWeapon, command.param3)
        endif
        
        if command.param4 != ""
            AttachMod(spawnedWeapon, command.param4)
        endif
        
        if command.param5 != ""
            AttachMod(spawnedWeapon, command.param5)
        endif
        
        if command.param6 != ""
            AttachMod(spawnedWeapon, command.param6)
        endif
        
        if command.param7 != ""
            AttachMod(spawnedWeapon, command.param7)
        endif
        
        if command.param8 != ""
            AttachMod(spawnedWeapon, command.param8)
        endif
        
        if command.param9 != ""
            AttachMod(spawnedWeapon, command.param9)
        endif
       
        Form baseObject = spawnedWeapon.GetBaseObject()
            
        PlayerInventoryRemoveAllItems(baseObject, true)
        AutoEquipAddedItem()
        player.AddItem(spawnedWeapon, 1, abSilent = true)
        player.DrawWeapon()
        
        status = viewer + " equipped you with: " + CrowdControlApi.GetName(command.id) + " (" + command.quantity + " ammo)"
        
		Respond(id, 0, status)
        PrintMessage(status)
        
        ; Add ammo
        if command.Param0 != ""
            theForm = FindForm(command.Param0)
            player.AddItem(theForm, command.quantity, abSilent = true)
        endif

    elseif command.command == "playeraddarmor"
        ; Add armor
        if player.IsInPowerArmor()
            status = viewer + ", cannot equip armor or clothing while in power armor"

            Respond(id, 1, status)
            PrintMessage(status)
        else
            Form theForm
            ObjectReference spawnedItem

            PlayerAddArmor(command.param0)
            PlayerAddArmor(command.param1)
            PlayerAddArmor(command.param2)
            PlayerAddArmor(command.param3)
            PlayerAddArmor(command.param4)
            PlayerAddArmor(command.param5)
            PlayerAddArmor(command.param6)
            PlayerAddArmor(command.param7)
            PlayerAddArmor(command.param8)
            PlayerAddArmor(command.param9)
            
            Utility.Wait(0.5)
            
            Actor:WornItem wornBody = player.GetWornItem(3)
            
            if command.id > 0 && (wornBody == None || wornBody.item == none || wornBody.ModelName == "Actors\\Character\\CharacterAssets\\FemaleBody.nif" || wornBody.ModelName == "Actors\\Character\\CharacterAssets\\MaleBody.nif")
                theForm = FindForm(command.id)
                
                spawnedItem = player.PlaceAtMe(theForm)
                
                PlayerInventoryRemoveAllItems(spawnedItem.GetBaseObject())
                AutoEquipAddedItem()
                player.AddItem(spawnedItem, 1, abSilent = true)
            endif

            status = viewer + " equipped you with: " + CrowdControlApi.GetName(command.param0)
            
            Respond(id, 0, status)
            PrintMessage(status)
            
            Game.ForceThirdPerson()
        
        endif
        
    elseif command.command == "playeraddpowerarmor"
        if !player.IsInPowerArmor()
            ; Add power armor
            Form theForm = FindForm(command.id)
            
            ObjectReference spawnedArmor = player.PlaceAtMe(theForm)
            
            player.SwitchToPowerArmor(spawnedArmor)
            
            status = viewer + " equipped you with: " + CrowdControlApi.GetName(command.id)
       
            PrintMessage(status)
            Respond(id, 0, status)
        else
            status = viewer + ", cannot equip another power armor. Already in power armor."
       
            PrintMessage(status)
            Respond(id, 1, status)
        endif
        
	elseif command.command == "playerplaceactoratme"
        ; Apply cooldown
        if command.Param0 != "" && command.Param0 as int > 0
            if !CheckCooldown(id, "playerplaceactoratme~" + command.id + "~" + command.quantity, command.Param0 as int)
                status = viewer + ", cannot spawn at this time. Cooldown active."
                
                PrintMessage(status)
                Respond(id, 1, status)
                return
            endif
        endif
      
        ; Only outdoors
        if command.param1 != "" && command.param1 as int > 0
            if player.IsInInterior()
                status = viewer + ", cannot spawn this indoors"
                
                Respond(id, 1, status)
                PrintMessage(status)
                return
            endif
        endif
        
        Form theForm = FindForm(command.id)
    
		Actor spawnedActor
        ActorBase theActorBase

        float pushForce = 10.0
        
        int i = 0
        while i < command.quantity
            PingUpdateTimer()
            
            spawnedActor = player.PlaceActorAtMe(theForm as ActorBase)
            
            spawnedActor.SetAngle(0.0, spawnedActor.GetAngleY(), spawnedActor.GetAngleZ())
            
            if command.param3 != "" && command.param3 as float > 0
                float maxDistance = command.param3 as float
                float minDistance = maxDistance - 100.0

                if maxDistance < minDistance
                    minDistance = 0.0
                endif

                Float randomAngle = Utility.RandomFloat() * 360.0
                Float randomDistance = minDistance + Utility.RandomFloat() * (maxDistance - minDistance)

                float offsetX = Math.Cos(randomAngle) * randomDistance
                float offsetY = Math.Sin(randomAngle) * randomDistance

                spawnedActor.MoveTo(player, offsetX, offsetY, 100, false)
            endif
            
            if command.param4 != ""
                Debug.Trace("Play custom sound")
                PlaySound(command.param4)
            elseif command.param2 as int != 1
                Debug.Trace("Play default sound")
                PlaySound(0xFBE6A)
            endif

            if command.param2 != ""
                if command.param2 as int == 1
                    spawnedActor.AddKeyword(keywordActorFriendlyNpc)
                    spawnedActor.RemoveFromAllFactions()
                    spawnedActor.AddToFaction(playerFaction)
                    if command.param3 == "" || command.param3 as float <= 0
                        player.PushActorAway(spawnedActor, pushForce)
                    endif
                    StopFriendlyCombat(spawnedActor)
                    StopFriendlyCombatWith(spawnedActor)
                    
                elseif command.param2 as int == 2
                    spawnedActor.AddToFaction(playerEnemyFaction)
                    
                    if spawnedActor.GetValue(Game.GetAggressionAV()) < 2
                        spawnedActor.SetValue(Game.GetAggressionAV(), 2)
                    endif

                    spawnedActor.StopCombat()
                    if command.param3 == "" || command.param3 as float <= 0
                        player.PushActorAway(spawnedActor, pushForce)
                    endif

                else
                    if command.param4 != ""
                        PlaySound(command.param4)
                    else
                        PlaySound(0xFBE6A)
                    endif                    
                endif
            else
                if command.param3 == "" || command.param3 as float <= 0
                    player.PushActorAway(spawnedActor, pushForce)
                endif
            endif
            
            if theActorBase == None
                theActorBase = spawnedActor.GetLeveledActorBase()          
                
                if command.param2 != "" && command.param2 as int == 1
                    status = viewer + " spawned friendly: " + CrowdControlApi.GetName(command.id) + " (" + command.quantity + ")"
                elseif command.param2 != "" && command.param2 as int == 2
                    status = viewer + " spawned hostile: " + CrowdControlApi.GetName(command.id) + " (" + command.quantity + ")"
                else
                    status = viewer + " spawned: " + CrowdControlApi.GetName(command.id) + " (" + command.quantity + ")"
                endif
                
                Respond(id, 0, status)
                PrintMessage(status)
            endif
            
            i += 1
        endWhile

    elseif command.command == "playerplaceactoratmefollower"
        bool isOutdoor = false
        
        if command.param0 != "" && command.param0 as int > 0
            if player.IsInInterior()
                status = viewer + ", cannot spawn this follower indoors"
                
                PrintMessage(status)
                Respond(id, 1, status)
                return
            endif

            isOutdoor = true
        endif
       
        if CountAllFollowers() >= 3
            status = viewer + ", can't spawn any more followers"
            
            PrintMessage(status)
            Respond(id, 1, status)
            
            return
        endif
        
		Actor spawnedActor = AddFollower(command.id, isOutdoor)
        
        if spawnedActor != None
            spawnedActor.AddKeyword(keywordActorFriendlyNpc)
            
            StopFriendlyCombat(spawnedActor)
            StopFriendlyCombatWith(spawnedActor)

            spawnedActor.SetAngle(0.0, spawnedActor.GetAngleY(), spawnedActor.GetAngleZ())
        
            ActorBase theActorBase = spawnedActor.GetLeveledActorBase()
            
            status = viewer + " spawned follower: " + CrowdControlApi.GetName(command.id)
           
            Respond(id, 0, status)
            PrintMessage(status)
        else
            status = viewer + ", can't spawn any more followers"
            
            PrintMessage(status)
            Respond(id, 1, status)
        endif
    
    elseif command.command == "playerplaceactoratmeunique"
        
        ReferenceAlias ra = GetAlias(command.Param0 as int)
        Actor a = ra.GetActorReference()
        
        if a == None
            Form theForm = FindForm(command.id)
        
            Actor spawnedActor = player.PlaceActorAtMe(theForm as ActorBase)

            spawnedActor.AddKeyword(keywordActorFriendlyNpc)
            
            StopFriendlyCombat(spawnedActor)
            StopFriendlyCombatWith(spawnedActor)
        
            ra.ForceRefTo(spawnedActor)

            spawnedActor.SetAngle(0.0, spawnedActor.GetAngleY(), spawnedActor.GetAngleZ())

            ActorBase theActorBase = spawnedActor.GetLeveledActorBase()
            
            status = viewer + " spawned: " + CrowdControlApi.GetName(command.id)

            Respond(id, 0, status)
            PrintMessage(status)
        else
            ActorBase theActorBase = a.GetLeveledActorBase()
            
            status = viewer + ", unique follower " + CrowdControlApi.GetName(command.id) + " already exists"
            
            PrintMessage(status)
            Respond(id, 1, status)
        endif

    elseif command.command == "controlsfasttraveloff"
        if type == 1
			if CrowdControlApi.HasTimer("controlsfasttraveloff")
				Respond(id, 3)
			elseif Game.IsFastTravelEnabled()
				inputControl.EnableFastTravel(false)
             
                status = viewer + " disabled fast travel for " + command.quantity + " seconds"
                
                PrintMessage(status)
				Respond(id, 4, status, 1000 * command.quantity)
			endif
		else
            inputControl.EnableFastTravel(true)
            
            status = "Fast travel enabled"
            
            PrintMessage(status)
			Respond(id, 0, status)
		endif 

    elseif command.command == "controlsvatmenusoff"
        if type == 1
			if CrowdControlApi.HasTimer("controlsvatmenusoff")
				Respond(id, 3)

			elseif Game.IsVATSControlsEnabled() && inputControl.IsMenuEnabled()
				inputControl.EnableVATS(false)
                inputControl.EnableMenu(false)
             
                status = viewer + " disabled VATS and PipBoy for " + command.quantity + " seconds"
                
                PrintMessage(status)
				Respond(id, 4, status, 1000 * command.quantity)
			endif
		else
            inputControl.EnableVATS(true)
            inputControl.EnableMenu(true)
            
            status = "VATS and PipBoy enabled"
            
            PrintMessage(status)
			Respond(id, 0, status)
		endif 
        
    elseif command.command == "controlsrunningsoff"
        if type == 1
			if CrowdControlApi.HasTimer("controlsrunningsoff")
				Respond(id, 3)

			elseif inputControl.IsRunningEnabled()
				inputControl.EnableRunning(false)
             
                status = viewer + " forced walking for " + command.quantity + " seconds"
                
                PrintMessage(status)
				Respond(id, 4, status, 1000 * command.quantity)
			endif
		else
            inputControl.EnableRunning(true)
            
            status = "Running enabled"
            
            PrintMessage(status)
			Respond(id, 0, status)
		endif 
        
    elseif command.command == "controlssprintingjumpingoff"
        if type == 1
			if CrowdControlApi.HasTimer("controlssprintingjumpingoff")
				Respond(id, 3)

			elseif inputControl.IsSprintingEnabled() && inputControl.IsJumpingEnabled()
				inputControl.EnableSprinting(false)
                inputControl.EnableJumping(false)
             
                status = viewer + " disabled sprinting and jumping for " + command.quantity + " seconds"
                
                PrintMessage(status)
				Respond(id, 4, status, 1000 * command.quantity)
			endif
		else
            inputControl.EnableSprinting(true)
            inputControl.EnableJumping(true)
            
            status = "Sprinting and jumping enabled"
            
            PrintMessage(status)
			Respond(id, 0, status)
		endif 

    elseif command.command == "autosave"
        Game.RequestAutoSave()
        
        status = viewer + " requested auto save"

		Respond(id, 0, status)
        PrintMessage(status)
        
    elseif command.command == "fasttravel"
        if Game.IsFastTravelEnabled()
            status = viewer + " requested fast travel to: " + CrowdControlApi.GetName(command.id)

            PrintMessage(status)
            Respond(id, 0, status)
            
            Utility.Wait(1)
            
            ObjectReference theMarker = FindForm(command.id) as ObjectReference
            
            Game.FastTravel(theMarker)
        else
            status = viewer + ", cannot fast travel at this time"

            PrintMessage(status)
            Respond(id, 1, status)
        endif
    
    elseif command.command == "setweather"
        Weather theWeather = FindForm(command.id) as Weather
    
        theWeather.SetActive(false, true)
       
        status = viewer + " changed the weather to: " + CrowdControlApi.GetName(command.id)

        Respond(id, 0, status)
        PrintMessage(status)
        
    elseif command.command == "givexp"
        int currentLevel = Game.GetPlayerLevel()
        if currentLevel < 65530
            int xp = command.quantity
            
            if xp <= 1
                xp = Game.GetXPForLevel(currentLevel + 1) - Game.GetXPForLevel(currentLevel)
            endif
        
            Game.RewardPlayerXP(xp)
            
            status = viewer + " gave " + xp + " XP."

            Respond(id, 0, status)
            PrintMessage(status)
        else
            status = viewer + ", cannot give XP. Maximum level reached."

            Respond(id, 1, status)
            PrintMessage(status)
        endif

    elseif command.command == "playeraidriven"
        if type == 1
			if CrowdControlApi.HasTimer("playeraidriven")
				Respond(id, 3)
            else
                ; Turn on the AI driven flag
                Game.SetPlayerAIDriven()
                
                status = viewer + " player is now controlled by AI"
                
                PrintMessage(status)
                Respond(id, 4, status, 1000 * command.quantity)
            endif
		else
            status = "Player AI off"
            
            Game.SetPlayerAIDriven(false)
            
            PrintMessage(status)
			Respond(id, 0, status)
		endif
        
    elseif command.command == "changeplayerluck"
        ChangeSpecial(id, viewer, command, Game.GetLuckAV(), "Luck")
        
    elseif command.command == "changeplayerstrength"
        ChangeSpecial(id, viewer, command, Game.GetStrengthAV(), "Strength")
        
    elseif command.command == "changeplayerperception"
        ChangeSpecial(id, viewer, command, Game.GetPerceptionAV(), "Perception")
    
    elseif command.command == "changeplayerendurance"
        ChangeSpecial(id, viewer, command, Game.GetEnduranceAV(), "Endurance")

    elseif command.command == "changeplayercharisma"
        ChangeSpecial(id, viewer, command, Game.GetCharismaAV(), "Charisma")

    elseif command.command == "changeplayerintelligence"
        ChangeSpecial(id, viewer, command, Game.GetIntelligenceAV(), "Intelligence")

    elseif command.command == "changeplayeragility"
        ChangeSpecial(id, viewer, command, Game.GetAgilityAV(), "Agility")
        
    elseif command.command == "playerlaunch"
        ; Create an instance of the launch marker at the player's location
        ObjectReference marker = player.PlaceAtMe(launchMarker)
		
        ; Generate a random angle between 0 and 360 degrees
        float angle = Utility.RandomFloat() * 360.0
        
        ; Set the horizontal displacement factor (used to control the range of possible launch angles)
        float horizontalDisplacementFactor = 25.0
        
        ; Check if a command parameter is provided to override the default horizontal displacement factor
        if command.param1 != "" && command.param1 as float > 0.0
            horizontalDisplacementFactor = command.param1 as float
        endif
        
        ; Calculate the horizontal displacements based on the random angle and the horizontal displacement factor
        float displacementX = Math.Cos(angle) * horizontalDisplacementFactor
        float displacementY = Math.Sin(angle) * horizontalDisplacementFactor

        ; Move the marker to the player's location plus the calculated horizontal and vertical displacements
        marker.MoveTo(player, displacementX, displacementY, - command.Param0 as int)
        
        ; Push the player away from the marker, causing the player to be launched
		marker.PushActorAway(player, command.quantity)
        
        status = viewer + " launched player"
            
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "playercamerafirstperson"
   
        Game.ForceFirstPerson()
    
        status = viewer + " set player camera to first person"
            
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "playercamerathirdperson"
   
        Game.ForceThirdPerson()
    
        status = viewer + " set player camera to third person"
            
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "playsound"
   
        if command.id > 0
            PlaySound(command.id)
        endif
       
        int playerSex = player.GetActorBase().GetSex()
        
        if playerSex == 0
            ; Male
            if command.param0 != "" && command.param0 as int > 0
                PlaySound(command.param0)
            endif
        elseif playerSex == 1
            ; Female
            if command.param1 != "" && command.param1 as int > 0
                PlaySound(command.param1)
            endif
        endif
    
        status = viewer + " played a sound"
        
        PrintMessage(status)
        Respond(id, 0, status)

    elseif command.command == "removeequippedweapon"

        Weapon akEquippedWeapon = player.GetEquippedWeapon()
        
        if akEquippedWeapon
            PlaySoundId(0xED8A3)

            player.RemoveItem(akEquippedWeapon, 1, true)

            status = viewer + " removed the current weapon"
        
            PrintMessage(status)
            Respond(id, 0, status)

        else
            status = viewer + ", no weapon currently equipped, cannot remove"
        
            PrintMessage(status)
            Respond(id, 1, status)
        endif
        
    elseif command.command == "removeequippedpowerarmor"
        if player.IsInPowerArmor()
            PlaySoundId(0xED8A3)
        
            Actor:WornItem wornItem0 = player.GetWornItem(0)
            Actor:WornItem wornItem11 = player.GetWornItem(11)
            Actor:WornItem wornItem12 = player.GetWornItem(12)
            Actor:WornItem wornItem13 = player.GetWornItem(13)
            Actor:WornItem wornItem14 = player.GetWornItem(14)
            Actor:WornItem wornItem15 = player.GetWornItem(15)
            Actor:WornItem wornItem3 = player.GetWornItem(3)
            
            if wornItem0
                player.RemoveItem(wornItem0.Item, 1, true)
            endif
            
            if wornItem11
                player.RemoveItem(wornItem11.Item, 1, true)
            endif
            
            if wornItem12
                player.RemoveItem(wornItem12.Item, 1, true)
            endif
            
            if wornItem13
                player.RemoveItem(wornItem13.Item, 1, true)
            endif
            
            if wornItem14
                player.RemoveItem(wornItem14.Item, 1, true)
            endif
            
            if wornItem15
                player.RemoveItem(wornItem15.Item, 1, true)
            endif

            while player.IsInPowerArmor()
                PingUpdateTimer()
                
                Debug.Trace("Remove power armor.")
                
                player.SwitchToPowerArmor(None)
                Utility.Wait(0.5)
            endWhile

            if wornItem3
                player.RemoveItem(wornItem3.Item, 1, true)
            endif
            
            status = viewer + " removed power armor"
        
            PrintMessage(status)
            Respond(id, 0, status)
        else
            status = viewer + ", no power armor currently equipped, cannot remove"
        
            PrintMessage(status)
            Respond(id, 1, status)
        endif
        
    elseif command.command == "setgamehour"
        int hour = command.id as int
    
        GameHour.SetValue(hour)
    
        if hour == 0
            status = viewer + " set game time to 12 AM"
        elseif hour < 12
            status = viewer + " set game time to " + hour + " AM"
            
        elseif hour == 12
            status = viewer + " set game time to 12 PM."
        else
            status = viewer + " set game time to " + (hour - 12) + " PM"
        endif
        
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "fadeoutscreen"
        status = viewer + " faded the screen out for " + command.quantity + " seconds"
        
        PrintMessage(status)
        Respond(id, 0, status)
        
        Game.FadeOutGame(false, false, command.quantity, 1.0)

    elseif command.command == "playerequipitem"
        Form theItem = FindForm(command.id)
        
        int i = 0
        while i < command.quantity
            PingUpdateTimer()
            
            player.EquipItem(theItem, false, true)
            
            i += 1
        endwhile
        
        status = viewer + " equipped you with: " + CrowdControlApi.GetName(command.id)
        
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "playersetav"
        ActorValue av = FindForm(command.id) as ActorValue
        
        Debug.Trace("Before value of " + command.id + ": " + player.GetValue(av))
        Debug.Trace("Before base value of " + command.id + ": " + player.GetBaseValue(av))
       
        float value = player.GetValue(av)
        
        if command.param0 != "" && command.param0 as int > 0
            player.ModValue(av, (-command.quantity) - value)
            
            Debug.Trace("Mod value " + command.id + ": " + ((-command.quantity) - value))
        else
            player.ModValue(av, command.quantity - value)
            
            Debug.Trace("Mod value " + command.id + ": " + (command.quantity - value))
        endif

        Debug.Trace("After value of " + command.id + ": " + player.GetValue(av))
        Debug.Trace("After base value of " + command.id + ": " + player.GetBaseValue(av))
        
        status = viewer + " set value " + command.id + " to " + command.quantity
       
        if command.param1 != "" && command.param1 as int > 0
          Debug.Trace("Adding spell: " + command.param1 as int)
        
          Spell newSpell = FindForm(command.param1) as Spell
          
          player.AddSpell(newSpell, false)
        endif
        
        if command.param2 != "" && command.param2 as int > 0
            Debug.Trace("Removing spell: " + command.param1 as int)
        
            player.RemoveSpell(FindForm(command.param2) as Spell)
        endif
        
        PrintMessage(status)
        Respond(id, 0, status)
   
    elseif command.command == "playerdamageav"
        if command.Param0 != "" && command.Param0 as int > 0
            if player.IsInPowerArmor()
                status = viewer + ", cannot cripple player while wearing power armor."
        
                PrintMessage(status)
                Respond(id, 1, status)
                
                return
            endif
        endif
    
        ActorValue av = FindForm(command.id) as ActorValue
        
        player.DamageValue(av, command.quantity)
        
        status = viewer + " crippled player"
        
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "playerrestoreav"
        ActorValue av = FindForm(command.id) as ActorValue
        
        player.RestoreValue(av, command.quantity)
        
        if command.param0 != "" && command.param0 as int > 0
            av = FindForm(command.param0) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param1 != "" && command.param1 as int > 0
            av = FindForm(command.param1) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param2 != "" && command.param2 as int > 0
            av = FindForm(command.param2) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param3 != "" && command.param3 as int > 0
            av = FindForm(command.param3) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param4 != "" && command.param4 as int > 0
            av = FindForm(command.param4) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param5 != "" && command.param5 as int > 0
            av = FindForm(command.param5) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param6 != "" && command.param6 as int > 0
            av = FindForm(command.param6) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param7 != "" && command.param7 as int > 0
            av = FindForm(command.param7) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param8 != "" && command.param8 as int > 0
            av = FindForm(command.param8) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        if command.param9 != "" && command.param9 as int > 0
            av = FindForm(command.param9) as ActorValue
            player.RestoreValue(av, command.quantity)
        endif
        
        status = viewer + " healed player"
        
        PrintMessage(status)
        Respond(id, 0, status)
    
    elseif command.command == "screenblood"
        Game.TriggerScreenBlood(command.quantity)
        
        status = viewer + " triggered blood effect"
        
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "shakecamera"
        Game.ShakeCamera(afStrength = (command.quantity as float / 100.0))
        
        status = viewer + " triggered camera shake"
        
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "shakecamera2"
        Game.ShakeCamera(afStrength = (command.param0 as float / 100.0), afDuration = command.quantity as float)
        
        status = viewer + " triggered camera shake"
        
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "scare"
        if command.param0 as int > 0
            Game.ShakeCamera(afStrength = (command.param0 as float / 100.0), afDuration = (command.param1 as float / 1000.0))
        endif
        
        if command.param2 as int > 0
            Game.TriggerScreenBlood(command.param2 as int)
        endif
        
        PlaySound(command.id)
        
        status = viewer + " triggered a scare"
        
        PrintMessage(status)
        Respond(id, 0, status)
        
    elseif command.command == "playerequipaddiction"
        if player.HasPerk(FindFormId(0x4A0D5) as Perk) || player.HasPerk(FindFormId(0x65E0C) as Perk)
           ; All addictions impossible
           
           status = viewer + ", player has the Chem Resistant perk. Cannot give player addictions."
        
            PrintMessage(status)
            Respond(id, 1, status)
        
        elseif command.id == 0x01005B99 && (player.HasPerk(FindFormId(0x4D887) as Perk) || player.HasPerk(FindFormId(0x1D2473) as Perk) || player.HasPerk(FindFormId(0x1D2474) as Perk) || player.HasPerk(FindFormId(0x4D888) as Perk) || player.HasPerk(FindFormId(0x1D2475) as Perk) || player.HasPerk(FindFormId(0x1D2476) as Perk))
            ; Alcohol addiction impossible
            
            int playerSex = player.GetActorBase().GetSex()
        
            if playerSex == 0
                ; Male
                status = viewer + ", player has the Party Boy perk. Cannot give player alcohol addiction."
            elseif playerSex == 1
                ; Female
                status = viewer + ", player has the Party Girl perk. Cannot give player alcohol addiction."
            endif
        
            PrintMessage(status)
            Respond(id, 1, status)
            
        else
            Form theItem = FindForm(command.id)
            
            int i = 0
            while i < command.quantity
                PingUpdateTimer()
                
                player.EquipItem(theItem, false, true)
                
                i += 1
            endwhile
            
            status = viewer + " gave you: " + CrowdControlApi.GetName(command.id)
            
            PrintMessage(status)
            Respond(id, 0, status)
        endif
        
    elseif command.command == "ShowNotification"
        status = ccCommand.Param0
        
        Debug.Notification(status)
        Respond(id, 0, status)
        
    elseif command.command == "ShouldShowNotifications"
        ShouldShowNotifications = ccCommand.Param0 as int
        
        Respond(id, 0, "Notifications set.")
    
    else
        Debug.Notification("Unknown command received: " + command.command)
	endif

EndFunction

Function ChangeSpecial(int id, string viewer, ParsedCommand command, ActorValue av, string name)
    string status
    int currentValue = command.quantity
        
    if command.id == 1
        currentValue = player.GetBaseValue(av) as int
        currentValue = currentValue + command.quantity
    endif
    
    if currentValue <= 10 && currentValue >= 1
        player.SetValue(av, currentValue)
        
        if command.id == 1
            if command.quantity >= 0
                status = viewer + " increased player " + name + " +" + command.quantity
            else
                status = viewer + " decreased player " + name + " " + command.quantity
            endif
        else
            status = viewer + " set player " + name + " to " + command.quantity
        endif 
        
        PrintMessage(status)
        Respond(id, 0, status)
    else
        status = viewer + ", player " + name + " is already at maximum"
        
        PrintMessage(status)
        Respond(id, 1, status)
    endif
endFunction

Function PlayerAddArmor(string id)
    Form theForm
    ObjectReference spawnedItem

    if id != ""
        ; id format: [formId]~[modId]~[modId]...
        string[] ids = CrowdControlApi.StringSplit(id, "~")
        
        if ids.length > 1
            theForm = FindForm(ids[0])
            spawnedItem = player.PlaceAtMe(theForm)
            
            int i = 1
            while i < ids.length
                AttachMod(spawnedItem, ids[i])
                i += 1
            endwhile
        else
            theForm = FindForm(id)
            spawnedItem = player.PlaceAtMe(theForm)
        endif
        
        PlayerInventoryRemoveAllItems(spawnedItem.GetBaseObject())
        AutoEquipAddedItem()
        player.AddItem(spawnedItem, 1, abSilent = true)
    endif
endfunction

;-- Workshop --

bool isPlayerInWorkshop

Event OnWorkshopMode(bool aStart)
  if aStart
    isPlayerInWorkshop = true
  else
    isPlayerInWorkshop = false
  endif
EndEvent

;-- Cooldowns --

struct ActiveCooldown
    string id
    int startTime
EndStruct

ActiveCooldown[] activeCooldowns

bool Function CheckCooldown(int id, string cooldownId, int seconds)
    ;Debug.Trace("CheckCooldown: " + cooldownId)

    ActiveCooldown ac = FindOrStartCooldown(cooldownId)
    if ac != None
        if (Utility.GetCurrentRealTime() as int) - ac.startTime < seconds
            ;Debug.Trace("  In cooldown")
            
            Respond(id, 1)
            return false
        else
            ;Debug.Trace("  cooldown ended")
        
            EndCooldown(cooldownId)
            FindOrStartCooldown(cooldownId)
        endif
    else
        ;Debug.Trace("  new cooldown started")
    endif
    
    return true
endFunction

ActiveCooldown Function FindOrStartCooldown(string cooldownId)
    ActiveCooldown ac = FindCooldown(cooldownId)
    if ac != None
        return ac
    endif

    ac = new ActiveCooldown

    ac.id = cooldownId
    ac.startTime = Utility.GetCurrentRealTime() as int

    activeCooldowns.Add(ac)
    
    return None
EndFunction

bool Function EndCooldown(string cooldownId)
    int i = activeCooldowns.FindStruct("id", cooldownId)
    
    if i < 0
        return false
    endif
   
    activeCooldowns.remove(i)
    
    return true
endFunction

ActiveCooldown Function FindCooldown(string cooldownId)
    int i = activeCooldowns.FindStruct("id", cooldownId)
    if i < 0
        return None
    endif
    return activeCooldowns[i]
endFunction

;-- Followers --

int Function CountFollowers(bool outdoorOnly)
    int startIndex = 2
    int endIndex = 4

    if outdoorOnly
        startIndex = 9
        endIndex = 11
    endif

    ReferenceAlias ra
    Actor a
   
    int count = 0
    
    int i = startIndex
    while i <= endIndex
        ra = GetOwningQuest().GetAlias(i) as ReferenceAlias
        a = ra.GetActorReference()

        ; Clear alias for any dead followers
        if a != None
            if a.IsDead()
                ra.Clear()
                a = None
            endif
        endif
      
        if a != None
            Debug.Trace("CountFollowers(): Found follower (i=" + i + ", id=" + a.GetFormID() + ")")
            
            count += 1
        endif
      
        i += 1
    endWhile
    
    return count
EndFunction

int Function CountAllFollowers()
    int count
    
    count += CountFollowers(false)
    count += CountFollowers(true)
    
    return count
EndFunction

Actor Function AddFollower(string id, bool outdoorOnly)
    int startIndex = 2
    int endIndex = 4

    if outdoorOnly
        startIndex = 9
        endIndex = 11
    endif

    bool wasAdded = false
    ReferenceAlias ra
    Actor a
    Actor spawnedActor
    int i = startIndex
    while i <= endIndex
      ra = GetOwningQuest().GetAlias(i) as ReferenceAlias
      a = ra.GetActorReference()
      
      ; Clear alias for any dead followers
      if a != None
          if a.IsDead()
            ra.Clear()
            a = None
          endif
      endif
      
      if a == None
        Form theForm = FindForm(id)
       
        if theForm != None
            spawnedActor = player.PlaceActorAtMe(theForm as ActorBase)
            spawnedActor.RemoveFromAllFactions()
            ra.ForceRefTo(spawnedActor)
            spawnedActor.SetPlayerTeammate(true)
            
            SetFollowerState(i)

            id = ""
        endif
        
      endif
      
      i += 1
    endWhile
    
    return spawnedActor
EndFunction

; Not currently used, but can be used to keep additional state associated with specific followers
struct FollowerState
    int index
EndStruct

FollowerState[] followerStates

FollowerState Function GetFollowerState(int index)
    int i = followerStates.FindStruct("index", index)
    if i < 0
        return None
    endif
    return followerStates[i]
endFunction

Function SetFollowerState(int index)
    FollowerState fs = GetFollowerState(index)
    if fs == None
        fs = new FollowerState
        followerStates.Add(fs)
    endif

    fs.index = index
endFunction

; -- Util --

float Function GetPlayerAngle()
    float gameAngleZ ; the game's version
    float trigAngleZ ; the rest of the world's interpretation of the same
     
    gameAngleZ = player.GetAngleZ()
    if gameAngleZ < 90
      trigAngleZ = 90 - gameAngleZ
    else
      trigAngleZ = 450 - gameAngleZ
    endif
    
    return trigAngleZ
endfunction

Function PlaySoundId(int id)
    Sound soundFound = FindForm(id) as Sound
    soundFound.Play(player)
endfunction

Function PlaySound(String id)
    Sound soundFound = FindForm(id) as Sound
    soundFound.Play(player)
endfunction

bool Function GetRandomBool()
    int i = Utility.RandomInt(0, 1)   ; Generate a random integer between 0 and 1
    If i == 0
        return False
    Else
        return True
    EndIf
EndFunction

; -- Debug --

Function TraceInventory()
    Form[] items = player.GetInventoryItems()
   
    Debug.Trace("TraceInventory() length=" + items.Length)
    
    int i = 0
    while i < items.Length
        Form item = items[i]
        
        Debug.Trace("  i: " + i)
        Debug.Trace("    Type: " + item)
        Debug.Trace("    Name: " + item.GetName())
        
        i += 1
    endWhile
endfunction

Function TraceWornItems()
    ; For each biped slot
    int index = 0
    int end = 43 const

    while (index < end)
        Actor:WornItem wornItem = player.GetWornItem(index)
        Debug.Trace("Slot Index: " + index + ", " + wornItem)
        index += 1
    EndWhile
endfunction