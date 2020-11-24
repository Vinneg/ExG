local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local order = function(self, field)
    local tmp = {};

    tinsert(tmp, { name = field, dir = 1, });

    for i, v in ipairs(self.sort) do
        if #tmp < 4 then
            if v.name == field then
                tmp[1].dir = -v.dir;
            else
                tinsert(tmp, { name = v.name, dir = v.dir, });
            end
        end
    end

    self.sort = tmp;

    local field1, field2, field3 = unpack(self.sort);

    sort(self.data, function(a, b)
        local compare = function(field)
            if not field or not a or not b then
                return 0;
            end

            if a[field.name] == b[field.name] then
                return 0;
            end

            return (a[field.name] < b[field.name] and 1 or -1) * field.dir;
        end

        local c1 = compare(field1);
        local c2 = compare(field2);
        local c3 = compare(field3);

        return c1 == 0 and (c2 == 0 and c3 > 0 or c2 > 0) or c1 > 0;
    end);
end

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

local PANE_WIDTH = 560;
local PANE_HEIGH = 500;

ExG.RosterFrame = {
    frame = nil,
    list = nil,
    current = 'guild',
    guild = {},
    raid = {},
};

local function switchView(self)
    if self.current == 'guild' then
        self.Guild:Open();
        self.Raid:Close();
        self.Reserve:Close();
    elseif self.current == 'raid' then
        self.Guild:Close();
        self.Raid:Open();
        self.Reserve:Close();
    elseif self.current == 'reserve' then
        self.Guild:Close();
        self.Raid:Close();
        self.Reserve:Open();
    end
end

local function makeTopLine(self)
    local guild = AceGUI:Create('Button');
    guild:SetWidth(100);
    guild:SetHeight(25);
    guild:SetText(L['View Guild']);
    guild:SetCallback('OnClick', function() self.current = 'guild'; switchView(self); end);
    self.frame:AddChild(guild);

    guild:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);

    local raid = AceGUI:Create('Button');
    raid:SetWidth(100);
    raid:SetHeight(25);
    raid:SetText(L['View Raid']);
    raid:SetCallback('OnClick', function() self.current = 'raid'; switchView(self); end);
    self.frame:AddChild(raid);

    raid:SetPoint('LEFT', guild.frame, 'RIGHT', 5, 0);

    local reserve = AceGUI:Create('Button');
    reserve:SetWidth(100);
    reserve:SetHeight(25);
    reserve:SetText(L['View Reserve']);
    reserve:SetCallback('OnClick', function() self.current = 'reserve'; switchView(self); end);
    self.frame:AddChild(reserve);

    reserve:SetPoint('LEFT', raid.frame, 'RIGHT', 5, 0);

    local options = AceGUI:Create('Button');
    options:SetWidth(100);
    options:SetHeight(25);
    options:SetText(L['View Options']);
    options:SetCallback('OnClick', function() InterfaceOptionsFrame_OpenToCategory(ExG.state.options); InterfaceOptionsFrame_OpenToCategory(ExG.state.options); end);
    self.frame:AddChild(options);

    options:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -10, -30);
end

function ExG.RosterFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['ExG']);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(PANE_WIDTH);
    self.frame:SetHeight(PANE_HEIGH + 60);
    self.frame:Hide();

    self.frame:SetCallback('OnClose', function() self:Close(); end);

    makeTopLine(self);

    self.Guild:Create(self);
    self.Raid:Create(self);
    self.Reserve:Create(self);

    self.AdjustDialog:Create();
    self.DecayDialog:Create();
    self.VersionDialog:Create();

    ExG:RestorePoints(self.frame, 'RosterFrame');
end

function ExG.RosterFrame:Open()
    self.frame:Show();

    switchView(self);
end

function ExG.RosterFrame:Close()
    self.Guild:Close();
    self.Raid:Close();
    self.Reserve:Close();

    self.AdjustDialog:Close();
    self.DecayDialog:Close();

    ExG:SavePoints(self.frame, 'RosterFrame');

    self.frame:Hide();
end

function ExG.RosterFrame:Refresh()
    if not self.frame:IsShown() then
        return;
    end

    if self.current == 'guild' then
        self.Guild:Open();
    elseif self.current == 'raid' then
        self.Raid:Open();
    elseif self.current == 'reserve' then
        self.Reserve:Open();
    end
end

ExG.RosterFrame.Guild = {
    frame = nil,
    list = nil,
    data = {},
    sort = {},
};

local function renderGuildItems(self)
    if not self.list then
        return;
    end

    for i, item in ipairs(self.data) do
        local row = self.list.children[i];

        if CanEditOfficerNote() then
            row.frame:SetScript('OnMouseDown', function() ExG.RosterFrame.AdjustDialog:Open(item.name, function() ExG.RosterFrame.Guild:Refresh(); end); end);
        end

        row.name:SetVertexColor(ExG:ClassColor(item.class));
        row.name:SetText(item.name);

        row.rank:SetVertexColor(ExG:ClassColor(item.class));
        row.rank:SetText(item.rank);

        row.pr:SetVertexColor(ExG:ClassColor(item.class));
        row.pr:SetText(format('%.2f', item.pr));

        row.gp:SetVertexColor(ExG:ClassColor(item.class));
        row.gp:SetText(item.gp);

        row.ep:SetVertexColor(ExG:ClassColor(item.class));
        row.ep:SetText(item.ep);
    end
end

local function sortGuildItems(self, field)
    return function()
        order(self, field);

        renderGuildItems(self);
    end;
end

local function makeGuildHeaders(self)
    local name = AceGUI:Create('InteractiveLabel');
    name:SetFont(DEFAULT_FONT, 10);
    name:SetWidth(80);
    name:SetHeight(20);
    name:SetJustifyH('CENTER');
    name:SetJustifyV('MIDDLE');
    name:SetColor(ExG:ClassColor('SYSTEM'));
    name:SetText(L['Name']);
    name:SetCallback('OnClick', sortGuildItems(self, 'name'));
    self.frame:AddChild(name);

    name:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -35);

    local class = AceGUI:Create('InteractiveLabel');
    class:SetFont(DEFAULT_FONT, 10);
    class:SetWidth(80);
    class:SetHeight(20);
    class:SetJustifyH('CENTER');
    class:SetJustifyV('MIDDLE');
    class:SetColor(ExG:ClassColor('SYSTEM'));
    class:SetText(L['Class']);
    class:SetCallback('OnClick', sortGuildItems(self, 'classLoc'));
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
    rank:SetCallback('OnClick', sortGuildItems(self, 'rankId'));
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
    pr:SetCallback('OnClick', sortGuildItems(self, 'pr'));
    self.frame:AddChild(pr);

    pr:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -20, -35);

    local gp = AceGUI:Create('InteractiveLabel');
    gp:SetFont(DEFAULT_FONT, 10);
    gp:SetWidth(50);
    gp:SetHeight(20);
    gp:SetFullHeight(true);
    gp:SetJustifyH('CENTER');
    gp:SetJustifyV('MIDDLE');
    gp:SetColor(ExG:ClassColor('SYSTEM'));
    gp:SetText(L['GP']);
    gp:SetCallback('OnClick', sortGuildItems(self, 'gp'));
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
    ep:SetCallback('OnClick', sortGuildItems(self, 'ep'));
    self.frame:AddChild(ep);

    ep:SetPoint('TOPRIGHT', gp.frame, 'TOPLEFT');
