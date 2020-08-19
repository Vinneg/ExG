local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

function ExG:ImportHistory()
    local tmp = {};

    for i, v in pairs(store().history.data) do
        if not v.type == 'old' then
            tmp[i] = v;
        end
    end

    store().history.data = tmp;

    local imported = 0;

    for _, v in ipairs(TRAFFIC) do
        local target = v[1];
        local master = v[2];

        local dt, offset = tonumber(v[9] or 1000), 0;

        while store().history.data[dt + offset / 1000] do
            offset = offset + 1;
        end

        dt = dt + offset / 1000;

        local targetInfo = ExG:GuildInfo(target);
        local masterInfo = ExG:GuildInfo(master);

        store().history.data[dt] = {
            type = 'old',
            target = { name = target, class = targetInfo and targetInfo.class or strupper(target), },
            master = { name = master, class = masterInfo and masterInfo.class or strupper(master), },
            desc = v[3],
            dt = dt,
        };

        if v[4] ~= '' or v[5] ~= '' then
            store().history.data[dt].ep = { before = v[4], after = v[5], };
        end

        if v[6] ~= '' and v[7] ~= '' then
            store().history.data[dt].gp = { before = v[6], after = v[7], };
        end

        if v[8] ~= '' then
            store().history.data[dt].link = v[8];
        end

        imported = imported + 1;
    end

    self:Print(L['Total imported'](imported));
end

function ExG:CopyHistory(settings)
    local res = {};
    local min, max, count = nil, nil, 0;
    local limit = time() - settings.offset * 86400;

    for i, v in pairs(store().history.data) do
        if (i >= limit) then
            res[i] = v;

            min = math.min(min or i, i);
            max = math.max(max or i, i);
            count = count + 1;
        end
    end

    return { data = res, count = count, min = min, max = max };
end

function ExG:ClearHistory()
    store().history.bak = store().history.data;
    store().history.data = {};
end

function ExG:GuidEG()
    local ep, gp, desc = store().mass.guildEp, store().mass.guildGp, store().mass;

    if (ep or 0) == 0 or (gp or 0) == 0 then
        return;
    end

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'guild',
        target = { name = L['ExG History GUILD'], class = 'GUILD', },
        master = { name = self.state.name, class = self.state.class, },
        desc = L['ExG Guid EG'](ep, gp);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, GetNumGuildMembers() do
        local st = dt + i / 1000;

        local name, _, _, _, _, _, _, officerNote, _, _, class = GetGuildRosterInfo(i);
        local info = { index = i, name = Ambiguate(name, 'all'), class = class, officerNote = officerNote };

        if info.name then
            local old = self:GetEG(officerNote);
            local new = self:SetEG(info, old.ep + ep, old.gp + gp);

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    self:HistoryShare({ data = { [dt] = store().history.data[dt] } });
end

function ExG:RaidEG()
    local ep, gp = store().mass.raidEp, store().mass.raidGp;

    if (ep or 0) == 0 or (gp or 0) == 0 then
        return;
    end

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'raid',
        target = { name = L['ExG History RAID'], class = 'RAID', },
        master = { name = self.state.name, class = self.state.class, },
        desc = L['ExG Raid EG'](ep, gp);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, GetNumGuildMembers() do
        local st = dt + i / 1000;

        local name, _, _, _, _, _, _, officerNote, _, _, class = GetGuildRosterInfo(i);
        local info = { index = i, name = Ambiguate(name, 'all'), class = class, officerNote = officerNote };

        if info.name then
            local old = self:GetEG(officerNote);
            local new = self:SetEG(info, old.ep + ep, old.gp + gp);

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    self:HistoryShare({ data = { [dt] = store().history.data[dt] } });
end

function ExG:GuidDecay()
    local decay = store().mass.decay;

    if (decay or 0) == 0 then
        return;
    end

    decay = 1 - decay;

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'guild',
        target = { name = L['ExG History GUILD'], class = 'GUILD', },
        master = { name = self.state.name, class = self.state.class, },
        desc = L['Guild Decay Desc'](store().mass.decay);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, GetNumGuildMembers() do
        local st = dt + i / 1000;

        local name, _, _, _, _, _, _, officerNote, _, _, class = GetGuildRosterInfo(i);
        local info = { index = i, name = Ambiguate(name, 'all'), class = class, officerNote = officerNote };

        if info.name then
            local old = self:GetEG(officerNote);
            local new = self:SetEG(info, floor(old.ep * decay), floor(old.gp * decay));

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    self:HistoryShare({ data = { [dt] = store().history.data[dt] } });
end
