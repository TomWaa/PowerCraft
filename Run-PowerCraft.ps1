# =================================================================================================================================
#
# NAME: Run-PowerCraft.ps1
#
# AUTHOR : Thomas Waaler
# DATE   : 
# VERSION: 1.0.0
# COMMENT: PowerShell game PowerCraft
#
# =================================================================================================================================
# CHANGELOG
# =================================================================================================================================
# DATE          VERSION     BY                        COMMENT
#               1.0.0       Thomas Waaler             Første utkast
# =================================================================================================================================

<#

 ▄ ▀
█ ░ ▒ ▓

┌───────────────┬───────┬─────────┐┌───────────────┬───────┬─────────┐
|     ▄▄▄▄▄     |Slot  0|Count   1||            ▄  |Slot  1|Count   4| 
|    ▀▄▄▄▄ ▀▀█  ├───────┴─────────┤|          ▄▀▄▀ ├───────┴─────────┤
|        ▄▀▄ ▀▄ |Wooden Pickaxe   ||        ▄▀▄▀   |Stick            |
|      ▄▀▄▀ █ █ ├─────────────────┘|      ▄▀▄▀     ├─────────────────┘
|    ▄▀▄▀   █ █ |                  |    ▄▀▄▀       |
|  ▄▀▄▀      ▀  |                  |  ▄▀▄▀         |
| ▀▄▀           |                  | ▀▄▀           |
└───────────────┘                  └───────────────┘
┌───────────────┬───────┬─────────┐
|█▓▓██▓█        |
|██▓▓▓▓█        |
|▓▒▓▓▒█▓        |
|▓▒█▓▒▒▓        |
|▓▓█▓▒▒█        |
|█▓▓▓▓▒█        |
|█▓▓█▓▓██       |
└───────────────┘
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
 
#Set Error Action to Stop
$ErrorActionPreference = "Stop"

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$configFilePath = "C:\Lokal Data\ConfigFiles\powercraft.xml"
$defaultItemsFilePath = "C:\Lokal Data\ConfigFiles\powercraft_items.xml"
$entityFilePath = "C:\Lokal Data\ConfigFiles\powercraft_entities.xml"
$actionMessage = ""

$commandList = @(
    "Help <Command>"
    "Get Commands"
    "Open <Chest|Furnace>"
    "Open Chest <Chest name>"
    "Open Furnace <Furnace name>"
    "Rename <Chest|Furnace>"
    "Rename Chest <Chest name> <New chest name>"
    "Rename Furnace <Furnace name> <New furnace name>"
    "List <Chest|Furnace|Inventory>"
    "Eat <Item name>"
    "Equip <Item name|Block name>"
    "Craft <Item name|Block name>"
    "Smelt <Item name|Block name> <Furnace name>"
    "Unequip <Hand|Helmet|Chestplate|Leggings|Boots|Armor|All>"
    "Chop <Tree>"
    "Mine <Ground|Cave|Mineshaft|Strip>"
    "Refresh"
    "Save"
    "Exit"
)

[xml]$configList = ""
[xml]$itemList = ""
[xml]$entityList = ""

