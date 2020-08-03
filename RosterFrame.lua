local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.RosterFrame = {
    frame = nil,
    list = nil,
    guild = {},
    raid = {},
};

local function makeTopLine(self)
    local guild = AceGUI:Create('Button');
    guild:SetWidth(120);
    guild:SetHeight(25);
    guild:SetText(L['View Guild']);
    guild:SetCallback('OnClick', function() end);
    self.frame:AddChild(guild);

    guild:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);

    local raid = AceGUI:Create('Button');
    raid:SetWidth(120);
    raid:SetHeight(25);
    raid:SetText(L['View Raid']);
    raid:SetCallback('OnClick', function() end);
    self.frame:AddChild(raid);

    raid:SetPoint('LEFT', guild.frame, 'RIGHT', 5, 0);

    local options = AceGUI:Create('Button');
    options:SetWidth(120);
    options:SetHeight(20);
    options:SetText(L['View Options']);
    options:SetCallback('OnClick', function() InterfaceOptionsFrame_OpenToCategory(ExG.state.options); InterfaceOptionsFrame_OpenToCategory(ExG.state.options); end);
    self.frame:AddChild(options);

    options:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -10, -30);
end

local function makeFilters(self)
    local classes = {
        ALL = '',
        DEATHKNIGHT = L['DEATHKNIGHT'],
        WARRIOR = L['WARRIOR'],
        ROGUE = L['ROGUE'],
        MAGE = L['MAGE'],
        PRIEST = L['PRIEST'],
        WARLOCK = L['WARLOCK'],
        HUNTER = L['HUNTER'],
        SHAMAN = L['SHAMAN'],
        DRUID = L['DRUID'],
        MONK = L['MONK'],
        PALADIN = L['PALADIN'],
    };
    local cOrder = { 'ALL', 'DEATHKNIGHT', 'WARRIOR', 'ROGUE', 'MAGE', 'PRIEST', 'WARLOCK', 'HUNTER', 'SHAMAN', 'DRUID', 'MONK', 'PALADIN', };

    local ranks, rOrder = { [0] = nil }, { 0 };

    for i = 1, GuildControlGetNumRanks() do
        ranks[i] = GuildControlGetRankName(i);
        tinsert(rOrder, i);
    end

    local cText = AceGUI:Create('Label');
    cText:SetWidth(80);
    cText:SetHeight(25);
    cText:SetText(L['Class Filter']);
    cText:SetJustifyH('RIGHT');
    cText:SetColor(ExG:ClassColor('SYSTEM'));
    self.frame:AddChild(cText);

    cText:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -65);

    local class = AceGUI:Create('Dropdown');
    class:SetWidth(120);
    class:SetHeight(25);
    class:SetLabel('');
    class:SetCallback('OnClick', function() end);
    class:SetList(classes, cOrder);
    self.frame:AddChild(class);

    class:SetPoint('LEFT', cText.frame, 'RIGHT', 5, 0);

    local rText = AceGUI:Create('Label');
    rText:SetWidth(80);
    rText:SetHeight(25);
    rText:SetText(L['Rank Filter']);
    rText:SetJustifyH('RIGHT');
    rText:SetColor(ExG:ClassColor('SYSTEM'));
    self.frame:AddChild(rText);

    rText:SetPoint('LEFT', class.frame, 'RIGHT', 5, 0);

    local rank = AceGUI:Create('Dropdown');
    rank:SetWidth(120);
    rank:SetHeight(25);
    rank:SetLabel('');
    rank:SetCallback('OnClick', function() end);
    rank:SetList(ranks, rOrder);
    self.frame:AddChild(rank);

    rank:SetPoint('LEFT', rText.frame, 'RIGHT', 5, 0);
end

local function makeHeaders(self)
    self.headers = AceGUI:Create('SimpleGroup');
    self.headers:SetFullWidth(true);
    self.headers:SetLayout('Flow');
    self.frame:AddChild(self.headers);

    self.headers:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -90);
    self.headers:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -10, -90);

    local name = AceGUI:Create('Label');
    name:SetFont(DEFAULT_FONT, 10);
    name:SetRelativeWidth(0.13);
    name:SetFullHeight(true);
    name:SetJustifyH('CENTER');
    name:SetColor(ExG:ClassColor('SYSTEM'));
    name:SetText(L['Name']);
    self.headers:AddChild(name);
end

