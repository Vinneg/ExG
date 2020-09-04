local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local function getEG(ep, gp)
    local resEp, resGp = tonumber(ep) or store().baseEP, tonumber(gp) or store().baseGP;

    return max(resEp, store().baseEP), max(resGp, store().baseGP);
end

local function toString(info, ep, gp)
    local newEPGP = 'cep{' .. ep .. ',' .. gp .. '}';

    if (info.officerNote or '') == '' then
        return newEPGP;
    end

    local newOffNote, subs = string.gsub(info.officerNote, 'cep{[^}]*}', newEPGP);

    if subs == 0 then
        newOffNote = newEPGP .. info.officerNote;
    end

    return newOffNote;
end

local LINK_PATTERN = '|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?';

local LOCS_OVER = {
    INVTYPE_ROBE = 'INVTYPE_ROBE',
};

local LOCS = {
    INVTYPE_AMMO = { 0 },
    INVTYPE_HEAD = { 1 },
    INVTYPE_NECK = { 2 },
    INVTYPE_SHOULDER = { 3 },
    INVTYPE_BODY = { 4 },
    INVTYPE_CHEST = { 5 },
    INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 6 },
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
    [18423] = { loc = 'INVTYPE_TRINKET', level = 74 }, -- of Onyxia (Alliance) -- Can also be a neck and ring
    [18422] = { loc = 'INVTYPE_TRINKET', level = 74 }, -- of Onyxia (Horde) -- Same deal
    [19802] = { loc = 'INVTYPE_TRINKET', level = 68 }, -- Heart of Hakkar
    [22520] = { loc = 'INVTYPE_TRINKET', level = 90 }, -- Phylactery of Kel'Thuzad
    [21220] = { loc = 'INVTYPE_NECK', level = 70 }, -- of Ossirian the Unscarred
    [21221] = { loc = 'INVTYPE_NECK', level = 88 }, -- Eye of C'Thun -- Can also be a cloak or ring
    [19003] = { loc = 'INVTYPE_HOLDABLE', level = 83 }, -- of Nefarian (Alliance) -- Can also be neck and ring
    [19002] = { loc = 'INVTYPE_HOLDABLE', level = 83 }, -- of Nefarian (Horde) -- Same deal
    [19717] = { loc = 'INVTYPE_WRIST', level = 61 }, -- Armsplint
    [19716] = { loc = 'INVTYPE_WRIST', level = 61 }, -- Bindings
    [19718] = { loc = 'INVTYPE_WRIST', level = 61 }, -- Stanchion
    [19719] = { loc = 'INVTYPE_WAIST', level = 61 }, -- Girdle
    [19720] = { loc = 'INVTYPE_WAIST', level = 61 }, -- Sash
    [19724] = { loc = 'INVTYPE_CHEST', level = 65 }, -- Aegis
    [19723] = { loc = 'INVTYPE_CHEST', level = 65 }, -- Kossack
    [19722] = { loc = 'INVTYPE_CHEST', level = 65 }, -- Tabard
    [19721] = { loc = 'INVTYPE_SHOULDER', level = 68 }, -- Shawl
    [20885] = { loc = 'INVTYPE_CLOAK', level = 67 }, -- Martial Drake
    [20889] = { loc = 'INVTYPE_CLOAK', level = 67 }, -- Regal Drape
    [20888] = { loc = 'INVTYPE_FINGER', level = 65 }, -- Ceremonial Ring
    [20884] = { loc = 'INVTYPE_FINGER', level = 65 }, -- Magisterial Ring
    [20886] = { loc = 'INVTYPE_WEAPONOFFHAND', level = 70 }, -- Spiked Hilt -- Exceptions apply - Paladin / Shaman weapon are main hand
    [21232] = { loc = 'INVTYPE_WEAPONOFFHAND', level = 79 }, -- Imperial Qiraji Armaments -- Can also be a ranged weapon or shield
    [20890] = { loc = 'INVTYPE_WEAPONMAINHAND', level = 70 }, -- Ornate Hilt
    [21237] = { loc = 'INVTYPE_2HWEAPON', level = 79 }, -- Imperial Qiraji Regalia -- Can also be a one-handed weapon
    [20928] = { loc = 'INVTYPE_FEET', level = 78 }, -- Qiraji Bindings of Command -- Can also be shoulders
    [20932] = { loc = 'INVTYPE_FEET', level = 78 }, -- Qiraji Bindings of Dominance -- same deal
    [20933] = { loc = 'INVTYPE_CHEST', level = 88 }, -- Husk of the Old God
    [20929] = { loc = 'INVTYPE_CHEST', level = 88 }, -- Carapace of the Old God
    [20926] = { loc = 'INVTYPE_HEAD', level = 81 }, -- Vek'nilash's Circlet
    [20927] = { loc = 'INVTYPE_LEGS', level = 81 }, -- Ouro's Intact Hide
    [20931] = { loc = 'INVTYPE_LEGS', level = 81 }, -- Skin of the Great Sandworm
    [22368] = { loc = 'INVTYPE_SHOULDER', level = 86 }, -- Shoulderpads
    [22354] = { loc = 'INVTYPE_SHOULDER', level = 86 }, -- Pauldrons
    [22361] = { loc = 'INVTYPE_SHOULDER', level = 86 }, -- Spaulders
    [22372] = { loc = 'INVTYPE_FEET', level = 86 }, -- Sandals
    [22365] = { loc = 'INVTYPE_FEET', level = 86 }, -- Boots
    [22358] = { loc = 'INVTYPE_FEET', level = 86 }, -- Sabatons
    [22369] = { loc = 'INVTYPE_WRIST', level = 88 }, -- Bindings
    [22362] = { loc = 'INVTYPE_WRIST', level = 88 }, -- Wristguards
    [22355] = { loc = 'INVTYPE_WRIST', level = 88 }, -- Bracers
    [22357] = { loc = 'INVTYPE_HAND', level = 88 }, -- Gauntlets
    [22364] = { loc = 'INVTYPE_HAND', level = 88 }, -- Handguards
    [22371] = { loc = 'INVTYPE_HAND', level = 88 }, -- Gloves
    [22363] = { loc = 'INVTYPE_WAIST', level = 88 }, -- Girdle
    [22370] = { loc = 'INVTYPE_WAIST', level = 88 }, -- Belt
    [22356] = { loc = 'INVTYPE_WAIST', level = 88 }, -- Waistguard
    [22359] = { loc = 'INVTYPE_LEGS', level = 88 }, -- Legguards
    [22352] = { loc = 'INVTYPE_LEGS', level = 88 }, -- Legplates
    [22366] = { loc = 'INVTYPE_LEGS', level = 88 }, -- Leggings
    [22367] = { loc = 'INVTYPE_HEAD', level = 88 }, -- Circlet
    [22360] = { loc = 'INVTYPE_HEAD', level = 88 }, -- Headpiece
    [22353] = { loc = 'INVTYPE_HEAD', level = 88 }, -- Helmet
    [22350] = { loc = 'INVTYPE_CHEST', level = 92 }, -- Tunic
    [22351] = { loc = 'INVTYPE_CHEST', level = 92 }, -- Robe
    [22349] = { loc = 'INVTYPE_CHEST', level = 92 }, -- Breastplate
};