end

local function makeGuildButtons(self)
    self.frame.eg = AceGUI:Create('Button');
    self.frame.eg:SetWidth(120);
    self.frame.eg:SetHeight(25);
    self.frame.eg:SetText(L['Change Guild EPGP']);
    self.frame.eg:SetCallback('OnClick', function() ExG.RosterFrame.AdjustDialog:Open('guild', function() ExG.RosterFrame.Guild:Refresh(); end); end);
    self.frame:AddChild(self.frame.eg);

    self.frame.eg:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -5);

    self.frame.decay = AceGUI:Create('Button');
    self.frame.decay:SetWidth(120);
    self.frame.decay:SetHeight(25);
    self.frame.decay:SetText(L['Guild Decay']);
    self.frame.decay:SetCallback('OnClick', function() ExG.RosterFrame.DecayDialog:Open(function() ExG.RosterFrame.Guild:Refresh(); end); end);
    self.frame:AddChild(self.frame.decay);

    self.frame.decay:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -5, -5);
end

local function makeGuildItems(self)
    self.list:ReleaseChildren();

    for _, item in ipairs(self.data) do
        local row = AceGUI:Create('SimpleGroup');
        row:SetFullWidth(true);
        row:SetHeight(20);
        row:SetLayout(nil);
        row:SetAutoAdjustHeight(false);
        row.frame:EnableMouse(true);

        if not row.highlight then
            row.highlight = row.frame:CreateTexture(nil, 'HIGHLIGHT');
            row.highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
            row.highlight:SetAllPoints(true);
            row.highlight:SetBlendMode('ADD');
        end

        self.list:AddChild(row);

        if not row.name then
            row.name = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.name:SetFont(DEFAULT_FONT, 10);
            row.name:ClearAllPoints();
            row.name:SetPoint('TOPLEFT', 2, 0);
            row.name:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 160, 0);
            row.name:SetJustifyH('LEFT');
            row.name:SetJustifyV('MIDDLE');
        end

        if not row.rank then
            row.rank = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.rank:SetFont(DEFAULT_FONT, 10);
            row.rank:ClearAllPoints();
            row.rank:SetPoint('TOPLEFT', 160, 0);
            row.rank:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 260, 0);
            row.rank:SetJustifyH('CENTER');
            row.rank:SetJustifyV('MIDDLE');
        end

        if not row.pr then
            row.pr = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.pr:SetFont(DEFAULT_FONT, 10);
            row.pr:ClearAllPoints();
            row.pr:SetPoint('TOPRIGHT');
            row.pr:SetPoint('BOTTOMLEFT', row.frame, 'BOTTOMRIGHT', -50, 0);
            row.pr:SetJustifyH('CENTER');
            row.pr:SetJustifyV('MIDDLE');
        end

        if not row.gp then
            row.gp = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.gp:SetFont(DEFAULT_FONT, 10);
            row.gp:ClearAllPoints();
            row.gp:SetPoint('TOPRIGHT', row.pr, 'TOPLEFT');
            row.gp:SetPoint('BOTTOMLEFT', row.pr, 'BOTTOMLEFT', -50, 0);
            row.gp:SetJustifyH('CENTER');
            row.gp:SetJustifyV('MIDDLE');
        end

        if not row.ep then
            row.ep = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.ep:SetFont(DEFAULT_FONT, 10);
            row.ep:ClearAllPoints();
            row.ep:SetPoint('TOPRIGHT', row.gp, 'TOPLEFT');
            row.ep:SetPoint('BOTTOMLEFT', row.gp, 'BOTTOMLEFT', -50, 0);
            row.ep:SetJustifyH('CENTER');
            row.ep:SetJustifyV('MIDDLE');
        end
    end
end

function ExG.RosterFrame.Guild:Create(parent)
    self.frame = AceGUI:Create('SimpleGroup');
    self.frame:SetLayout(nil);
    self.frame:SetWidth(PANE_WIDTH);
    self.frame:SetHeight(PANE_HEIGH);
    parent.frame:AddChild(self.frame);

    self.frame:SetPoint('TOP', parent.frame.frame, 'TOP', 0, -60);

    makeGuildButtons(self);
    makeGuildHeaders(self);

    local group = AceGUI:Create('SimpleGroup');
    group:SetFullWidth(true);
    group:SetFullHeight(true);
    group:SetLayout('Fill');

    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -50);
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -5, 5);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');

    group:AddChild(self.list);

    self.frame.frame:Hide();
end

function ExG.RosterFrame.Guild:Open()
    self.data = {};

    for i = 1, GetNumGuildMembers() do
        local name, rank, rankId, level, classLoc, _, _, officerNote, isOnline, _, class = GetGuildRosterInfo(i);

        local eg = ExG:GetEG(officerNote);

        tinsert(self.data, { name = Ambiguate(name, 'all'), rank = rank, rankId = rankId, level = level, class = class, classLoc = classLoc, offNote = officerNote, isOnline = isOnline, ep = eg.ep, gp = eg.gp, pr = eg.pr, });
    end

    makeGuildItems(self);

    self.frame.eg:SetDisabled(not CanEditOfficerNote());
    self.frame.decay:SetDisabled(not CanEditOfficerNote());

    self.frame.frame:Show();

    renderGuildItems(self);
end

function ExG.RosterFrame.Guild:Close()
    self.data = {};
    self.frame.frame:Hide();
end

