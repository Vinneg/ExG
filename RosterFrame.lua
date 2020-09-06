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

    if not row.highlight then
        row.highlight = row.frame:CreateTexture(nil, 'HIGHLIGHT');
        row.highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
        row.highlight:SetAllPoints(true);
        row.highlight:SetBlendMode('ADD');
    end

    self.list:AddChild(row);

    if CanEditOfficerNote() then
        row.frame:SetScript('OnMouseDown', function() self.AdjustDialog:Show(item.name); end);
    end

    if not row.name then
        row.name = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        row.name:SetFont(DEFAULT_FONT, 10);
        row.name:ClearAllPoints();
        row.name:SetPoint('TOPLEFT', 2, 0);
        row.name:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 160, 0);
        row.name:SetJustifyH('LEFT');
        row.name:SetJustifyV('MIDDLE');
    end

    row.name:SetVertexColor(ExG:ClassColor(item.class));
    row.name:SetText(item.name);

    if not row.rank then
        row.rank = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        row.rank:SetFont(DEFAULT_FONT, 10);
        row.rank:ClearAllPoints();
        row.rank:SetPoint('TOPLEFT', 160, 0);
        row.rank:SetPoint('BOTTOMRIGHT', row.frame, 'BOTTOMLEFT', 260, 0);
        row.rank:SetJustifyH('CENTER');
        row.rank:SetJustifyV('MIDDLE');
    end

    row.rank:SetVertexColor(ExG:ClassColor(item.class));
    row.rank:SetText(item.rank);

    if not row.pr then
        row.pr = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        row.pr:SetFont(DEFAULT_FONT, 10);
        row.pr:ClearAllPoints();
        row.pr:SetPoint('TOPRIGHT');
        row.pr:SetPoint('BOTTOMLEFT', row.frame, 'BOTTOMRIGHT', -50, 0);
        row.pr:SetJustifyH('CENTER');
        row.pr:SetJustifyV('MIDDLE');
    end

    row.pr:SetVertexColor(ExG:ClassColor(item.class));
    row.pr:SetText(item.pr);

    if not row.gp then
        row.gp = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        row.gp:SetFont(DEFAULT_FONT, 10);
        row.gp:ClearAllPoints();
        row.gp:SetPoint('TOPRIGHT', row.pr, 'TOPLEFT');
        row.gp:SetPoint('BOTTOMLEFT', row.pr, 'BOTTOMLEFT', -50, 0);
        row.gp:SetJustifyH('CENTER');
        row.gp:SetJustifyV('MIDDLE');
    end

    row.gp:SetVertexColor(ExG:ClassColor(item.class));
    row.gp:SetText(item.gp);

    if not row.ep then
        row.ep = row.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        row.ep:SetFont(DEFAULT_FONT, 10);
        row.ep:ClearAllPoints();
        row.ep:SetPoint('TOPRIGHT', row.gp, 'TOPLEFT');
        row.ep:SetPoint('BOTTOMLEFT', row.gp, 'BOTTOMLEFT', -50, 0);
        row.ep:SetJustifyH('CENTER');
        row.ep:SetJustifyV('MIDDLE');
    end

    row.ep:SetVertexColor(ExG:ClassColor(item.class));
    row.ep:SetText(item.ep);
end

