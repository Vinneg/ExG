local L = LibStub('AceLocale-3.0'):NewLocale('ExG', 'enUS', true);

local eg = function(val, postfix)
    local tmp = tonumber(val);

    if (tmp or 0) == 0 then
        return '';
    end

    return format('%s%d %s', tmp < 0 and ' ' or ' +', tmp, strupper(postfix));
end

L['ExG'] = "Extended EPGP";
L['Roll Frame'] = 'Roll';
L['Inventory Frame'] = 'Inventory';
L['History Frame'] = function(page, total) return format('History. Page %d of %d.', (page or 0) + 1, total or 0); end;
L['Items Frame'] = function(page, total) return 'Items Settings. Page ' .. ((page or 0) + 1) .. ' of ' .. (total or 0) .. '.'; end;
L['Usage:'] = true;
L['to open Options frame'] = true;
L['to open Roster frame'] = true;
L['General'] = true;
L['Base EP'] = true;
L['Base GP'] = true;
L['Cancel'] = true;
L['Ok'] = true;
L['ExG Show GP'] = 'Show GP values on tooltips';
L['Unit Adjust Desc'] = function(type, diff, reason) return format('Individual %s%d %s%s', diff < 0 and '' or '+', diff, type or 'EP', (reason or '') == '' and '' or format(' (%s)', reason)); end;
L['ExG Tooltip GP value'] = function(gp) return format('GP value: %d', gp or 0); end;
L['Mass Operations'] = true;
L['Add Guild EPGP'] = true;
L['ExG Guid EG'] = function(ep, gp, desc) return format('Guild EPGP%s%s%s', eg(ep, 'EP'), eg(gp, 'GP'), (desc or '') == '' and '' or format(' (%s)', desc)); end;
L['Add Raid EPGP'] = true;
L['ExG Raid EG'] = function(ep, gp, desc) return format('Raid EPGP%s%s%s', eg(ep, 'EP'), eg(gp, 'GP'), (desc or '') == '' and '' or format(' (%s)', desc)); end;
L['Guild Decay'] = true;
L['Guild Decay Desc'] = function(decay) return format('Guild EPGP Decay by %d%%', (decay or 0) * 100); end;
L['ExG Items'] = 'Items';
L['Open Items Settings'] = true;
L['Items import text'] = true;
L['Items Loot Settings'] = 'Loot Settings';
L['Loot Threshold'] = true;
L['Loot Threshold Desc'] = 'Loot distribution threshold - selected quality and higher';
L['Close item on pass'] = true;
L['Items Formula'] = 'GP formula';
L['Items Formula Desc'] = '|cff33ff99COEF * BASE ^ [ (LEVEL / 26 + RARITY - 4) ] * SLOT * MOD|r';
L['Items Formula Coef'] = 'Formula coefficients';
L['Items coef'] = 'COEF';
L['Items base'] = 'BASE';
L['Items mod'] = 'MOD';
L['Items INVTYPE_HEAD'] = 'Head';
L['Items INVTYPE_NECK'] = 'Neck';
L['Items INVTYPE_SHOULDER'] = 'Shoulder';
L['Items INVTYPE_CLOAK'] = 'Back';
L['Items INVTYPE_CHEST'] = 'Chest';
L['Items INVTYPE_WRIST'] = 'Wrist';
L['Items INVTYPE_HAND'] = 'Hands';
L['Items INVTYPE_WAIST'] = 'Waist';
L['Items INVTYPE_LEGS'] = 'Legs';
L['Items INVTYPE_FEET'] = 'Feet';
L['Items INVTYPE_FINGER'] = 'Finger';
L['Items INVTYPE_TRINKET'] = 'Trinket';
L['Items INVTYPE_WEAPONMAINHAND'] = 'Weapon MH';
L['Items INVTYPE_WEAPONOFFHAND'] = 'Weapon OH';
L['Items INVTYPE_HOLDABLE'] = 'Holdable OH';
L['Items INVTYPE_WEAPON'] = 'Weapon 1H';
L['Items INVTYPE_2HWEAPON'] = 'Weapon 2H';
L['Items INVTYPE_SHIELD'] = 'Shield';
L['Items INVTYPE_RANGED'] = 'Ranged';
L['Items INVTYPE_WAND'] = 'Wand';
L['Items INVTYPE_RELIC'] = 'Relic';
L['Items INVTYPE_THROWN'] = 'Thrown';
L['ExG History'] = 'History';
L['History Common'] = 'Common';
L['History page size'] = 'Page size';
L['History Exchange'] = true;
L['History source player'] = 'Source player';
L['History source offset'] = 'Offset (days)';
L['History Pull Header'] = 'Pull player history';
L['History Pull'] = 'Pull';
L['Clear'] = true;
L['Open History'] = true;
L['Import History'] = true;
L['Import'] = true;
L['ExG Buttons'] = "Buttons";
L['Button 1'] = true;
L['Button 2'] = true;
L['Button 3'] = true;
L['Button 4'] = true;
L['Button 5'] = true;
L['Button 6'] = 'Pass button';
L['Disenchant'] = true;
L['ExG History Item'] = function(gp, option) return format('Add %d GP%s', gp or 0, option and (' (' .. option .. ')') or ''); end;
L['ExG History Item Disenchant'] = 'Disenchant';
L['Button Text'] = 'Text';
L['Button Ratio'] = 'Ratio';
L['Button Roll'] = 'Do roll';
L['Value must be a not empty string'] = true;
L['Value must be a number'] = true;
L['Value must be more than X'] = function(val) return format('Value must be more than %d', val or 0) end;
L['Player must be in guild'] = true;
L['Announce'] = true;
L['Refresh'] = true;
L['Date'] = '-';
L['Name'] = true;
L['Rank'] = true;
L['Class'] = true;
L['PR'] = true;
L['GP'] = true;
L['Master'] = true;
L['Description'] = true;
L['EP'] = true;
L['GP'] = true;
L['Amount'] = true;
L['Reason'] = true;
L['ExG Debug'] = 'Debug mode';
L['ExG Debug Desc'] = 'In debug mode, EP and GP values are not saved to officer notes';
L['ExG Bosses'] = 'Bosses';
L['ExG Bosses MC'] = 'Molten Core';
L['ExG Bosses BWL'] = 'Blackwing Lair';
L['ExG Bosses ZG'] = 'Zul\'Gurub';
L['ExG Bosses AK20'] = 'Ruins of Ahn\'Qiraj';
L['ExG Bosses AK40'] = 'Ahn\'Qiraj';
L['ExG Bosses NAXX'] = 'Naxxramas';
L['ExG Bosses OTHER'] = 'Other';
L['ExG History RAID'] = 'Raid';
L['RAID'] = 'Raid';
L['Raid'] = 'Raid';
L['ExG History GUILD'] = 'Guild';
L['GUILD'] = 'Guild';
L['Guild'] = 'Guild';
L['ExG History Boss End'] = function(boss, ep) return 'Raid EP ' .. (ep < 0 and '' or '+') .. (ep or 0) .. ' for ' .. (boss or 'Unknown'); end;
L['History pulled'] = function(data) return '|cff33ff99Pull history from ' .. (data.source or 'unknown') .. ' for last ' .. (data.offset or 0) .. ' days.|r'; end;
L['History imported'] = function(data) return '|cff33ff99Imported ' .. (data.count or 0) .. ' history entries. From ' .. date('%d.%m %H:%M:%S', data.min) .. ' to ' .. date('%d.%m %H:%M:%S', data.max) .. '.|r'; end;
L['Pretenders'] = function(roll, attend) return '|cff33ff99Pretenders ' .. (roll or 0) .. ' of ' .. (attend or 0) .. '|r'; end;
L['Total imported'] = function(count) return 'Total history record imported: ' .. (count or 0); end;
L['History EG'] = function(eg) if not eg then return '' end if (eg.before or 0) == (eg.after or 0) then return '' .. (eg.before or '') else return '' .. (eg.before or 0) .. ' > ' .. (eg.after or 0) end end;
L['View Guild'] = true;
L['View Raid'] = true;
L['View Options'] = true;
L['Class Filter'] = true;
L['Rank Filter'] = true;
L['DEATHKNIGHT'] = 'Death Knight';
L['WARRIOR'] = 'Warrior';
L['ROGUE'] = 'Rogue';
L['MAGE'] = 'Mage';
L['PRIEST'] = 'Priest';
L['WARLOCK'] = 'Warlock';
L['HUNTER'] = 'Hunter';
L['SHAMAN'] = 'Shaman';
L['DRUID'] = 'Druid';
L['MONK'] = 'Monk';
L['PALADIN'] = 'Paladin';