function ExG.RosterFrame.Guild:Refresh()
    for i, v in ipairs(self.data) do
        local info = ExG:GuildInfo(v.name);
        local eg = ExG:GetEG(info.officerNote);

        v.ep = eg.ep;
        v.gp = eg.gp;
        v.pr = eg.pr;
    end

    renderGuildItems(self);
end

ExG.RosterFrame.Raid = {
    frame = nil,
    list = nil,
    data = {},
    sort = {},
};

local function renderRaidItems(self)
    if not self.list then
        return;
    end

    for i, item in ipairs(self.data) do
        local row = self.list.children[i];

        if CanEditOfficerNote() then
            row.frame:SetScript('OnMouseDown', function() ExG.RosterFrame.AdjustDialog:Open(item.name, function() ExG.RosterFrame.Raid:Refresh(); end); end);
        end

        row.name:SetVertexColor(ExG:ClassColor(item.class));
        row.name:SetText(item.name);

        row.rank:SetVertexColor(ExG:ClassColor(item.class));
        row.rank:SetText(item.rank);

        row.group:SetVertexColor(ExG:ClassColor(item.class));
        row.group:SetText(L['Group Title'](item.group));

        row.pr:SetVertexColor(ExG:ClassColor(item.class));
        row.pr:SetText(format('%.2f', item.pr));

        row.gp:SetVertexColor(ExG:ClassColor(item.class));
        row.gp:SetText(item.gp);

        row.ep:SetVertexColor(ExG:ClassColor(item.class));
        row.ep:SetText(item.ep);
    end
end

local function sortRaidItems(self, field)
    return function()
        order(self, field);

        renderRaidItems(self);
    end;
end

local function makeRaidHeaders(self)
    local name = AceGUI:Create('InteractiveLabel');
    name:SetFont(DEFAULT_FONT, 10);
    name:SetWidth(80);
    name:SetHeight(20);
    name:SetJustifyH('CENTER');
    name:SetJustifyV('MIDDLE');
    name:SetColor(ExG:ClassColor('SYSTEM'));
    name:SetText(L['Name']);
    name:SetCallback('OnClick', sortRaidItems(self, 'name'));
    self.frame:AddChild(name);

    name:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -35);

    local class = AceGUI:Create('InteractiveLabel');
    class:SetFont(DEFAULT_FONT, 10);
    class:SetWidth(80);
    class:SetHeight(20);
    class:SetJustifyH('CENTER');
    class:SetJustifyV('MIDDLE');
    class:SetColor(ExG:ClassColor('SYSTEM'));
    class:SetText(L['Class']);
    class:SetCallback('OnClick', sortRaidItems(self, 'classLoc'));
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
    rank:SetCallback('OnClick', sortRaidItems(self, 'rankId'));
    self.frame:AddChild(rank);

    rank:SetPoint('TOPLEFT', class.frame, 'TOPRIGHT', 0, 0);

    local group = AceGUI:Create('InteractiveLabel');
    group:SetFont(DEFAULT_FONT, 10);
    group:SetWidth(140);
    group:SetHeight(20);
    group:SetJustifyH('CENTER');
    group:SetJustifyV('MIDDLE');
    group:SetColor(ExG:ClassColor('SYSTEM'));
    group:SetText(L['Group']);
    group:SetCallback('OnClick', sortRaidItems(self, 'group'));
    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', rank.frame, 'TOPRIGHT', 0, 0);

    local pr = AceGUI:Create('InteractiveLabel');
    pr:SetFont(DEFAULT_FONT, 10);
    pr:SetWidth(50);
    pr:SetHeight(20);
    pr:SetJustifyH('CENTER');
    pr:SetJustifyV('MIDDLE');
    pr:SetColor(ExG:ClassColor('SYSTEM'));
    pr:SetText(L['PR']);
    pr:SetCallback('OnClick', sortRaidItems(self, 'pr'));
    self.frame:AddChild(pr);

    pr:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -20, -35);

    local gp = AceGUI:Create('InteractiveLabel');
    gp:SetFont(DEFAULT_FONT, 10);
    gp:SetWidth(50);
    gp:SetHeight(20);
    gp:SetFullHeight(true);
    gp:SetJustifyH('CENTER');
    gp:SetJustifyV('MIDDLE');
    gp:SetColor(ExG:ClassColor('SYSTEM'));
    gp:SetText(L['GP']);
    gp:SetCallback('OnClick', sortRaidItems(self, 'gp'));
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
    ep:SetCallback('OnClick', sortRaidItems(self, 'ep'));
    self.frame:AddChild(ep);

    ep:SetPoint('TOPRIGHT', gp.frame, 'TOPLEFT');
end

local function makeRaidButtons(self)
    self.frame.eg = AceGUI:Create('Button');
    self.frame.eg:SetWidth(120);
    self.frame.eg:SetHeight(25);
    self.frame.eg:SetText(L['Change Raid EPGP']);
    self.frame.eg:SetCallback('OnClick', function() ExG.RosterFrame.AdjustDialog:Open('raid', function() ExG.RosterFrame.Raid:Refresh(); end); end);
    self.frame:AddChild(self.frame.eg);

    self.frame.eg:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -5);

    self.frame.version = AceGUI:Create('Button');
    self.frame.version:SetWidth(120);
    self.frame.version:SetHeight(25);
    self.frame.version:SetText(L['Version'](ExG.state.version));
    self.frame.version:SetCallback('OnClick', function() ExG.RosterFrame.VersionDialog:Open(); end);
    self.frame:AddChild(self.frame.version);

    self.frame.version:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -5, -5);
end

