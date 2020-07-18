local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.ItemsFrame = {
    frame = nil,
    headers = nil;
    list = nil,
    data = {},
    page = 0,
};

local function fillData(self)
    self.data = {};
end

local function renderRow(self, rec)
    local row = AceGUI:Create('SimpleGroup');
    row:SetFullWidth(true);
    row:SetLayout('Flow');
    row.frame:EnableMouse(true);

    local highlight = row.frame:CreateTexture(nil, "HIGHLIGHT");
    highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
    highlight:SetAllPoints(true);
    highlight:SetBlendMode("ADD");
    self.list:AddChild(row);

    local dt = AceGUI:Create('Label');
    dt:SetFont(DEFAULT_FONT, 10);
    dt:SetRelativeWidth(0.07);
    dt:SetFullHeight(true);
    dt:SetJustifyH('CENTER');
    dt:SetText(date('%d.%m', rec.dt));
    row:AddChild(dt);
end

local function renderList(self)
    self.list:ReleaseChildren();

    local offset = self.page * store().items.pageSize;

    for i = 1, store().items.pageSize do
        local rec = self.data[i + offset];

        if rec then
            renderRow(self, rec);
        end
    end
end

local function totalPages(self)
    return math.floor(#self.data / store().items.pageSize);
end

local function goBack(self)
    self.page = math.max(0, self.page - 1);
    self.frame:SetTitle(L['Items Frame'](self.page, totalPages(self)));
    renderList(self);
end

local function goForward(self)
    self.page = math.min(totalPages(self), self.page + 1);
    self.frame:SetTitle(L['Items Frame'](self.page, totalPages(self)));
    renderList(self);
end

local function goRefresh(self)
    fillData(self);

    self.page = 0;
    self.frame:SetTitle(L['Items Frame'](self.page, totalPages(self)));
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

local function parseLine(res, line)
    local tmp = {};

    gsub(line, '[^,]+', function(item) local value = gsub(item, '"', ''); tinsert(tmp, value); end);

    tinsert(res, tmp);
end

local function parseCell(text)
    local tmp = {};

    gsub(text, '[^&]+', function(item) local left, right = strsplit('=', item, 2); tmp[strlower(left)] = right; end);

    return tmp;
end

local function processImport(text)
    local tmp = {};

    gsub(text, '[^\r\n]+', function(line) parseLine(tmp, line); end);

    if #tmp < 2 then
        return;
    end

    local header = tmp[1];

    for k = 2, #tmp do
        local line = tmp[k];
        local id = tonumber(line[1]);

        store().items.data[id] = {};

        for i = 2, #line do
            store().items.data[id][header[i]] = parseCell(line[i]);
            store().items.data[id].id = id;
        end
    end
end

function ExG.ItemsFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Items Frame'](self.page, totalPages(self)));
    self.frame:SetWidth(500);
    self.frame:SetWidth(750);
    self.frame:SetLayout(nil);
    self.frame:SetCallback('OnClose', function() self.data = {}; self.frame:Hide(); end)
    self.frame:Hide();

    makeButtons(self);
    makeHeaders(self);

    local group = AceGUI:Create('SimpleGroup');
    group:SetLayout('Fill');
    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -69);
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -10, 119);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');
    group:AddChild(self.list);

    local box = AceGUI:Create('MultiLineEditBox');
    box:SetLabel(L['Items import text']);
    box:SetCallback('OnEnterPressed', function() processImport(box:GetText()); end);
    self.frame:AddChild(box);

    box:SetPoint('TOPLEFT', self.frame.frame, 'BOTTOMLEFT', 10, 117);
    box:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -10, 10);
end

function ExG.ItemsFrame:Show()
    self.frame:Show();

    fillData(self);
    self.frame:SetTitle(L['Items Frame'](self.page, totalPages(self)));
    renderList(self);
end

function ExG.ItemsFrame:Hide()
    self.frame:Hide();
end
