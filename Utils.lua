local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local function toString(offNote, ep, gp)
    local newEPGP = 'cep{' .. (tonumber(ep) or store().BaseEP) .. ',' .. (tonumber(gp) or store().BaseGP) .. '}';

    if not offNote then
        return newEPGP;
    end

    local newOffNote, subs = string.gsub(offNote, 'cep{[^}]*}', newEPGP);

    if subs == 0 then
        newOffNote = newEPGP + offNote;
    end

    return newOffNote;
end

local LOCS = {
    INVTYPE_AMMO = { 0 },
    INVTYPE_HEAD = { 1 },
    INVTYPE_NECK = { 2 },
    INVTYPE_SHOULDER = { 3 },
    INVTYPE_BODY = { 4 },
    INVTYPE_CHEST = { 5 },
    INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 5 },
    INVTYPE_LEGS = { 7 },
    INVTYPE_FEET = { 8 },
    INVTYPE_WRIST = { 9 },
    INVTYPE_HAND = { 10 },
    INVTYPE_FINGER = { 11, 12 },
    INVTYPE_TRINKET = { 13, 14 },
    INVTYPE_CLOAK = { 15 },
    INVTYPE_WEAPON = { 16, 17 },
    INVTYPE_SHIELD = { 17 },
    INVTYPE_2HWEAPON = { 16 },
    INVTYPE_WEAPONMAINHAND = { 16 },
    INVTYPE_WEAPONOFFHAND = { 17 },
    INVTYPE_HOLDABLE = { 17 },
    INVTYPE_RANGED = { 18 },
    INVTYPE_THROWN = { 18 },
    INVTYPE_RANGEDRIGHT = { 18 },
    INVTYPE_RELIC = { 18 },
    INVTYPE_TABARD = { 19 },
};

local TOKENS = {
    [18423] = 'INVTYPE_TRINKET', -- of Onyxia (Alliance) -- Can also be a neck and ring
    [18422] = 'INVTYPE_TRINKET', -- of Onyxia (Horde) -- Same deal
    [19802] = 'INVTYPE_TRINKET', -- Heart of Hakkar
    [22520] = 'INVTYPE_TRINKET', -- Phylactery of Kel'Thuzad
    [21220] = 'INVTYPE_NECK', -- of Ossirian the Unscarred
    [21221] = 'INVTYPE_NECK', -- Eye of C'Thun -- Can also be a cloak or ring
    [19003] = 'INVTYPE_HOLDABLE', -- of Nefarian (Alliance) -- Can also be neck and ring
    [19002] = 'INVTYPE_HOLDABLE', -- of Nefarian (Horde) -- Same deal
    [19717] = 'INVTYPE_WRIST', -- Armsplint
    [19716] = 'INVTYPE_WRIST', -- Bindings
    [19718] = 'INVTYPE_WRIST', -- Stanchion
    [19719] = 'INVTYPE_WAIST', -- Girdle
    [19720] = 'INVTYPE_WAIST', -- Sash
    [19724] = 'INVTYPE_CHEST', -- Aegis
    [19723] = 'INVTYPE_CHEST', -- Kossack
    [19722] = 'INVTYPE_CHEST', -- Tabard
    [19721] = 'INVTYPE_SHOULDER', -- Shawl
    [20885] = 'INVTYPE_CLOAK', -- Martial Drake
    [20889] = 'INVTYPE_CLOAK', -- Regal Drape
    [20888] = 'INVTYPE_FINGER', -- Ceremonial Ring
    [20884] = 'INVTYPE_FINGER', -- Magisterial Ring
    [20886] = 'INVTYPE_WEAPONOFFHAND', -- Spiked Hilt -- Exceptions apply - Paladin / Shaman weapon are main hand
    [21232] = 'INVTYPE_WEAPONOFFHAND', -- Imperial Qiraji Armaments -- Can also be a ranged weapon or shield
    [20890] = 'INVTYPE_WEAPONMAINHAND', -- Ornate Hilt
    [21237] = 'INVTYPE_2HWEAPON', -- Imperial Qiraji Regalia -- Can also be a one-handed weapon
    [20928] = 'INVTYPE_FEET', -- Qiraji Bindings of Command -- Can also be shoulders
    [20932] = 'INVTYPE_FEET', -- Qiraji Bindings of Dominance -- same deal
    [20933] = 'INVTYPE_CHEST', -- Husk of the Old God
    [20929] = 'INVTYPE_CHEST', -- Carapace of the Old God
    [20927] = 'INVTYPE_LEGS', -- Ouro's Intact Hide
    [20931] = 'INVTYPE_LEGS', -- Skin of the Great Sandworm
    [22368] = 'INVTYPE_SHOULDER', -- Shoulderpads
    [22354] = 'INVTYPE_SHOULDER', -- Pauldrons
    [22361] = 'INVTYPE_SHOULDER', -- Spaulders
    [22372] = 'INVTYPE_FEET', -- Sandals
    [22365] = 'INVTYPE_FEET', -- Boots
    [22358] = 'INVTYPE_FEET', -- Sabatons
    [22369] = 'INVTYPE_WRIST', -- Bindings
    [22362] = 'INVTYPE_WRIST', -- Wristguards
    [22355] = 'INVTYPE_WRIST', -- Bracers
    [22357] = 'INVTYPE_HAND', -- Gauntlets
    [22364] = 'INVTYPE_HAND', -- Handguards
    [22371] = 'INVTYPE_HAND', -- Gloves
    [22363] = 'INVTYPE_WAIST', -- Girdle
    [22370] = 'INVTYPE_WAIST', -- Belt
    [22356] = 'INVTYPE_WAIST', -- Waistguard
    [22359] = 'INVTYPE_LEGS', -- Legguards
    [22352] = 'INVTYPE_LEGS', -- Legplates
    [22366] = 'INVTYPE_LEGS', -- Leggings
    [22367] = 'INVTYPE_HEAD', -- Circlet
    [22360] = 'INVTYPE_HEAD', -- Headpiece
    [22353] = 'INVTYPE_HEAD', -- Helmet
    [22350] = 'INVTYPE_CHEST', -- Tunic
    [22351] = 'INVTYPE_CHEST', -- Robe
    [22349] = 'INVTYPE_CHEST', -- Breastplate
};