local function makeRaidItems(self)
    self.list:ReleaseChildren();

    for _, item in ipairs(self.data) do
        local row = AceGUI:Create('SimpleGroup');
        row:SetFullWidth(true);
        row:SetHeight(20);
        row:SetLayout(nil);
        row:SetAutoAdjustHeight(false);
        row.frame:EnableMouse(true);

        if not row.highlight then
            row.highlight = row.frame:CreateTexture(nil, 'HIGHLIGHT');
            row.highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
            row.highlight:SetAllPoints(true);
            row.highlight:SetBlendMode('ADD');
        end

        self.list:AddChild(row);

        if not row.name then
            row.name = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.name:SetFont(DEFAULT_FONT, 10);
            row.name:ClearAllPoints();
            row.name:SetPoint('TOPLEFT', 2, 0);
            row.name:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 160, 0);
            row.name:SetJustifyH('LEFT');
            row.name:SetJustifyV('MIDDLE');
        end

        if not row.rank then
            row.rank = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.rank:SetFont(DEFAULT_FONT, 10);
            row.rank:ClearAllPoints();
            row.rank:SetPoint('TOPLEFT', 160, 0);
            row.rank:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 260, 0);
            row.rank:SetJustifyH('CENTER');
            row.rank:SetJustifyV('MIDDLE');
        end

        if not row.group then
            row.group = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.group:SetFont(DEFAULT_FONT, 10);
            row.group:ClearAllPoints();
            row.group:SetPoint('TOPLEFT', 260, 0);
            row.group:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 400, 0);
            row.group:SetJustifyH('CENTER');
            row.group:SetJustifyV('MIDDLE');
        end

        if not row.pr then
            row.pr = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.pr:SetFont(DEFAULT_FONT, 10);
            row.pr:ClearAllPoints();
            row.pr:SetPoint('TOPRIGHT');
            row.pr:SetPoint('BOTTOMLEFT', row.frame, 'BOTTOMRIGHT', -50, 0);
            row.pr:SetJustifyH('CENTER');
            row.pr:SetJustifyV('MIDDLE');
        end

        if not row.gp then
            row.gp = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.gp:SetFont(DEFAULT_FONT, 10);
            row.gp:ClearAllPoints();
            row.gp:SetPoint('TOPRIGHT', row.pr, 'TOPLEFT');
            row.gp:SetPoint('BOTTOMLEFT', row.pr, 'BOTTOMLEFT', -50, 0);
            row.gp:SetJustifyH('CENTER');
            row.gp:SetJustifyV('MIDDLE');
        end

        if not row.ep then
            row.ep = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.ep:SetFont(DEFAULT_FONT, 10);
            row.ep:ClearAllPoints();
            row.ep:SetPoint('TOPRIGHT', row.gp, 'TOPLEFT');
            row.ep:SetPoint('BOTTOMLEFT', row.gp, 'BOTTOMLEFT', -50, 0);
            row.ep:SetJustifyH('CENTER');
            row.ep:SetJustifyV('MIDDLE');
        end
    end
end

function ExG.RosterFrame.Raid:Create(parent)
    self.frame = AceGUI:Create('SimpleGroup');
    self.frame:SetLayout(nil);
    self.frame:SetWidth(PANE_WIDTH);
    self.frame:SetHeight(PANE_HEIGH);
    parent.frame:AddChild(self.frame);

    self.frame:SetPoint('TOP', parent.frame.frame, 'TOP', 0, -60);

    makeRaidButtons(self);
    makeRaidHeaders(self);

    local group = AceGUI:Create('SimpleGroup');
    group:SetFullWidth(true);
    group:SetFullHeight(true);
    group:SetLayout('Fill');

    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -50);
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -5, 5);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');

    group:AddChild(self.list);

    self.frame.frame:Hide();
end

function ExG.RosterFrame.Raid:Open()
    self.data = {};

    for i = 1, MAX_RAID_MEMBERS do
        local name, rank, subgroup, level, classDisplayName, class, zone, online, isDead, role, isMl, combatRole = GetRaidRosterInfo(i);

        if name then
            name = Ambiguate(name, 'all');

            local info = ExG:GuildInfo(name);
            local eg = ExG:GetEG(info.officerNote);

            tinsert(self.data, { name = name, rank = info.rank, rankId = info.rankId, group = subgroup, level = level, class = class, classLoc = info.classLoc, offNote = info.officerNote, isOnline = info.isOnline, ep = eg.ep, gp = eg.gp, pr = eg.pr, });
        end
    end

    makeRaidItems(self);

    self.frame.eg:SetDisabled(not CanEditOfficerNote());

    self.frame.frame:Show();

    renderRaidItems(self);
end

function ExG.RosterFrame.Raid:Close()
    self.data = {};
    self.frame.frame:Hide();
end

function ExG.RosterFrame.Raid:Refresh()
    for i, v in ipairs(self.data) do
        local info = ExG:GuildInfo(v.name);
        local eg = ExG:GetEG(info.officerNote);

        v.ep = eg.ep;
        v.gp = eg.gp;
        v.pr = eg.pr;
    end

    renderRaidItems(self);
end

ExG.RosterFrame.Reserve = {
    frame = nil,
    list = nil,
    data = {},
    sort = {},
};

local function renderReserveItems(self)
    if not self.list then
        return;
    end

    for i, item in ipairs(self.data) do
        local row = self.list.children[i];

        if CanEditOfficerNote() then
            row.frame:SetScript('OnMouseDown', function() ExG.RosterFrame.AdjustDialog:Open(item.name, function() ExG.RosterFrame.Reserve:Refresh(); end); end);
        end

        row.name:SetVertexColor(ExG:ClassColor(item.class));
        row.name:SetText(item.name);

        row.rank:SetVertexColor(ExG:ClassColor(item.class));
        row.rank:SetText(item.rank);

        row.pr:SetVertexColor(ExG:ClassColor(item.class));
        row.pr:SetText(format('%.2f', item.pr));

        row.gp:SetVertexColor(ExG:ClassColor(item.class));
        row.gp:SetText(item.gp);

        row.ep:SetVertexColor(ExG:ClassColor(item.class));
        row.ep:SetText(item.ep);

        row.remove:SetDisabled(not ExG:IsMl());
        if ExG:IsMl() then
            row.remove:SetCallback('OnClick', function() store().raid.reserve[item.name] = nil; ExG:Reserve({ action = 'sync', reserve = store().raid.reserve, }); end);
        end
    end
end

local function sortReserveItems(self, field)
    return function()
        order(self, field);

        renderReserveItems(self);
    end;
end

local function makeReserveHeaders(self)
    local name = AceGUI:Create('InteractiveLabel');
    name:SetFont(DEFAULT_FONT, 10);
    name:SetWidth(80);
    name:SetHeight(20);
    name:SetJustifyH('CENTER');
    name:SetJustifyV('MIDDLE');
    name:SetColor(ExG:ClassColor('SYSTEM'));
    name:SetText(L['Name']);
    name:SetCallback('OnClick', sortReserveItems(self, 'name'));
    self.frame:AddChild(name);

    name:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -35);

    local class = AceGUI:Create('InteractiveLabel');
    class:SetFont(DEFAULT_FONT, 10);
    class:SetWidth(80);
    class:SetHeight(20);
    class:SetJustifyH('CENTER');
    class:SetJustifyV('MIDDLE');
    class:SetColor(ExG:ClassColor('SYSTEM'));
    class:SetText(L['Class']);
    class:SetCallback('OnClick', sortReserveItems(self, 'classLoc'));
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
    rank:SetCallback('OnClick', sortReserveItems(self, 'rankId'));
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
    pr:SetCallback('OnClick', sortReserveItems(self, 'pr'));
    self.frame:AddChild(pr);

    pr:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -20, -35);

    local gp = AceGUI:Create('InteractiveLabel');
    gp:SetFont(DEFAULT_FONT, 10);
    gp:SetWidth(50);
    gp:SetHeight(20);
    gp:SetFullHeight(true);
    gp:SetJustifyH('CENTER');
    gp:SetJustifyV('MIDDLE');
    gp:SetColor(ExG:ClassColor('SYSTEM'));
    gp:SetText(L['GP']);
    gp:SetCallback('OnClick', sortReserveItems(self, 'gp'));
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
    ep:SetCallback('OnClick', sortReserveItems(self, 'ep'));
    self.frame:AddChild(ep);

    ep:SetPoint('TOPRIGHT', gp.frame, 'TOPLEFT');