#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Load-ConfigFile {
    param(
        $Path
    )

    #Sjekk om configfilen finnes
    if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
        #Sjekk om "Lokal Data" finnes
        if (-not (Test-Path -Path "C:\Lokal Data" -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path "C:\" -Name "Lokal Data" | Out-Null }

        #Sjekk om "ConfigFiles" finnes
        if (-not (Test-Path -Path "C:\Lokal Data\ConfigFiles" -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path "C:\Lokal Data" -Name "ConfigFiles" | Out-Null }        
        
        #Opprett default configfil
        [xml]$Doc = New-Object System.Xml.XmlDocument

        #Description
        $dec = $Doc.CreateXmlDeclaration("1.0", "UTF-8", $null)
        $Doc.AppendChild($dec) | Out-Null

        #Root element "XML"
        $root = $Doc.CreateNode("element", "xml", $null)
        $Doc.AppendChild($root) | Out-Null

            #Playerstats
            $playerStats = $Doc.CreateNode("element", "playerstats", $null)
            $root.AppendChild($playerStats) | Out-Null

                #Playername
                $playerName = $Doc.CreateNode("element", "playername", $null)
                $playerName.InnerText = Read-Host "Playername"
                $playerStats.AppendChild($playerName) | Out-Null

                #Health
                $health = $Doc.CreateNode("element", "health", $null)
                $health.InnerText = "10"
                $playerStats.AppendChild($health) | Out-Null

                #Level
                $level = $Doc.CreateNode("element", "level", $null)
                $level.InnerText = "0"
                $playerStats.AppendChild($level) | Out-Null

                #ExperiencePoints
                $xp = $Doc.CreateNode("element", "experiencepoints", $null)
                $xp.InnerText = "0"
                $playerStats.AppendChild($xp) | Out-Null
                
                #Hand
                $hand = $Doc.CreateNode("element", "hand", $null)
                $handItemCount = $Doc.CreateAttribute("ItemCount")
                $handItemCount.Value = "0"
                $hand.Attributes.Append($handItemCount) | Out-Null
                $playerStats.AppendChild($hand) | Out-Null

                #Inventory
                $inventory = $Doc.CreateNode("element", "inventory", $null)
                $playerStats.AppendChild($inventory) | Out-Null

                for ($i = 0; $i -lt 27; $i++) {
                    $slot = $Doc.CreateNode("element", "slot$($i)", $null)
                    $slotItemCount = $Doc.CreateAttribute("ItemCount")
                    $slotItemCount.Value = "0"
                    $slot.Attributes.Append($slotItemCount) | Out-Null
                    $inventory.AppendChild($slot) | Out-Null
                }

                #Armor
                $armor = $Doc.CreateNode("element", "armor", $null)
                $playerStats.AppendChild($armor) | Out-Null

                    #Armor helmet
                    $armorHelmet = $Doc.CreateNode("element", "helmet", $null)
                    $armorHelmetEquiped = $Doc.CreateAttribute("equipped")
                    $armorHelmetEquiped.Value = "0"
                    $armorHelmet.Attributes.Append($armorHelmetEquiped) | Out-Null
                    $armorHelmetType = $Doc.CreateAttribute("type")
                    $armorHelmetType.Value = ""
                    $armorHelmet.Attributes.Append($armorHelmetType) | Out-Null
                    $armor.AppendChild($armorHelmet) | Out-Null

                    #Armor chestplate
                    $armorChestplate = $Doc.CreateNode("element", "chestplate", $null)
                    $armorChestplateEquiped = $Doc.CreateAttribute("equipped")
                    $armorChestplateEquiped.Value = "0"
                    $armorChestplate.Attributes.Append($armorChestplateEquiped) | Out-Null
                    $armorChestplateType = $Doc.CreateAttribute("type")
                    $armorChestplateType.Value = ""
                    $armorChestplate.Attributes.Append($armorChestplateType) | Out-Null
                    $armor.AppendChild($armorChestplate) | Out-Null

                    #Armor leggings
                    $armorLeggings = $Doc.CreateNode("element", "leggings", $null)
                    $armorLeggingsEquiped = $Doc.CreateAttribute("equipped")
                    $armorLeggingsEquiped.Value = "0"
                    $armorLeggings.Attributes.Append($armorLeggingsEquiped) | Out-Null
                    $armorLeggingsType = $Doc.CreateAttribute("type")
                    $armorLeggingsType.Value = ""
                    $armorLeggings.Attributes.Append($armorLeggingsType) | Out-Null
                    $armor.AppendChild($armorLeggings) | Out-Null

                    #Armor boots
                    $armorBoots = $Doc.CreateNode("element", "boots", $null)
                    $armorBootsEquiped = $Doc.CreateAttribute("equipped")
                    $armorBootsEquiped.Value = "0"
                    $armorBoots.Attributes.Append($armorBootsEquiped) | Out-Null
                    $armorBootsType = $Doc.CreateAttribute("type")
                    $armorBootsType.Value = ""
                    $armorBoots.Attributes.Append($armorBootsType) | Out-Null
                    $armor.AppendChild($armorBoots) | Out-Null

                #Chests
                $chests = $Doc.CreateNode("element", "chests", $null)
                $playerStats.AppendChild($chests) | Out-Null

                #Furnaces
                $furnaces = $Doc.CreateNode("element", "furnaces", $null)
                $playerStats.AppendChild($furnaces) | Out-Null

            #GameSettings
            $gamesettings = $Doc.CreateNode("element", "gamesettings", $null)
            $root.AppendChild($gamesettings) | Out-Null

            #Default stats
            $defualtStats = $Doc.CreateNode("element", "defaultstats", $null)
            $root.AppendChild($defualtStats) | Out-Null

        $Doc.Save($Path) | Out-Null

        [xml]$XmlDocument = Get-Content -Path $Path        
        $script:configList = $XmlDocument
        Load-MainHud
    } else { #Configfilen finnes
        [xml]$XmlDocument = Get-Content -Path $Path        
        $script:configList = $XmlDocument
        Load-MainHud
    }
}

function Load-ItemList {
    param(
        $Path
    )

    if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
        #Sjekk om "Lokal Data" finnes
        if (-not (Test-Path -Path "C:\Lokal Data" -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path "C:\" -Name "Lokal Data" | Out-Null }

        #Sjekk om "ConfigFiles" finnes
        if (-not (Test-Path -Path "C:\Lokal Data\ConfigFiles" -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path "C:\Lokal Data" -Name "ConfigFiles" | Out-Null }        
        
        #Opprett default configfil
        [xml]$Doc = New-Object System.Xml.XmlDocument

        #Description
        $dec = $Doc.CreateXmlDeclaration("1.0", "UTF-8", $null)
        $Doc.AppendChild($dec) | Out-Null

        #Root element "XML"
        $root = $Doc.CreateNode("element", "xml", $null)
        $Doc.AppendChild($root) | Out-Null

        #Items
        $items = $Doc.CreateNode("element", "items", $null)
        $root.AppendChild($items) | Out-Null
            
            #==============================
            #=========== Helmet ===========
            #==============================
            #Leather Helmet
            $helmetLeather = $Doc.CreateNode("element", "helmetleather", $null)
            $helmetLeatherName = $Doc.CreateAttribute("name")
            $helmetLeatherName.Value = "Leather Helmet"
            $helmetLeather.Attributes.Append($helmetLeatherName) | Out-Null
            $helmetLeatherDurability = $Doc.CreateAttribute("durability")
            $helmetLeatherDurability.Value = "56"
            $helmetLeather.Attributes.Append($helmetLeatherDurability) | Out-Null
            $helmetLeatherProtection = $Doc.CreateAttribute("protection")
            $helmetLeatherProtection.Value = "1"
            $helmetLeather.Attributes.Append($helmetLeatherProtection) | Out-Null
            $items.AppendChild($helmetLeather) | Out-Null

            #Iron Helmet
            $helmetIron = $Doc.CreateNode("element", "helmetiron", $null)
            $helmetIronName = $Doc.CreateAttribute("name")
            $helmetIronName.Value = "Iron Helmet"
            $helmetIron.Attributes.Append($helmetIronName) | Out-Null
            $helmetIronDurability = $Doc.CreateAttribute("durability")
            $helmetIronDurability.Value = "166"
            $helmetIron.Attributes.Append($helmetIronDurability) | Out-Null
            $helmetIronProtection = $Doc.CreateAttribute("protection")
            $helmetIronProtection.Value = "2"
            $helmetIron.Attributes.Append($helmetIronProtection) | Out-Null
            $items.AppendChild($helmetIron) | Out-Null

            #Gold Helmet
            $helmetGold = $Doc.CreateNode("element", "helmetgold", $null)
            $helmetGoldName = $Doc.CreateAttribute("name")
            $helmetGoldName.Value = "Gold Helmet"
            $helmetGold.Attributes.Append($helmetGoldName) | Out-Null
            $helmetGoldDurability = $Doc.CreateAttribute("durability")
            $helmetGoldDurability.Value = "78"
            $helmetGold.Attributes.Append($helmetGoldDurability) | Out-Null
            $helmetGoldProtection = $Doc.CreateAttribute("protection")
            $helmetGoldProtection.Value = "2"
            $helmetGold.Attributes.Append($helmetGoldProtection) | Out-Null
            $items.AppendChild($helmetGold) | Out-Null

            #Diamond Helmet
            $helmetDiamond = $Doc.CreateNode("element", "helmetdiamond", $null)
            $helmetDiamondName = $Doc.CreateAttribute("name")
            $helmetDiamondName.Value = "Diamond Helmet"
            $helmetDiamond.Attributes.Append($helmetDiamondName) | Out-Null
            $helmetDiamondDurability = $Doc.CreateAttribute("durability")
            $helmetDiamondDurability.Value = "364"
            $helmetDiamond.Attributes.Append($helmetDiamondDurability) | Out-Null
            $helmetDiamondProtection = $Doc.CreateAttribute("protection")
            $helmetDiamondProtection.Value = "3"
            $helmetDiamond.Attributes.Append($helmetDiamondProtection) | Out-Null
            $items.AppendChild($helmetDiamond) | Out-Null

            #==============================
            #========= Chestplate =========
            #==============================
            #Leather Chestplate
            $chestplateLeather = $Doc.CreateNode("element", "chestplateleather", $null)
            $chestplateLeatherName = $Doc.CreateAttribute("name")
            $chestplateLeatherName.Value = "Leather Chestplate"
            $chestplateLeather.Attributes.Append($chestplateLeatherName) | Out-Null
            $chestplateLeatherDurability = $Doc.CreateAttribute("durability")
            $chestplateLeatherDurability.Value = "81"
            $chestplateLeather.Attributes.Append($chestplateLeatherDurability) | Out-Null
            $chestplateLeatherProtection = $Doc.CreateAttribute("protection")
            $chestplateLeatherProtection.Value = "3"
            $chestplateLeather.Attributes.Append($chestplateLeatherProtection) | Out-Null
            $items.AppendChild($chestplateLeather) | Out-Null

            #Iron Chestplate
            $chestplateIron = $Doc.CreateNode("element", "chestplateiron", $null)
            $chestplateIronName = $Doc.CreateAttribute("name")
            $chestplateIronName.Value = "Iron Chestplate"
            $chestplateIron.Attributes.Append($chestplateIronName) | Out-Null
            $chestplateIronDurability = $Doc.CreateAttribute("durability")
            $chestplateIronDurability.Value = "241"
            $chestplateIron.Attributes.Append($chestplateIronDurability) | Out-Null
            $chestplateIronProtection = $Doc.CreateAttribute("protection")
            $chestplateIronProtection.Value = "6"
            $chestplateIron.Attributes.Append($chestplateIronProtection) | Out-Null
            $items.AppendChild($chestplateIron) | Out-Null

            #Gold Chestplate
            $chestplateGold = $Doc.CreateNode("element", "chestplategold", $null)
            $chestplateGoldName = $Doc.CreateAttribute("name")
            $chestplateGoldName.Value = "Gold Chestplate"
            $chestplateGold.Attributes.Append($chestplateGoldName) | Out-Null
            $chestplateGoldDurability = $Doc.CreateAttribute("durability")
            $chestplateGoldDurability.Value = "113"
            $chestplateGold.Attributes.Append($chestplateGoldDurability) | Out-Null
            $chestplateGoldProtection = $Doc.CreateAttribute("protection")
            $chestplateGoldProtection.Value = "5"
            $chestplateGold.Attributes.Append($chestplateGoldProtection) | Out-Null
            $items.AppendChild($chestplateGold) | Out-Null

            #Diamond Chestplate
            $chestplateDiamond = $Doc.CreateNode("element", "chestplatediamond", $null)
            $chestplateDiamondName = $Doc.CreateAttribute("name")
            $chestplateDiamondName.Value = "Diamond Chestplate"
            $chestplateDiamond.Attributes.Append($chestplateDiamondName) | Out-Null
            $chestplateDiamondDurability = $Doc.CreateAttribute("durability")
            $chestplateDiamondDurability.Value = "529"
            $chestplateDiamond.Attributes.Append($chestplateDiamondDurability) | Out-Null
            $chestplateDiamondProtection = $Doc.CreateAttribute("protection")
            $chestplateDiamondProtection.Value = "8"
            $chestplateDiamond.Attributes.Append($chestplateDiamondProtection) | Out-Null
            $items.AppendChild($chestplateDiamond) | Out-Null

            #==============================
            #========== Leggings ==========
            #==============================
            #Leather Leggings
            $leggingsLeather = $Doc.CreateNode("element", "leggingsleather", $null)
            $leggingsLeatherName = $Doc.CreateAttribute("name")
            $leggingsLeatherName.Value = "Leather Leggings"
            $leggingsLeather.Attributes.Append($leggingsLeatherName) | Out-Null
            $leggingsLeatherDurability = $Doc.CreateAttribute("durability")
            $leggingsLeatherDurability.Value = "76"
            $leggingsLeather.Attributes.Append($leggingsLeatherDurability) | Out-Null
            $leggingsLeatherProtection = $Doc.CreateAttribute("protection")
            $leggingsLeatherProtection.Value = "2"
            $leggingsLeather.Attributes.Append($leggingsLeatherProtection) | Out-Null
            $items.AppendChild($leggingsLeather) | Out-Null

            #Iron Leggings
            $leggingsIron = $Doc.CreateNode("element", "leggingsiron", $null)
            $leggingsIronName = $Doc.CreateAttribute("name")
            $leggingsIronName.Value = "Iron Leggings"
            $leggingsIron.Attributes.Append($leggingsIronName) | Out-Null
            $leggingsIronDurability = $Doc.CreateAttribute("durability")
            $leggingsIronDurability.Value = "226"
            $leggingsIron.Attributes.Append($leggingsIronDurability) | Out-Null
            $leggingsIronProtection = $Doc.CreateAttribute("protection")
            $leggingsIronProtection.Value = "5"
            $leggingsIron.Attributes.Append($leggingsIronProtection) | Out-Null
            $items.AppendChild($leggingsIron) | Out-Null

            #Gold Leggings
            $leggingsGold = $Doc.CreateNode("element", "leggingsgold", $null)
            $leggingsGoldName = $Doc.CreateAttribute("name")
            $leggingsGoldName.Value = "Gold Leggings"
            $leggingsGold.Attributes.Append($leggingsGoldName) | Out-Null
            $leggingsGoldDurability = $Doc.CreateAttribute("durability")
            $leggingsGoldDurability.Value = "106"
            $leggingsGold.Attributes.Append($leggingsGoldDurability) | Out-Null
            $leggingsGoldProtection = $Doc.CreateAttribute("protection")
            $leggingsGoldProtection.Value = "3"
            $leggingsGold.Attributes.Append($leggingsGoldProtection) | Out-Null
            $items.AppendChild($leggingsGold) | Out-Null

            #Diamond Leggings
            $leggingsDiamond = $Doc.CreateNode("element", "leggingsdiamond", $null)
            $leggingsDiamondName = $Doc.CreateAttribute("name")
            $leggingsDiamondName.Value = "Diamond Leggings"
            $leggingsDiamond.Attributes.Append($leggingsDiamondName) | Out-Null
            $leggingsDiamondDurability = $Doc.CreateAttribute("durability")
            $leggingsDiamondDurability.Value = "496"
            $leggingsDiamond.Attributes.Append($leggingsDiamondDurability) | Out-Null
            $leggingsDiamondProtection = $Doc.CreateAttribute("protection")
            $leggingsDiamondProtection.Value = "6"
            $leggingsDiamond.Attributes.Append($leggingsDiamondProtection) | Out-Null
            $items.AppendChild($leggingsDiamond) | Out-Null

            #==============================
            #============ Boots ===========
            #==============================
            #Leather Boots
            $bootsLeather = $Doc.CreateNode("element", "bootsleather", $null)
            $bootsLeatherName = $Doc.CreateAttribute("name")
            $bootsLeatherName.Value = "Leather Boots"
            $bootsLeather.Attributes.Append($bootsLeatherName) | Out-Null
            $bootsLeatherDurability = $Doc.CreateAttribute("durability")
            $bootsLeatherDurability.Value = "66"
            $bootsLeather.Attributes.Append($bootsLeatherDurability) | Out-Null
            $bootsLeatherProtection = $Doc.CreateAttribute("protection")
            $bootsLeatherProtection.Value = "1"
            $bootsLeather.Attributes.Append($bootsLeatherProtection) | Out-Null
            $items.AppendChild($bootsLeather) | Out-Null

            #Iron Boots
            $bootsIron = $Doc.CreateNode("element", "bootsiron", $null)
            $bootsIronName = $Doc.CreateAttribute("name")
            $bootsIronName.Value = "Iron Boots"
            $bootsIron.Attributes.Append($bootsIronName) | Out-Null
            $bootsIronDurability = $Doc.CreateAttribute("durability")
            $bootsIronDurability.Value = "196"
            $bootsIron.Attributes.Append($bootsIronDurability) | Out-Null
            $bootsIronProtection = $Doc.CreateAttribute("protection")
            $bootsIronProtection.Value = "2"
            $bootsIron.Attributes.Append($bootsIronProtection) | Out-Null
            $items.AppendChild($bootsIron) | Out-Null

            #Gold Boots
            $bootsGold = $Doc.CreateNode("element", "bootsgold", $null)
            $bootsGoldName = $Doc.CreateAttribute("name")
            $bootsGoldName.Value = "Gold Boots"
            $bootsGold.Attributes.Append($bootsGoldName) | Out-Null
            $bootsGoldDurability = $Doc.CreateAttribute("durability")
            $bootsGoldDurability.Value = "92"
            $bootsGold.Attributes.Append($bootsGoldDurability) | Out-Null
            $bootsGoldProtection = $Doc.CreateAttribute("protection")
            $bootsGoldProtection.Value = "1"
            $bootsGold.Attributes.Append($bootsGoldProtection) | Out-Null
            $items.AppendChild($bootsGold) | Out-Null

            #Diamond Boots
            $bootsDiamond = $Doc.CreateNode("element", "bootsdiamond", $null)
            $bootsDiamondName = $Doc.CreateAttribute("name")
            $bootsDiamondName.Value = "Diamond Boots"
            $bootsDiamond.Attributes.Append($bootsDiamondName) | Out-Null
            $bootsDiamondDurability = $Doc.CreateAttribute("durability")
            $bootsDiamondDurability.Value = "430"
            $bootsDiamond.Attributes.Append($bootsDiamondDurability) | Out-Null
            $bootsDiamondProtection = $Doc.CreateAttribute("protection")
            $bootsDiamondProtection.Value = "3"
            $bootsDiamond.Attributes.Append($bootsDiamondProtection) | Out-Null
            $items.AppendChild($bootsDiamond) | Out-Null

            #==============================
            #============ Axe =============
            #==============================
            #Wooden Axe
            $axeWood = $Doc.CreateNode("element", "axewood", $null)
            $axeWoodName = $Doc.CreateAttribute("name")
            $axeWoodName.Value = "Wooden Axe"
            $axeWood.Attributes.Append($axeWoodName) | Out-Null
            $axeWoodDurability = $Doc.CreateAttribute("durability")
            $axeWoodDurability.Value = "60"
            $axeWood.Attributes.Append($axeWoodDurability) | Out-Null
            $axeWoodAttackDamage = $Doc.CreateAttribute("attackdamage")
            $axeWoodAttackDamage.Value = "7"
            $axeWood.Attributes.Append($axeWoodAttackDamage) | Out-Null
            $items.AppendChild($axeWood) | Out-Null

            #Iron Axe
            $axeIron = $Doc.CreateNode("element", "axeiron", $null)
            $axeIronName = $Doc.CreateAttribute("name")
            $axeIronName.Value = "Iron Axe"
            $axeIron.Attributes.Append($axeIronName) | Out-Null
            $axeIronDurability = $Doc.CreateAttribute("durability")
            $axeIronDurability.Value = "251"
            $axeIron.Attributes.Append($axeIronDurability) | Out-Null
            $axeIronAttackDamage = $Doc.CreateAttribute("attackdamage")
            $axeIronAttackDamage.Value = "9"
            $axeIron.Attributes.Append($axeIronAttackDamage) | Out-Null
            $items.AppendChild($axeIron) | Out-Null

            #Stone Axe
            $axeStone = $Doc.CreateNode("element", "axestone", $null)
            $axeStoneName = $Doc.CreateAttribute("name")
            $axeStoneName.Value = "Stone Axe"
            $axeStone.Attributes.Append($axeStoneName) | Out-Null
            $axeStoneDurability = $Doc.CreateAttribute("durability")
            $axeStoneDurability.Value = "132"
            $axeStone.Attributes.Append($axeStoneDurability) | Out-Null
            $axeStoneAttackDamage = $Doc.CreateAttribute("attackdamage")
            $axeStoneAttackDamage.Value = "9"
            $axeStone.Attributes.Append($axeStoneAttackDamage) | Out-Null
            $items.AppendChild($axeStone) | Out-Null

            #Gold Axe
            $axeGold = $Doc.CreateNode("element", "axegold", $null)
            $axeGoldName = $Doc.CreateAttribute("name")
            $axeGoldName.Value = "Gold Axe"
            $axeGold.Attributes.Append($axeGoldName) | Out-Null
            $axeGoldDurability = $Doc.CreateAttribute("durability")
            $axeGoldDurability.Value = "33"
            $axeGold.Attributes.Append($axeGoldDurability) | Out-Null
            $axeGoldAttackDamage = $Doc.CreateAttribute("attackdamage")
            $axeGoldAttackDamage.Value = "7"
            $axeGold.Attributes.Append($axeGoldAttackDamage) | Out-Null
            $items.AppendChild($axeGold) | Out-Null

            #Diamond Axe
            $axeDiamond = $Doc.CreateNode("element", "axediamond", $null)
            $axeDiamondName = $Doc.CreateAttribute("name")
            $axeDiamondName.Value = "Diamond Axe"
            $axeDiamond.Attributes.Append($axeDiamondName) | Out-Null
            $axeDiamondDurability = $Doc.CreateAttribute("durability")
            $axeDiamondDurability.Value = "1562"
            $axeDiamond.Attributes.Append($axeDiamondDurability) | Out-Null
            $axeDiamondAttackDamage = $Doc.CreateAttribute("attackdamage")
            $axeDiamondAttackDamage.Value = "9"
            $axeDiamond.Attributes.Append($axeDiamondAttackDamage) | Out-Null
            $items.AppendChild($axeDiamond) | Out-Null

            #==============================
            #========== Pickaxe ===========
            #==============================
            #Wooden Pickaxe
            $pickaxeWood = $Doc.CreateNode("element", "pickaxewood", $null)
            $pickaxeWoodName = $Doc.CreateAttribute("name")
            $pickaxeWoodName.Value = "Wooden Pickaxe"
            $pickaxeWood.Attributes.Append($pickaxeWoodName) | Out-Null
            $pickaxeWoodDurability = $Doc.CreateAttribute("durability")
            $pickaxeWoodDurability.Value = "59"
            $pickaxeWood.Attributes.Append($pickaxeWoodDurability) | Out-Null
            $pickaxeWoodAttackDamage = $Doc.CreateAttribute("attackdamage")
            $pickaxeWoodAttackDamage.Value = "3"
            $pickaxeWood.Attributes.Append($pickaxeWoodAttackDamage) | Out-Null
            $items.AppendChild($pickaxeWood) | Out-Null
            
            #Stone Pickaxe
            $pickaxeStone = $Doc.CreateNode("element", "pickaxestone", $null)
            $pickaxeStoneName = $Doc.CreateAttribute("name")
            $pickaxeStoneName.Value = "Stone Pickaxe"
            $pickaxeStone.Attributes.Append($pickaxeStoneName) | Out-Null
            $pickaxeStoneDurability = $Doc.CreateAttribute("durability")
            $pickaxeStoneDurability.Value = "131"
            $pickaxeStone.Attributes.Append($pickaxeStoneDurability) | Out-Null
            $pickaxeStoneAttackDamage = $Doc.CreateAttribute("attackdamage")
            $pickaxeStoneAttackDamage.Value = "4"
            $pickaxeStone.Attributes.Append($pickaxeStoneAttackDamage) | Out-Null
            $items.AppendChild($pickaxeStone) | Out-Null

            #Iron Pickaxe
            $pickaxeIron = $Doc.CreateNode("element", "pickaxeiron", $null)
            $pickaxeIronName = $Doc.CreateAttribute("name")
            $pickaxeIronName.Value = "Iron Pickaxe"
            $pickaxeIron.Attributes.Append($pickaxeIronName) | Out-Null
            $pickaxeIronDurability = $Doc.CreateAttribute("durability")
            $pickaxeIronDurability.Value = "250"
            $pickaxeIron.Attributes.Append($pickaxeIronDurability) | Out-Null
            $pickaxeIronAttackDamage = $Doc.CreateAttribute("attackdamage")
            $pickaxeIronAttackDamage.Value = "4"
            $pickaxeIron.Attributes.Append($pickaxeIronAttackDamage) | Out-Null
            $items.AppendChild($pickaxeIron) | Out-Null

            #Gold Pickaxe
            $pickaxeGold = $Doc.CreateNode("element", "pickaxegold", $null)
            $pickaxeGoldName = $Doc.CreateAttribute("name")
            $pickaxeGoldName.Value = "Gold Pickaxe"
            $pickaxeGold.Attributes.Append($pickaxeGoldName) | Out-Null
            $pickaxeGoldDurability = $Doc.CreateAttribute("durability")
            $pickaxeGoldDurability.Value = "32"
            $pickaxeGold.Attributes.Append($pickaxeGoldDurability) | Out-Null
            $pickaxeGoldAttackDamage = $Doc.CreateAttribute("attackdamage")
            $pickaxeGoldAttackDamage.Value = "3"
            $pickaxeGold.Attributes.Append($pickaxeGoldAttackDamage) | Out-Null
            $items.AppendChild($pickaxeGold) | Out-Null

            #Diamond Pickaxe
            $pickaxeDiamond = $Doc.CreateNode("element", "pickaxediamond", $null)
            $pickaxeDiamondName = $Doc.CreateAttribute("name")
            $pickaxeDiamondName.Value = "Diamond Pickaxe"
            $pickaxeDiamond.Attributes.Append($pickaxeDiamondName) | Out-Null
            $pickaxeDiamondDurability = $Doc.CreateAttribute("durability")
            $pickaxeDiamondDurability.Value = "1561"
            $pickaxeDiamond.Attributes.Append($pickaxeDiamondDurability) | Out-Null
            $pickaxeDiamondAttackDamage = $Doc.CreateAttribute("attackdamage")
            $pickaxeDiamondAttackDamage.Value = "6"
            $pickaxeDiamond.Attributes.Append($pickaxeDiamondAttackDamage) | Out-Null
            $items.AppendChild($pickaxeDiamond) | Out-Null

            #==============================
            #=========== Shovel ===========
            #==============================
            #Wooden Shovel
            $shovelWood = $Doc.CreateNode("element", "shovelwood", $null)
            $shovelWoodName = $Doc.CreateAttribute("name")
            $shovelWoodName.Value = "Wooden Shovel"
            $shovelWood.Attributes.Append($shovelWoodName) | Out-Null
            $shovelWoodDurability = $Doc.CreateAttribute("durability")
            $shovelWoodDurability.Value = "60"
            $shovelWood.Attributes.Append($shovelWoodDurability) | Out-Null
            $shovelWoodAttackDamage = $Doc.CreateAttribute("attackdamage")
            $shovelWoodAttackDamage.Value = "2"
            $shovelWood.Attributes.Append($shovelWoodAttackDamage) | Out-Null
            $items.AppendChild($shovelWood) | Out-Null
            
            #Stone Shovel
            $shovelStone = $Doc.CreateNode("element", "shovelstone", $null)
            $shovelStoneName = $Doc.CreateAttribute("name")
            $shovelStoneName.Value = "Stone Shovel"
            $shovelStone.Attributes.Append($shovelStoneName) | Out-Null
            $shovelStoneDurability = $Doc.CreateAttribute("durability")
            $shovelStoneDurability.Value = "132"
            $shovelStone.Attributes.Append($shovelStoneDurability) | Out-Null
            $shovelStoneAttackDamage = $Doc.CreateAttribute("attackdamage")
            $shovelStoneAttackDamage.Value = "3"
            $shovelStone.Attributes.Append($shovelStoneAttackDamage) | Out-Null
            $items.AppendChild($shovelStone) | Out-Null

            #Iron Shovel
            $shovelIron = $Doc.CreateNode("element", "shoveliron", $null)
            $shovelIronName = $Doc.CreateAttribute("name")
            $shovelIronName.Value = "Iron Shovel"
            $shovelIron.Attributes.Append($shovelIronName) | Out-Null
            $shovelIronDurability = $Doc.CreateAttribute("durability")
            $shovelIronDurability.Value = "251"
            $shovelIron.Attributes.Append($shovelIronDurability) | Out-Null
            $shovelIronAttackDamage = $Doc.CreateAttribute("attackdamage")
            $shovelIronAttackDamage.Value = "4"
            $shovelIron.Attributes.Append($shovelIronAttackDamage) | Out-Null
            $items.AppendChild($shovelIron) | Out-Null

            #Gold Shovel
            $shovelGold = $Doc.CreateNode("element", "shovelgold", $null)
            $shovelGoldName = $Doc.CreateAttribute("name")
            $shovelGoldName.Value = "Gold Shovel"
            $shovelGold.Attributes.Append($shovelGoldName) | Out-Null
            $shovelGoldDurability = $Doc.CreateAttribute("durability")
            $shovelGoldDurability.Value = "33"
            $shovelGold.Attributes.Append($shovelGoldDurability) | Out-Null
            $shovelGoldAttackDamage = $Doc.CreateAttribute("attackdamage")
            $shovelGoldAttackDamage.Value = "2"
            $shovelGold.Attributes.Append($shovelGoldAttackDamage) | Out-Null
            $items.AppendChild($shovelGold) | Out-Null

            #Diamond Shovel
            $shovelDiamond = $Doc.CreateNode("element", "shoveldiamond", $null)
            $shovelDiamondName = $Doc.CreateAttribute("name")
            $shovelDiamondName.Value = "Diamond Shovel"
            $shovelDiamond.Attributes.Append($shovelDiamondName) | Out-Null
            $shovelDiamondDurability = $Doc.CreateAttribute("durability")
            $shovelDiamondDurability.Value = "1562"
            $shovelDiamond.Attributes.Append($shovelDiamondDurability) | Out-Null
            $shovelDiamondAttackDamage = $Doc.CreateAttribute("attackdamage")
            $shovelDiamondAttackDamage.Value = "5"
            $shovelDiamond.Attributes.Append($shovelDiamondAttackDamage) | Out-Null
            $items.AppendChild($shovelDiamond) | Out-Null

            #==============================
            #============ Hoe =============
            #==============================
            #Wooden Hoe
            $hoeWood = $Doc.CreateNode("element", "hoewood", $null)
            $hoeWoodName = $Doc.CreateAttribute("name")
            $hoeWoodName.Value = "Wooden Hoe"
            $hoeWood.Attributes.Append($hoeWoodName) | Out-Null
            $hoeWoodDurability = $Doc.CreateAttribute("durability")
            $hoeWoodDurability.Value = "60"
            $hoeWood.Attributes.Append($hoeWoodDurability) | Out-Null
            $hoeWoodAttackDamage = $Doc.CreateAttribute("attackdamage")
            $hoeWoodAttackDamage.Value = "1"
            $hoeWood.Attributes.Append($hoeWoodAttackDamage) | Out-Null
            $items.AppendChild($hoeWood) | Out-Null
            
            #Stone Hoe
            $hoeStone = $Doc.CreateNode("element", "hoestone", $null)
            $hoeStoneName = $Doc.CreateAttribute("name")
            $hoeStoneName.Value = "Stone Hoe"
            $hoeStone.Attributes.Append($hoeStoneName) | Out-Null
            $hoeStoneDurability = $Doc.CreateAttribute("durability")
            $hoeStoneDurability.Value = "132"
            $hoeStone.Attributes.Append($hoeStoneDurability) | Out-Null
            $hoeStoneAttackDamage = $Doc.CreateAttribute("attackdamage")
            $hoeStoneAttackDamage.Value = "2"
            $hoeStone.Attributes.Append($hoeStoneAttackDamage) | Out-Null
            $items.AppendChild($hoeStone) | Out-Null

            #Iron Hoe
            $hoeIron = $Doc.CreateNode("element", "hoeiron", $null)
            $hoeIronName = $Doc.CreateAttribute("name")
            $hoeIronName.Value = "Iron Hoe"
            $hoeIron.Attributes.Append($hoeIronName) | Out-Null
            $hoeIronDurability = $Doc.CreateAttribute("durability")
            $hoeIronDurability.Value = "251"
            $hoeIron.Attributes.Append($hoeIronDurability) | Out-Null
            $hoeIronAttackDamage = $Doc.CreateAttribute("attackdamage")
            $hoeIronAttackDamage.Value = "3"
            $hoeIron.Attributes.Append($hoeIronAttackDamage) | Out-Null
            $items.AppendChild($hoeIron) | Out-Null

            #Gold Hoe
            $hoeGold = $Doc.CreateNode("element", "hoegold", $null)
            $hoeGoldName = $Doc.CreateAttribute("name")
            $hoeGoldName.Value = "Gold Hoe"
            $hoeGold.Attributes.Append($hoeGoldName) | Out-Null
            $hoeGoldDurability = $Doc.CreateAttribute("durability")
            $hoeGoldDurability.Value = "33"
            $hoeGold.Attributes.Append($hoeGoldDurability) | Out-Null
            $hoeGoldAttackDamage = $Doc.CreateAttribute("attackdamage")
            $hoeGoldAttackDamage.Value = "1"
            $hoeGold.Attributes.Append($hoeGoldAttackDamage) | Out-Null
            $items.AppendChild($hoeGold) | Out-Null

            #Diamond Hoe
            $hoeDiamond = $Doc.CreateNode("element", "hoediamond", $null)
            $hoeDiamondName = $Doc.CreateAttribute("name")
            $hoeDiamondName.Value = "Diamond Hoe"
            $hoeDiamond.Attributes.Append($hoeDiamondName) | Out-Null
            $hoeDiamondDurability = $Doc.CreateAttribute("durability")
            $hoeDiamondDurability.Value = "1562"
            $hoeDiamond.Attributes.Append($hoeDiamondDurability) | Out-Null
            $hoeDiamondAttackDamage = $Doc.CreateAttribute("attackdamage")
            $hoeDiamondAttackDamage.Value = "4"
            $hoeDiamond.Attributes.Append($hoeDiamondAttackDamage) | Out-Null
            $items.AppendChild($hoeDiamond) | Out-Null

            #==============================
            #=========== Sword ============
            #==============================
            #Wooden Sword
            $swordWood = $Doc.CreateNode("element", "swordwood", $null)
            $swordWoodName = $Doc.CreateAttribute("name")
            $swordWoodName.Value = "Wooden Sword"
            $swordWood.Attributes.Append($swordWoodName) | Out-Null
            $swordWoodDurability = $Doc.CreateAttribute("durability")
            $swordWoodDurability.Value = "60"
            $swordWood.Attributes.Append($swordWoodDurability) | Out-Null
            $swordWoodAttackDamage = $Doc.CreateAttribute("attackdamage")
            $swordWoodAttackDamage.Value = "4"
            $swordWood.Attributes.Append($swordWoodAttackDamage) | Out-Null
            $items.AppendChild($swordWood) | Out-Null
            
            #Stone Sword
            $swordStone = $Doc.CreateNode("element", "swordstone", $null)
            $swordStoneName = $Doc.CreateAttribute("name")
            $swordStoneName.Value = "Stone Sword"
            $swordStone.Attributes.Append($swordStoneName) | Out-Null
            $swordStoneDurability = $Doc.CreateAttribute("durability")
            $swordStoneDurability.Value = "132"
            $swordStone.Attributes.Append($swordStoneDurability) | Out-Null
            $swordStoneAttackDamage = $Doc.CreateAttribute("attackdamage")
            $swordStoneAttackDamage.Value = "5"
            $swordStone.Attributes.Append($swordStoneAttackDamage) | Out-Null
            $items.AppendChild($swordStone) | Out-Null

            #Iron Sword
            $swordIron = $Doc.CreateNode("element", "swordiron", $null)
            $swordIronName = $Doc.CreateAttribute("name")
            $swordIronName.Value = "Iron Sword"
            $swordIron.Attributes.Append($swordIronName) | Out-Null
            $swordIronDurability = $Doc.CreateAttribute("durability")
            $swordIronDurability.Value = "251"
            $swordIron.Attributes.Append($swordIronDurability) | Out-Null
            $swordIronAttackDamage = $Doc.CreateAttribute("attackdamage")
            $swordIronAttackDamage.Value = "6"
            $swordIron.Attributes.Append($swordIronAttackDamage) | Out-Null
            $items.AppendChild($swordIron) | Out-Null

            #Gold Sword
            $swordGold = $Doc.CreateNode("element", "swordgold", $null)
            $swordGoldName = $Doc.CreateAttribute("name")
            $swordGoldName.Value = "Gold Sword"
            $swordGold.Attributes.Append($swordGoldName) | Out-Null
            $swordGoldDurability = $Doc.CreateAttribute("durability")
            $swordGoldDurability.Value = "33"
            $swordGold.Attributes.Append($swordGoldDurability) | Out-Null
            $swordGoldAttackDamage = $Doc.CreateAttribute("attackdamage")
            $swordGoldAttackDamage.Value = "4"
            $swordGold.Attributes.Append($swordGoldAttackDamage) | Out-Null
            $items.AppendChild($swordGold) | Out-Null

            #Diamond Sword
            $swordDiamond = $Doc.CreateNode("element", "sworddiamond", $null)
            $swordDiamondName = $Doc.CreateAttribute("name")
            $swordDiamondName.Value = "Diamond Sword"
            $swordDiamond.Attributes.Append($swordDiamondName) | Out-Null
            $swordDiamondDurability = $Doc.CreateAttribute("durability")
            $swordDiamondDurability.Value = "1562"
            $swordDiamond.Attributes.Append($swordDiamondDurability) | Out-Null
            $swordDiamondAttackDamage = $Doc.CreateAttribute("attackdamage")
            $swordDiamondAttackDamage.Value = "7"
            $swordDiamond.Attributes.Append($swordDiamondAttackDamage) | Out-Null
            $items.AppendChild($swordDiamond) | Out-Null

            #Stick
            $stick = $Doc.CreateNode("element","stick", $null)
            $stickName = $Doc.CreateAttribute("name")
            $stickName.Value = "Stick"
            $stick.Attributes.Append($stickName) | Out-Null
            $stickMaxStack = $Doc.CreateAttribute("maxstack")
            $stickMaxStack.Value = "64"
            $stick.Attributes.Append($stickMaxStack) | Out-Null
            $items.AppendChild($stick) | Out-Null

            #Gold Ingot
            $goldingot = $Doc.CreateNode("element","goldingot", $null)
            $goldingotName = $Doc.CreateAttribute("name")
            $goldingotName.Value = "Gold Ingot"
            $goldingot.Attributes.Append($goldingotName) | Out-Null
            $goldingotMaxStack = $Doc.CreateAttribute("maxstack")
            $goldingotMaxStack.Value = "64"
            $goldingot.Attributes.Append($goldingotMaxStack) | Out-Null
            $items.AppendChild($goldingot) | Out-Null

            #Iron Ingot
            $ironingot = $Doc.CreateNode("element","ironingot", $null)
            $ironingotName = $Doc.CreateAttribute("name")
            $ironingotName.Value = "Iron Ingot"
            $ironingot.Attributes.Append($ironingotName) | Out-Null
            $ironingotMaxStack = $Doc.CreateAttribute("maxstack")
            $ironingotMaxStack.Value = "64"
            $ironingot.Attributes.Append($ironingotMaxStack) | Out-Null
            $items.AppendChild($ironingot) | Out-Null

            #Coal
            $coal = $Doc.CreateNode("element","coal", $null)
            $coalName = $Doc.CreateAttribute("name")
            $coalName.Value = "Coal"
            $coal.Attributes.Append($coalName) | Out-Null
            $coalMaxStack = $Doc.CreateAttribute("maxstack")
            $coalMaxStack.Value = "64"
            $coal.Attributes.Append($coalMaxStack) | Out-Null
            $items.AppendChild($coal) | Out-Null

            #Diamond
            $diamond = $Doc.CreateNode("element","diamond", $null)
            $diamondName = $Doc.CreateAttribute("name")
            $diamondName.Value = "Diamond"
            $diamond.Attributes.Append($diamondName) | Out-Null
            $diamondMaxStack = $Doc.CreateAttribute("maxstack")
            $diamondMaxStack.Value = "64"
            $diamond.Attributes.Append($diamondMaxStack) | Out-Null
            $items.AppendChild($diamond) | Out-Null

        #Blocks
        $blocks = $Doc.CreateNode("element", "blocks", $null)
        $root.AppendChild($blocks) | Out-Null
        
            #==============================
            #=========  StoneType =========
            #==============================       
            #Stone
            $stone = $Doc.CreateNode("element", "stone", $null)
            $stoneName = $Doc.CreateAttribute("name")
            $stoneName.Value = "Stone"
            $stone.Attributes.Append($stoneName) | Out-Null
            $stoneMaxStack = $Doc.CreateAttribute("maxstack")
            $stoneMaxStack.Value = "64"
            $stone.Attributes.Append($stoneMaxStack) | Out-Null
            $stoneDrop = $Doc.CreateAttribute("drop")
            $stoneDrop.Value = "cobblestone"
            $stone.Attributes.Append($stoneDrop) | Out-Null
            $stoneDropNbr = $Doc.CreateAttribute("dropnumber")
            $stoneDropNbr.Value = "1"
            $stone.Attributes.Append($stoneDropNbr) | Out-Null
            $blocks.AppendChild($stone) | Out-Null
            
            #Cobblestone
            $cobblestone = $Doc.CreateNode("element", "cobblestone", $null)
            $cobblestoneName = $Doc.CreateAttribute("name")
            $cobblestoneName.Value = "Cobblestone"
            $cobblestone.Attributes.Append($cobblestoneName) | Out-Null
            $cobblestoneMaxStack = $Doc.CreateAttribute("maxstack")
            $cobblestoneMaxStack.Value = "64"
            $cobblestone.Attributes.Append($cobblestoneMaxStack) | Out-Null
            $cobblestoneDrop = $Doc.CreateAttribute("drop")
            $cobblestoneDrop.Value = "cobblestone"
            $cobblestone.Attributes.Append($cobblestoneDrop) | Out-Null
            $cobblestoneDropNbr = $Doc.CreateAttribute("dropnumber")
            $cobblestoneDropNbr.Value = "1"
            $cobblestone.Attributes.Append($cobblestoneDropNbr) | Out-Null
            $blocks.AppendChild($cobblestone) | Out-Null

            #Iron Ore
            $ironOre = $Doc.CreateNode("element", "ironore", $null)
            $ironOreName = $Doc.CreateAttribute("name")
            $ironOreName.Value = "Iron Ore"
            $ironOre.Attributes.Append($ironOreName) | Out-Null
            $ironOreMaxStack = $Doc.CreateAttribute("maxstack")
            $ironOreMaxStack.Value = "64"
            $ironOre.Attributes.Append($ironOreMaxStack) | Out-Null
            $ironOreDrop = $Doc.CreateAttribute("drop")
            $ironOreDrop.Value = "ironore"
            $ironOre.Attributes.Append($ironOreDrop) | Out-Null
            $ironOreDropNbr = $Doc.CreateAttribute("dropnumber")
            $ironOreDropNbr.Value = "1"
            $ironOre.Attributes.Append($ironOreDropNbr) | Out-Null
            $blocks.AppendChild($ironOre) | Out-Null

            #Gold Ore
            $goldOre = $Doc.CreateNode("element", "goldore", $null)
            $goldOreName = $Doc.CreateAttribute("name")
            $goldOreName.Value = "Gold Ore"
            $goldOre.Attributes.Append($goldOreName) | Out-Null
            $goldOreMaxStack = $Doc.CreateAttribute("maxstack")
            $goldOreMaxStack.Value = "64"
            $goldOre.Attributes.Append($goldOreMaxStack) | Out-Null
            $goldOreDrop = $Doc.CreateAttribute("drop")
            $goldOreDrop.Value = "goldore"
            $goldOre.Attributes.Append($goldOreDrop) | Out-Null
            $goldOreDropNbr = $Doc.CreateAttribute("dropnumber")
            $goldOreDropNbr.Value = "1"
            $goldOre.Attributes.Append($goldOreDropNbr) | Out-Null
            $blocks.AppendChild($goldOre) | Out-Null

            #==============================
            #========== WoodType ==========
            #==============================
            #Crafting Table
            $craftingtable = $Doc.CreateNode("element", "craftingtable", $null)
            $craftingtableName = $Doc.CreateAttribute("name")
            $craftingtableName.Value = "Crafting Table"
            $craftingtable.Attributes.Append($craftingtableName) | Out-Null
            $craftingtableMaxStack = $Doc.CreateAttribute("maxstack")
            $craftingtableMaxStack.Value = "64"
            $craftingtable.Attributes.Append($craftingtableMaxStack) | Out-Null
            $craftingtableDrop = $Doc.CreateAttribute("drop")
            $craftingtableDrop.Value = "craftingtable"
            $craftingtable.Attributes.Append($craftingtableDrop) | Out-Null
            $craftingtableDropNbr = $Doc.CreateAttribute("dropnumber")
            $craftingtableDropNbr.Value = "1"
            $craftingtable.Attributes.Append($craftingtableDropNbr) | Out-Null
            $blocks.AppendChild($craftingtable) | Out-Null
            
            #Chest
            $chest = $Doc.CreateNode("element", "chest", $null)
            $chestName = $Doc.CreateAttribute("name")
            $chestName.Value = "Chest"
            $chest.Attributes.Append($chestName) | Out-Null
            $chestMaxStack = $Doc.CreateAttribute("maxstack")
            $chestMaxStack.Value = "64"
            $chest.Attributes.Append($chestMaxStack) | Out-Null
            $chestDrop = $Doc.CreateAttribute("drop")
            $chestDrop.Value = "chest"
            $chest.Attributes.Append($chestDrop) | Out-Null
            $chestDropNbr = $Doc.CreateAttribute("dropnumber")
            $chestDropNbr.Value = "1"
            $chest.Attributes.Append($chestDropNbr) | Out-Null
            $blocks.AppendChild($chest) | Out-Null

            #Wood
            $wood = $Doc.CreateNode("element", "wood", $null)
            $woodName = $Doc.CreateAttribute("name")
            $woodName.Value = "Wood"
            $wood.Attributes.Append($woodName) | Out-Null
            $woodMaxStack = $Doc.CreateAttribute("maxstack")
            $woodMaxStack.Value = "64"
            $wood.Attributes.Append($woodMaxStack) | Out-Null
            $woodDrop = $Doc.CreateAttribute("drop")
            $woodDrop.Value = "wood"
            $wood.Attributes.Append($woodDrop) | Out-Null
            $woodDropNbr = $Doc.CreateAttribute("dropnumber")
            $woodDropNbr.Value = "1"
            $wood.Attributes.Append($woodDropNbr) | Out-Null
            $blocks.AppendChild($wood) | Out-Null

            #Wood planks
            $woodPlanks = $Doc.CreateNode("element", "woodenplanks", $null)
            $woodPlanksName = $Doc.CreateAttribute("name")
            $woodPlanksName.Value = "Wooden Planks"
            $woodPlanks.Attributes.Append($woodPlanksName) | Out-Null
            $woodPlanksMaxStack = $Doc.CreateAttribute("maxstack")
            $woodPlanksMaxStack.Value = "64"
            $woodPlanks.Attributes.Append($woodPlanksMaxStack) | Out-Null
            $woodPlanksDrop = $Doc.CreateAttribute("drop")
            $woodPlanksDrop.Value = "woodenplanks"
            $woodPlanks.Attributes.Append($woodPlanksDrop) | Out-Null
            $woodPlanksDropNbr = $Doc.CreateAttribute("dropnumber")
            $woodPlanksDropNbr.Value = "1"
            $woodPlanks.Attributes.Append($woodPlanksDropNbr) | Out-Null
            $blocks.AppendChild($woodPlanks) | Out-Null

        #Crafting recipes
        $craftingRecipes = $Doc.CreateNode("element", "craftingrecipes", $null)
        $root.AppendChild($craftingRecipes) | Out-Null

            #Crafting Table
            $craftingtable = $Doc.CreateNode("element", "craftingtable", $null)
            $craftingtableWoodenPlanks = $Doc.CreateAttribute("woodenplanks")
            $craftingtableWoodenPlanks.Value = "4"
            $craftingtable.Attributes.Append($craftingtableWoodenPlanks) | Out-Null
            $craftingtableReturn = $Doc.CreateAttribute("returnamount")
            $craftingtableReturn.Value = "1"
            $craftingtable.Attributes.Append($craftingtableReturn) | Out-Null
            $craftingRecipes.AppendChild($craftingtable) | Out-Null
            
            #Wood planks
            $craftWoodPlanks = $Doc.CreateNode("element", "woodenplanks", $null)
            $craftWoodPlanksWood = $Doc.CreateAttribute("wood")
            $craftWoodPlanksWood.Value = "1"
            $craftWoodPlanks.Attributes.Append($craftWoodPlanksWood) | Out-Null
            $craftWoodPlanksReturn = $Doc.CreateAttribute("returnamount")
            $craftWoodPlanksReturn.Value = "4"
            $craftWoodPlanks.Attributes.Append($craftWoodPlanksReturn) | Out-Null
            $craftingRecipes.AppendChild($craftWoodPlanks) | Out-Null

            #Chest
            $craftChest = $Doc.CreateNode("element", "chest", $null)
            $craftcraftChestWoodenPlanks = $Doc.CreateAttribute("woodenplanks")
            $craftcraftChestWoodenPlanks.Value = "8"
            $craftChest.Attributes.Append($craftcraftChestWoodenPlanks) | Out-Null
            $craftChestReturn = $Doc.CreateAttribute("returnamount")
            $craftChestReturn.Value = "1"
            $craftChest.Attributes.Append($craftChestReturn) | Out-Null
            $craftingRecipes.AppendChild($craftChest) | Out-Null

            #Stick
            $craftStick = $Doc.CreateNode("element", "stick", $null)
            $craftStickWoodplanks = $Doc.CreateAttribute("woodenplanks")
            $craftStickWoodplanks.Value = "3"
            $craftStick.Attributes.Append($craftStickWoodplanks) | Out-Null
            $craftStickReturn = $Doc.CreateAttribute("returnamount")
            $craftStickReturn.Value = "3"
            $craftStick.Attributes.Append($craftStickReturn) | Out-Null
            $craftingRecipes.AppendChild($craftStick) | Out-Null

            #Wood Pickaxe
            $craftPickaxeWood = $Doc.CreateNode("element", "pickaxewood", $null)
            $craftPickaxeWoodStick = $Doc.CreateAttribute("stick")
            $craftPickaxeWoodStick.Value = "2"
            $craftPickaxeWood.Attributes.Append($craftPickaxeWoodStick) | Out-Null
            $craftPickaxeWoodWoodPlank = $Doc.CreateAttribute("woodenplanks")
            $craftPickaxeWoodWoodPlank.Value = "3"
            $craftPickaxeWood.Attributes.Append($craftPickaxeWoodWoodPlank) | Out-Null
            $craftPickaxeWoodReturn = $Doc.CreateAttribute("returnamount")
            $craftPickaxeWoodReturn.Value = "1"
            $craftPickaxeWood.Attributes.Append($craftPickaxeWoodReturn) | Out-Null
            $craftingRecipes.AppendChild($craftPickaxeWood) | Out-Null

            #Wood Pickaxe
            $craftPickaxeWood = $Doc.CreateNode("element", "pickaxewood", $null)
            $craftPickaxeWoodStick = $Doc.CreateAttribute("stick")
            $craftPickaxeWoodStick.Value = "2"
            $craftPickaxeWood.Attributes.Append($craftPickaxeWoodStick) | Out-Null
            $craftPickaxeWoodWoodPlank = $Doc.CreateAttribute("woodenplanks")
            $craftPickaxeWoodWoodPlank.Value = "3"
            $craftPickaxeWood.Attributes.Append($craftPickaxeWoodWoodPlank) | Out-Null
            $craftPickaxeWoodReturn = $Doc.CreateAttribute("returnamount")
            $craftPickaxeWoodReturn.Value = "1"
            $craftPickaxeWood.Attributes.Append($craftPickaxeWoodReturn) | Out-Null
            $craftingRecipes.AppendChild($craftPickaxeWood) | Out-Null

            #Stone Pickaxe
            $craftPickaxeStone = $Doc.CreateNode("element", "pickaxestone", $null)
            $craftPickaxeStoneStick = $Doc.CreateAttribute("stick")
            $craftPickaxeStoneStick.Value = "2"
            $craftPickaxeStone.Attributes.Append($craftPickaxeStoneStick) | Out-Null
            $craftPickaxeStoneCobblestone = $Doc.CreateAttribute("cobblestone")
            $craftPickaxeStoneCobblestone.Value = "3"
            $craftPickaxeStone.Attributes.Append($craftPickaxeStoneCobblestone) | Out-Null
            $craftPickaxeStoneReturn = $Doc.CreateAttribute("returnamount")
            $craftPickaxeStoneReturn.Value = "1"
            $craftPickaxeStone.Attributes.Append($craftPickaxeStoneReturn) | Out-Null
            $craftingRecipes.AppendChild($craftPickaxeStone) | Out-Null

            #Gold Pickaxe
            $craftPickaxeGold = $Doc.CreateNode("element", "pickaxegold", $null)
            $craftPickaxeGoldStick = $Doc.CreateAttribute("stick")
            $craftPickaxeGoldStick.Value = "2"
            $craftPickaxeGold.Attributes.Append($craftPickaxeGoldStick) | Out-Null
            $craftPickaxeGoldGoldingot = $Doc.CreateAttribute("goldingot")
            $craftPickaxeGoldGoldingot.Value = "3"
            $craftPickaxeGold.Attributes.Append($craftPickaxeGoldGoldingot) | Out-Null
            $craftPickaxeGoldReturn = $Doc.CreateAttribute("returnamount")
            $craftPickaxeGoldReturn.Value = "1"
            $craftPickaxeGold.Attributes.Append($craftPickaxeGoldReturn) | Out-Null
            $craftingRecipes.AppendChild($craftPickaxeGold) | Out-Null

            #Iron Pickaxe
            $craftPickaxeIron = $Doc.CreateNode("element", "pickaxeiron", $null)
            $craftPickaxeIronStick = $Doc.CreateAttribute("stick")
            $craftPickaxeIronStick.Value = "2"
            $craftPickaxeIron.Attributes.Append($craftPickaxeIronStick) | Out-Null
            $craftPickaxeIronIronIngot = $Doc.CreateAttribute("ironingot")
            $craftPickaxeIronIronIngot.Value = "3"
            $craftPickaxeIron.Attributes.Append($craftPickaxeIronIronIngot) | Out-Null
            $craftPickaxeIronReturn = $Doc.CreateAttribute("returnamount")
            $craftPickaxeIronReturn.Value = "1"
            $craftPickaxeIron.Attributes.Append($craftPickaxeIronReturn) | Out-Null
            $craftingRecipes.AppendChild($craftPickaxeIron) | Out-Null

            #Diamond Pickaxe
            $craftPickaxeDiamond = $Doc.CreateNode("element", "pickaxediamond", $null)
            $craftPickaxeDiamondStick = $Doc.CreateAttribute("stick")
            $craftPickaxeDiamondStick.Value = "2"
            $craftPickaxeDiamond.Attributes.Append($craftPickaxeDiamondStick) | Out-Null
            $craftPickaxeDiamondDiamond = $Doc.CreateAttribute("diamond")
            $craftPickaxeDiamondDiamond.Value = "3"
            $craftPickaxeDiamond.Attributes.Append($craftPickaxeDiamondDiamond) | Out-Null
            $craftPickaxeDiamondReturn = $Doc.CreateAttribute("returnamount")
            $craftPickaxeDiamondReturn.Value = "1"
            $craftPickaxeDiamond.Attributes.Append($craftPickaxeDiamondReturn) | Out-Null
            $craftingRecipes.AppendChild($craftPickaxeDiamond) | Out-Null
        
        $Doc.Save($Path) | Out-Null

        [xml]$XmlDocument = Get-Content -Path $Path
        $script:itemList = $XmlDocument
    } else {
        [xml]$XmlDocument = Get-Content -Path $Path
        $script:itemList = $XmlDocument
    }
}

function Load-EntityList {
    param(
        $Path
    )

    if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
        #Sjekk om "Lokal Data" finnes
        if (-not (Test-Path -Path "C:\Lokal Data" -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path "C:\" -Name "Lokal Data" | Out-Null }

        #Sjekk om "ConfigFiles" finnes
        if (-not (Test-Path -Path "C:\Lokal Data\ConfigFiles" -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path "C:\Lokal Data" -Name "ConfigFiles" | Out-Null }        
        
        #Opprett default configfil
        [xml]$Doc = New-Object System.Xml.XmlDocument

        #Description
        $dec = $Doc.CreateXmlDeclaration("1.0", "UTF-8", $null)
        $Doc.AppendChild($dec) | Out-Null

        #Root element "XML"
        $root = $Doc.CreateNode("element", "xml", $null)
        $Doc.AppendChild($root) | Out-Null

        #Entities
        $entities = $Doc.CreateNode("element", "entities", $null)
        $root.AppendChild($entities) | Out-Null

            #Her kommer det ting lizzom XD

        $Doc.Save($Path) | Out-Null

        [xml]$XmlDocument = Get-Content -Path $Path
        $script:entityList = $XmlDocument
    } else {
        [xml]$XmlDocument = Get-Content -Path $Path
        $script:entityList = $XmlDocument
    }
}

function Load-MainHud {
    param(
        [xml]$XMLDocument = $configList
    )

    cls
    "┌─ PowerCraft ─────────────────────────────────────────────────────┐"
    "|┌─ User ────────────┐┌─ Hand ───────────────┐┌─ Time ────────────┐|"
    Write-Host "|| $($XMLDocument.xml.playerstats.playername)$(for ($i = 0; $i -lt (19 - ($XMLDocument.xml.playerstats.playername).Length); $i++) {''})" -NoNewline;$i=0 #42 mellomrom hvis tom
    Write-Host "|| $(if ($XMLDocument.xml.playerstats.hand.ChildNodes.Count -eq 0) { "Empty                " } else { $XMLDocument.xml.playerstats.hand.FirstChild.Name;for ($i = 0; $i -lt (21 - ($XMLDocument.xml.playerstats.hand.FirstChild.Name).Length); $i++) {''} } )" -NoNewline
    "|| 12:30   ║ Day     ||"
    "|└───────────────────┘└──────────────────────┘└───────────────────┘|"
    "|┌─ Armor ───────────┐┌───────────────────────────────────────────┐|"
    if ($XMLDocument.xml.playerstats.armor.helmet.equipped -eq 1) { Write-Host "|| Helmet     = [X" -NoNewline;$helmetType = "$($XMLDocument.xml.playerstats.armor.helmet.type)" } else { Write-Host "|| Helmet     = [ " -NoNewline;$helmetType = "Empty" }
    "]  │|                                           ||"
    Write-Host "|| └─ $helmetType$(for ($i = 0; $i -lt (16 - $helmetType.Length); $i++) {''})" -NoNewline;$i=0 #16 mellomrom hvis tom
    "||                                           ||"
    "||                   ||                                           ||"
    if ($XMLDocument.xml.playerstats.armor.chestplate.equipped -eq 1) { Write-Host "|| Chestplate = [X" -NoNewline;$chestplateType = "$($XMLDocument.xml.playerstats.armor.chestplate.type)" } else { Write-Host "|| Chestplate = [ " -NoNewline;$chestplateType = "Empty" }
    "]  ||                                           ||"
    Write-Host "|| └─ $chestplateType$(for ($i = 0; $i -lt (16 - $chestplateType.Length); $i++) {''})" -NoNewline;$i=0 #16 mellomrom hvis tom
    "||                                           ||"
    "||                   ||                                           ||"
    if ($XMLDocument.xml.playerstats.armor.leggings.equipped -eq 1) { Write-Host "|| Leggings   = [X" -NoNewline;$leggingsType = "$($XMLDocument.xml.playerstats.armor.leggings.type)" } else { Write-Host "|| Leggings   = [ " -NoNewline;$leggingsType = "Empty" }
    "]  ||                                           ||"
    Write-Host "|| └─ $leggingsType$(for ($i = 0; $i -lt (16 - $leggingsType.Length); $i++) {''})" -NoNewline;$i=0 #16 mellomrom hvis tom
    "||                                           ||"
    "||                   ||                                           ||"
    if ($XMLDocument.xml.playerstats.armor.boots.equipped -eq 1) { Write-Host "|| Boots      = [X" -NoNewline;$bootsType = "$($XMLDocument.xml.playerstats.armor.boots.type)" } else { Write-Host "|| Boots      = [ " -NoNewline;$bootsType = "Empty" }
    "]  ||                                           ||"
    Write-Host "|| └─ $bootsType$(for ($i = 0; $i -lt (16 - $bootsType.Length); $i++) {''})" -NoNewline;$i=0 #16 mellomrom hvis tom
    "||                                           ||"
    "||                   ||                                           ||"
    #Regn ut hvor mye "protection" du har
    $helmetProtection, $chestplateProtection, $leggingsProtection, $bootsProtection = 0
    if ($XMLDocument.xml.playerstats.armor.helmet.ChildNodes.Count -eq 0) { $helmetProtection = 0 } else { $helmetProtection = "$($XMLDocument.xml.playerstats.armor.helmet.$("helmet"+$XMLDocument.xml.playerstats.armor.helmet.type).protection)" }
    if ($XMLDocument.xml.playerstats.armor.chestplate.ChildNodes.Count -eq 0) { $chestplateProtection = 0 } else { $chestplateProtection = "$($XMLDocument.xml.playerstats.armor.chestplate.$("chestplate"+$XMLDocument.xml.playerstats.armor.chestplate.type).protection)" }
    if ($XMLDocument.xml.playerstats.armor.leggings.ChildNodes.Count -eq 0) { $leggingsProtection = 0 } else { $leggingsProtection = "$($XMLDocument.xml.playerstats.armor.leggings.$("leggings"+$XMLDocument.xml.playerstats.armor.leggings.type).protection)" }
    if ($XMLDocument.xml.playerstats.armor.boots.ChildNodes.Count -eq 0) { $bootsProtection = 0 } else { $bootsProtection = "$($XMLDocument.xml.playerstats.armor.boots.$("boots"+$XMLDocument.xml.playerstats.armor.boots.type).protection)" }
    $armorProtection = [int]$helmetProtection + [int]$chestplateProtection + [int]$leggingsProtection + [int]$bootsProtection
    $(
        $full = 20
        [String]$armorProtectionCalc = $((10 / $full) * $armorProtection)
        if ($armorProtectionCalc -like "*.*") { [Array]$armorProtectionCalc = $armorProtectionCalc.Split(".") } else { $armorProtectionCalc = $armorProtectionCalc + ".0"; [Array]$armorProtectionCalc = $armorProtectionCalc.Split(".") }
        $armorProtectionCalc0 = $armorProtectionCalc[0]
        $armorProtectionCalc1 = $armorProtectionCalc[1]

        $armorString = ""

        if ($armorProtectionCalc0 -eq 0 -and -not ($armorProtectionCalc1 -eq 5)) {
            $armorString = "○ ○ ○ ○ ○ ○ ○ ○ ○ ○"
        } elseif ($armorProtectionCalc0 -eq 10 -and -not ($armorProtectionCalc1 -eq 5)) {
            $armorString = "♦ ♦ ♦ ♦ ♦ ♦ ♦ ♦ ♦ ♦"
        } else {
            if (-not ($armorProtectionCalc0 -eq 0)) { for ($i = 0;$i -lt $armorProtectionCalc0; $i++) { $armorString += "♦"; if ($armorString.Length -lt 18) { $armorString += " " } };$i=0 }
            if ($armorProtectionCalc1 -eq 5) { $armorString += "■"; if ($armorString.Length -lt 18) { $armorString += " " } }
            if (-not ($armorProtectionCalc0 -eq 10)) { While ($armorString.Length -lt 19) { $armorString += "○"; if ($armorString.Length -lt 18) { $armorString += " " } } }
        }
        Write-Host "||$armorString" -NoNewline
    )
    "||                                           ||"
    "|└───────────────────┘|                                           ||"
    "|┌─ Health ──────────┐|                                           ||"
    "||♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ■ ○||                                           ||"
    "|└───────────────────┘└───────────────────────────────────────────┘|"
    "|┌─ XP // Lvl 0 ──────────────────────────────────────────────────┐|"
    "||¦¦¦¦¦¦¦¦¦¦¦¦¦                                                   ||"
    "||                            13/200 xp                           ||"
    "|└────────────────────────────────────────────────────────────────┘|"
    "└──────────────────────────────────────────────────────────────────┘"
    ""
    Write-Host $actionMessage
    $script:actionMessage = ""

    $action = Read-Host "Action"
    Run-Command -Command $action
}

function Equip-ItemBlock {
    param(
        $ItemBlock
    )

    foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
        if ($slot.HasChildNodes) {
            if (($slot.FirstChild.Name).ToLower() -like $ItemBlock.ToLower()) {
                if ($ItemBlock.ToLower() -like "*helmet*") {
                    if ($configList.xml.playerstats.armor.helmet.HasChildNodes) {
                        #Change position
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $armorItemElement = $configList.xml.playerstats.armor.helmet.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)
                        $armorType = ($invItemElement.Name).Split(" ")

                        $configList.xml.playerstats.armor.helmet.RemoveChild($armorItemElement) | Out-Null
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.helmet.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.helmet.SetAttribute("type", $armorType[0])
                        $slot.AppendChild($importArmorItemElement) | Out-Null

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to helmet slot"
                    } else {
                        #Equip into helmet spot
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $helmetType = ($invItemElement.Name).Split(" ")

                        $slot.SetAttribute("ItemCount", "0")
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.helmet.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.helmet.SetAttribute("equipped", "1")
                        $configList.xml.playerstats.armor.helmet.SetAttribute("type", $helmetType[0])

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to helmet slot"
                    }
                } elseif ($ItemBlock.ToLower() -like "*chestplate*") {
                    if ($configList.xml.playerstats.armor.chestplate.HasChildNodes) {
                        #Change position
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $armorItemElement = $configList.xml.playerstats.armor.chestplate.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)
                        $armorType = ($invItemElement.Name).Split(" ")

                        $configList.xml.playerstats.armor.chestplate.RemoveChild($armorItemElement) | Out-Null
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.chestplate.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.chestplate.SetAttribute("type", $armorType[0])
                        $slot.AppendChild($importArmorItemElement) | Out-Null

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to chestplate slot"
                    } else {
                        #Equip into helmet spot
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $helmetType = ($invItemElement.Name).Split(" ")

                        $slot.SetAttribute("ItemCount", "0")
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.chestplate.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.chestplate.SetAttribute("equipped", "1")
                        $configList.xml.playerstats.armor.chestplate.SetAttribute("type", $helmetType[0])

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to chestplate slot"
                    }
                } elseif ($ItemBlock.ToLower() -like "*leggings*") {
                    if ($configList.xml.playerstats.armor.leggings.HasChildNodes) {
                        #Change position
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $armorItemElement = $configList.xml.playerstats.armor.leggings.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)
                        $armorType = ($invItemElement.Name).Split(" ")

                        $configList.xml.playerstats.armor.leggings.RemoveChild($armorItemElement) | Out-Null
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.leggings.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.leggings.SetAttribute("type", $armorType[0])
                        $slot.AppendChild($importArmorItemElement) | Out-Null

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to leggings slot"
                    } else {
                        #Equip into helmet spot
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $helmetType = ($invItemElement.Name).Split(" ")

                        $slot.SetAttribute("ItemCount", "0")
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.leggings.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.leggings.SetAttribute("equipped", "1")
                        $configList.xml.playerstats.armor.leggings.SetAttribute("type", $helmetType[0])

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to leggings slot"
                    }
                } elseif ($ItemBlock.ToLower() -like "*boots*") {
                    if ($configList.xml.playerstats.armor.boots.HasChildNodes) {
                        #Change position
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $armorItemElement = $configList.xml.playerstats.armor.boots.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)
                        $armorType = ($invItemElement.Name).Split(" ")

                        $configList.xml.playerstats.armor.boots.RemoveChild($armorItemElement) | Out-Null
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.boots.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.boots.SetAttribute("type", $armorType[0])
                        $slot.AppendChild($importArmorItemElement) | Out-Null

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to boots slot"
                    } else {
                        #Equip into helmet spot
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $helmetType = ($invItemElement.Name).Split(" ")

                        $slot.SetAttribute("ItemCount", "0")
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.armor.boots.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.armor.boots.SetAttribute("equipped", "1")
                        $configList.xml.playerstats.armor.boots.SetAttribute("type", $helmetType[0])

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to boots slot"
                    }
                } else {
                    if ($configList.xml.playerstats.hand.HasChildNodes) {                    
                        #Change position
                        $invItemElement = $slot.FirstChild
                        $invItemCount = $slot.ItemCount
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $handItemElement = $configList.xml.playerstats.hand.FirstChild
                        $handItemCount = $configList.xml.playerstats.hand.ItemCount
                        $importHandItemElement = $configList.ImportNode($handItemElement, $true)

                        #$configList.xml.playerstats.hand.SetAttribute("ItemCount", "0")
                        $configList.xml.playerstats.hand.RemoveChild($handItemElement) | Out-Null
                        #$slot.SetAttribute("ItemCount", "0")
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.hand.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.hand.SetAttribute("ItemCount", $invItemCount)
                        $slot.AppendChild($importHandItemElement) | Out-Null
                        $slot.SetAttribute("ItemCount", $handItemCount)

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to hand"
                    } else {
                        #Equip item to hand
                        $invItemElement = $slot.FirstChild
                        $importInvItemElement = $configList.ImportNode($invItemElement, $true)
                        $itemCount = $slot.ItemCount

                        $slot.SetAttribute("ItemCount","0")
                        $slot.RemoveChild($invItemElement) | Out-Null

                        $configList.xml.playerstats.hand.AppendChild($importInvItemElement) | Out-Null
                        $configList.xml.playerstats.hand.SetAttribute("ItemCount", $itemCount)

                        $configList.Save($configFilePath)
                        return "Equipped $ItemBlock to hand"
                    }
                }
            }
        }
    }
    return "Didn't find the item $ItemBlock"
}

