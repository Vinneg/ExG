local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local order = function(self, field)
    return function()
        self.order[field] = -(self.order[field] or -1);

        sort(self[self.current], function(a, b)
            if self.order[field] == 1 then
                return a[field] < b[field];
            else
                return a[field] > b[field];
            end
        end);

        self:RenderItems(self);
    end;
end

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.RosterFrame = {
    frame = nil,
    list = nil,
    current = 'guild',
    guild = {},
    raid = {},
    order = {},
};

local function getData(self)
    if self.current == 'guild' then
        self.guild = {};

        for i = 1, GetNumGuildMembers() do
            local name, rank, rankId, level, classLoc, _, _, officerNote, isOnline, _, class = GetGuildRosterInfo(i);

            local eg = ExG:GetEG(officerNote);

            tinsert(self.guild, { name = Ambiguate(name, 'all'), rank = rank, rankId = rankId, level = level, class = class, classLoc = classLoc, offNote = officerNote, isOnline = isOnline, ep = eg.ep, gp = eg.gp, pr = eg.pr, });
        end
    elseif self.current == 'raid' then
        self.raid = {};

        for i = 1, MAX_RAID_MEMBERS do
            local name, rank, subgroup, level, classDisplayName, class, zone, online, isDead, role, isMl, combatRole = GetRaidRosterInfo(i);

            if name then
                name = Ambiguate(name, 'all');

                local info = ExG:GuildInfo(name);
                local eg = ExG:GetEG(info.officerNote);

                tinsert(self.raid, { name = name, rank = info.rank, rankId = info.rankId, level = level, class = class, classLoc = info.classLoc, offNote = info.officerNote, isOnline = info.isOnline, ep = eg.ep, gp = eg.gp, pr = eg.pr, });
            end
        end
    end
end

local function makeTopLine(self)
    local guild = AceGUI:Create('Button');
    guild:SetWidth(120);
    guild:SetHeight(25);
    guild:SetText(L['View Guild']);
    guild:SetCallback('OnClick', function() self.current = 'guild'; getData(self); self:RenderItems(); end);
    self.frame:AddChild(guild);

    guild:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);

    local raid = AceGUI:Create('Button');
    raid:SetWidth(120);
    raid:SetHeight(25);
    raid:SetText(L['View Raid']);
    raid:SetCallback('OnClick', function() self.current = 'raid'; getData(self); self:RenderItems(); end);
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
    local name = AceGUI:Create('InteractiveLabel');
    name:SetFont(DEFAULT_FONT, 10);
    name:SetWidth(80);
    name:SetHeight(20);
    name:SetJustifyH('CENTER');
    name:SetJustifyV('MIDDLE');
    name:SetColor(ExG:ClassColor('SYSTEM'));
    name:SetText(L['Name']);
    name:SetCallback('OnClick', order(self, 'name'));
    self.frame:AddChild(name);

    name:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -90);

    local class = AceGUI:Create('InteractiveLabel');
    class:SetFont(DEFAULT_FONT, 10);
    class:SetWidth(80);
    class:SetHeight(20);
    class:SetJustifyH('CENTER');
    class:SetJustifyV('MIDDLE');
    class:SetColor(ExG:ClassColor('SYSTEM'));
    class:SetText(L['Class']);
    class:SetCallback('OnClick', order(self, 'classLoc'));
    self.frame:AddChild(class);

    class:SetPoint('TOPLEFT', name.frame, 'TOPRIGHT', 0, 0);

    local rank = AceGUI:Create('InteractiveLabel');
    rank:SetFont(DEFAULT_FONT, 10);
    rank:SetWidth(100);
    rank:SetHeight(20);
    rank:SetJustifyH('CENTER');
    rank:SetJustifyV('MIDDLE');
    rank:SetColor(ExG:ClassColor('SYSTEM'));
    rank:SetText(L['Rank']);
    rank:SetCallback('OnClick', order(self, 'rankId'));
    self.frame:AddChild(rank);

    rank:SetPoint('TOPLEFT', class.frame, 'TOPRIGHT', 0, 0);

    local pr = AceGUI:Create('InteractiveLabel');
    pr:SetFont(DEFAULT_FONT, 10);
    pr:SetWidth(50);
    pr:SetHeight(20);
    pr:SetJustifyH('CENTER');
    pr:SetJustifyV('MIDDLE');
    pr:SetColor(ExG:ClassColor('SYSTEM'));
    pr:SetText(L['PR']);
    pr:SetCallback('OnClick', order(self, 'pr'));
    self.frame:AddChild(pr);

    pr:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -30, -90);

    local gp = AceGUI:Create('InteractiveLabel');
    gp:SetFont(DEFAULT_FONT, 10);
    gp:SetWidth(50);
    gp:SetHeight(20);
    gp:SetFullHeight(true);
    gp:SetJustifyH('CENTER');
    gp:SetJustifyV('MIDDLE');
    gp:SetColor(ExG:ClassColor('SYSTEM'));
    gp:SetText(L['GP']);
    gp:SetCallback('OnClick', order(self, 'gp'));
    self.frame:AddChild(gp);

    gp:SetPoint('TOPRIGHT', pr.frame, 'TOPLEFT');

    local ep = AceGUI:Create('InteractiveLabel');
    ep:SetFont(DEFAULT_FONT, 10);
    ep:SetWidth(50);
    ep:SetHeight(20);
    ep:SetFullHeight(true);
    ep:SetJustifyH('CENTER');
    ep:SetJustifyV('MIDDLE');
    ep:SetColor(ExG:ClassColor('SYSTEM'));
    ep:SetText(L['EP']);
    ep:SetCallback('OnClick', order(self, 'ep'));
    self.frame:AddChild(ep);

    ep:SetPoint('TOPRIGHT', gp.frame, 'TOPLEFT');