end

local function makeReserveButtons(self)
    self.eg = AceGUI:Create('Button');
    self.eg:SetWidth(120);
    self.eg:SetHeight(25);
    self.eg:SetText(L['Change Reserve EPGP']);
    self.eg:SetCallback('OnClick', function() ExG.RosterFrame.AdjustDialog:Open('reserve', function() ExG.RosterFrame.Reserve:Refresh(); end); end);
    self.frame:AddChild(self.eg);

    self.eg:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -5);

    self.join = AceGUI:Create('Button');
    self.join:SetWidth(120);
    self.join:SetHeight(25);
    self.join:SetText(L['Join Reserve']);
    self.join:SetCallback('OnClick', function() ExG:Reserve({ action = 'join', }); end);
    self.frame:AddChild(self.join);

    self.join:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -5, -5);

    self.label = AceGUI:Create('Label');
    self.label:SetWidth(85);
    self.label:SetHeight(25);
    self.label:SetJustifyH('RIGHT');
    self.label:SetJustifyV('MIDDLE');
    self.label:SetText(L['Add Reserve Player']);
    self.frame:AddChild(self.label);

    self.label:SetPoint('LEFT', self.eg.frame, 'RIGHT', 25, 0);

    self.unit = AceGUI:Create('EditBox');
    self.unit:SetWidth(150);
    self.unit:SetHeight(25);
    self.unit:SetText(nil);
    self.unit:SetCallback('OnEnterPressed', function() local info = ExG:GuildInfo(self.unit:GetText()); if info then store().raid.reserve[info.name] = true; ExG:Reserve({ action = 'sync', reserve = store().raid.reserve, }); self.unit:SetText(''); end end);
    self.frame:AddChild(self.unit);

    self.unit:SetPoint('LEFT', self.label.frame, 'RIGHT', 5, 0);
end

local function makeReserveItems(self)
    self.list:ReleaseChildren();

    for _, item in ipairs(self.data) do
        local row = AceGUI:Create('SimpleGroup');
        row:SetFullWidth(true);
        row:SetHeight(20);
        row:SetLayout(nil);
        row:SetAutoAdjustHeight(false);
        row.frame:EnableMouse(true);

        if not row.highlight then
            row.highlight = row.frame:CreateTexture(nil, 'HIGHLIGHT');
            row.highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
            row.highlight:SetAllPoints(true);
            row.highlight:SetBlendMode('ADD');
        end

        self.list:AddChild(row);

        if not row.name then
            row.name = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.name:SetFont(DEFAULT_FONT, 10);
            row.name:ClearAllPoints();
            row.name:SetPoint('TOPLEFT', 2, 0);
            row.name:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 160, 0);
            row.name:SetJustifyH('LEFT');
            row.name:SetJustifyV('MIDDLE');
        end

        if not row.rank then
            row.rank = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.rank:SetFont(DEFAULT_FONT, 10);
            row.rank:ClearAllPoints();
            row.rank:SetPoint('TOPLEFT', 160, 0);
            row.rank:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 260, 0);
            row.rank:SetJustifyH('CENTER');
            row.rank:SetJustifyV('MIDDLE');
        end

        row.remove = AceGUI:Create('Button');
        row.remove:SetHeight(20);
        row.remove:SetWidth(20);
        row.remove:SetText('X');
        row.remove:SetCallback('OnClick', function() end);

        row:AddChild(row.remove);

        row.remove:SetPoint('TOPLEFT', 300, 0);
        row.remove:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 340, 0);

        if not row.pr then
            row.pr = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.pr:SetFont(DEFAULT_FONT, 10);
            row.pr:ClearAllPoints();
            row.pr:SetPoint('TOPRIGHT');
            row.pr:SetPoint('BOTTOMLEFT', row.frame, 'BOTTOMRIGHT', -50, 0);
            row.pr:SetJustifyH('CENTER');
            row.pr:SetJustifyV('MIDDLE');
        end

        if not row.gp then
            row.gp = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.gp:SetFont(DEFAULT_FONT, 10);
            row.gp:ClearAllPoints();
            row.gp:SetPoint('TOPRIGHT', row.pr, 'TOPLEFT');
            row.gp:SetPoint('BOTTOMLEFT', row.pr, 'BOTTOMLEFT', -50, 0);
            row.gp:SetJustifyH('CENTER');
            row.gp:SetJustifyV('MIDDLE');
        end

        if not row.ep then
            row.ep = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            row.ep:SetFont(DEFAULT_FONT, 10);
            row.ep:ClearAllPoints();
            row.ep:SetPoint('TOPRIGHT', row.gp, 'TOPLEFT');
            row.ep:SetPoint('BOTTOMLEFT', row.gp, 'BOTTOMLEFT', -50, 0);
            row.ep:SetJustifyH('CENTER');
            row.ep:SetJustifyV('MIDDLE');
        end
    end
end

function ExG.RosterFrame.Reserve:Create(parent)
    self.frame = AceGUI:Create('SimpleGroup');
    self.frame:SetLayout(nil);
    self.frame:SetWidth(PANE_WIDTH);
    self.frame:SetHeight(PANE_HEIGH);
    parent.frame:AddChild(self.frame);

    self.frame:SetPoint('TOP', parent.frame.frame, 'TOP', 0, -60);

    makeReserveButtons(self);
    makeReserveHeaders(self);

    local group = AceGUI:Create('SimpleGroup');
    group:SetFullWidth(true);
    group:SetFullHeight(true);
    group:SetLayout('Fill');

    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -50);
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -5, 5);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');

    group:AddChild(self.list);

    self.frame.frame:Hide();