function Unequip {
    param(
        $Type
    )

    switch ($Type) {
        "hand" {
            #Sjekk om du har noe i hånda
            if ($configList.xml.playerstats.hand.HasChildNodes) {
                #Sjekk om det er plass i inventorien
                foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
                    if (-not ($slot.HasChildNodes)) {
                        #Flytt item til inventory slot
                        $handItemElement = $configList.xml.playerstats.hand.FirstChild
                        $importHandItemElement = $configList.ImportNode($handItemElement, $true)
                        $itemCount = $configList.xml.playerstats.hand.ItemCount

                        $configList.xml.playerstats.hand.SetAttribute("ItemCount", "0")
                        $configList.xml.playerstats.hand.RemoveChild($handItemElement) | Out-Null

                        $slot.AppendChild($importHandItemElement) | Out-Null
                        $slot.SetAttribute("ItemCount", $itemCount)

                        $configList.Save($configFilePath)
                        return "Unequipped from your hand"
                    }
                }
                return "No space in inventory"
            } else {
                return "Nothing equipped in hand"
            }
        }
        "helmet" {
            if ($configList.xml.playerstats.armor.helmet.HasChildNodes) {
                foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
                    if (-not ($slot.HasChildNodes)) {
                        $armorItemElement = $configList.xml.playerstats.armor.helmet.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)

                        $configList.xml.playerstats.armor.helmet.SetAttribute("equipped", "0")
                        $configList.xml.playerstats.armor.helmet.SetAttribute("type","")
                        $configList.xml.playerstats.armor.helmet.RemoveChild($armorItemElement) | Out-Null

                        $slot.AppendChild($importArmorItemElement) | Out-Null
                        $slot.SetAttribute("ItemCount", "1")

                        $configList.Save($configFilePath)
                        return "Unequipped from helmet slot"
                    }
                }
                return "No space in inventory"
            } else {
                return "Nothing equipped in helmet slot"
            }
        }
        "chestplate" {
            if ($configList.xml.playerstats.armor.chestplate.HasChildNodes) {
                foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
                    if (-not ($slot.HasChildNodes)) {
                        $armorItemElement = $configList.xml.playerstats.armor.chestplate.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)

                        $configList.xml.playerstats.armor.chestplate.SetAttribute("equipped", "0")
                        $configList.xml.playerstats.armor.chestplate.SetAttribute("type","")
                        $configList.xml.playerstats.armor.chestplate.RemoveChild($armorItemElement) | Out-Null

                        $slot.AppendChild($importArmorItemElement) | Out-Null
                        $slot.SetAttribute("ItemCount", "1")

                        $configList.Save($configFilePath)
                        return "Unequipped from chestplate slot"
                    }
                }
                return "No space in inventory"
            } else {
                return "Nothing equipped in chestplate slot"
            }
        }
        "leggings" {
            if ($configList.xml.playerstats.armor.leggings.HasChildNodes) {
                foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
                    if (-not ($slot.HasChildNodes)) {
                        $armorItemElement = $configList.xml.playerstats.armor.leggings.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)

                        $configList.xml.playerstats.armor.leggings.SetAttribute("equipped", "0")
                        $configList.xml.playerstats.armor.leggings.SetAttribute("type","")
                        $configList.xml.playerstats.armor.leggings.RemoveChild($armorItemElement) | Out-Null

                        $slot.AppendChild($importArmorItemElement) | Out-Null
                        $slot.SetAttribute("ItemCount", "1")

                        $configList.Save($configFilePath)
                        return "Unequipped from leggings slot"
                    }
                }
                return "No space in inventory"
            } else {
                return "Nothing equipped in leggings slot"
            }
        }
        "boots" {
            if ($configList.xml.playerstats.armor.boots.HasChildNodes) {
                foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
                    if (-not ($slot.HasChildNodes)) {
                        $armorItemElement = $configList.xml.playerstats.armor.boots.FirstChild
                        $importArmorItemElement = $configList.ImportNode($armorItemElement, $true)

                        $configList.xml.playerstats.armor.boots.SetAttribute("equipped", "0")
                        $configList.xml.playerstats.armor.boots.SetAttribute("type","")
                        $configList.xml.playerstats.armor.boots.RemoveChild($armorItemElement) | Out-Null

                        $slot.AppendChild($importArmorItemElement) | Out-Null
                        $slot.SetAttribute("ItemCount", "1")

                        $configList.Save($configFilePath)
                        return "Unequipped from boots slot"
                    }
                }
                return "No space in inventory"
            } else {
                return "Nothing equipped in boots slot"
            }
        }
        "armor" {
            return "Not implementet yet"
        }
        "all" {
            return "Not implementet yet"
        }
        default {
            return "What do you mean by: Unequip $($Type)?$(foreach ($commandLine in $commandList) { if ($commandLine -like "Unequip*") { "`n$commandLine" } } )"
        }
    }
}

function List-ToConsole {
    param(
        $Object
    )

    switch ($Object.ToLower()) {
        {($_ -eq "inv") -or ($_ -eq "inventory")} {
            $inventory = $configList.xml.playerstats.inventory.ChildNodes

            $inventoryItems = @{slotName = @(); itemCount = @(); itemName = @()}
            for ($i = 0; $i -lt $inventory.Count; $i++) {
                $slotName = ($inventory[$i].Name).TrimStart("slot")
                $itemCount = $inventory[$i].ItemCount
                $itemName = $inventory[$i].FirstChild.Name

                $inventoryItems.slotName += $slotName
                $inventoryItems.itemCount += $itemCount
                if (($inventory[$i].ChildNodes.Count) -eq 0) { $inventoryItems.itemName += "Empty" } else { $inventoryItems.itemName += $itemName }
            };$i=0

            if ($configList.xml.playerstats.hand.HasChildNodes) {
                $returnHandContent = "Hand content:$(
                    foreach ($slot in $configList.xml.playerstats.hand.ChildNodes) {
                        "`n┌───────┬─────────┐"
                        "`n|Hand   |Count$(if(($slot.ParentNode.ItemCount).Length -eq 1){"   $($slot.ParentNode.ItemCount)"}elseif(($slot.ParentNode.ItemCount).Length -eq 2){"  $($slot.ParentNode.ItemCount)"}elseif(($slot.ParentNode.ItemCount).Length -eq 3){" $($slot.ParentNode.ItemCount)"} )|"
                        "`n├───────┴─────────┤"
                        "`n|$(if($slot.name.Length -gt 3){"$($slot.name)$(for ($j = 0; $j -lt (18 - ($slot.name).Length); $j++) {''})"}elseif($slot.name.Length -lt 3){"Empty            "};$j=0)|"
                        "`n└─────────────────┘"
                    }
                )"
            } else {
                $returnHandContent = ""
            }
            
            $returnContent = "`nInventory content:$(
                for ($i = 0; $i -lt (27 / 3); $i++) {                    
                    "`n┌───────┬─────────┐┌───────┬─────────┐┌───────┬─────────┐"
                    
                    $firstSlot = $inventoryItems.slotName[($i * 3)]
                    $firstCount = $inventoryItems.itemCount[($i * 3)]
                    $firstItem = $inventoryItems.itemName[($i * 3)]
                    $secondSlot = $inventoryItems.slotName[($i * 3) + 1]
                    $secondCount = $inventoryItems.itemCount[($i * 3) + 1]
                    $secondItem = $inventoryItems.itemName[($i * 3) + 1]
                    $thirdSlot = $inventoryItems.slotName[($i * 3) + 2]
                    $thirdCount = $inventoryItems.itemCount[($i * 3) + 2]
                    $thirdItem = $inventoryItems.itemName[($i * 3) + 2]

                    "`n|Slot$(if($firstSlot.Length -eq 1){"  $firstSlot"}elseif($firstSlot.Length -eq 2){" $firstSlot"})|Count$(if($firstCount.Length -eq 1){"   $firstCount"}elseif($firstCount.Length -eq 2){"  $firstCount"}elseif($firstCount.Length -eq 3){" $firstCount"})||Slot$(if($secondSlot.Length -eq 1){"  $secondSlot"}elseif($secondSlot.Length -eq 2){" $secondSlot"})|Count$(if($secondCount.Length -eq 1){"   $secondCount"}elseif($secondCount.Length -eq 2){"  $secondCount"}elseif($secondCount.Length -eq 3){" $secondCount"})||Slot$(if($thirdSlot.Length -eq 1){"  $thirdSlot"}elseif($thirdSlot.Length -eq 2){" $thirdSlot"})|Count$(if($thirdCount.Length -eq 1){"   $thirdCount"}elseif($thirdCount.Length -eq 2){"  $thirdCount"}elseif($thirdCount.Length -eq 3){" $thirdCount"})|"
                    "`n├───────┴─────────┤├───────┴─────────┤├───────┴─────────┤"
                    "`n|$(if($firstItem.Length -gt 3){"$firstItem$(for ($j = 0; $j -lt (18 - ($firstItem).Length); $j++) {''})"}elseif($firstItem.Length -lt 3){"Empty            "};$j=0)||$(if($secondItem.Length -gt 3){"$secondItem$(for ($j = 0; $j -lt (18 - ($secondItem).Length); $j++) {''})"}elseif($secondItem.Length -lt 3){"Empty            "};$j=0)||$(if($thirdItem.Length -gt 3){"$thirdItem$(for ($j = 0; $j -lt (18 - ($thirdItem).Length); $j++) {''})"}elseif($thirdItem.Length -lt 3){"Empty            "};$j=0)|"
                    "`n└─────────────────┘└─────────────────┘└─────────────────┘"
                }
            )"
            return $returnHandContent + $returnContent
        }
        default {
            return "What do you mean by: List $($Object)?$(foreach ($commandLine in $commandList) { if ($commandLine -like "List*") { "`n$commandLine" } } )"
        }
    }
}

function Chop {
    param(
        $Object
    )
    
    switch ($Object) {
        "tree" {
            #Sjekk hva man holder
            if ($configList.xml.playerstats.hand.ChildNodes.Count -eq 0) {
                $amount = Get-Random -Minimum 1 -Maximum 4

                return "You hit the tree with your hands`n$(Add-ToInventory -Name "wood" -Type "blocks" -Amount $amount)"
            } else {
                #Sjekk om det er en øks
                if ($configList.xml.playerstats.hand.FirstChild.name -like "* Axe*") {
                    #Finn ut hva slags type øks det er                 
                    if ($configList.xml.playerstats.hand.FirstChild.name -like "Wooden*") {
                        $amount = Get-Random -Minimum 4 -Maximum 7

                        return "You hit the tree with your Wooden Axe`n$(Add-ToInventory -Name "wood" -Type "blocks" -Amount $amount)$(Calc-Durability -PlayerSlot Hand -Damage $amount)"
                    } elseif ($configList.xml.playerstats.hand.FirstChild.name -like "Stone*") {
                        $amount = Get-Random -Minimum 7 -Maximum 10

                        return "You hit the tree with your Stone Axe`n$(Add-ToInventory -Name "wood" -Type "blocks" -Amount $amount)$(Calc-Durability -PlayerSlot Hand -Damage $amount)"
                    } elseif ($configList.xml.playerstats.hand.FirstChild.name -like "Gold*") {
                        $amount = Get-Random -Minimum 7 -Maximum 10

                        return "You hit the tree with your Gold Axe`n$(Add-ToInventory -Name "wood" -Type "blocks" -Amount $amount)$(Calc-Durability -PlayerSlot Hand -Damage $amount)"
                    } elseif ($configList.xml.playerstats.hand.FirstChild.name -like "Iron*") {
                        $amount = Get-Random -Minimum 10 -Maximum 13

                        return "You hit the tree with your Iron Axe`n$(Add-ToInventory -Name "wood" -Type "blocks" -Amount $amount)$(Calc-Durability -PlayerSlot Hand -Damage $amount)"
                    } elseif ($configList.xml.playerstats.hand.FirstChild.name -like "Diamond*") {
                        $amount = Get-Random -Minimum 13 -Maximum 16

                        return "You hit the tree with your Diamond Axe`n$(Add-ToInventory -Name "wood" -Type "blocks" -Amount $amount)$(Calc-Durability -PlayerSlot Hand -Damage $amount)"
                    }
                    
                    return "You're holding an axe!"
                } else {
                    $amount = Get-Random -Minimum 1 -Maximum 3
                    
                    return "You hit the tree with your $($configList.xml.playerstats.hand.FirstChild.name), it's not very effective`n$(Add-ToInventory -Name "wood" -Type "blocks" -Amount $amount)"
                }
            }
        }
        default {
            return "What?"
        }
    }
}

