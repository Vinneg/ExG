local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.UnitFrame = {
    frame = nil,
    unit = nil,
};

local function makeFrame(self)
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
    self.amount:SetWidth(120);
    self.amount:SetHeight(25);
    self.amount:SetLabel(L['Amount']);
    self.frame:AddChild(self.amount);

    self.amount:SetPoint('TOPLEFT', self.gp.frame, 'BOTTOMLEFT', 0, -5);
    self.amount:SetPoint('RIGHT', self.gp.frame, 'RIGHT', 0, 0);

    self.reason = AceGUI:Create('EditBox');
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
    self.apply:SetCallback('OnClick', function() self:AdjustEG(); end);
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

function ExG.UnitFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(self.unit);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(300);
    self.frame:SetHeight(210);
    self.frame:SetCallback('OnClose', function() self.frame:Hide(); end);
    self.frame:Hide();

    makeFrame(self);
end

function ExG.UnitFrame:Show(unit)
    self.unit = unit;

    self.frame:SetTitle(self.unit);

    self.frame:Show();
end

function ExG.UnitFrame:Hide()
    self.unit = nil;

    self.frame:Hide();
end

function ExG.UnitFrame:AdjustEG()
    if not self.unit then
        return;
    end

    local diff = tonumber(self.amount:GetText());

    if not diff then
        return;
    end

    local info = ExG:GuildInfo(self.unit);

    if not info then
        return;
    end

    local old = ExG:GetEG(info.officerNote);
    local new, type;

    if self.ep:GetValue() then
        type = 'EP';
        new = ExG:SetEG(info, old.ep + diff, old.gp);
    elseif self.gp:GetValue() then
        type = 'GP';
        new = ExG:SetEG(info, old.ep, old.gp + diff);
    end

    if not new then
        return;
    end

    print('reason = ', self.reason:GetText());

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'unit',
        target = { name = self.unit, class = info.class, },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['Unit Adjust Desc'](type, diff, self.reason:GetText());
        ep = { before = old.ep, after = new.ep, };
        gp = { before = old.gp, after = new.gp, };
        dt = dt,
    };

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    self.frame:Hide();
end