end

local function renderItem(self, item)
    if not item then
        return;
    end

    local row = AceGUI:Create('SimpleGroup');
    row:SetFullWidth(true);
    row:SetHeight(20);
    row:SetLayout(nil);
    row:SetAutoAdjustHeight(false);
    row.frame:EnableMouse(true);

    local highlight = row.frame:CreateTexture(nil, 'HIGHLIGHT');
    highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
    highlight:SetAllPoints(true);
    highlight:SetBlendMode('ADD');

    self.list:AddChild(row);

    if CanEditOfficerNote() then
        row.frame:SetScript('OnMouseDown', function() ExG.UnitFrame:Show(item.name); end);
    end

    row.name = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
    row.name:SetFont(DEFAULT_FONT, 10);
    row.name:ClearAllPoints();
    row.name:SetPoint('TOPLEFT', 2, 0);
    row.name:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 160, 0);
    row.name:SetJustifyH('LEFT');
    row.name:SetJustifyV('MIDDLE');
    row.name:SetVertexColor(ExG:ClassColor(item.class));
    row.name:SetText(item.name);

    row.rank = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
    row.rank:SetFont(DEFAULT_FONT, 10);
    row.rank:ClearAllPoints();
    row.rank:SetPoint('TOPLEFT', 160, 0);
    row.rank:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 260, 0);
    row.rank:SetJustifyH('CENTER');
    row.rank:SetJustifyV('MIDDLE');
    row.rank:SetVertexColor(ExG:ClassColor(item.class));
    row.rank:SetText(item.rank);

    row.pr = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
    row.pr:SetFont(DEFAULT_FONT, 10);
    row.pr:ClearAllPoints();
    row.pr:SetPoint('TOPRIGHT');
    row.pr:SetPoint('BOTTOMLEFT', row.frame, 'BOTTOMRIGHT', -50, 0);
    row.pr:SetJustifyH('CENTER');
    row.pr:SetJustifyV('MIDDLE');
    row.pr:SetVertexColor(ExG:ClassColor(item.class));
    row.pr:SetText(item.pr);

    row.gp = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
    row.gp:SetFont(DEFAULT_FONT, 10);
    row.gp:ClearAllPoints();
    row.gp:SetPoint('TOPRIGHT', row.pr, 'TOPLEFT');
    row.gp:SetPoint('BOTTOMLEFT', row.pr, 'BOTTOMLEFT', -50, 0);
    row.gp:SetJustifyH('CENTER');
    row.gp:SetJustifyV('MIDDLE');
    row.gp:SetVertexColor(ExG:ClassColor(item.class));
    row.gp:SetText(item.gp);

    row.ep = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
    row.ep:SetFont(DEFAULT_FONT, 10);
    row.ep:ClearAllPoints();
    row.ep:SetPoint('TOPRIGHT', row.gp, 'TOPLEFT');
    row.ep:SetPoint('BOTTOMLEFT', row.gp, 'BOTTOMLEFT', -50, 0);
    row.ep:SetJustifyH('CENTER');
    row.ep:SetJustifyV('MIDDLE');
    row.ep:SetVertexColor(ExG:ClassColor(item.class));
    row.ep:SetText(item.ep);

    row.OnRelease = function(self)
        if self.name then self.name:ClearAllPoints(); self.name = nil; end
        if self.rank then self.rank:ClearAllPoints(); self.rank = nil; end
        if self.pr then self.pr:ClearAllPoints(); self.pr = nil; end
        if self.gp then self.gp:ClearAllPoints(); self.gp = nil; end
        if self.ep then self.ep:ClearAllPoints(); self.ep = nil; end
    end;
end

local function renderItems(self)
    self.list:ReleaseChildren();

    for i, v in ipairs(self[self.current]) do
        renderItem(self, v);
    end
end

function ExG.RosterFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['ExG']);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(470);
    self.frame:SetHeight(700);
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
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -10, 10);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');

    group:AddChild(self.list);
end

function ExG.RosterFrame:Show()
    self.frame:Show();

    getData(self);

    self:RenderItems();
end

function ExG.RosterFrame:Hide()
    self.frame:Hide();
end

function ExG.RosterFrame:RenderItems()
    renderItems(self)
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