function Calc-Durability {
    param(
        [ValidateSet("Hand","Armor")]$PlayerSlot,
        $Damage
    )

    if ($PlayerSlot -eq "Hand") {
        $handElement = $configList.xml.playerstats.hand.FirstChild
        [int]$handElementDurability = $handElement.durability

        #$handElement.durability.value = "$($handElementDurability - $Damage)"

        if (($handElementDurability - $Damage) -le 0) {
            #Da er den ødelagt
            $configList.xml.playerstats.hand.RemoveChild($handElement) | Out-Null
            $configList.xml.playerstats.hand.SetAttribute("ItemCount", "0")

            $configList.Save($configFilePath)
            return "`n$($handElement.Name) broke"
        } else {
            #Durability går ned
            $handElement.SetAttribute("durability", $($handElementDurability - $Damage))

            $configList.Save($configFilePath)
            return
        }

        return
    } elseif ($PlayerSlot -eq "Armor") {
    
    }
}

function Remove-FromInventory {
    param(
        $Name,
        [int]$Amount
    )

    foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
        if ($slot.HasChildNodes) {
            if (($slot.FirstChild.Name).ToLower() -eq $Name.ToLower()) {
                [int]$slotAmount = $slot.ItemCount

                if ($Amount -lt $slotAmount) {
                    $slot.SetAttribute("ItemCount", $($slotAmount - $Amount))

                    $configList.Save($configFilePath)
                    return "-$($Amount) $($Name)"
                } elseif ($Amount -eq $slotAmount) {
                    $element = $slot.FirstChild

                    $slot.SetAttribute("ItemCount", "0")
                    $slot.RemoveChild($element) | Out-Null

                    $configList.Save($configFilePath)
                    return "-$($Amount) $($Name)"
                } else {
                    $amountLeft = $slotAmount - $Amount
                    $element = $slot.FirstChild

                    $slot.SetAttribute("ItemCount", "0")
                    $slot.RemoveChild($element) | Out-Null

                    $configList.Save($configFilePath)
                    return "-$($Amount) $($Name)`n$(Remove-FromInventory -Name $Name -Type $Type -Amount $Amount)"
                }
            }
        }
    }

    return "Can't find the item '$Name' in your inventory??"
}