end

function ExG.RosterFrame.Reserve:Open()
    self.data = {};

    for name in pairs(store().raid.reserve) do
        local info = ExG:GuildInfo(name);
        local eg = ExG:GetEG(info.officerNote);

        tinsert(self.data, { name = name, rank = info.rank, rankId = info.rankId, level = info.level, class = info.class, classLoc = info.classLoc, offNote = info.officerNote, isOnline = info.isOnline, ep = eg.ep, gp = eg.gp, pr = eg.pr, });
    end

    makeReserveItems(self);

    self.eg:SetDisabled(not CanEditOfficerNote());
    self.unit:SetDisabled(not ExG:IsMl());

    self.frame.frame:Show();

    renderReserveItems(self);
end

function ExG.RosterFrame.Reserve:Close()
    self.data = {};
    self.frame.frame:Hide();
end

function ExG.RosterFrame.Reserve:Refresh()
    for i, v in ipairs(self.data) do
        local info = ExG:GuildInfo(v.name);
        local eg = ExG:GetEG(info.officerNote);

        v.ep = eg.ep;
        v.gp = eg.gp;
        v.pr = eg.pr;
    end

    renderReserveItems(self);
end

ExG.RosterFrame.AdjustDialog = {
    frame = nil,
    unit = nil,
}

local function renderAdjustDialog(self)
    self.ep = AceGUI:Create('CheckBox');
    self.ep:SetLabel(L['EP']);
    self.ep:SetValue(true);
    self.ep:SetCallback('OnValueChanged', function(value) self.gp:SetValue(not value.checked); end);
    self.frame:AddChild(self.ep);

    self.ep:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -30);
    self.ep:SetPoint('BOTTOMRIGHT', self.frame.frame, 'TOPRIGHT', -5, -50);

    self.gp = AceGUI:Create('CheckBox');
    self.gp:SetLabel(L['GP']);
    self.gp:SetCallback('OnValueChanged', function(value) self.ep:SetValue(not value.checked); end);
    self.frame:AddChild(self.gp);

    self.gp:SetPoint('TOPLEFT', self.ep.frame, 'BOTTOMLEFT', 0, -5);
    self.gp:SetPoint('BOTTOMRIGHT', self.ep.frame, 'BOTTOMRIGHT', 0, -25);

    self.amount = AceGUI:Create('EditBox');
    self.amount:DisableButton(true);
    self.amount:SetWidth(120);
    self.amount:SetHeight(25);
    self.amount:SetLabel(L['Amount']);
    self.frame:AddChild(self.amount);

    self.amount:SetPoint('TOPLEFT', self.gp.frame, 'BOTTOMLEFT', 0, -5);
    self.amount:SetPoint('RIGHT', self.gp.frame, 'RIGHT', 0, 0);

    self.reason = AceGUI:Create('EditBox');
    self.reason:DisableButton(true);
    self.reason:SetWidth(120);
    self.reason:SetHeight(25);
    self.reason:SetLabel(L['Reason']);
    self.frame:AddChild(self.reason);

    self.reason:SetPoint('TOPLEFT', self.amount.frame, 'BOTTOMLEFT', 0, -5);
    self.reason:SetPoint('RIGHT', self.amount.frame, 'RIGHT', 0, 0);

    self.apply = AceGUI:Create('Button');
    self.apply:SetWidth(120);
    self.apply:SetHeight(25);
    self.apply:SetText(L['Ok']);
    self.apply:SetCallback('OnClick', function() self:Adjust(); end);
    self.frame:AddChild(self.apply);

    self.apply:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 5, 5);
    self.apply:SetPoint('TOPRIGHT', self.frame.frame, 'BOTTOMLEFT', 120, 30);

    self.cancel = AceGUI:Create('Button');
    self.cancel:SetWidth(120);
    self.cancel:SetHeight(25);
    self.cancel:SetText(L['Cancel']);
    self.cancel:SetCallback('OnClick', function() self:Close(); end);
    self.frame:AddChild(self.cancel);

    self.cancel:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -5, 5);
    self.cancel:SetPoint('TOPLEFT', self.frame.frame, 'BOTTOMRIGHT', -120, 30);
end

function ExG.RosterFrame.AdjustDialog:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(self.unit);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(300);
    self.frame:SetHeight(210);
    self.frame:SetCallback('OnClose', function() self:Close(); end);
    self.frame:Hide();

    renderAdjustDialog(self);

    ExG:RestorePoints(self.frame, 'RosterFrame.AdjustDialog');
end

function ExG.RosterFrame.AdjustDialog:Open(unit, callback)
    self.unit = unit;
    self.callback = callback;

    if strlower(self.unit) == 'guild' then
        self.frame:SetTitle(L['GUILD']);
    elseif strlower(self.unit) == 'raid' then
        self.frame:SetTitle(L['RAID']);
    elseif strlower(self.unit) == 'reserve' then
        self.frame:SetTitle(L['RESERVE']);
    else
        self.frame:SetTitle(self.unit);
    end

    self.frame:Show();
end

function ExG.RosterFrame.AdjustDialog:Close()
    if self.callback then
        ExG:ScheduleTimer(self.callback, 0.5);
    end

    self.unit = nil;
    self.callback = nil;

    ExG:SavePoints(self.frame, 'RosterFrame.AdjustDialog');

    self.frame:Hide();
end

function ExG.RosterFrame.AdjustDialog:Adjust()
    if not self.unit then
        return;
    end

    local ep, gp;

    if self.ep:GetValue() then
        ep = tonumber(self.amount:GetText());
    elseif self.gp:GetValue() then
        gp = tonumber(self.amount:GetText());
    end

    local desc = self.reason:GetText();

    if strlower(self.unit) == 'guild' then
        self:GuidEG(ep, gp, desc);
    elseif strlower(self.unit) == 'raid' then
        self:RaidEG(ep, gp, desc);
    elseif strlower(self.unit) == 'reserve' then
        self:ReserveEG(ep, gp, desc);
    else
        self:UnitEG(self.unit, ep, gp, desc);
    end

    self:Close();
end