local function renderItems(self)
    if self.current == 'guild' then
        self.frame.guild.frame:Show();
        self.frame.raid.frame:Hide();
        self.frame.decay.frame:Show();
    elseif self.current == 'raid' then
        self.frame.guild.frame:Hide();
        self.frame.raid.frame:Show();
        self.frame.decay.frame:Hide();
    end

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
    self.frame:SetWidth(570);
    self.frame:SetHeight(700);
    self.frame:Hide();

    self.frame:SetCallback('OnClose', function() self.frame:Hide(); self.AdjustDialog:Hide(); self.DecayDialog:Hide(); end);

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

    self.frame.guild = AceGUI:Create('Button');
    self.frame.guild:SetWidth(120);
    self.frame.guild:SetHeight(25);
    self.frame.guild:SetText(L['Add Guild EPGP']);
    self.frame.guild:SetCallback('OnClick', function() self.AdjustDialog:Show('guild'); end);
    self.frame:AddChild(self.frame.guild);

    self.frame.guild:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 10, 5);
    self.frame.guild:SetPoint('TOPRIGHT', self.frame.frame, 'BOTTOMLEFT', 180, 25);

    self.frame.raid = AceGUI:Create('Button');
    self.frame.raid:SetWidth(120);
    self.frame.raid:SetHeight(25);
    self.frame.raid:SetText(L['Add Raid EPGP']);
    self.frame.raid:SetCallback('OnClick', function() self.AdjustDialog:Show('raid'); end);
    self.frame:AddChild(self.frame.raid);

    self.frame.raid:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 10, 5);
    self.frame.raid:SetPoint('TOPRIGHT', self.frame.frame, 'BOTTOMLEFT', 180, 25);

    self.frame.decay = AceGUI:Create('Button');
    self.frame.decay:SetWidth(120);
    self.frame.decay:SetHeight(25);
    self.frame.decay:SetText(L['Guild Decay']);
    self.frame.decay:SetCallback('OnClick', function() self.DecayDialog:Show(); end);
    self.frame:AddChild(self.frame.decay);

    self.frame.decay:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -10, 5);
    self.frame.decay:SetPoint('TOPLEFT', self.frame.frame, 'BOTTOMRIGHT', -180, 25);

    self.AdjustDialog:Create();
    self.DecayDialog:Create();
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

ExG.RosterFrame.AdjustDialog = {
    frame = nil,
    unit = nil,
}

local function guidEG(self, ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    if (ep or 0) == 0 and (gp or 0) == 0 then
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

    self:Hide();
end

local function raidEG(self, ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    if (ep or 0) == 0 and (gp or 0) == 0 then
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
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['ExG Raid EG'](ep, gp, desc);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, MAX_RAID_MEMBERS do
        local name = GetRaidRosterInfo(i);

        if name then
            local st = dt + i / 1000;

            local info = ExG:GuildInfo(Ambiguate(name, 'all'));

            if info.name then
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

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    self:Hide();
end

local function unitEG(self, unit, ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    local info = ExG:GuildInfo(self.unit);

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

    local dt, offset = time(), 0;

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

    self:Hide();
end

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
    self.cancel:SetCallback('OnClick', function() self.frame:Hide(); end);
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
    self.frame:SetCallback('OnClose', function() self.frame:Hide(); end);
    self.frame:Hide();

    renderAdjustDialog(self);
end

function ExG.RosterFrame.AdjustDialog:Show(unit)
    self.unit = unit;

    if strlower(self.unit) == 'guild' then
        self.frame:SetTitle(L['GUILD']);
    elseif strlower(self.unit) == 'raid' then
        self.frame:SetTitle(L['RAID']);
    else
        self.frame:SetTitle(self.unit);
    end

    self.frame:Show();
end

function ExG.RosterFrame.AdjustDialog:Hide()
    self.unit = nil;

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
        guidEG(self, ep, gp, desc);
    elseif strlower(self.unit) == 'raid' then
        raidEG(self, ep, gp, desc);
    else
        unitEG(self, self.unit, ep, gp, desc);
    end
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
    self.cancel:SetCallback('OnClick', function() self.frame:Hide(); end);
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
    self.frame:SetCallback('OnClose', function() self.frame:Hide(); end);
    self.frame:Hide();

    renderDecayDialog(self);
end

function ExG.RosterFrame.DecayDialog:Show()
    self.frame:SetTitle(L['Guild Decay']);

    self.frame:Show();
end

function ExG.RosterFrame.DecayDialog:Hide()
    self.frame:Hide();
end

function ExG.RosterFrame.DecayDialog:Adjust()
    local percent = tonumber(self.amount:GetText());

    if not percent then
        return;
    end

    print(percent);

    local decay = 1 - percent / 100;

    local dt, offset = time(), 0;

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
        local info = { index = i, name = Ambiguate(name, 'all'), class = class, officerNote = officerNote };

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

    self:Hide();
end