function Add-ToInventory {
    param(
        $Name,
        $Type,
        [int]$Amount
    )
    
    foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
        if ($slot.HasChildNodes) {
            if ($slot.FirstChild.Name -eq $Name) {
                if ($itemList.xml.$($Type).$($Name).maxstack) { [int]$maxCount = $itemList.xml.$($Type).$($Name).maxstack }
                else { [int]$maxCount = 1 }

                [int]$slotAmount = $slot.ItemCount
                $amountFreeSpace = $maxCount - $slotAmount

                if (-not ($amountFreeSpace -le 0)) {
                    if ($Amount -le $amountFreeSpace) {
                        $slot.SetAttribute("ItemCount", $($slotAmount + $Amount))

                        $configList.Save($configFilePath)
                        return "+$($Amount) $($Name)"
                    } else {
                        $amountLeft = $Amount - $amountFreeSpace

                        $slot.SetAttribute("ItemCount", $($maxCount))

                        $configList.Save($configFilePath)
                        return "+$($amountFreeSpace) $($Name)`n$(Add-ToInventory -Name $Name -Type $Type -Amount $amountLeft)"
                    }
                }
            }
        }
    }

    #Kommer hit hvis den ikke finner noen items i inv eller at alle er fulle
    foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
        if (-not ($slot.HasChildNodes)) {
            if ($itemList.xml.$($Type).$($Name).maxstack) { [int]$maxCount = $itemList.xml.$($Type).$($Name).maxstack }
            else { [int]$maxCount = 1 }

            if ($Amount -le $maxCount) {
                $element = $itemList.xml.$($Type).$($Name)
                $importElement = $configList.ImportNode($element, $true)

                $slot.AppendChild($importElement) | Out-Null
                $slot.SetAttribute("ItemCount", $Amount)

                $configList.Save($configFilePath)
                return "+$($Amount) $($Name)"
            } else {
                $AmountLeft = $Amount - $maxCount

                $element = $itemList.xml.$($Type).$($Name)
                $importElement = $configList.ImportNode($element, $true)

                $slot.AppendChild($importElement) | Out-Null
                $slot.SetAttribute("ItemCount", $maxCount)

                $configList.Save($configFilePath)
                return "+$($maxCount) $($Name)`n$(Add-ToInventory -Name $Name -Type $Type -Amount $AmountLeft)"
            }
        }
    }

    #Finner ingen plass til å plassere items
    return "You don't have room for the items, you therefore left it on the ground"
}

