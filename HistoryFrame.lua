local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local onClick = function(owner, link) return function() GameTooltip:SetOwner(owner, 'ANCHOR_CURSOR'); GameTooltip:SetHyperlink(link); GameTooltip:Show(); end; end;
local onLeave = function() return function() GameTooltip:Hide(); end; end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.HistoryFrame = {
    frame = nil,
    headers = nil;
    list = nil,
    data = {},
    page = 0,
};

local function fillData(self)
    self.data = {};

    for _, v in pairs(store().history.data) do
        tinsert(self.data, v);
    end

    sort(self.data, function(a, b) return (a.dt or 0) > (b.dt or 0); end);
end

local function renderRow(self, rec)
    local row = AceGUI:Create('SimpleGroup');
    row:SetFullWidth(true);
    row:SetLayout('Flow');
    row.frame:EnableMouse(true);

    local highlight = row.frame:CreateTexture(nil, 'HIGHLIGHT');
    highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
    highlight:SetAllPoints(true);
    highlight:SetBlendMode('ADD');
    self.list:AddChild(row);

    local dt = AceGUI:Create('Label');
    dt:SetFont(DEFAULT_FONT, 10);
    dt:SetRelativeWidth(0.07);
    dt:SetFullHeight(true);
    dt:SetJustifyH('CENTER');
    dt:SetText(date('%d.%m', rec.dt));
    row:AddChild(dt);

    local target = AceGUI:Create('Label');
    target:SetFont(DEFAULT_FONT, 10);
    target:SetRelativeWidth(0.12);
    target:SetFullHeight(true);
    target:SetColor(ExG:ClassColor(rec.target and rec.target.class));
    target:SetText(rec.target and rec.target.name);
    row:AddChild(target);

    local master = AceGUI:Create('Label');
    master:SetFont(DEFAULT_FONT, 10);
    master:SetRelativeWidth(0.12);
    master:SetFullHeight(true);
    master:SetColor(ExG:ClassColor(rec.master.class));
    master:SetText(rec.master.name);
    row:AddChild(master);

    local desc = AceGUI:Create('Label');
    desc:SetFont(DEFAULT_FONT, 10);
    desc:SetRelativeWidth(0.45);
    desc:SetFullHeight(true);
    desc:SetJustifyH('RIGHT');
    desc:SetText(rec.desc);

    if rec.link and rec.link ~= '' then
        row.frame:SetScript('OnMouseDown', onClick(self.frame.frame, rec.link));
        row.frame:SetScript('OnLeave', onLeave());

        local link = desc.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        link:SetFont(DEFAULT_FONT, 10);
        link:ClearAllPoints();
        link:SetAllPoints();
        link:SetJustifyH('LEFT');
        link:SetText(rec.link);

        desc.link = link;

        desc.OnRelease = function(self) if self.link then self.link:ClearAllPoints(); self.link = nil; end end;
    end

    row:AddChild(desc);

    local ep = AceGUI:Create('Label');
    ep:SetFont(DEFAULT_FONT, 10);
    ep:SetRelativeWidth(0.12);
    ep:SetFullHeight(true);
    ep:SetJustifyH('CENTER');
    if rec.ep and (rec.ep.before or rec.ep.before) then
        ep:SetText(L['History EG'](rec.ep));
    end
    row:AddChild(ep);

    local gp = AceGUI:Create('Label');
    gp:SetFont(DEFAULT_FONT, 10);
    gp:SetRelativeWidth(0.12);
    gp:SetFullHeight(true);
    gp:SetJustifyH('CENTER');
    if rec.gp and (rec.gp.after or rec.gp.after) then
        gp:SetText(L['History EG'](rec.gp));
    end
    row:AddChild(gp);
end

local function renderList(self)
    self.list:ReleaseChildren();

    local offset = self.page * store().history.pageSize;

    for i = 1, store().history.pageSize do
        local rec = self.data[i + offset];

        if rec then
            renderRow(self, rec);
        end
    end
end

