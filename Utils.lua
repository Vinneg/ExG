local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local store = function() return ExG.store.char; end;

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
    unit = unit or self.state.name;

    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, _, _, _, _, _, _, isML = GetRaidRosterInfo(i);

        if name then
            name = Ambiguate(name, 'all');

            if unit == name then
                return isML;
            end
        end
    end

    return false;
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

function ExG:ItemInfo(itemLink)
    local itemString = string.match(itemLink, "item[%-?%d:]+");
    local _, id = strsplit(':', itemString);
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

function ExG:FromString(offNote)
    if not offNote then
        return tonumber(store().BaseEP), tonumber(store().BaseGP);
    end

    local ep, gp = string.match(offNote, 'cep{(-?%d+%.?%d*),(-?%d+%.?%d*)}');

    if ep and gp then
        return tonumber(ep or store().BaseEP), tonumber(gp or store().BaseGP);
    end

    return tonumber(store().BaseEP), tonumber(store().BaseGP);
end

function ExG:ToString(offNote, ep, gp)
    local newEPGP = 'cep{' .. (tonumber(ep or store().BaseEP)) .. ',' .. (tonumber(gp or store().BaseGP)) .. '}';

    if not offNote then
        return newEPGP;
    end

    local newOffNote, subs = string.gsub(offNote, 'cep{[^}]*}', newEPGP);

    if subs == 0 then
        newOffNote = newEPGP + offNote;
    end

    return newOffNote;
end

function ExG:GetEG(name)
    if not name then
        return;
    end

    local info = self:GuildInfo(name);

    local ep, gp = self:FromString(info.officerNote);

    return { ep = ep, gp = gp, pr = floor(ep * 100 / gp) / 100 };
end

function ExG:SetEG(name, ep, gp)
    if not name then
        return;
    end

    local info = self:GuildInfo(name);

    if not info.index then
        return;
    end

    GuildRosterSetOfficerNote(info.index, self:ToString(info.officerNote, ep, gp));
end

function ExG:CalcGP(itemInfo)
    return 10;
end