function Craft {
    param(
        $ItemBlock
    )

    switch ($ItemBlock) {
        "Wooden Planks" {
            $craftTypeName = "woodenplanks"
            $craftType = "blocks"
        }
        "Stick" {
            $craftTypeName = "stick"
            $craftType = "items"
        }
        "Wooden Pickaxe" {
            $craftTypeName = "pickaxewood"
            $craftType = "items"
        }
        "Stone Pickaxe" {
            $craftTypeName = "pickaxestone"
            $craftType = "items"
        }
        "Gold Pickaxe" {
            $craftTypeName = "pickaxegold"
            $craftType = "items"
        }
        "Iron Pickaxe" {
            $craftTypeName = "pickaxeiron"
            $craftType = "items"
        }
        "Diamond Pickaxe" {
            $craftTypeName = "pickaxediamond"
            $craftType = "items"
        }
        default {
            return "Can't find the crafting recipe for: $ItemBlock"
        }
    }

    $items = @{ItemName = @(); ItemCount = @()}
            
    foreach ($attr in $itemList.xml.craftingrecipes.$($craftTypeName).Attributes) {
        if ($attr.Name -ne "returnamount") {
            $items.ItemName += ($attr.Name).ToLower()
            $items.ItemCount += [int]$attr.Value
        }
    }

    $ok = $false
    for ($i = 0; $i -lt $items.ItemName.Count; $i++) {
        $totalItemInvCount = 0
        foreach ($slot in $configList.xml.playerstats.inventory.ChildNodes) {
            if ($slot.HasChildNodes) {
                if (($slot.FirstChild.Name).ToLower() -eq $items.ItemName[$i]) {
                    [int]$slotItemCount = $slot.ItemCount
                    $totalItemInvCount += $slotItemCount
                }
            }
        }
        if ($totalItemInvCount -ge $items.ItemCount[$i]) { $ok = $true }
        else { $ok = $false;break }
    };$i=0

    if ($ok) { 
        [int]$returnAmount = $itemList.xml.craftingrecipes.$($craftTypeName).returnamount
        
        Return "$(foreach($attr in $itemList.xml.craftingrecipes.$($craftTypeName).Attributes){[int]$attribVal = $attr.value;if($attr.Name -ne "returnamount"){if((($itemList.xml.craftingrecipes.$($craftTypeName).Attributes).Count - 1) -gt 1){"`n$(Remove-FromInventory -Name $attr.Name -Amount $attribVal)"}else{Remove-FromInventory -Name $attr.Name -Amount $attribVal}}})`n$(Add-ToInventory -Name $craftTypeName -Type $craftType -Amount $returnAmount)"
    } else { 
        return "Not enough to craft $ItemBlock"
    }

    
}