local function toSlots(item)
    local token = TOKENS[item.id];

    return token and LOCS[token] or LOCS[item.loc];
end

local COLORS = {
    DEATHKNIGHT = { 0.77, 0.12, 0.23 },
    DEMONHUNTER = { 0.64, 0.19, 0.79 },
    DRUID = { 1.00, 0.49, 0.04 },
    HUNTER = { 0.67, 0.83, 0.45 },
    MAGE = { 0.25, 0.78, 0.92 },
    MONK = { 0.00, 1.00, 0.59 },
    PALADIN = { 0.96, 0.55, 0.73 },
    PRIEST = { 1.00, 1.00, 1.00 },
    ROGUE = { 1.00, 0.96, 0.41 },
    SHAMAN = { 0.00, 0.44, 0.87 },
    WARLOCK = { 0.53, 0.53, 0.93 },
    WARRIOR = { 0.78, 0.61, 0.43 },
    RAID = { 1, 0.5, 0 },
    GUILD = { 0.25, 1, 0.25 },
    GROUP = { 0.67, 0.67, 1 },
    SYSTEM = { 1, 1, 0 },
    DEFAULT = { 1, 1, 0 },
};

function ExG:ClassColor(class)
    local res = class and (COLORS[class] or COLORS['DEFAULT']) or COLORS['DEFAULT'];

    return unpack(res);
end

function ExG:NameColor(name)
    local info = self:GuildInfo(name);

    return ExG:ClassColor(info and info.class or 'DEFAULT');
end

function ExG:Copy(target, source)
    target = target or {};

    if not source then
        return target;
    end

    for i, v in pairs(source) do
        target[i] = v;
    end

    return target;
end

function ExG:Size(table)
    local result = 0;

    if not table then
        return result;
    end

    for _, v in pairs(table) do
        if v then
            result = result + 1;
        end
    end

    return result;
end

function ExG:IsMl(unit)
    if store().debug then
        return true;
    end

    if not IsInRaid() then
        return false;
    end

    local info = self:RaidInfo(unit);

    if info then
        return info.isMl;
    else
        return false;
    end
end

