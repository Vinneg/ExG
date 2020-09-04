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
