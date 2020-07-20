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
    local res = class and (COLORS[class] or COLORS['DEFAULT']) or COLORS('DEFAULT');

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

    local ttlMembers = GetNumGuildMembers();

    for i = 1, ttlMembers do
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

    local id = 0;

    if tonumber(linkOrId) then
        id = tonumber(linkOrId);
    else
        local itemString = string.match(linkOrId, "item[%-?%d:]+");

        if not itemString then
            return nil;
        end

        local _, tmp = strsplit(':', itemString);

        if not tmp then
            return nil;
        end

        id = tmp;
    end

    local name, link, rarity, level, minLevel, type, subtype, stackCount, loc, texture, sellPrice, classID, subClassID, bindType, expacID, setID, isCraftReg = GetItemInfo(id);

    return {
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

function ExG:CalcGP(itemInfo)
    return 10;
end
