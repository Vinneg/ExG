local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

ExG.OptionsFrame = {
    frame = nil,
    items = {},
};

function ExG.OptionsFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Options Frame']);
    self.frame:SetLayout(nil);
    self.frame:SetCallback('OnClose', function() self:Close(); end);
    self.frame:SetWidth(500);
    self.frame:SetHeight(500);
    self.frame:EnableResize(false);

    self.frame:Hide();
end

function ExG.OptionsFrame:Open()
    self.frame:Show();
end

function ExG.OptionsFrame:Close()
    self.frame:Hide();
end