function ExG.RosterFrame.AdjustDialog:GuidEG(ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    if (ep or 0) == 0 and (gp or 0) == 0 then
        return;
    end

    local dt, offset = ExG:ServerTime(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'guild',
        target = { name = L['ExG History GUILD'], class = 'GUILD', },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['ExG Guid EG'](ep, gp, desc);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, GetNumGuildMembers() do
        local st = dt + i / 1000;

        local name, _, _, _, _, _, _, officerNote, _, _, class = GetGuildRosterInfo(i);
        local info = { index = i, name = Ambiguate(name, 'all'), class = class, officerNote = officerNote };

        if info.name then
            local old = ExG:GetEG(officerNote);
            local new = ExG:SetEG(info, old.ep + ep, old.gp + gp);

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    ExG:Report(L['ExG Report Guild EG'](ep, gp, desc));
end

function ExG.RosterFrame.AdjustDialog:RaidEG(ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    if (ep or 0) == 0 and (gp or 0) == 0 then
        return;
    end

    local dt, offset = ExG:ServerTime(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'raid',
        target = { name = L['ExG History RAID'], class = 'RAID', },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['ExG Raid EG'](ep, gp, desc);
        dt = dt,
        details = {},
    };

    local details = {};
    local ignore = {};
    local i = 0;

    for i = 1, MAX_RAID_MEMBERS do
        local name = GetRaidRosterInfo(i);

        if name then
            name = Ambiguate(name, 'all');
            ignore[name] = true;

            local info = ExG:GuildInfo(name);

            if info.name then
                local st = dt + i / 1000;
                local old = ExG:GetEG(info.officerNote);
                local new = ExG:SetEG(info, old.ep + ep, old.gp + gp);

                details[st] = {
                    target = { name = info.name, class = info.class, },
                    ep = { before = old.ep, after = new.ep, };
                    gp = { before = old.gp, after = new.gp, };
                    dt = st,
                };
            end
        end
    end

    for name, v in pairs(store().raid.reserve) do
        i = i + 1;

        local info = ExG:GuildInfo(name);

        if v and info and (not ignore[name]) then
            local st = dt + i / 1000;
            local old = ExG:GetEG(info.officerNote);
            local new = ExG:SetEG(info, old.ep + ep, old.gp + gp);

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    ExG:Report(L['ExG Report Raid EG'](ep, gp, desc));
end

function ExG.RosterFrame.AdjustDialog:ReserveEG(ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    if (ep or 0) == 0 and (gp or 0) == 0 then
        return;
    end

    local dt, offset = ExG:ServerTime(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'raid',
        target = { name = L['ExG History RESERVE'], class = 'RESERVE', },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['ExG Reserve EG'](ep, gp, desc);
        dt = dt,
        details = {},
    };

    local details = {};
    local ignore = {};
    local i = 0;

    for name, v in pairs(store().raid.reserve) do
        i = i + 1;

        local info = ExG:GuildInfo(name);

        if v and info.name then
            local st = dt + i / 1000;
            local old = ExG:GetEG(info.officerNote);
            local new = ExG:SetEG(info, old.ep + ep, old.gp + gp);

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    ExG:Report(L['ExG Report Reserve EG'](ep, gp, desc));
end

function ExG.RosterFrame.AdjustDialog:UnitEG(unit, ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    local info = ExG:GuildInfo(unit);

    if not info then
        return;
    end

    local old = ExG:GetEG(info.officerNote);
    local new, type, diff;

    if ep ~= 0 then
        type = 'EP';
        diff = ep;
        new = ExG:SetEG(info, old.ep + ep, old.gp);
    elseif gp ~= 0 then
        type = 'GP';
        diff = gp;
        new = ExG:SetEG(info, old.ep, old.gp + gp);
    end

    if not new then
        return;
    end

    local dt, offset = ExG:ServerTime(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'unit',
        target = { name = unit, class = info.class, },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['Unit Adjust Desc'](type, diff, desc);
        ep = { before = old.ep, after = new.ep, };
        gp = { before = old.gp, after = new.gp, };
        dt = dt,
    };

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    ExG:Report(L['ExG Report Unit EG'](unit, type, diff, desc));
end

ExG.RosterFrame.DecayDialog = {
    frame = nil,
};

local function renderDecayDialog(self)
    self.amount = AceGUI:Create('EditBox');
    self.amount:DisableButton(true);
    self.amount:SetWidth(120);
    self.amount:SetHeight(25);
    self.amount:SetLabel(L['Percent']);
    self.frame:AddChild(self.amount);

    self.amount:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -30);
    self.amount:SetPoint('RIGHT', self.frame.frame, 'RIGHT', -5, 0);

    self.apply = AceGUI:Create('Button');
    self.apply:SetWidth(120);
    self.apply:SetHeight(25);
    self.apply:SetText(L['Ok']);
    self.apply:SetCallback('OnClick', function() self:Adjust(); end);
    self.frame:AddChild(self.apply);

    self.apply:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 5, 5);
    self.apply:SetPoint('TOPRIGHT', self.frame.frame, 'BOTTOMLEFT', 120, 30);

    self.cancel = AceGUI:Create('Button');
    self.cancel:SetWidth(120);
    self.cancel:SetHeight(25);
    self.cancel:SetText(L['Cancel']);
    self.cancel:SetCallback('OnClick', function() self:Close(); end);
    self.frame:AddChild(self.cancel);

    self.cancel:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -5, 5);
    self.cancel:SetPoint('TOPLEFT', self.frame.frame, 'BOTTOMRIGHT', -120, 30);
end

function ExG.RosterFrame.DecayDialog:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(self.unit);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(300);
    self.frame:SetHeight(107);
    self.frame:SetCallback('OnClose', function() self:Close(); end);
    self.frame:Hide();

    renderDecayDialog(self);

    ExG:RestorePoints(self.frame, 'RosterFrame.DecayDialog');
end

function ExG.RosterFrame.DecayDialog:Open(callback)
    self.frame:SetTitle(L['Guild Decay']);
    self.callback = callback;

    self.frame:Show();
end

function ExG.RosterFrame.DecayDialog:Close()
    if self.callback then
        ExG:ScheduleTimer(self.callback, 0.5);
    end

    self.callback = nil;

    ExG:SavePoints(self.frame, 'RosterFrame.DecayDialog');

    self.frame:Hide();
end

function ExG.RosterFrame.DecayDialog:Adjust()
    local percent = tonumber(self.amount:GetText());

    if not percent then
        return;
    end

    local decay = 1 - percent / 100;

    local dt, offset = ExG:ServerTime(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'guild',
        target = { name = L['ExG History GUILD'], class = 'GUILD', },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['Guild Decay Desc'](percent);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, GetNumGuildMembers() do
        local st = dt + i / 1000;

        local name, _, _, _, _, _, _, officerNote, _, _, class = GetGuildRosterInfo(i);
        local info = { index = i, name = Ambiguate(name, 'all'), class = class, officerNote = officerNote, };

        if info.name then
            local old = ExG:GetEG(officerNote);
            local new = ExG:SetEG(info, floor(old.ep * decay), floor(old.gp * decay));

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    self:Close();
end

ExG.RosterFrame.VersionDialog = {
    frame = nil,
    raid = {},
    group = {},
    colors = {
        offline = { 0.7, 0.7, 0.7 },
        normal = { 0.25, 1, 0.25 },
        error = { 0.77, 0.12, 0.23 },
    },
};

local function makeVersionDialog(self)
    local refresh = AceGUI:Create('Button');
    refresh:SetWidth(120);
    refresh:SetHeight(25);
    refresh:SetText(L['Refresh']);
    refresh:SetCallback('OnClick', function() self:Refresh(); ExG:ScanVersions({ event = 'request', }); end);
    self.frame:AddChild(refresh);

    refresh:SetPoint('TOP', self.frame.frame, 'TOP', 0, -30);

    local report = AceGUI:Create('Button');
    report:SetWidth(120);
    report:SetHeight(25);
    report:SetText(L['Report']);
    report:SetCallback('OnClick', function() self:Report(); end);
    self.frame:AddChild(report);

    report:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -5, -30);

    local points = {
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 5, y = -60 },
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 145, y = -60 },
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 285, y = -60 },
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 425, y = -60 },
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 5, y = -230 },
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 145, y = -230 },
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 285, y = -230 },
        { point = 'TOPLEFT', frame = self.frame.frame, rel = 'TOPLEFT', x = 425, y = -230 },
    };

    self.group = {};

    for i = 1, 8 do
        self.group[i] = {};

        self.group[i].label = AceGUI:Create('Label');
        self.group[i].label:SetText(L['Group Title'](i));
        self.frame:AddChild(self.group[i].label);

        self.group[i].label:SetPoint(points[i].point, points[i].frame, points[i].rel, points[i].x, points[i].y);

        for k = 1, 5 do
            local unit = AceGUI:Create('SimpleGroup');

            unit = AceGUI:Create('SimpleGroup');
            unit:SetLayout(nil);
            unit:SetWidth(120);
            unit:SetHeight(25);

            unit.name = unit.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            unit.name:SetFont(DEFAULT_FONT, 10);
            unit.name:ClearAllPoints();
            unit.name:SetAllPoints();
            unit.name:SetJustifyH('LEFT');
            unit.name:SetJustifyV('MIDDLE');

            unit.status = unit.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
            unit.status:SetFont(DEFAULT_FONT, 10);
            unit.status:ClearAllPoints();
            unit.status:SetAllPoints();
            unit.status:SetJustifyH('RIGHT');
            unit.status:SetJustifyV('MIDDLE');

            self.frame:AddChild(unit);

            unit:SetPoint(points[i].point, points[i].frame, points[i].rel, points[i].x, points[i].y - (k == 1 and 20 or 20 + 28 * (k - 1)));

            self.group[i][k] = unit;
        end
    end
