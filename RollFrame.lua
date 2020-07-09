local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local onEnter = function(owner, link) return function() GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT'); GameTooltip:SetHyperlink(link); GameTooltip:Show(); end; end;
local onLeave = function() return GameTooltip:Hide(); end;
local onClick = function(item) return function() ExG:RollItem(item); end; end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.RollFrame = {
    frame = nil,
    panes = {},
    items = {},
};

function ExG.RollFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Roll Frame']);
    self.frame:SetWidth(400);
    --    self.frame:SetHeight(500);
    --    self.frame:OnHeightSet(500);
    self.frame:SetLayout('Flow');
    self.frame:EnableResize(false);
    self.frame:SetCallback('OnClose', function() self.frame:Hide(); end);
    self.frame:Hide();
end

function ExG.RollFrame:Show()
    self.frame:Show();
end

function ExG.RollFrame:Hide()
    self.frame:Hide();
end

function ExG.RollFrame:AddItem(item)
    self.items[item.id] = self.items[item.id] or { accepted = 0, rolls = {} };

    local tmp = self.items[item.id];
    tmp.id = item.id;
    tmp.name = item.name;
    tmp.rarity = item.rarity;
    tmp.type = item.type;
    tmp.subtype = item.subtype;
    tmp.loc = item.loc;
    tmp.link = item.link;
    tmp.texture = item.texture;
    tmp.count = (tmp.count or 0) + 1;
    tmp.buttons = item.buttons or {};

    self:RenderItem(tmp);
end

function ExG.RollFrame:RenderItem(item)
    local this = self.panes[item.id];

    if this then
        return;
    end

    self.panes[item.id] = self.panes[item.id] or {};
    this = self.panes[item.id];

    this.pane = AceGUI:Create('SimpleGroup');
    this.pane:SetWidth(300);
    this.pane:SetFullHeight(true);
    this.pane:SetLayout('Flow');
    self.frame:AddChild(this.pane);

    local icon = AceGUI:Create('Icon');
    icon:SetImage(item.texture);
    icon:SetImageSize(50, 50);
    icon:SetFullWidth(true);
    icon:SetCallback('OnEnter', onEnter(icon.frame, item.link));
    icon:SetCallback('OnLeave', onLeave);
    this.pane:AddChild(icon);

    local name = AceGUI:Create('InteractiveLabel');
    name:SetFont(DEFAULT_FONT, 14, 'OUTLINE');
    name:SetText(item.link);
    name:SetFullWidth(true);
    name:SetCallback('OnEnter', onEnter(name.frame, item.link));
    name:SetCallback('OnLeave', onLeave);
    this.pane:AddChild(name);

    sort(item.buttons, function(a, b) return a.id < b.id; end);

    for _, v in ipairs(item.buttons) do
        local btn = AceGUI:Create('Button');
        btn:SetText(v.text);
        btn:SetRelativeWidth(0.5);
        btn:SetCallback('OnClick', onClick({ id = item.id, option = v.id }));
        this.pane:AddChild(btn);
    end

    if ExG:IsMl() then
        local btn = AceGUI:Create('Button');
        btn:SetText('Disenchant');
        btn:SetFullWidth(true);
        this.pane:AddChild(btn);
    end

    this.accepted = AceGUI:Create('Label');
    this.accepted:SetText('-');
    this.accepted:SetFullWidth(true);
    this.pane:AddChild(this.accepted);

    this.rolls = {};
end

function ExG.RollFrame:AcceptItem(itemId)
    local item = self.items[itemId];

    if not item then
        return;
    end

    item.accepted = (item.accepted or 0) + 1;

    self.panes[item.id].accepted:SetText(L['Pretenders'](#item.rolls, item.accepted));
end

function ExG.RollFrame:RollItem(data, unit)
    local item = self.items[data.id];

    if not item then
        return;
    end

    item.rolls[unit] = item.rolls[unit] or {};
    item.rolls[unit].name = unit;
    item.rolls[unit].option = data.option;

    self.panes[item.id].accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), item.accepted));

    self:RenderRolls(item);
end

function ExG.RollFrame:RenderRolls(item)
    local rolls = {};

    for _, v in pairs(item.rolls) do
        if v.option < 'button5' then
            tinsert(rolls, { name = v.name, option = v.option, pr = ExG:GetEG(v.name).pr });
        end
    end

    sort(rolls, function(a, b) if a.option < b.option then return true elseif a.option == b.option then return a.pr < a.pr; end; return false; end);

    for i, v in ipairs(rolls) do
        local roll = self.panes[item.id].rolls[i];

        if not roll then
            self.panes[item.id].rolls[i] = self.panes[item.id].rolls[i] or {};
            roll = self.panes[item.id].rolls[i];

            roll.pane = AceGUI:Create('SimpleGroup');
            roll.pane:SetFullWidth(true);
            roll.pane:SetLayout('Flow');
            roll.pane.frame:EnableMouse(true);

            local highlight = roll.pane.frame:CreateTexture(nil, "HIGHLIGHT");
            highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
            highlight:SetAllPoints(true);
            highlight:SetBlendMode("ADD");

            self.panes[item.id].pane:AddChild(roll.pane);

            roll.name = AceGUI:Create('Label');
            roll.name:SetFont(DEFAULT_FONT, 12);
            roll.name:SetRelativeWidth(0.6);
            roll.pane:AddChild(roll.name);

            roll.option = AceGUI:Create('Label');
            roll.option:SetFont(DEFAULT_FONT, 12);
            roll.option:SetRelativeWidth(0.2);
            roll.pane:AddChild(roll.option);

            roll.pr = AceGUI:Create('Label');
            roll.pr:SetFont(DEFAULT_FONT, 12);
            roll.pr:SetRelativeWidth(0.2);
            roll.pane:AddChild(roll.pr);
        else
            roll.pane.frame:Show();
        end

        roll.name:SetColor(ExG:NameColor(v.name));
        roll.name:SetText(v.name);
        roll.option:SetText(store().buttons[v.option].text);
        roll.pr:SetText(v.pr);
    end

    for i = #rolls + 1, #self.panes[item.id].rolls do
        self.panes[item.id].rolls[i].pane.frame:Hide();
    end
end

function ExG.RollFrame:GiveBag(player)
    if not ExG.state.looting then
        return;
    end

    local lootIndex = ExG:BagLootIndex();

    if not lootIndex then
        return;
    end

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
