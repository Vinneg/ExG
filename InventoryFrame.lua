local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local onEnter = function(owner, link) return function() GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT'); GameTooltip:SetHyperlink(link); GameTooltip:Show(); end; end;
local onLeave = function() return GameTooltip:Hide(); end;
local onClick = function(item) return function() ExG:AnnounceItems({ item }); end; end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.InventoryFrame = {
    frame = nil,
    panes = {},
    items = {},
};

local function scan(self)
    self.items = {};

    for i = 0, NUM_BAG_SLOTS do
        local slots = GetContainerNumSlots(i);

        if slots ~= 0 then
            for j = 1, slots do
                local link = GetContainerItemLink(i, j);

                if (link) then
                    local info = ExG:ItemInfo(link);

                    if info and info.rarity > 3 then
                        self.items[info.id] = info;
                    end
                end
            end
        end
    end
end

local function renderItem(self, item)
    self.panes[item.id] = self.panes[item.id] or {};

    local this = self.panes[item.id];

    this.pane = AceGUI:Create('SimpleGroup')
    this.pane:SetHeight(300);
    this.pane:SetFullWidth(true);
    this.pane:SetLayout('Flow');
    self.frame:AddChild(this.pane);

    this.icon = AceGUI:Create('Icon');
    this.icon:SetImage(item.texture);
    this.icon:SetImageSize(40, 40);
    this.icon:SetRelativeWidth(0.1);
    this.icon:SetFullHeight(true);
    this.icon:SetCallback('OnEnter', onEnter(this.icon.frame, item.link));
    this.icon:SetCallback('OnLeave', onLeave);
    this.pane:AddChild(this.icon);

    this.name = AceGUI:Create('InteractiveLabel');
    this.name:SetFont(DEFAULT_FONT, 14, 'OUTLINE');
    this.name:SetText(item.link);
    this.name:SetRelativeWidth(0.7);
    this.name:SetFullHeight(true);
    this.name:SetCallback('OnEnter', onEnter(this.name.frame, item.link));
    this.name:SetCallback('OnLeave', onLeave);
    this.pane:AddChild(this.name);

    this.button = AceGUI:Create('Button');
    this.button:SetText(L['Announce']);
    this.button:SetRelativeWidth(0.2);
    this.button:SetHeight(30);
    this.button:SetCallback('OnClick', onClick(item.id));
    this.pane:AddChild(this.button);

    return this;
end

local function renderList(self)
    self.frame:ReleaseChildren();

    local height = 35 + 12;

    for _, v in pairs(self.items) do
        local tmp = renderItem(self, v);

        height = height + tmp.pane.frame:GetHeight() + 3;
    end

    self.frame:SetHeight(height);
    self.frame:OnHeightSet(height);
end

function ExG.InventoryFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Inventory Frame']);
    self.frame:SetWidth(500);
    self.frame:SetLayout('Flow');
    self.frame:EnableResize(false);
    self.frame:SetCallback('OnClose', function() self.frame:Hide(); end)
    self.frame:Hide();
end

function ExG.InventoryFrame:Show()
    self.frame:Show();

    scan(self);
    renderList(self);
end

function ExG.InventoryFrame:Hide()
    self.frame:Hide();
end