function Run-Command {
    param(
        $Command,
        $XMLDocument = $configList
    )

    switch -wildcard ($Command) {        
        "Craft*" {
            $CommandBits = $Command.Split(" ")

            switch ($CommandBits[1]) {
                default {
                    if ($CommandBits[1].Length -gt 0) {
                        if ($CommandBits[2]) { $ChosenCraft = $CommandBits[1] + " " + $CommandBits[2] }
                        else { $ChosenCraft = $CommandBits[1] }

                        $script:actionMessage = "$(Craft -ItemBlock $ChosenCraft)"
                        Load-MainHud
                    } else {
                        $script:actionMessage = "You need to specify what you want to craft$(foreach ($commandLine in $commandList) { if ($commandLine -like "Craft*") { "`n$commandLine" } })"
                        Load-MainHud
                    }
                }
            }
        }
        "Chop*" {
            $CommandBits = $Command.Split(" ")
            
            switch ($CommandBits[1]) {
                default {
                    if ($CommandBits[1].Length -gt 0) {
                        if ($CommandBits[2]) { $Object = $CommandBits[1] + " " + $CommandBits[2] }
                        else { $Object = $CommandBits[1] }
                        
                        $script:actionMessage = "$(Chop -Object $Object)"
                        Load-MainHud
                    } else {
                        $script:actionMessage = "You need to specify what you want to chop$(foreach ($commandLine in $commandList) { if ($commandLine -like "Chop*") { "`n$commandLine" } })"
                        Load-MainHud
                    }
                    
                }
            }    
        }
        "Equip*" {
            $CommandBits = $Command.Split(" ")

            switch ($CommandBits[1]) {
                default {                    
                    if ($CommandBits[1].Length -gt 0) {
                        if ($CommandBits[2]) { $ItemBlock = $CommandBits[1] + " " + $CommandBits[2] }
                        else { $ItemBlock = $CommandBits[1] }
                        
                        $script:actionMessage = "$(Equip-ItemBlock -ItemBlock $ItemBlock)"
                        Load-MainHud
                    } else {
                        $script:actionMessage = "You need to specify what you want to equip$(foreach ($commandLine in $commandList) { if ($commandLine -like "Equip*") { "`n$commandLine" } })"
                        Load-MainHud
                    }
                }
            }
        }
        "Unequip*" {
            $CommandBits = $Command.Split(" ")

            switch ($CommandBits[1]) {
                default {
                    if ($CommandBits[1].Length -gt 0) {
                        $script:actionMessage = "$(Unequip -Type $CommandBits[1])"
                        Load-MainHud
                    } else {
                        $script:actionMessage = "You need to specify what you want to unequip?$(foreach ($commandLine in $commandList) { if ($commandLine -like "Unequip*") { "`n$commandLine" } })"
                        Load-MainHud    
                    }
                }
            }
        }
        "List*" {
            $CommandBits = $Command.Split(" ")

            switch ($CommandBits[1]) {
                default {
                    if ($CommandBits[1].Length -gt 0) {
                        $script:actionMessage = "$(List-ToConsole -Object $CommandBits[1])"
                        Load-MainHud
                    } else {
                        $script:actionMessage = "List what?$(foreach ($commandLine in $commandList) { if ($commandLine -like "List*") { "`n$commandLine" } } )"
                        Load-MainHud
                    }
                }
            }
        }
        "help*" {
            $CommandBits = $Command.Split(" ")

            if ($CommandBits[1].Length -gt 0) {
                $script:actionMessage = "$(foreach ($commandLine in $commandList) { if ($commandLine -like "$($CommandBits[1])*") { "`n$commandLine" } } )"
                Load-MainHud
            } else {
                $script:actionMessage = "Help with what?$(foreach ($commandLine in $commandList) { if ($commandLine -like "Help*") { "`n$commandLine" } } )"
                Load-MainHud
            }
        }
        "get commands" {
            $script:actionMessage = "PowerCraft Commands:`n$(foreach ($commandLine in $commandList) { "`t$commandLine`n" })"
            Load-MainHud
        }
        "Refresh" {
            $script:actionMessage = "Refreshed"
            Load-ConfigFile -Path $configFilePath
        }
        "exit" {
            $quitAnswer = Read-Host "Are you sure you want to quit? [Y/N]"
            switch ($quitAnswer) {
                "Y" { exit }
                "yes" { exit }
                default {
                    Load-MainHud
                }
            }
        }
        default {
            $script:actionMessage = "What!? IDK what you want, try again ;)"
            Load-MainHud
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
"██████╗  ██████╗ ██╗    ██╗███████╗██████╗  ██████╗██████╗  █████╗ ███████╗████████╗
██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝
██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██║     ██████╔╝███████║█████╗     ██║   
██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║     ██╔══██╗██╔══██║██╔══╝     ██║   
██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║╚██████╗██║  ██║██║  ██║██║        ██║   
╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   
                                                                By: Thomas Waaler
                                                                
                                                                
                                                                
Loading game..."

Load-ItemList -Path $defaultItemsFilePath
Load-EntityList -Path $entityFilePath
Load-ConfigFile -Path $configFilePath