end

local function renderVersionDialog(self)
    for i = 1, 8 do
        for k = 1, 5 do
            self.group[i][k].unit = nil;

            self.group[i][k].name:SetText('-');
            self.group[i][k].name:SetVertexColor(ExG:ClassColor('PRIEST'));

            self.group[i][k].status:SetText('');
            self.group[i][k].status:SetVertexColor(unpack(self.colors.normal));
        end
    end

    if not IsInRaid() then
        return;
    end

    local raid = {};
    self.raid = {};

    for i = 1, MAX_RAID_MEMBERS do
        local name, rank, subgroup, level, classLoc, class, zone, online, isDead, role, isMl, combatRole = GetRaidRosterInfo(i);

        if name then
            raid[subgroup] = raid[subgroup] or {};

            tinsert(raid[subgroup], { name = Ambiguate(name, 'all'), class = class, online = online, });
        end
    end

    for i, group in pairs(raid) do
        sort(group, function(a, b) return a.name < b.name; end);

        for k, unit in ipairs(group) do
            self.raid[unit.name] = { group = i, idx = k, name = unit.name, old = true, };

            self.group[i][k].name:SetText(unit.name);
            self.group[i][k].name:SetVertexColor(ExG:ClassColor(unit.class));

            if unit.online then
                self.group[i][k].status:SetText(L['No response']);
                self.group[i][k].status:SetVertexColor(unpack(self.colors.error));
            else
                self.group[i][k].status:SetText(L['Offline']);
                self.group[i][k].status:SetVertexColor(unpack(self.colors.offline));
            end
        end
    end
end

function ExG.RosterFrame.VersionDialog:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Version'](ExG.state.version));
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(550);
    self.frame:SetHeight(395);
    self.frame:SetCallback('OnClose', function() self:Close(); end);
    self.frame:Hide();

    makeVersionDialog(self);

    ExG:RestorePoints(self.frame, 'RosterFrame.VersionDialog');
end

function ExG.RosterFrame.VersionDialog:Open()
    renderVersionDialog(self);

    self.frame:Show();

    self:Refresh();
    ExG:ScanVersions({ event = 'request', });
end

function ExG.RosterFrame.VersionDialog:Close()
    ExG:SavePoints(self.frame, 'RosterFrame.VersionDialog');

    self.frame:Hide();
end

function ExG.RosterFrame.VersionDialog:Update(status)
    local unit = self.raid[status.name];

    if not unit then
        return;
    end

    unit.old = (status.version ~= ExG.state.version);

    local pane = self.group[unit.group][unit.idx];

    if not pane then
        return;
    end

    if status.version == ExG.state.version then
        pane.status:SetText(status.version);
        pane.status:SetVertexColor(unpack(self.colors.normal));
    elseif status.version then
        pane.status:SetText(status.version);
        pane.status:SetVertexColor(unpack(self.colors.error));
    end
end

function ExG.RosterFrame.VersionDialog:Refresh()
    renderVersionDialog(self);
end

function ExG.RosterFrame.VersionDialog:Report()
    local res = {};

    for _, v in pairs(self.raid) do
        if v.old then
            tinsert(res, v);
        end
    end

    if #res == 0 then
        return;
    end

    sort(res, function(a, b) return a.name < b.name; end);

    for _, v in ipairs(res) do
        SendChatMessage(L['Need to update ExG version'](ExG.state.version), ExG.messages.whisper, nil, v.name);
    end
end