L['Poor'] = '|cff9d9d9dPoor|r';
L['Common'] = '|cffffffffCommon|r';
L['Uncommon'] = '|cff1eff00Uncommon|r';
L['Rare'] = '|cff0070ddRare|r';
L['Epic'] = '|cffa335eeEpic|r';
L['Legendary'] = '|cffff8000Legendary|r';
L['Artifact'] = '|cffe6cc80Artifact|r';
L['ExG Boss 785'] = 'High Priestess Jeklik';
L['ExG Boss 784'] = 'High Priest Venoxis';
L['ExG Boss 786'] = 'High Priestess Mar\'li';
L['ExG Boss 787'] = 'Bloodlord Mandokir';
L['ExG Boss 788'] = 'Edge of Madness';
L['ExG Boss 789'] = 'High Priest Thekal';
L['ExG Boss 790'] = 'Gahz\'ranka';
L['ExG Boss 791'] = 'High Priestess Arlokk';
L['ExG Boss 792'] = 'Jin\'do the Hexxer';
L['ExG Boss 793'] = 'Hakkar';
L['ExG Boss 663'] = 'Lucifron';
L['ExG Boss 664'] = 'Magmadar';
L['ExG Boss 665'] = 'Gehennas';
L['ExG Boss 666'] = 'Garr';
L['ExG Boss 667'] = 'Shazzrah';
L['ExG Boss 668'] = 'Baron Geddon';
L['ExG Boss 669'] = 'Sulfuron Harbinger';
L['ExG Boss 670'] = 'Golemagg the Incinerator';
L['ExG Boss 671'] = 'Majordomo Executus';
L['ExG Boss 672'] = 'Ragnaros';
L['ExG Boss 610'] = 'Razorgore the Untamed';
L['ExG Boss 611'] = 'Vaelastrasz the Corrupt';
L['ExG Boss 612'] = 'Broodlord Lashlayer';
L['ExG Boss 613'] = 'Firemaw';
L['ExG Boss 614'] = 'Ebonroc';
L['ExG Boss 615'] = 'Flamegor';
L['ExG Boss 616'] = 'Chromaggus';
L['ExG Boss 617'] = 'Nefarian';
L['ExG Boss 718'] = 'Kurinnaxx';
L['ExG Boss 719'] = 'General Rajaxx';
L['ExG Boss 720'] = 'Moam';
L['ExG Boss 721'] = 'Buru the Gorger';
L['ExG Boss 722'] = 'Ayamiss the Hunter';
L['ExG Boss 723'] = 'Ossirian the Unscarred';
L['ExG Boss 709'] = 'The Prophet Skeram';
L['ExG Boss 710'] = 'The Silithid Royalty';
L['ExG Boss 711'] = 'Battleguard Sartura';
L['ExG Boss 712'] = 'Fankriss the Unyielding';
L['ExG Boss 713'] = 'Viscidus';
L['ExG Boss 714'] = 'Princess Huhuran';
L['ExG Boss 715'] = 'The Twin Emperors';
L['ExG Boss 716'] = 'Ouro';
L['ExG Boss 717'] = 'C\'Thun';
L['ExG Boss 1084'] = 'Onyxia';
L['ExG Boss 1107'] = 'Anub\'Rekhan';
L['ExG Boss 1110'] = 'Grand Widow Faerlina';
L['ExG Boss 1116'] = 'Maexxna';
L['ExG Boss 1117'] = 'Noth the Plaguebringer';
L['ExG Boss 1112'] = 'Heigan the Unclean';
L['ExG Boss 1115'] = 'Loatheb';
L['ExG Boss 1113'] = 'Instructor Razuvious';
L['ExG Boss 1109'] = 'Gothik the Harvester';
L['ExG Boss 1121'] = 'The Four Horsemen';
L['ExG Boss 1118'] = 'Patchwerk';
L['ExG Boss 1111'] = 'Grobbulus';
L['ExG Boss 1108'] = 'Gluth';
L['ExG Boss 1120'] = 'Thaddius';
L['ExG Boss 1119'] = 'Sapphiron';
L['ExG Boss 1114'] = 'Kel\'Thuzad';