local function toSlots(item)
    local token = TOKENS[item.id] and TOKENS[item.id].loc;

    print('toSlots: item = ', item.name, ', id = ', item.id, ', token = ', token);

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
        local name, rank, rankId, level, classLoc, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i);

        name = Ambiguate(name, 'all');

        if name == unit then
            return {
                index = i,
                name = name,
                rank = rank,
                rankId = rankId,
                level = level,
                classLoc = classLoc,
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

local RARITY_COLORS = {
    ['9d9d9d'] = 0,
    ['ffffff'] = 1,
    ['1eff00'] = 2,
    ['0070dd'] = 3,
    ['a335ee'] = 4,
    ['ff8000'] = 5,
    ['e6cc80'] = 6,
    ['00ccff'] = 7,
};

function ExG:LinkInfo(link)
    if not link then
        return nil;
    end

    local _, _, color, _, _, _, _, _, _, _, _, _, _, _, name = string.find(link, LINK_PATTERN);

    local id, type, subtype, loc, texture, classID, subClassID = GetItemInfoInstant(link);

    local item = {
        id = id,
        link = link,
        name = name,
        rarity = color and RARITY_COLORS[color],
        type = type,
        subtype = subtype,
        loc = loc,
        texture = texture,
        classID = classID,
        subClassID = subClassID,
    };

    item.slots = toSlots(item);

    return item;
end

function ExG:ItemInfo(linkOrId)
    if not linkOrId then
        return nil;
    end

    local id = GetItemInfoInstant(linkOrId);

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
        local info = self:LinkInfo(GetInventoryItemLink('player', v));

        tinsert(res, info);
    end

    return unpack(res);
end

function ExG:GetEG(offNote)
    local ep, gp;

    local ep, gp = string.match(offNote or '', 'cep{(-?%d+%.?%d*),(-?%d+%.?%d*)}');

    ep, gp = getEG(ep, gp);

    return { ep = ep, gp = gp, pr = floor(ep * 100 / gp) / 100, };
end

function ExG:SetEG(info, ep, gp)
    if not info.index then
        return;
    end

    local newEp, newGp = getEG(ep, gp);

    local res = toString(info, newEp, newGp);

    if store().debug then
        self:Print('Set EG for ', info.name, ': ', info.officerNote, ' -> ', res);
    else
        GuildRosterSetOfficerNote(info.index, res);
    end

    return { ep = newEp, gp = newGp, pr = floor(newEp * 100 / newGp) / 100, };
end

function ExG:CalcGP(linkOrId)
    local info = self:ItemInfo(linkOrId);

    if not info then
        return 0;
    end

    local settings = store().items.data[info.id];
    local class = settings and settings[ExG.state.class] or {};
    local def = settings and settings['DEFAULT'] or {};

    if class.gp or def.gp then
        return class.gp or def.gp;
    end

    local token = TOKENS[info.id];
    local loc = token and token.loc or info.loc;
    local lvl = token and token.level or info.level;

    if info.classID == 2 and info.subClassID == 19 then
        loc = 'INVTYPE_WAND';
    end
    if info.classID == 2 and (info.subClassID == 2 or info.subClassID == 3 or info.subClassID == 18) then
        loc = 'INVTYPE_RANGED';
    end

    local slot = store().items.formula[LOCS_OVER[loc] or loc];

    if not slot then
        return 0;
    end

    local formula = store().items.formula;

    return math.floor(formula.coef * (formula.base ^ (lvl / 26 + info.rarity - 4)) * slot * formula.mod);
end