local function makeRows(self)
    for i = 1, GetNumGuildMembers() do
        local row = AceGUI:Create('SimpleGroup');
        row:SetFullWidth(true);
        row:SetLayout('Flow');
        row.frame:EnableMouse(true);

        local highlight = row.frame:CreateTexture(nil, 'HIGHLIGHT');
        highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
        highlight:SetAllPoints(true);
        highlight:SetBlendMode('ADD');
        self.list:AddChild(row);

        local name = AceGUI:Create('Label');
        name:SetFont(DEFAULT_FONT, 10);
        name:SetRelativeWidth(0.12);
        name:SetFullHeight(true);
        name:SetText('');
        row:AddChild(name);

        local rank = AceGUI:Create('Label');
        rank:SetFont(DEFAULT_FONT, 10);
        rank:SetRelativeWidth(0.12);
        rank:SetFullHeight(true);
        rank:SetText('');
        row:AddChild(rank);

        local ep = AceGUI:Create('Label');
        ep:SetFont(DEFAULT_FONT, 10);
        ep:SetRelativeWidth(0.12);
        ep:SetFullHeight(true);
        ep:SetText('');
        row:AddChild(ep);

        local gp = AceGUI:Create('Label');
        gp:SetFont(DEFAULT_FONT, 10);
        gp:SetRelativeWidth(0.12);
        gp:SetFullHeight(true);
        gp:SetText('');
        row:AddChild(gp);

        local pr = AceGUI:Create('Label');
        pr:SetFont(DEFAULT_FONT, 10);
        pr:SetRelativeWidth(0.12);
        pr:SetFullHeight(true);
        pr:SetText('');
        row:AddChild(pr);

        row.frame:Hide();
    end
end

local function getData(self)
    self.guild = {};

    for i = 1, GetNumGuildMembers() do
        local name, rank, rankId, level, classLoc, _, _, offNote, isOnline, _, class = GetGuildRosterInfo(i);

        local eg = ExG:GetEG(offNote);

        tinsert(self.guild, { name = Ambiguate(name, 'all'), rank = rank, rankId = rankId, level = level, class = class, classLoc = classLoc, offNote = offNote, isOnline = isOnline, ep = eg.ep, gp = eg.gp });
    end
end

local function renderItem(self, item)
    local row = AceGUI:Create('SimpleGroup');
    row:SetFullWidth(true);
    row:SetLayout('Flow');

    self.list:AddChild(row);

    local name = AceGUI:Create('InteractiveLabel');
    name:SetFont(DEFAULT_FONT, 12);
    name:SetColor(ExG:ClassColor(item.class));
    name:SetText(item.name);
    name:SetRelativeWidth(0.4);
    name:SetFullHeight(true);
    name:SetHighlight('Interface\\BUTTONS\\UI-Listbox-Highlight.blp')
    name:SetCallback('OnClick', function() end);
    row:AddChild(name);

    local ep = AceGUI:Create('Label');
    ep:SetFont(DEFAULT_FONT, 12);
    ep:SetText(item.ep);
    ep:SetRelativeWidth(0.3);
    ep:SetFullHeight(true);
    row:AddChild(ep);

    local gp = AceGUI:Create('Label');
    gp:SetFont(DEFAULT_FONT, 12);
    gp:SetText(item.gp);
    gp:SetRelativeWidth(0.3);
    gp:SetFullHeight(true);
    row:AddChild(gp);
end

local function renderList(self)
    for _, item in ipairs(self.data) do
        renderItem(self, item);
    end
end

function ExG.RosterFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['ExG']);
    self.frame:SetLayout(nil);
    self.frame:Hide();

    makeTopLine(self);
    makeFilters(self);
    makeHeaders(self);

    local group = AceGUI:Create('SimpleGroup');
    group:SetFullWidth(true);
    group:SetFullHeight(true);
    group:SetLayout('Fill');

    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -105);
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -10, 30);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');

    group:AddChild(self.list);

    makeRows(self);
end

function ExG.RosterFrame:Show()
    self.frame:Show();

    getData(self);

    self:RenderList();
end

function ExG.RosterFrame:Hide()
    self.frame:Hide();
end

function ExG.RosterFrame:RenderList()
    if not IsInGuild() then
        return;
    end

    sort(self.guild, function(a, b) return (a.name or '') < (b.name or ''); end);

    for _, v in ipairs(self.guild) do
        --        self:RenderItem(v);
    end
end

function ExG.RosterFrame:Ajust(player)
    local playerIndex;

    for i = 1, MAX_RAID_MEMBERS do
        local name = GetMasterLootCandidate(lootIndex, i);

        if name then
            name = Ambiguate(name, 'all');

            if name == player then
                playerIndex = i;
            end
        end
    end

    if not playerIndex then
        return;
    end

    GiveMasterLoot(lootIndex, playerIndex);
end