local function totalPages(self)
    return math.ceil(#self.data / store().history.pageSize);
end

local function goBack(self)
    self.page = math.max(0, self.page - 1);
    self.frame:SetTitle(L['History Frame'](self.page, totalPages(self)));
    renderList(self);
end

local function goForward(self)
    self.page = math.min(totalPages(self), self.page + 1);
    self.frame:SetTitle(L['History Frame'](self.page, totalPages(self)));
    renderList(self);
end

local function goRefresh(self)
    fillData(self);

    self.page = 0;
    self.frame:SetTitle(L['History Frame'](self.page, totalPages(self)));
    renderList(self);
end

local function makeButtons(self)
    local back = AceGUI:Create('Button');
    back:SetWidth(20);
    back:SetHeight(20);
    back:SetText('<');
    back:SetCallback('OnClick', function() goBack(self); end);
    self.frame:AddChild(back);

    back:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);

    local forward = AceGUI:Create('Button');
    forward:SetWidth(20);
    forward:SetHeight(20);
    forward:SetText('>');
    forward:SetCallback('OnClick', function() goForward(self); end);
    self.frame:AddChild(forward);

    forward:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -10, -30);

    local refresh = AceGUI:Create('Button');
    refresh:SetWidth(120);
    refresh:SetHeight(20);
    refresh:SetText(L['Refresh']);
    refresh:SetCallback('OnClick', function() goRefresh(self); end);
    self.frame:AddChild(refresh);

    refresh:SetPoint('TOP', self.frame.frame, 'TOP', 0, -30);
end

local function makeHeaders(self)
    self.headers = AceGUI:Create('SimpleGroup');
    self.headers:SetFullWidth(true);
    self.headers:SetLayout('Flow');
    self.frame:AddChild(self.headers);

    self.headers:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -55);
    self.headers:SetPoint('TOPRIGHT', self.frame.frame, 'TOPRIGHT', -10, -55);

    local dt = AceGUI:Create('Label');
    dt:SetFont(DEFAULT_FONT, 10);
    dt:SetRelativeWidth(0.05);
    dt:SetFullHeight(true);
    dt:SetJustifyH('CENTER');
    dt:SetColor(ExG:ClassColor('SYSTEM'));
    dt:SetText(L['Date']);
    self.headers:AddChild(dt);

    local name = AceGUI:Create('Label');
    name:SetFont(DEFAULT_FONT, 10);
    name:SetRelativeWidth(0.13);
    name:SetFullHeight(true);
    name:SetJustifyH('CENTER');
    name:SetColor(ExG:ClassColor('SYSTEM'));
    name:SetText(L['Name']);
    self.headers:AddChild(name);

    local master = AceGUI:Create('Label');
    master:SetFont(DEFAULT_FONT, 10);
    master:SetRelativeWidth(0.13);
    master:SetFullHeight(true);
    master:SetJustifyH('CENTER');
    master:SetColor(ExG:ClassColor('SYSTEM'));
    master:SetText(L['Master']);
    self.headers:AddChild(master);

    local desc = AceGUI:Create('Label');
    desc:SetFont(DEFAULT_FONT, 10);
    desc:SetRelativeWidth(0.45);
    desc:SetFullHeight(true);
    desc:SetJustifyH('CENTER');
    desc:SetColor(ExG:ClassColor('SYSTEM'));
    desc:SetText(L['Description']);
    self.headers:AddChild(desc);

    local ep = AceGUI:Create('Label');
    ep:SetFont(DEFAULT_FONT, 10);
    ep:SetRelativeWidth(0.12);
    ep:SetFullHeight(true);
    ep:SetJustifyH('CENTER');
    ep:SetColor(ExG:ClassColor('SYSTEM'));
    ep:SetText(L['EP']);
    self.headers:AddChild(ep);

    local gp = AceGUI:Create('Label');
    gp:SetFont(DEFAULT_FONT, 10);
    gp:SetRelativeWidth(0.12);
    gp:SetFullHeight(true);
    gp:SetJustifyH('CENTER');
    gp:SetColor(ExG:ClassColor('SYSTEM'));
    gp:SetText(L['GP']);
    self.headers:AddChild(gp);
end

function ExG.HistoryFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['History Frame'](self.page, totalPages(self)));
    self.frame:SetWidth(500);
    self.frame:SetWidth(750);
    self.frame:SetLayout(nil);
    self.frame:SetCallback('OnClose', function() self.data = {}; self.frame:Hide(); end)
    self.frame:Hide();

    makeButtons(self);
    makeHeaders(self);

    local group = AceGUI:Create('SimpleGroup');
    group:SetFullWidth(true);
    group:SetFullHeight(true);
    group:SetLayout('Fill');
    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -69);
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -10, 30);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');
    group:AddChild(self.list);
end

function ExG.HistoryFrame:Show()
    self.frame:Show();

    fillData(self);
    self.frame:SetTitle(L['History Frame'](self.page, totalPages(self)));
    renderList(self);
end

function ExG.HistoryFrame:Hide()
    self.frame:Hide();
end
