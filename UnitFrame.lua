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
    local ep = AceGUI:Create('CheckBox');
    ep:SetLabel(L['EP']);
    self.frame:AddChild(ep);

    ep:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);
    ep:SetPoint('BOTTOMRIGHT', self.frame.frame, 'TOPRIGHT', -10, -50);

    local gp = AceGUI:Create('CheckBox');
    gp:SetLabel(L['GP']);
    self.frame:AddChild(gp);

    gp:SetPoint('TOPLEFT', ep.frame, 'BOTTOMLEFT', 0, -5);
    gp:SetPoint('BOTTOMRIGHT', ep.frame, 'BOTTOMRIGHT', 0, -25);

    local amount = AceGUI:Create('EditBox');
    amount:SetWidth(120);
    amount:SetHeight(25);
    amount:SetLabel(L['Amount']);
    self.frame:AddChild(amount);

    amount:SetPoint('TOPLEFT', gp.frame, 'BOTTOMLEFT', 0, -5);
    amount:SetPoint('RIGHT', gp.frame, 'RIGHT', 0, 0);

    local reason = AceGUI:Create('EditBox');
    reason:SetWidth(120);
    reason:SetHeight(25);
    reason:SetLabel(L['Reason']);
    self.frame:AddChild(reason);

    reason:SetPoint('TOPLEFT', amount.frame, 'BOTTOMLEFT', 0, -5);
    reason:SetPoint('RIGHT', amount.frame, 'RIGHT', 0, 0);
end

function ExG.UnitFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(self.unit);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(300);
    self.frame:SetHeight(250);
    self.frame:SetCallback('OnClose', function() self.unit = nil; self.frame:Hide(); end)
    self.frame:Hide();

    makeFrame(self);
end

function ExG.UnitFrame:Show(unit)
    self.unit = unit;

    self.frame:Show();
end

function ExG.UnitFrame:Hide()
    self.unit = nil;

    self.frame:Hide();
end
