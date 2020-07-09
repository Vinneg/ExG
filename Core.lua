ExG = LibStub('AceAddon-3.0'):NewAddon('ExG', 'AceConsole-3.0', 'AceEvent-3.0', 'AceComm-3.0', 'AceTimer-3.0');

local AceConfig = LibStub('AceConfig-3.0');
local AceConfigDialog = LibStub('AceConfigDialog-3.0');
local AceDB = LibStub('AceDB-3.0');
local Serializer = LibStub('AceSerializer-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local buttons = {
    validateText = function(_, value)
        if not value then
            return L['Value must be a not empty string'];
        end
        local txt = string.gsub(value, '%s', '');
        if not txt or #txt == 0 then
            return L['Value must be a not empty string'];
        end
        return true;
    end,
    getText = function(btnId)
        return function() return store().buttons[btnId].text; end;
    end,
    setText = function(btnId)
        return function(_, value) store().buttons[btnId].text = value; end;
    end,
    validateRatio = function(_, value)
        if not tonumber(value) then
            return L['Value must be a number'];
        end
        return true;
    end,
    getRatio = function(btnId)
        return function() return tostring(store().buttons[btnId].ratio); end;
    end,
    setRatio = function(btnId)
        return function(_, value) store().buttons[btnId].ratio = tonumber(value); end;
    end,
    getRoll = function(btnId)
        return function() return store().buttons[btnId].roll; end;
    end,
    setRoll = function(btnId)
        return function(_, value) store().buttons[btnId].roll = value; end;
    end,
};

ExG.messages = {
    prefix = {
        announce = 'ExG_Announce',
        accept = 'ExG_Accept',
        roll = 'ExG_Roll',
        pull = 'ExG_Pull',
        share = 'ExG_Share',
    },
    raid = 'RAID',
    warning = 'RAID_WARNING',
    guild = 'GUILD',
    whisper = 'WHISPER',
};

ExG.state = {
    name = '',
    class = '',
    looting = false,
    options = nil,
};

ExG.defaults = {
    factionrealm = {
        chars = {},
    },
    char = {
        BaseEP = 10,
        BaseGP = 10,
        items = {},
        buttons = {
            count = 2,
            button1 = { enabled = true, id = 'button1', text = 'need', ratio = 1, roll = false },
            button2 = { enabled = true, id = 'button2', text = 'greed', ratio = 0.5, roll = false },
            button3 = { enabled = true, id = 'button3', text = 'offspec', ratio = 0.3, roll = false },
            button4 = { enabled = true, id = 'button4', text = 'gold', ratio = 0, roll = true },
            button5 = { enabled = true, id = 'button5', text = 'free', ratio = 0, roll = true },
            button6 = { enabled = true, id = 'button6', text = 'pass', ratio = 0, roll = false },
        },
        history = {
            pageSize = 50,
            offset = 1,
            source = nil,
            data = {},
            bak = {},
        },
    },
};