function ExG:GuildInfo(unit)
    if not IsInGuild() then
        return nil;
    end

    for i = 1, GetNumGuildMembers() do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i);

        name = Ambiguate(name, 'all');

        if name == unit then
            return {
                index = i,
                name = name,
                rankName = rankName,
                rankIndex = rankIndex,
                level = level,
                classDisplayName = classDisplayName,
                zone = zone,
                publicNote = publicNote,
                officerNote = officerNote,
                isOnline = isOnline,
                status = status,
                class = class,
                achievementPoints = achievementPoints,
                achievementRank = achievementRank,
                isMobile = isMobile,
                canSoR = canSoR,
                repStanding = repStanding,
                GUID = GUID
            };
        end
    end

    return nil;
end

function ExG:RaidInfo(unit)
    if not IsInRaid() then
        return nil;
    end

    unit = unit or self.state.name;

    for i = 1, MAX_RAID_MEMBERS do
        local name, rank, subgroup, level, classDisplayName, class, zone, online, isDead, role, isMl, combatRole = GetRaidRosterInfo(i);

        if name then
            name = Ambiguate(name, 'all');

            if unit == name then
                return {
                    index = i,
                    name = name,
                    rank = rank,
                    subgroup = subgroup,
                    level = level,
                    classDisplayName = classDisplayName,
                    class = class,
                    zone = zone,
                    online = online,
                    isDead = isDead,
                    role = role,
                    isMl = isMl,
                    combatRole = combatRole,
                };
            end
        end
    end

    return nil;
end

function ExG:ItemInfo(linkOrId)
    if not linkOrId then
        return nil;
    end

    local id = tonumber(linkOrId);

    if not id then
        local itemString = string.match(linkOrId, 'item[%-?%d:]+');

        if not itemString then
            return nil;
        end

        local _, tmp = strsplit(':', itemString);

        if not tmp then
            return nil;
        end

        id = tonumber(tmp);
    end

    if not id then
        return nil;
    end

    local name, link, rarity, level, minLevel, type, subtype, stackCount, loc, texture, sellPrice, classID, subClassID, bindType, expacID, setID, isCraftReg = GetItemInfo(id);

    if not name then
        return nil;
    end

    local item = {
        id = id,
        link = link,
        name = name,
        rarity = rarity,
        level = level,
        minLevel = minLevel,
        type = type,
        subtype = subtype,
        stackCount = stackCount,
        loc = loc,
        texture = texture,
        sellPrice = sellPrice,
        classID = classID,
        subClassID = subClassID,
        bindType = bindType,
        expacID = expacID,
        setID = setID,
        isCraftReg = isCraftReg
    };

    item.slots = toSlots(item);

    return item;
end

function ExG:Equipped(slots)
    if not slots then
        return nil;
    end

    local res = {};

    for _, v in ipairs(slots) do
        local info = self:ItemInfo(GetInventoryItemLink('player', v));

        tinsert(res, info and info.id);
    end

    return unpack(res);
end

function ExG:GetEG(offNote)
    local ep, gp;

    if not offNote then
        ep, gp = store().BaseEP, store().BaseGP;

        return { ep = ep, gp = gp, pr = floor(ep * 100 / gp) / 100, };
    end

    local ep, gp = string.match(offNote, 'cep{(-?%d+%.?%d*),(-?%d+%.?%d*)}');

    if ep and gp then
        ep, gp = tonumber(ep) or store().BaseEP, tonumber(gp) or store().BaseGP;

        return { ep = ep, gp = gp, pr = floor(ep * 100 / gp) / 100, };
    end

    ep, gp = store().BaseEP, store().BaseGP;

    return { ep = ep, gp = gp, pr = floor(ep * 100 / gp) / 100, };
end

function ExG:SetEG(info, ep, gp)
    if not info.index then
        return;
    end

    ep, gp = tonumber(ep) or store().BaseEP, tonumber(gp) or store().BaseGP;

    if store().debug then
        self:Print(L['ExG SetEG'](info.name, info, ep, gp));
    else
        GuildRosterSetOfficerNote(info.index, toString(info.officerNote, ep, gp));
    end

    return { ep = ep, gp = gp, pr = floor(ep * 100 / gp) / 100, };
end

function ExG:CalcGP(infoOrId)
    local id = tonumber(infoOrId);

    if not id then
        id = 0;
    end

    return 10;
end

function ExG:LootIndex(link)
    for i = 1, GetNumLootItems() do
        if link == GetLootSlotLink(i) then
            return i;
        end
    end

    return nil;
end
