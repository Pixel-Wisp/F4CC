// Copyright (c) 2023 kmrkle.tv community. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.

using System;
using System.Collections.Generic;
using CrowdControl.Common;

namespace CrowdControl.Games.Packs
{
    public class Fallout4 : SimpleTCPPack
    {
        public override string Host => "127.0.0.1";
         
        public override ushort Port => 5420;

        public Fallout4(UserRecord player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) 
            : base(player, responseHandler, statusUpdateHandler)
        {
        }

        public override Game Game { get; } = new Game("Fallout 4", "Fallout4", "PC", ConnectorType.SimpleTCPServerConnector);

        private uint? priceOverride = null;
        private double priceScale = 1.0;

        private uint? neutralSpawnDistance = 200;
        private uint? hostileSpawnDistance = 500;
        private uint? hostileSpawnDistanceFar = 1000;
        private uint? hostileSpawnDistanceSwarm = 1500;

        private uint GetPrice(int basePrice)
        {
            return priceOverride ?? (uint)(basePrice * priceScale);
        }

        public override EffectList Effects => new[]
        {
            #region Play Sound (category)

            new Effect("Rage", $"playsound_0_1_{0x2496C2}_{0x2496C1}") { Price = GetPrice(10), Category = "Play Sound" },
            new Effect("Laugh", $"playsound_0_1_{0x2496BF}_{0x2496BE}") { Price = GetPrice(10), Category = "Play Sound" },
            new Effect("Air Raid Siren", $"playsound_{0x11A00B}_1") { Price = GetPrice(50), Category = "Play Sound" },
            new Effect("Applause", $"playsound_{0x010079FD}_1") { Price = GetPrice(25), Category = "Play Sound" },

            #endregion

            #region Give Misc. Items (category)

            new Effect("Caps (1000)", "playeradditem_15_1000") { Price = GetPrice(25), Category = "Give Misc. Items" },
            new Effect("Bobby Pin Box", "playeradditem_588968_1") { Price = GetPrice(5), Category = "Give Misc. Items" },
            new Effect("Fusion Cores (5)", "playeradditem_483300_5") { Price = GetPrice(10), Category = "Give Misc. Items" },

            #endregion
            
            #region Give Crafting Components (category)

            new Effect("Adhesive (15)", $"playeradditem_{0x001BF72E}_15") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Aluminum (35)", $"playeradditem_{0x0006907A}_35") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Screws (50)", $"playeradditem_{0x00069081}_50") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Steel (100)", $"playeradditem_{0x000731A4}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Copper (25)", $"playeradditem_{0x0006907C}_25") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Oil (25)", $"playeradditem_{0x001BF732}_25") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Circuitry (20)", $"playeradditem_{0x0006907B}_20") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Nuclear Material (10)", $"playeradditem_{0x00069086}_10") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Fiber Optics (20)", $"playeradditem_{0x00069087}_20") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Crystal (25)", $"playeradditem_{0x0006907D}_25") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Acid (50)", $"playeradditem_{0x001BF72D}_50") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Antiseptic (35)", $"playeradditem_{0x001BF72F}_35") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Ballistic Fiber (20)", $"playeradditem_{0x000AEC5B}_20") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Bone (100)", $"playeradditem_{0x000AEC5D}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Ceramic (100)", $"playeradditem_{0x000AEC5E}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Cloth (100)", $"playeradditem_{0x000AEC5F}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Concrete (100)", $"playeradditem_{0x00106D99}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Cork (100)", $"playeradditem_{0x000AEC60}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Fertilizer (100)", $"playeradditem_{0x001BF730}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Fiberglass (20)", $"playeradditem_{0x000AEC61}_20") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Gears (35)", $"playeradditem_{0x0006907E}_35") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Glass (50)", $"playeradditem_{0x00069085}_50") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Gold (15)", $"playeradditem_{0x000AEC62}_15") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Lead (100)", $"playeradditem_{0x000AEC63}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Leather (50)", $"playeradditem_{0x000AEC64}_50") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Plastic (100)", $"playeradditem_{0x0006907F}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Rubber (50)", $"playeradditem_{0x00106D98}_50") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Silver (20)", $"playeradditem_{0x000AEC66}_20") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Spring (35)", $"playeradditem_{0x00069082}_35") { Price = GetPrice(25), Category = "Give Crafting Components" },
            new Effect("Wood (100)", $"playeradditem_{0x000731A3}_100") { Price = GetPrice(25), Category = "Give Crafting Components" },

            #endregion

            #region Player Aid (category)

            new Effect("Give Addictol", $"playeradditem_{0x459c5}_1") { Price = GetPrice(100), Category = "Player Aid" },
            new Effect("Use Stimpack", "playerequipitem_145206_1") { Price = GetPrice(10), Category = "Player Aid" },
            new Effect("Stim-plosion (30)", "placeatme_145206_30_1000") { Price = GetPrice(100), Description = "Stimpacks will appear to explode from the player.", Category = "Player Aid" },
            new Effect("Use RadAway", "playerequipitem_145218_1") { Price = GetPrice(10), Category = "Player Aid" },
            new Effect("RadAway-plosion (10)", "placeatme_145218_10_500") { Price = GetPrice(100), Description = "RadAways will appear to explode from the player.", Category = "Player Aid" },
            new Effect("Give Rad-X", "playeradditem_147543_1") { Price = GetPrice(10), Category = "Player Aid" },
            new Effect("Give Calmex", $"playeradditem_{0x58aa7}_1") { Price = GetPrice(100), Category = "Player Aid" },
            new Effect("Give Psycho Jet", "playeradditem_363176_1") { Price = GetPrice(100), Category = "Player Aid" },
            new Effect("Give X-Cell", "playeradditem_1378036_1") { Price = GetPrice(100), Category = "Player Aid" },
            new Effect("Use Stealth Boy", "playerequipitem_324774_1") { Price = GetPrice(50), Category = "Player Aid" },
            new Effect("Perfect Pie-plosion (100)", "placeatme_1729430_100_500") { Price = GetPrice(1000), Description = "Pieces of perfectly preserved pies will appear to explode from the player.", Category = "Player Aid" },
            new Effect("Nuka-Cola-plosion (30)", $"placeatme_{0x4835D}_30_2500") { Price = GetPrice(50), Description = "Nuka-Colas will appear to explode from the player.\r\n\r\nThis drink restores a total of 20 Hit Points, 10 Action Points, and adds 5 rads.", Category = "Player Aid" },
            new Effect("Nuka-Cola Quantum-plosion (15)", $"placeatme_{0x4835F}_15_2500") { Price = GetPrice(100), Description = "Nuka-Cola Quantums will appear to explode from the player.\r\n\r\nThis drink restores a total of 400 Hit Points, 100 Action Points, and adds 5 rads.", Category = "Player Aid" },
            new Effect("Tato-plosion (30)", $"placeatme_{0x0009DCC4}_30_25") { Price = GetPrice(25), Description = "Tatos will appear to explode from the player.", Category = "Player Aid" },
            new Effect("Melon-plosion (15)", $"placeatme_{0x000FAFEB}_30_50") { Price = GetPrice(25), Description = "Melons will appear to explode from the player.", Category = "Player Aid" },
            
            new Effect("Nuka-Love-plosion (30)", $"placeatme_dlcnukaworld__{0x0502C6}__plosion_30_2500") { Price = GetPrice(75), Description = "Ice cold Nuka-Loves will appear to explode from the player.\r\n\r\nThis drink restores 150 Hit Points and 300 Action Points.", Category = "Player Aid" },
            new Effect("Nuka-Cide-plosion (15)", $"placeatme_dlcnukaworld__{0x0502B4}__plosion_15_2500") { Price = GetPrice(150), Description = "Ice cold Nuka-Cides will appear to explode from the player.\r\n\r\nThis drink restores 1800 Hit Points, 360 Action Points, temporarily increases maximum AP by 20, temporarily increases maximum HP by 50, temporarily increases Radiation Resistance by 35, and temporarily increases maximum carry weight by 35.", Category = "Player Aid" },
            new Effect("Nuka-Frutti-plosion (15)", $"placeatme_dlcnukaworld__{0x0502BD}__plosion_15_2500") { Price = GetPrice(75), Description = "Ice cold Nuka-Fruttis will appear to explode from the player.\r\n\r\nThis drink restores 250 Hit Points and 75 Action Points, removes 500 Rads, and temporarily increases Radiation Resistance by 25.", Category = "Player Aid" },
            new Effect("Nuka-Power-plosion (10)", $"placeatme_dlcnukaworld__{0x0502C9}__plosion_10_2500") { Price = GetPrice(50), Description = "Ice cold Nuka-Powers will appear to explode from the player.\r\n\r\nThis drink temporarily increases one's maximum Carry Weight by 60 pounds for 8 minutes.", Category = "Player Aid" },
            
            new Effect("Vim-plosion Captain's Blend (15)", $"placeatme_dlccoast__{0x054282}__plosion_15_2000") { Price = GetPrice(125), Description = "Ice cold Vim Captain's Blends will appear to explode from the player.\r\n\r\nThis drink restores 700 Hit Points, 120 Action Points, and lowers Charisma by 2 while making sea creatures more reluctant to attack for 120s.", Category = "Player Aid" },

            #endregion

            #region Use Weapons (category)

            new Effect("Furious Power Fist", "playergiveweapon2_1159990_1_0_2028673_2198613") { Price = GetPrice(20), Category = "Use Weapons" },
            new Effect("Grognak's Axe", "playergiveweapon2_1589197_1_0") { Price = GetPrice(20), Category = "Use Weapons" },
            new Effect("Wastelander's Friend (100 ammo)", "playergiveweapon2_2056678_100_127606_1449213_1344436_597953_1592409_1994091_2198613") { Price = GetPrice(20), Description = "This weapon consumes 10mm rounds.", Category = "Use Weapons" },
            new Effect("Alien Blaster (100 ammo)", "playergiveweapon2_1046933_100_1058218") { Price = GetPrice(50), Description = "This weapon consumes alien blaster rounds.", Category = "Use Weapons" },
            new Effect("Lorenzo's Artifact (200 ammo)", "playergiveweapon2_2254587_200_914041") { Price = GetPrice(50), Description = "This weapon consumes gamma rounds.", Category = "Use Weapons" },
            new Effect("Experiment 18-A (200 ammo)", "playergiveweapon2_2056681_200_121783_1699018_1699011_1122172_2016621_2198613") { Price = GetPrice(50), Description = "This weapon consumes plasma cartridges.", Category = "Use Weapons" },
            new Effect("The Last Minute (100 ammo)", "playergiveweapon2_2274819_100_1616863_1547090_1753683_1848481_1547088_1994091_2198613") { Price = GetPrice(50), Description = "This weapon consumes 2mm electromagnetic cartridges.", Category = "Use Weapons" },
            new Effect("Broadsider (100 ammo)", "playergiveweapon2_1608302_100_1036572") { Price = GetPrice(50), Description = "This weapon consumes cannonballs.", Category = "Use Weapons" },
            new Effect("Overseer's Guardian (100 ammo)", "playergiveweapon2_2056679_100_128618_1344372_1344445_1344542_1884845_2198613") { Price = GetPrice(50), Description = "This weapon consumes .45 rounds.", Category = "Use Weapons" },
            new Effect("Final Judgment (500 ammo)", "playergiveweapon2_2251454_1_483300_2016621") { Price = GetPrice(75), Description = "This weapon consumes fusion cores.", Category = "Use Weapons" },
            new Effect("Ashmaker (1000 ammo)", "playergiveweapon2_2041134_1000_128620_1995123_1608197_1187155_2198613") { Price = GetPrice(75), Description = "This weapon consumes 5mm rounds.", Category = "Use Weapons" },
            new Effect("Death From Above (10 ammo)", "playergiveweapon2_2251113_10_830371_2013885_2198613") { Price = GetPrice(75), Description = "This weapon consumes missiles.", Category = "Use Weapons" },
            new Effect("Spray n' Pray (400 ammo)", "playergiveweapon2_2056675_400_128618_1779962_1608294_1779965_1779968_1995709_2198613") { Price = GetPrice(100), Description = "This weapon consumes .45 rounds.", Category = "Use Weapons" },
            new Effect("Big Boy (5 ammo)", "playergiveweapon2_2204990_5_944942_1884845_2198613") { Price = GetPrice(100), Description = "This weapon consumes mini nukes.", Category = "Use Weapons" },
            new Effect("Experimental MIRV (5 ammo)", "playergiveweapon2_775535_5_944942_1753676_2198613") { Price = GetPrice(150), Description = "This weapon consumes mini nukes.", Category = "Use Weapons" },
            
            new Effect("Nuka-nuke Launcher (5 ammo)", $"playergiveweapon2_fallout4__{0xBD56F}__nukanuke_5_dlcnukaworld__{0x1B039}_dlcnukaworld__{0x4e494}") { Price = GetPrice(75), Description = "This weapon consumes nuka-nukes.", Category = "Use Weapons" },
            new Effect("Thirst Zapper", $"playergiveweapon2_dlcnukaworld__{0x007BC8}__thirstzapper_0") { Price = GetPrice(10), Description = "This weapon does not require ammo.", Category = "Use Weapons" },
            new Effect("Quantum Thirst Zapper (10 ammo)", $"playergiveweapon2_dlcnukaworld__{0x007BC8}__quantumthirstzapper_10_dlcnukaworld__{0x00A6C6}_dlcnukaworld__{0x02c683}") { Price = GetPrice(50), Description = "This weapon consumes Weaponized Nuka-Cola Quantums.", Category = "Use Weapons" },

            new Effect("Salvaged Assaultron Head (50 ammo)", $"playergiveweapon2_dlcrobot__{0x0100B7}_50_fallout4__{0x000C1897}") { Price = GetPrice(50), Description = "This weapon consumes fusion cells.", Category = "Use Weapons" },
            new Effect("Tesla Rifle (100 ammo)", $"playergiveweapon2_dlcrobot__{0x003E07}_100_fallout4__{0x000C1897}_dlcrobot__{0x000FEC}") { Price = GetPrice(50), Description = "This weapon consumes fusion cells.", Category = "Use Weapons" },
            
            new Effect("Atom's Judgement", $"playergiveweapon2_dlccoast__{0x03A388}_1_0_dlccoast__{0x03A387}_fallout4__{0x0690AF}") { Price = GetPrice(30), Category = "Use Weapons" },
            new Effect("Admiral's Friend (20 ammo)", $"playergiveweapon2_dlccoast__{0x05158B}_20_dlccoast__{0x010B80}_dlccoast__{0x037CF3}_dlccoast__{0x037CFD}_{0x1F04B8}_{0x248384}") { Price = GetPrice(50), Description = "This weapon consumes harpoons.", Category = "Use Weapons" },
            new Effect("Kiloton Radium Rifle (400 ammo)", $"playergiveweapon2_dlccoast__{0x05158E}_400_128618_dlccoast__{0x03EC3B}_dlccoast__{0x025FCA}_dlccoast__{0x025FCD}_dlccoast__{0x0407E3}_dlccoast__{0x025FCC}_{0x1E73BD}_{0x248384}") { Price = GetPrice(100), Description = "This weapon consumes .45 rounds.", Category = "Use Weapons" },
            new Effect("Sergeant Ash (200 ammo)", $"playergiveweapon2_dlccoast__{0x051599}_200_{0x0CAC78}_{0x147B01}_{0x147AFA}_{0x1AC24F}_{0x1F1048}_{0x24836E}") { Price = GetPrice(50), Description = "This weapon consumes flamer fuel.", Category = "Use Weapons" },
            new Effect("The Striker (100 ammo)", $"playergiveweapon2_dlccoast__{0x031702}_100_dlccoast__{0x02740E}_dlccoast__{0x02740C}_dlccoast__{0x056F2A}") { Price = GetPrice(10), Description = "This weapon consumes modified bowling balls.", Category = "Use Weapons" },

            #endregion

            #region Give Ammo (category)

            new Effect("Alien Blaster Round (100)", "playeradditem_1058218_100") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("10mm (100)", "playeradditem_127606_100") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect(".45 (200)", "playeradditem_128618_200") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("2mm EC (100)", "playeradditem_1616863_100") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("5mm (1000)", "playeradditem_128620_1000") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Plasma Cartridge (200)", "playeradditem_121783_200") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Fusion Cell (200)", $"playeradditem_{0x000C1897}_200") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Gamma Round (200)", "playeradditem_914041_200") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Missile (10)", "playeradditem_830371_10") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Cannonball (10)", "playeradditem_1036572_10") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Mini Nuke (5)", "playeradditem_944942_5") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Fragmentation Grenade (10)", "playeradditem_977901_10") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Pulse Grenade (10)", "playeradditem_1045023_10") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Flamer Fuel (300)", $"playeradditem_{0x0CAC78}_300") { Price = GetPrice(10), Category = "Give Ammo" },
            
            new Effect("Nuka-nuke (5)", $"playeradditem_dlcnukaworld__{0x1B039}_5") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Weaponized Nuka-Cola Quantum (10)", $"playeradditem_dlcnukaworld__{0x00A6C6}_10") { Price = GetPrice(10), Category = "Give Ammo" },

            new Effect("Harpoon (100)", $"playeradditem_dlccoast__{0x010B80}_100") { Price = GetPrice(10), Category = "Give Ammo" },
            new Effect("Modified Bowling Ball (100)", $"playeradditem_dlccoast__{0x02740E}_100") { Price = GetPrice(10), Category = "Give Ammo" },

            #endregion

            #region Use Outfits (category)

            new Effect("Armored Bathrobe", $"playeraddarmor_0_1_fallout4__{0x0014A349}___fallout4__{0x22DC7D}_{0x001F599A}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Agatha's Dress", $"playeraddarmor_0_1_fallout4__{0x000F15CF}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Institute Division Head Coat", $"playeraddarmor_0_1_{0x001236AD}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Institute Lab Coat", $"playeraddarmor_0_1_{0x001B350D}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Cabot's Lab Coat", $"playeraddarmor_0_1_fallout4__{0x001E8CAB}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Clean Black Suit", $"playeraddarmor_0_1_fallout4__{0x001BDDF8}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Cleanroom Suit", $"playeraddarmor_0_1_{0x00115AEB}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Colonial Duster", $"playeraddarmor_0_1_{0x000316D4}_{0x0001F17B}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Corset", $"playeraddarmor_0_1_{0x001921D6}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Courser Uniform", $"playeraddarmor_0_1_fallout4__{0x0012A332}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Father's Lab Coat", $"playeraddarmor_0_1_fallout4__{0x0014FBD0}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Feathered Dress", $"playeraddarmor_0_1_fallout4__{0x001B5F1B}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Geneva's Ensemble", $"playeraddarmor_0_1_fallout4__{0x0023CAA4}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Grognak Costume", $"playeraddarmor_0_1_{0x1828CC}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Hazmat Suit", $"playeraddarmor_0_1_{0x000CEAC4}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Pink Dress", $"playeraddarmor_0_1_fallout4__{0x002075BF}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Mechanic Jumpsuit", $"playeraddarmor_0_1_fallout4__{0x0005E76C}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Postman Uniform", $"playeraddarmor_0_1_fallout4__{0x00146174}___fallout4__{0x22DC7D}_{0x001F9790}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Red Dress", $"playeraddarmor_0_1_fallout4__{0x000FD9A8}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Sequin Dress", $"playeraddarmor_0_1_fallout4__{0x0011A27B}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Silver Shroud Costume", $"playeraddarmor_0_1_{0x0014E58E}_{0x000DED29}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Summer Shorts", $"playeraddarmor_0_1_fallout4__{0x0014941A}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored T-shirt and Slacks", $"playeraddarmor_0_1_fallout4__{0x0014B019}___fallout4__{0x22DC7D}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Tuxedo", $"playeraddarmor_0_1_fallout4__{0x000FC395}___fallout4__{0x22DC7D}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Vault-Tec Lab Coat", $"playeraddarmor_0_1_{0x00068CF3}") { Price = GetPrice(10), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Yellow Trench Coat", $"playeraddarmor_0_1_fallout4__{0x000DF455}___fallout4__{0x22DC7D}_{0x000DF457}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("BOS uniform", $"playeraddarmor_0_1_{0x002223E3}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Army Fatigues", $"playeraddarmor_0_1_fallout4__{0x00023431}___fallout4__{0x22DC7D}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            
            new Effect("Cowhide Western Outfit", $"playeraddarmor_0_1_dlcnukaworld__{0x029C0B}_dlcnukaworld__{0x042323}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Magician's Tuxedo", $"playeraddarmor_0_1_dlcnukaworld__{0x03407C}___fallout4__{0x22DC7D}_dlcnukaworld__{0x050DD1}") { Price = GetPrice(30), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Nuka-Girl Rocketsuit", $"playeraddarmor_0_1_dlcnukaworld__{0x029C0D}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Western Outfit & Chaps", $"playeraddarmor_0_1_dlcnukaworld__{0x029C09}_dlcnukaworld__{0x042322}") { Price = GetPrice(10), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Spacesuit Costume", $"playeraddarmor_0_1_dlcnukaworld__{0x00D2AE}_dlcnukaworld__{0x0296B8}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Wildman Rags", $"playeraddarmor_0_1_dlcnukaworld__{0x0392AE}") { Price = GetPrice(10), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            
            new Effect("Armored Legend of the Harbor", $"playeraddarmor_0_1_dlccoast__{0x04B9B1}___fallout4__{0x22DC7D}_dlccoast__{0x00914B}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Armored Hunter's Long Coat", $"playeraddarmor_0_1_dlccoast__{0x046027}___fallout4__{0x22DC7D}_dlccoast__{0x046024}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },
            new Effect("Marine Wetsuit", $"playeraddarmor_0_1_dlccoast__{0x03A556}_dlccoast__{0x03A557}") { Price = GetPrice(20), Description = "An outfit can only be equipped if the player is not in power armor.", Category = "Use Outfits" },

            #endregion

            #region Use Armor (category)

            new Effect("Combat Armor", $"playeraddarmor_{0x00023431}_1_{0x0011e2c8}_{0x00184bd1}_{0x00184bcb}_{0x00184bce}_{0x00184bc5}_{0x00184bc8}") { Price = GetPrice(50), Description = "Armor can only be equipped if the player is not in power armor.", Category = "Use Armor" },
            new Effect("Synth Armor", $"playeraddarmor_{0x0012B91D}_1_{0x0022e2ed}_{0x0022e2e4}_{0x0022e2e1}_{0x0022e2ea}_{0x0022e2e7}_{0x00187976}") { Price = GetPrice(50), Description = "Armor can only be equipped if the player is not in power armor.", Category = "Use Armor" },
            new Effect("T-45 Power Armor", $"playeraddpowerarmor_{0x17FB09}_1") { Price = GetPrice(100), Description = "Power armor can only be equipped if the player is not already in power armor.", Category = "Use Armor" },
            new Effect("T-51 Power Armor", $"playeraddpowerarmor_{0x108EA0}_1") { Price = GetPrice(150), Description = "Power armor can only be equipped if the player is not already in power armor.", Category = "Use Armor" },
            new Effect("T-60 Power Armor", $"playeraddpowerarmor_{0x17FB0A}_1") { Price = GetPrice(175), Description = "Power armor can only be equipped if the player is not already in power armor.", Category = "Use Armor" },
            new Effect("X-01 Power Armor", $"playeraddpowerarmor_{0x1681E2}_1") { Price = GetPrice(200), Description = "Power armor can only be equipped if the player is not already in power armor.", Category = "Use Armor" },
            
            new Effect("X-01 Power Armor (Quantum)", $"playeraddpowerarmor_dlcnukaworld__{0x31723}_1") { Price = GetPrice(225), Description = "Power armor can only be equipped if the player is not already in power armor.", Category = "Use Armor" },
            
            new Effect("Robot Armor", $"playeraddarmor_{0x002223E3}_1_dlcrobot__{0x00863F}_dlcrobot__{0x008646}_dlcrobot__{0x008648}_dlcrobot__{0x008642}_dlcrobot__{0x008644}_dlcrobot__{0x00864A}") { Price = GetPrice(40), Description = "Armor can only be equipped if the player is not in power armor.", Category = "Use Armor" },
            new Effect("Mechanist's Armor", $"playeraddarmor_0_1_dlcrobot__{0x008BC1}___fallout4__{0x22DC7D}_dlcrobot__{0x008BC3}") { Price = GetPrice(50), Description = "Armor can only be equipped if the player is not in power armor.", Category = "Use Armor" },
            new Effect("T-60 Power Armor (Tesla)", $"playeraddpowerarmor_dlcrobot__{0x00C579}_1") { Price = GetPrice(185), Description = "Power armor can only be equipped if the player is not already in power armor.", Category = "Use Armor" },
            
            new Effect("Assault Marine Armor", $"playeraddarmor_dlccoast__{0x03A556}_1_dlccoast__{0x056F80}_dlccoast__{0x056F7F}_dlccoast__{0x056F7E}_dlccoast__{0x056F7C}_dlccoast__{0x056F7B}_dlccoast__{0x056F7D}") { Price = GetPrice(60), Description = "Armor can only be equipped if the player is not in power armor.", Category = "Use Armor" },
            new Effect("Rescue Diver Suit", $"playeraddarmor_0_1_dlccoast__{0x04FA7D}") { Price = GetPrice(30), Description = "Armor can only be equipped if the player is not in power armor.", Category = "Use Armor" },

            #endregion

            #region Spawn Neutral NPC (category)

            new Effect("Eye Bot", $"playerplaceactoratme_{0xEFBB4}_1_0_0_0_{neutralSpawnDistance}_crowdcontrol__{0x01356A}") { Price = GetPrice(10), Category = "Spawn Neutral NPC" },
            new Effect("Radstag", $"playerplaceactoratme_{0x90E57}_1_0_0_0_{neutralSpawnDistance}_crowdcontrol__{0x00AE62}") { Price = GetPrice(10), Category = "Spawn Neutral NPC" },
            new Effect("House Cat", $"playerplaceactoratme_crowdcontrol__{0x006332}_1_0_0_0_{neutralSpawnDistance}_crowdcontrol__{0x00AE60}") { Price = GetPrice(10), Category = "Spawn Neutral NPC" },
            new Effect("Brahmin", $"playerplaceactoratme_{0x00020480}_1_0_0_0_{neutralSpawnDistance}_crowdcontrol__{0x00AE61}") { Price = GetPrice(10), Category = "Spawn Neutral NPC" },
            new Effect("Gazelle", $"playerplaceactoratme_dlcnukaworld__{0x00D35B}_1_0_0_0_{neutralSpawnDistance}_crowdcontrol__{0x00AE62}") { Price = GetPrice(10), Category = "Spawn Neutral NPC" },
            new Effect("Rad Rabbits (10)", $"playerplaceactoratme_dlccoast__{0x03DDE2}_10_0_0_0_{neutralSpawnDistance}_{0xC1AD1}") { Price = GetPrice(20), SessionCooldiown = SITimeSpan.FromSeconds(10), Category = "Spawn Neutral NPC" },
            new Effect("Rad Chickens (5)", $"playerplaceactoratme_dlccoast__{0x03FD6A}_5_0_0_0_{neutralSpawnDistance}_crowdcontrol__{0x00F1E6}") { Price = GetPrice(20), SessionCooldiown = SITimeSpan.FromSeconds(5), Category = "Spawn Neutral NPC" },

            #endregion

            #region Spawn Hostile NPC (category)

            new Effect("Protectrons (2)", $"playerplaceactoratme_1075975_2_0_0_2_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Hostile NPC" },
            new Effect("Feral Ghouls (5)", $"playerplaceactoratme_480055_5_0_0_0_{hostileSpawnDistanceFar}") { Price = GetPrice(20), Category = "Spawn Hostile NPC" },
            new Effect("Glowing Ones (3)", $"playerplaceactoratme_866799_3_0_0_0_{hostileSpawnDistanceFar}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Alien", $"playerplaceactoratme_{0x00184C51}_1_0_0_2_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Hostile NPC" },
            new Effect("Glowing Bloatflies (3)", $"playerplaceactoratme_{0x001423B2}_3_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(60), Category = "Spawn Hostile NPC" },
            new Effect("Legendary Glowing Ones (2)", $"playerplaceactoratme_1463670_2_0_0_0_{hostileSpawnDistanceFar}") { Price = GetPrice(60), Category = "Spawn Hostile NPC" },
            new Effect("Raiders (4)", $"playerplaceactoratme_166283_4_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Hostile NPC" },
            new Effect("Gunners (4)", $"playerplaceactoratme_911721_4_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Feral Ghoul Horde (30)", "playerplaceactoratme_480055_30") { Price = GetPrice(100), SessionCooldiown = SITimeSpan.FromMinutes(4), Category = "Spawn Hostile NPC" },
            new Effect("Synths (3)", $"playerplaceactoratme_480058_3_0_0_2_{hostileSpawnDistance}") { Price = GetPrice(30), Category = "Spawn Hostile NPC" },
            new Effect("Courser", $"playerplaceactoratme_1452270_1_0_0_2_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Mr. Gutsys (2)", $"playerplaceactoratme_955027_2_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Super Mutants (2)", $"playerplaceactoratme_480053_2_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Super Mutant Suiciders (3)", $"playerplaceactoratme_1355352_3_0_1_0_{hostileSpawnDistanceSwarm}") { Price = GetPrice(100), Description = "Super mutant suiciders can only be spawned outdoors.", Category = "Spawn Hostile NPC" },
            new Effect("Brotherhood of Steel", $"playerplaceactoratme_1442143_1_0_0_2_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Mirelurks (2)", $"playerplaceactoratme_1695193_2_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(50), Category = "Spawn Hostile NPC" },
            new Effect("Yao Guai", $"playerplaceactoratme_736638_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(50), Category = "Spawn Hostile NPC" },
            new Effect("Rad Scorpion", $"playerplaceactoratme_134024_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(80), Category = "Spawn Hostile NPC" },
            new Effect("Sentry Bot", $"playerplaceactoratme_1017367_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(100), Category = "Spawn Hostile NPC" },
            new Effect("Deathclaw", $"playerplaceactoratme_480056_1_0_1_0_{hostileSpawnDistance}") { Price = GetPrice(100), Description = "A deathclaw can only be spawned outdoors.", Category = "Spawn Hostile NPC" },
            new Effect("Behemoth", $"playerplaceactoratme_1227134_1_0_1_2_{hostileSpawnDistance}") { Price = GetPrice(150), Description = "A behemoth can only be spawned outdoors.", Category = "Spawn Hostile NPC" },

            new Effect("Brahmiluff Longhorn", $"playerplaceactoratme_dlcnukaworld__{0x00D353}_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(10), Category = "Spawn Hostile NPC" },
            new Effect("Ghoulrilla", $"playerplaceactoratme_dlcnukaworld__{0x00D347}_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(10), Category = "Spawn Hostile NPC" },
            new Effect("Rad-rats (10)", $"playerplaceactoratme_dlcnukaworld__{0x0201EC}_10_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), SessionCooldiown = SITimeSpan.FromMinutes(1), Category = "Spawn Hostile NPC" },
            new Effect("Plagued Rad-rats (3)", $"playerplaceactoratme_dlcnukaworld__{0x03B8A6}_3_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(60), Category = "Spawn Hostile NPC" },
            new Effect("Gatorclaws (2)", $"playerplaceactoratme_dlcnukaworld__{0x00D357}_2_0_1_0_{hostileSpawnDistance}") { Price = GetPrice(60), Description = "Gatorclaws can only be spawned outdoors.", Category = "Spawn Hostile NPC" },
            new Effect("Soldier Ants (5)", $"playerplaceactoratme_dlcnukaworld__{0x0201EA}_5_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Glowing Ants (5)", $"playerplaceactoratme_dlcnukaworld__{0x0201EB}_5_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(60), Category = "Spawn Hostile NPC" },
            new Effect("Flying Glowing Ants (5)", $"playerplaceactoratme_dlcnukaworld__{0x03B57D}_5_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(60), Category = "Spawn Hostile NPC" },
            new Effect("Cave Crickets (5)", $"playerplaceactoratme_dlcnukaworld__{0xAB02}_5_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Glowing Cave Crickets (5)", $"playerplaceactoratme_dlcnukaworld__{0x0201E5}_5_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(60), Category = "Spawn Hostile NPC" },
            new Effect("Nukalurk Queen", $"playerplaceactoratme_dlcnukaworld__{0x3d661}_1_0_1_2_{hostileSpawnDistance}") { Price = GetPrice(200), Description = "Nukalurk Queen can only be spawned outdoors.", Category = "Spawn Hostile NPC" },
            new Effect("Bloodworms (5)", $"playerplaceactoratme_dlcnukaworld__{0xa1a7}_5_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(20), SessionCooldiown = SITimeSpan.FromMinutes(1), Category = "Spawn Hostile NPC" },
            new Effect("Nukatrons (2)", $"playerplaceactoratme_dlcnukaworld__{0x01F5F9}_2_0_0_2_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Hostile NPC" },
            new Effect("Galactrons (2)", $"playerplaceactoratme_dlcnukaworld__{0x03290A}_2_0_0_2_{hostileSpawnDistance}") { Price = GetPrice(30), Category = "Spawn Hostile NPC" },
            new Effect("Astro-Gutsys (2)", $"playerplaceactoratme_dlcnukaworld__{0x01FAF4}_2_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Space Sentry Bot", $"playerplaceactoratme_dlcnukaworld__{0x01F5FE}_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(100), Category = "Spawn Hostile NPC" },

            new Effect("Robobrains (2)", $"playerplaceactoratme_dlcrobot__{0x00444F}_2_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Swarmbots (4)", $"playerplaceactoratme_dlcrobot__{0x0026EC}_4_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(60), Category = "Spawn Hostile NPC" },
            new Effect("Tankbot", $"playerplaceactoratme_dlcrobot__{0x0026EE}_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(100), Category = "Spawn Hostile NPC" },
            new Effect("Junkbots (2)", $"playerplaceactoratme_dlcrobot__{0x0026ED}_2_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Hostile NPC" },
            new Effect("Scrapbot", $"playerplaceactoratme_dlcrobot__{0x0036CA}_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Rust Devils (4)", $"playerplaceactoratme_dlcrobot__{0x005050}_4_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
            new Effect("Rust Devil Bots (4)", $"playerplaceactoratme_dlcrobot__{0x004387}_4_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(80), Category = "Spawn Hostile NPC" },
            
            new Effect("Wolfs (5)", $"playerplaceactoratme_dlccoast__{0x0140F8}_5_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Hostile NPC" },
            new Effect("Angler", $"playerplaceactoratme_dlccoast__{0x009590}_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(110), Category = "Spawn Hostile NPC" },
            new Effect("Gulper", $"playerplaceactoratme_dlccoast__{0x02793A}_1_0_0_0_{hostileSpawnDistance}") { Price = GetPrice(90), Category = "Spawn Hostile NPC" },
            new Effect("Fog Crawler", $"playerplaceactoratme_dlccoast__{0x00A2D4}_1_0_1_0_{hostileSpawnDistance}") { Price = GetPrice(110), Description = "A fog crawler can only be spawned outdoors.", Category = "Spawn Hostile NPC" },
            new Effect("Hermit Crab", $"playerplaceactoratme_dlccoast__{0x04B34F}_1_0_1_0_{hostileSpawnDistance}") { Price = GetPrice(150), Description = "A hermit crab can only be spawned outdoors.", Category = "Spawn Hostile NPC" },

            #endregion

            #region Spawn Friendly NPC (category)

            new Effect("Eye Bots (3)", $"playerplaceactoratme_981940_3_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(10), Category = "Spawn Friendly NPC" },
            new Effect("Protectrons (5)", $"playerplaceactoratme_1075975_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Friendly NPC" },
            new Effect("Feral Ghouls (5)", $"playerplaceactoratme_480055_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Friendly NPC" },
            new Effect("Raiders (4)", $"playerplaceactoratme_166283_4_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Friendly NPC" },
            new Effect("Gunners (4)", $"playerplaceactoratme_911721_4_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Synths (3)", $"playerplaceactoratme_480058_3_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(30), Category = "Spawn Friendly NPC" },
            new Effect("Courser", $"playerplaceactoratme_1452270_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Mr. Gutsys (2)", $"playerplaceactoratme_955027_2_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Super Mutants (2)", $"playerplaceactoratme_480053_2_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Brotherhood of Steel", $"playerplaceactoratme_1442143_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Mirelurk (2)", $"playerplaceactoratme_1695193_2_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(50), Category = "Spawn Friendly NPC" },
            new Effect("Yao Guai", $"playerplaceactoratme_736638_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(50), Category = "Spawn Friendly NPC" },
            new Effect("Rad Scorpion", $"playerplaceactoratme_134024_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(80), Category = "Spawn Friendly NPC" },
            new Effect("Sentry Bot", $"playerplaceactoratme_1017367_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(100), Category = "Spawn Friendly NPC" },
            new Effect("Deathclaw", $"playerplaceactoratme_480056_1_0_1_1_{hostileSpawnDistance}") { Price = GetPrice(100), Description = "A deathclaw can only be spawned outdoors.", Category = "Spawn Friendly NPC" },
            new Effect("Behemoth", $"playerplaceactoratme_1227134_1_0_1_1_{hostileSpawnDistance}") { Price = GetPrice(200), Description = "A behemoth can only be spawned outdoors.", Category = "Spawn Friendly NPC" },

            new Effect("Rad-rats (5)", $"playerplaceactoratme_dlcnukaworld__{0x0201EC}_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(30), SessionCooldiown = SITimeSpan.FromMinutes(1), Category = "Spawn Friendly NPC" },
            new Effect("Gatorclaws (2)", $"playerplaceactoratme_dlcnukaworld__{0x00D357}_2_0_1_1_{hostileSpawnDistance}") { Price = GetPrice(60), Description = "Gatorclaws can only be spawned outdoors.", Category = "Spawn Friendly NPC" },
            new Effect("Soldier Ants (5)", $"playerplaceactoratme_dlcnukaworld__{0x0201EA}_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Cave Crickets (5)", $"playerplaceactoratme_dlcnukaworld__{0xAB02}_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Bloodworms (5)", $"playerplaceactoratme_dlcnukaworld__{0xa1a7}_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), SessionCooldiown = SITimeSpan.FromMinutes(1), Category = "Spawn Friendly NPC" },
            new Effect("Nukatrons (5)", $"playerplaceactoratme_dlcnukaworld__{0x01F5F9}_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Friendly NPC" },
            new Effect("Galactrons (3)", $"playerplaceactoratme_dlcnukaworld__{0x03290A}_3_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Friendly NPC" },
            new Effect("Astro-Gutsys (2)", $"playerplaceactoratme_dlcnukaworld__{0x01FAF4}_2_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Space Sentry Bot", $"playerplaceactoratme_dlcnukaworld__{0x01F5FE}_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(100), Category = "Spawn Friendly NPC" },

            new Effect("Robobrains (2)", $"playerplaceactoratme_dlcrobot__{0x00444F}_2_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Swarmbots (4)", $"playerplaceactoratme_dlcrobot__{0x0026EC}_4_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(60), Category = "Spawn Friendly NPC" },
            new Effect("Tankbot", $"playerplaceactoratme_dlcrobot__{0x0026EE}_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(100), Category = "Spawn Friendly NPC" },
            new Effect("Junkbots (5)", $"playerplaceactoratme_dlcrobot__{0x0026ED}_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Friendly NPC" },
            new Effect("Scrapbot", $"playerplaceactoratme_dlcrobot__{0x0036CA}_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Rust Devils (4)", $"playerplaceactoratme_dlcrobot__{0x005050}_4_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(40), Category = "Spawn Friendly NPC" },
            new Effect("Rust Devil Bots (4)", $"playerplaceactoratme_dlcrobot__{0x004387}_4_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(80), Category = "Spawn Friendly NPC" },

            new Effect("Wolfs (5)", $"playerplaceactoratme_dlccoast__{0x0140F8}_5_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(20), Category = "Spawn Friendly NPC" },
            new Effect("Angler", $"playerplaceactoratme_dlccoast__{0x009590}_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(110), Category = "Spawn Friendly NPC" },
            new Effect("Gulper", $"playerplaceactoratme_dlccoast__{0x02793A}_1_0_0_1_{hostileSpawnDistance}") { Price = GetPrice(90), Category = "Spawn Friendly NPC" },
            new Effect("Fog Crawler", $"playerplaceactoratme_dlccoast__{0x00A2D4}_1_0_1_1_{hostileSpawnDistance}") { Price = GetPrice(110), Description = "A fog crawler can only be spawned outdoors.", Category = "Spawn Friendly NPC" },

            #endregion

            #region Spawn Follower NPC (category)

            new Effect("Assaultron", "playerplaceactoratmefollower_2398662_1") { Price = GetPrice(150), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time.", Category = "Spawn Follower NPC" },
            new Effect("Brotherhood of Steel", $"playerplaceactoratmefollower_{0x16015F}_1") { Price = GetPrice(100), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time.", Category = "Spawn Follower NPC" },
            new Effect("Courser", $"playerplaceactoratmefollower_1452270_1") { Price = GetPrice(100), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time.", Category = "Spawn Follower NPC" },
            new Effect("Mr. Gutsy", "playerplaceactoratmefollower_2398644_1") { Price = GetPrice(100), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time.", Category = "Spawn Follower NPC" },
            new Effect("Sentry Bot (outdoors)", "playerplaceactoratmefollower_1017367_1_1") { Price = GetPrice(200), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time. This follower can only be spawned outdoors and will not follow the player when the player enters an indoor area.", Category = "Spawn Follower NPC" },
            new Effect("Super Mutant", $"playerplaceactoratmefollower_{0x117d85}_1") { Price = GetPrice(50), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time.", Category = "Spawn Follower NPC" },

            new Effect("Space Sentry Bot (outdoors)", $"playerplaceactoratmefollower_dlcnukaworld__{0x01F5FE}_1_1") { Price = GetPrice(200), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time.", Category = "Spawn Follower NPC" },
            new Effect("Novatron", $"playerplaceactoratmefollower_dlcnukaworld__{0x01FAF8}_1") { Price = GetPrice(150), Description = "Followers will follow the player and assist them in combat. A maximum of 3 followers can be spawned at a time.", Category = "Spawn Follower NPC" },

            new Effect("Turretbot", $"playerplaceactoratmefollower_dlcrobot__{0x007843}_1") { Price = GetPrice(200), Category = "Spawn Follower NPC" },
            new Effect("Duelbot", $"playerplaceactoratmefollower_dlcrobot__{0x007844}_1") { Price = GetPrice(150), Category = "Spawn Follower NPC" },

            #endregion

            #region Controls (category)

            new Effect("Auto Save", "autosave_0_1") { Price = GetPrice(10), Category = "Controls" },
            new Effect("Disable Fast Travel", "controlsfasttraveloff_0_60") { Duration = SITimeSpan.FromSeconds(60), Price = GetPrice(50), Description = "Fast travel will be disabled for 1 minute.", Category = "Controls" },
            new Effect("Disable VATS and PipBoy", "controlsvatmenusoff_0_60") { Duration = SITimeSpan.FromSeconds(60), Price = GetPrice(50), Description = "VATS and PipBoy will be disabled for 1 minute.", Category = "Controls" },
            new Effect("Launch Player", "playerlaunch_0_20_100_50") { Price = GetPrice(20), Category = "Controls" },
            new Effect("Switch Camera to First Person", "playercamerafirstperson_0_1") { Price = GetPrice(10), Category = "Controls" },
            new Effect("Switch Camera to Third Person", "playercamerathirdperson_0_1") { Price = GetPrice(10), Category = "Controls" },

            #endregion

            #region Fast Travel (category)

            new Effect("Sanctuary Hills", "fasttravel_469576_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Concord", "fasttravel_532792_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Diamond City", "fasttravel_117461_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Goodneighbor", "fasttravel_140840_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("The Castle", "fasttravel_179365_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Cambridge Police Station", "fasttravel_252598_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Bunker Hill", "fasttravel_178304_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Vault 111", "fasttravel_651890_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Vault 81", "fasttravel_292432_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Fort Hagen", "fasttravel_151450_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Boston Airport", "fasttravel_2211691_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("The Glowing Sea (Atom's Glow)", "fasttravel_712073_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("The Glowing Sea (Virgil's Laboratory)", "fasttravel_738900_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Mass Fusion", "fasttravel_178238_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Abernathy Farm", "fasttravel_456148_1") { Price = GetPrice(100), Category = "Fast Travel" },
            new Effect("Spectacle Island", $"fasttravel_{0x2CF9E}_1") { Price = GetPrice(100), Category = "Fast Travel" },

            #endregion

            #region Weather (category)

            new Effect("Clear", "setweather_177450_1_clear") { Price = GetPrice(20), Category = "Weather" },
            new Effect("Foggy", "setweather_1848435_1_foggy") { Price = GetPrice(20), Category = "Weather" },
            new Effect("Dusty", "setweather_2056609_1_dusty") { Price = GetPrice(20), Category = "Weather" },
            new Effect("Rain", "setweather_1877988_1_raining") { Price = GetPrice(20), Category = "Weather" },
            new Effect("Rad Storm", "setweather_1850718_1_stormy") { Price = GetPrice(20), Category = "Weather" },
            new Effect("Polluted", "setweather_2011903_1_polluted") { Price = GetPrice(20), Category = "Weather" },

            #endregion

            #region Progression (category)

            new Effect("Add XP to level up", "givexp_0_1") { Price = GetPrice(50), Category = "Progression" },
            new Effect("Increase Strength +1", "changeplayerstrength_1_1") { Price = GetPrice(20), Category = "Progression" },
            new Effect("Increase Perception +1", "changeplayerperception_1_1") { Price = GetPrice(20), Category = "Progression" },
            new Effect("Increase Endurance +1", "changeplayerendurance_1_1") { Price = GetPrice(20), Category = "Progression" },
            new Effect("Increase Charisma +1", "changeplayercharisma_1_1") { Price = GetPrice(20), Category = "Progression" },
            new Effect("Increase Intelligence +1", "changeplayerintelligence_1_1") { Price = GetPrice(20), Category = "Progression" },
            new Effect("Increase Agility +1", "changeplayeragility_1_1") { Price = GetPrice(20), Category = "Progression" },
            new Effect("Increase Luck +1", "changeplayerluck_1_1") { Price = GetPrice(20), Category = "Progression" },
            new Effect("Decrease Strength to 1", "changeplayerstrength_0_1") { Price = GetPrice(100), Category = "Progression" },
            new Effect("Decrease Perception to 1", "changeplayerperception_0_1") { Price = GetPrice(100), Category = "Progression" },
            new Effect("Decrease Endurance to 1", "changeplayerendurance_0_1") { Price = GetPrice(100), Category = "Progression" },
            new Effect("Decrease Charisma to 1", "changeplayercharisma_0_1") { Price = GetPrice(100), Category = "Progression" },
            new Effect("Decrease Intelligence to 1", "changeplayerintelligence_0_1") { Price = GetPrice(100), Category = "Progression" },
            new Effect("Decrease Agility to 1", "changeplayeragility_0_1") { Price = GetPrice(100), Category = "Progression" },
            new Effect("Decrease Luck to 1", "changeplayerluck_0_1") { Price = GetPrice(100), Category = "Progression" },

            #endregion
            
            #region Remove (category)

            new Effect("Remove Equipped Weapon", "removeequippedweapon_0_1") { Price = GetPrice(100), Description = "The currently equipped weapon will be unequipped and removed from the player's inventory.", Category = "Remove" },
            new Effect("Remove Equipped Power Armor", "removeequippedpowerarmor_0_1") { Price = GetPrice(300), Description = "The player will exit the currently equipped power armor and the power armor will be stripped of all components down to its frame.", Category = "Remove" },

            #endregion

            #region Set Time (category)

            new Effect("Set Time to Morning", "setgamehour_7_1") { Price = GetPrice(25), Category = "Set Time" },
            new Effect("Set Time to Afternoon", "setgamehour_12_1") { Price = GetPrice(25), Category = "Set Time" },
            new Effect("Set Time to Evening", "setgamehour_19_1") { Price = GetPrice(25), Category = "Set Time" },
            new Effect("Set Time to Midnight", "setgamehour_0_1") { Price = GetPrice(25), Category = "Set Time" },

            #endregion

            #region Screen (category)

            new Effect("Fade the Screen", "fadeoutscreen_0_2") { Duration = SITimeSpan.FromSeconds(2), Price = GetPrice(50), Category = "Screen Effects" },
            new Effect("Screen Blood", "screenblood_0_50") { Price = GetPrice(10), Category = "Screen Effects" },
            new Effect("Shake Camera", "shakecamera2_0_5_1000000") { Duration = SITimeSpan.FromSeconds(5), Price = GetPrice(10), Category = "Screen Effects" },
            new Effect("Deathclaw Scare", $"scare_{0x43354}_1_100_0_10") { Price = GetPrice(25), Category = "Screen Effects" },
            new Effect("Behemoth Scare", $"scare_{0x21C3E4}_1_100_4000_100") { Price = GetPrice(50), Category = "Screen Effects" },
            new Effect("Impact Scare", $"scare_{0x24995D}_1_1000000_600_1000") { Price = GetPrice(15), Category = "Screen Effects" },

            #endregion

            #region Player Limbs (category)

            new Effect("Cripple Head", $"playerdamageav_{0x36C}_100_1") { Price = GetPrice(10), Description = "The player can only be crippled while not wearing power armor.", Category = "Player Limbs" },
            new Effect("Cripple Left Arm", $"playerdamageav_{0x36E}_100_1") { Price = GetPrice(10), Description = "The player can only be crippled while not wearing power armor.", Category = "Player Limbs" },
            new Effect("Cripple Right Arm", $"playerdamageav_{0x36F}_100_1") { Price = GetPrice(10), Description = "The player can only be crippled while not wearing power armor.", Category = "Player Limbs" },
            new Effect("Cripple Left Leg", $"playerdamageav_{0x370}_100_1") { Price = GetPrice(10), Description = "The player can only be crippled while not wearing power armor.", Category = "Player Limbs" },
            new Effect("Cripple Right Leg", $"playerdamageav_{0x371}_100_1") { Price = GetPrice(10), Description = "The player can only be crippled while not wearing power armor.", Category = "Player Limbs" },

            #endregion

            #region Addictions (category)

            new Effect("Give Alcohol Addiction", $"playerequipaddiction_{0x01005B99}_1") { Price = GetPrice(25), Category = "Addictions" },
            new Effect("Give Buffout Addiction", $"playerequipaddiction_{0x01005B9B}_1") { Price = GetPrice(25), Category = "Addictions" },
            new Effect("Give Jet Addiction", $"playerequipaddiction_{0x01007265}_1") { Price = GetPrice(25), Category = "Addictions" },
            new Effect("Give Med-X Addiction", $"playerequipaddiction_{0x01005B9D}_1") { Price = GetPrice(25), Category = "Addictions" },
            new Effect("Give Mentats Addiction", $"playerequipaddiction_{0x01005B9F}_1") { Price = GetPrice(25), Category = "Addictions" },
            new Effect("Give Psycho Addiction", $"playerequipaddiction_{0x01005BA1}_1") { Price = GetPrice(25), Category = "Addictions" },

            #endregion

        };
    }
}