ExG.options = {
    type = 'group',
    name = L['ExG'],
    handler = ExG,
    args = {
        general = {
            type = 'group',
            name = L['ExG General'],
            order = 0,
            args = {
                baseEP = {
                    type = 'input',
                    name = L['ExG BaseEP'],
                    order = 0,
                    get = function() return store().baseEP; end,
                    set = function(_, value) store().baseEP = value; end,
                },
                baseGP = {
                    type = 'input',
                    name = L['ExG BaseGP'],
                    order = 10,
                    get = function() return store().baseGP; end,
                    set = function(_, value) store().baseGP = value; end,
                },
            },
        },
        history = {
            type = 'group',
            name = L['ExG History'],
            order = 10,
            args = {
                openHistory = {
                    type = 'execute',
                    name = L['ExG Open History'],
                    order = 10,
                    width = 'full',
                    func = function() ExG.HistoryFrame:Show(); end,
                },
                historyHeader1 = {
                    type = 'header',
                    name = L['History Common'],
                    order = 20,
                },
                historyPage = {
                    type = 'input',
                    name = L['History page size'],
                    order = 21,
                    validate = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end,
                    get = function() return tostring(store().history.pageSize); end,
                    set = function(_, value) store().history.pageSize = tonumber(value); end,
                },
                historyHeader2 = {
                    type = 'header',
                    name = L['History Pull Header'],
                    order = 30,
                },
                historyPlayer = {
                    type = 'input',
                    name = L['History source player'],
                    order = 31,
                    validate = function(_, value) local info = ExG:GuildInfo(value); if not info then return L['Player must be in guild']; end return true; end,
                    get = function() return store().history.source; end,
                    set = function(_, value) store().history.source = value; end,
                },
                historyOffset = {
                    type = 'input',
                    name = L['History source offset'],
                    order = 32,
                    validate = function(_, value) local tmp = tonumber(value); if not tmp then return L['Value must be a number']; elseif tmp < 1 then return L['Value must be more than X'](0); end return true; end,
                    get = function() return tostring(store().history.offset); end,
                    set = function(_, value) store().history.offset = tonumber(value); end,
                },
                historyExchange = {
                    type = 'execute',
                    name = L['History Pull'],
                    order = 33,
                    disabled = function() return not store().history.source or not store().history.offset; end,
                    func = function() ExG:HistoryPull(); end,
                },
                historyClear = {
                    type = 'execute',
                    name = L['Clear'],
                    order = 34,
                    func = function() ExG:ClearHistory(); end,
                },
                historyHeader3 = {
                    type = 'header',
                    name = L['ExG Import History'],
                    order = 40,
                },
                importHistory = {
                    type = 'execute',
                    name = L['Import'],
                    order = 41,
                    width = 'full',
                    func = function() ExG:ImportHistory(); end,
                },
            },
        },
        buttons = {
            type = 'group',
            name = L['ExG Buttons'],
            order = 20,
            args = {
                count = {
                    type = 'range',
                    name = L['ExG Buttons'],
                    order = 0,
                    min = 2,
                    max = 6,
                    step = 1,
                    get = function() return store().buttons.count; end,
                    set = function(_, value) local btns = store().buttons; btns.count = value; btns.button2.enabled = (value > 2); btns.button3.enabled = (value > 3); btns.button4.enabled = (value > 4); btns.button5.enabled = (value > 5); end,
                },
                button1Header = {
                    type = 'header',
                    name = L['Button 1'],
                    order = 10,
                },
                button1Text = {
                    type = 'input',
                    name = L['Button Text'],
                    order = 11,
                    validate = buttons.validateText,
                    get = buttons.getText('button1'),
                    set = buttons.setText('button1'),
                },
                button1Ratio = {
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 12,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button1'),
                    set = buttons.setRatio('button1'),
                },
                button1Roll = {
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 13,
                    get = buttons.getRoll('button1'),
                    set = buttons.setRoll('button1'),
                },
                button2Header = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'header',
                    name = L['Button 2'],
                    order = 20,
                },
                button2Text = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 21,
                    validate = buttons.validateText,
                    get = buttons.getText('button2'),
                    set = buttons.setText('button2'),
                },
                button2Ratio = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 22,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button2'),
                    set = buttons.setRatio('button2'),
                },
                button2Roll = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 23,
                    get = buttons.getRoll('button2'),
                    set = buttons.setRoll('button2'),
                },
                button3Header = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'header',
                    name = L['Button 3'],
                    order = 30
                },
                button3Text = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 31,
                    validate = buttons.validateText,
                    get = buttons.getText('button3'),
                    set = buttons.setText('button3'),
                },
                button3Ratio = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 32,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button3'),
                    set = buttons.setRatio('button3'),
                },
                button3Roll = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 33,
                    get = buttons.getRoll('button3'),
                    set = buttons.setRoll('button3'),
                },
                button4Header = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'header',
                    name = L['Button 4'],
                    order = 40
                },
                button4Text = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 41,
                    validate = buttons.validateText,
                    get = buttons.getText('button4'),
                    set = buttons.setText('button4'),
                },
                button4Ratio = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 42,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button4'),
                    set = buttons.setRatio('button4'),
                },
                button4Roll = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 43,
                    get = buttons.getRoll('button4'),
                    set = buttons.setRoll('button4'),
                },
                button5Header = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'header',
                    name = L['Button 5'],
                    order = 50
                },
                button5Text = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 51,
                    validate = buttons.validateText,
                    get = buttons.getText('button5'),
                    set = buttons.setText('button5'),
                },
                button5Ratio = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 52,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button5'),
                    set = buttons.setRatio('button5'),
                },
                button5Roll = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 53,
                    get = buttons.getRoll('button5'),
                    set = buttons.setRoll('button5'),
                },
                button6Header = {
                    type = 'header',
                    name = L['Button 6'],
                    order = 60
                },
                button6Text = {
                    type = 'input',
                    name = L['Button Text'],
                    order = 61,
                    validate = buttons.validateText,
                    get = buttons.getText('button6'),
                    set = buttons.setText('button6'),
                },
            },
        },
    }
};

ExG.store = {};

function ExG:HandleChatCommand(input)
    local arg = strlower(input or '');

    if arg == 'Announce' then
        local tmp = self:ItemInfo(GetInventoryItemLink('player', 1));
        tmp.buttons = self:ItemOptions(tmp);
        tmp.gp = self:ItemGP(tmp);
        self:AnnounceItem(tmp)
    elseif arg == 'his' then
        self.HistoryFrame:Show();
    elseif arg == 'inv' then
        self.InventoryFrame:Show();
    elseif arg == 'opts' then
        InterfaceOptionsFrame_OpenToCategory(self.state.options);
        InterfaceOptionsFrame_OpenToCategory(self.state.options);
    elseif arg == 'open' then
        self.RosterFrame:Show();
    else
        self:Print('|cff33ff99', L['Usage:'], '|r');
        self:Print('opts|cff33ff99 - ', L['to open Options frame'], '|r');
        self:Print('open|cff33ff99 - ', L['to open Roster frame'], '|r');
    end
end

function ExG:OnInitialize()
    self:RegisterChatCommand('exg', 'HandleChatCommand');

    AceConfig:RegisterOptionsTable('ExGOptions', self.options);
    self.state.options = AceConfigDialog:AddToBlizOptions('ExGOptions', L['ExG']);
    self.store = AceDB:New('ExGStore', self.defaults, true);

    self:RegisterComm(self.messages.prefix.announce, 'handleAnnounceItem');
    self:RegisterComm(self.messages.prefix.roll, 'handleRollItem');
    self:RegisterComm(self.messages.prefix.accept, 'handleAcceptItem');
    self:RegisterComm(self.messages.prefix.pull, 'handleHistoryPull');
    self:RegisterComm(self.messages.prefix.share, 'handleHistoryShare');

    self.state.name = UnitName('player');
    self.state.class = select(2, UnitClass('player'));

    self.RosterFrame:Create();
    self.RollFrame:Create();
    self.InventoryFrame:Create();
    self.HistoryFrame:Create();

    self:RegisterEvent('ENCOUNTER_END');
    self:RegisterEvent('LOOT_OPENED');
    self:RegisterEvent('LOOT_CLOSED');

    self:ScheduleTimer('PostInit', 10);
end

function ExG:PostInit()
    self.state.name = UnitName('player');
    self.state.class = select(2, UnitClass('player'));

    self.store.factionrealm.chars[self.state.name] = self.store.factionrealm.chars[self.state.name] or {};

    local tmp = self.store.factionrealm.chars[self.state.name];
    tmp.name = self.state.name;
    tmp.class = self.state.class;

    local version = GetAddOnMetadata(self.name, 'Version');

    self:Print('|cff33ff99Version ', version, ' loaded!|r');
end

function ExG:AnnounceItem(item)
    local data = Serializer:Serialize(item);

    self:SendCommMessage(self.messages.prefix.announce, data, self.messages.raid);
end

function ExG:handleAnnounceItem(_, message, _, sender)
    if not self:IsMl(sender) then
        return;
    end

    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:AddItem(data);
    self.RollFrame:Show();

    local resp = Serializer:Serialize(data.id);

    self:SendCommMessage(self.messages.prefix.accept, resp, self.messages.raid);
end

function ExG:handleAcceptItem(_, message, _, _)
    local success, itemId = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:AcceptItem(itemId);
end

function ExG:RollItem(item)
    local data = Serializer:Serialize(item);

    self:SendCommMessage(self.messages.prefix.roll, data, self.messages.raid);
end

function ExG:handleRollItem(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:RollItem(data, sender);
end

function ExG:HistoryPull()
    if not store().history.source or not store().history.offset then
        return;
    end

    self:Print(L['History pulled']({ source = store().history.source, offset = store().history.offset }));

    local data = Serializer:Serialize({ offset = store().history.offset });

    self:SendCommMessage(self.messages.prefix.pull, data, self.messages.whisper, store().history.source);
end

function ExG:handleHistoryPull(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    local res = self:CopyHistory(data);

    self:HistoryShare(res, sender);
end

function ExG:HistoryShare(source, target)
    local data = Serializer:Serialize(source);

    self:SendCommMessage(self.messages.prefix.share, data, self.messages.whisper, target);
end

function ExG:handleHistoryShare(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    for i, v in pairs(data.data) do
        store().history.data[i] = v;
    end

    self:Print(L['History imported'](data));
end

function ExG:ScanLoot()
    local result = {};

    local count = GetNumLootItems();

    for i = 1, count do
        local link = GetLootSlotLink(i);

        if link then
            local tmp = self:ItemInfo(link);

            if tmp.rarity > 3 then
                result[tmp.id] = tmp;
            end
        end
    end

    return result;
end

function ExG:ItemOptions(itemInfo)
    return {
        store().buttons.button1,
        store().buttons.button2,
        store().buttons.button3,
        store().buttons.button4,
        store().buttons.button5,
    };
end

function ExG:ItemGP(itemInfo)
    return self:CalcGP(itemInfo);
end

function ExG:ENCOUNTER_END(_, id, _, _, _, success)
end

function ExG:LOOT_OPENED()
    self.state.looting = true;
end

function ExG:LOOT_CLOSED()
    self.state.looting = false;
end

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

        local dt = tonumber(v[9] or 1000);
        local offset = 0;

        while store().history.data[dt + offset / 1000] do
            offset = offset + 1;
        end

        dt = dt + offset / 1000;

        local targetInfo = ExG:GuildInfo(target);
        local masterInfo = ExG:GuildInfo(master);

        store().history.data[dt] = {
            type = 'old',
            target = { name = target, class = targetInfo and targetInfo.class or strupper(target), },
            master = { name = master, class = masterInfo and masterInfo.class or strupper(master) },
            desc = v[3],
            ep = { before = v[4], after = v[5] },
            gp = { before = v[6], after = v[7] },
            link = v[8] or '',
            dt = dt,
        };

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
