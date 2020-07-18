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
    items = {},
};

local function addPane(self, item)
    local pane, new;

    for i = 1, #self.frame.children do
        local tmp = self.frame.children[i];

        if tmp.itemId == item.id then
            pane = tmp;
        end
    end

    local new = not pane;

    if not pane then
        pane = AceGUI:Create('SimpleGroup');
        pane:SetWidth(200);
        pane:SetFullHeight(true);
        pane:SetLayout('Flow');
        self.frame:AddChild(pane);

        if #self.frame.children == 1 then
            pane:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);
            pane:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 10, 10);
        else
            pane:SetPoint('TOPLEFT', self.frame.children[#self.frame.children - 1].frame, 'TOPRIGHT', 5, 0);
            pane:SetPoint('BOTTOMLEFT', self.frame.children[#self.frame.children - 1].frame, 'BOTTOMRIGHT', 5, 0);
        end

        pane.itemId = item.id;
    end

    self.frame:SetWidth(#self.frame.children * 205 + 15);

    return new, pane;
end

local function removePane(self, itemId)
    local pane, right, idx;

    for i = 1, #self.frame.children do
        local tmp = self.frame.children[i];

        if tmp.itemId == itemId then
            idx = i;
            pane = tmp;
            right = self.frame.children[math.min(i + 1, #self.frame.children)];
        end
    end

    if not right then
        return;
    end

    for i = 1, pane:GetNumPoints() do
        right:SetPoint(pane:GetPoint(i));
    end

    AceGUI:Release(pane);
    tremove(self.frame.children, idx);

    self.items[itemId] = nil;

    if #self.frame.children == 0 then
        self.frame:Hide();
    else
        self.frame:SetWidth(#self.frame.children * 205 + 15);
    end
end

local function renderButons(self, pane, item)
    sort(item.buttons, function(a, b) return a.id < b.id; end);

    for _, v in ipairs(item.buttons) do
        if v.enabled then
            local btn = AceGUI:Create('Button');
            btn:SetText(v.text);
            btn:SetRelativeWidth(0.5);
            btn:SetCallback('OnClick', onClick({ id = item.id, option = v.id }));
            pane:AddChild(btn);
        end
    end

    if ExG:IsMl() then
        local btn = AceGUI:Create('Button');
        btn:SetText(L['Disenchant']);
        btn:SetFullWidth(true);
        btn:SetCallback('OnClick', function() self:DisenchantItem(item.id); end);
        pane:AddChild(btn);
    end
end

local function renderItem(self, item)
    local new, pane = addPane(self, item);

    if new then
        pane.icon = AceGUI:Create('Icon');
        pane.icon:SetImage(item.texture);
        pane.icon:SetImageSize(50, 50);
        pane.icon:SetFullWidth(true);
        pane.icon:SetCallback('OnEnter', onEnter(pane.icon.frame, item.link));
        pane.icon:SetCallback('OnLeave', onLeave);
        pane:AddChild(pane.icon);

        pane.name = AceGUI:Create('InteractiveLabel');
        pane.name:SetFont(DEFAULT_FONT, 14, 'OUTLINE');
        pane.name:SetJustifyH('CENTER');
        pane.name:SetText(item.link);
        pane.name:SetFullWidth(true);
        pane.name:SetCallback('OnEnter', onEnter(pane.name.frame, item.link));
        pane.name:SetCallback('OnLeave', onLeave);
        pane:AddChild(pane.name);

        renderButons(self, pane, item);

        pane.accepted = AceGUI:Create('Label');
        pane.accepted:SetText('-');
        pane.accepted:SetFullWidth(true);
        pane:AddChild(pane.accepted);

        pane.rolls = {};

        item.pane = pane;
    end
end

local function renderRolls(self, item)
    local rolls = {};

    for _, v in pairs(item.rolls) do
        if v.option < 'button6' then
            tinsert(rolls, { name = v.name, option = v.option, pr = ExG:GetEG(v.name).pr });
        end
    end

    sort(rolls, function(a, b) if a.option < b.option then return true elseif a.option == b.option then return a.pr < a.pr; end; return false; end);

    for i, v in ipairs(rolls) do
        local roll = item.pane.rolls[i];

        if not roll then
            item.pane.rolls[i] = item.pane.rolls[i] or {};
            roll = item.pane.rolls[i];

            roll.pane = AceGUI:Create('SimpleGroup');
            roll.pane:SetFullWidth(true);
            roll.pane:SetLayout('Flow');
            roll.pane.frame:EnableMouse(true);

            local highlight = roll.pane.frame:CreateTexture(nil, "HIGHLIGHT");
            highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
            highlight:SetAllPoints(true);
            highlight:SetBlendMode("ADD");

            item.pane:AddChild(roll.pane);

            roll.name = AceGUI:Create('Label');
            roll.name:SetFont(DEFAULT_FONT, 12);
            roll.name:SetRelativeWidth(0.4);
            roll.pane:AddChild(roll.name);

            roll.option = AceGUI:Create('Label');
            roll.option:SetFont(DEFAULT_FONT, 12);
            roll.option:SetJustifyH('CENTER');
            roll.option:SetRelativeWidth(0.3);
            roll.pane:AddChild(roll.option);

            roll.pr = AceGUI:Create('Label');
            roll.pr:SetFont(DEFAULT_FONT, 12);
            roll.pr:SetJustifyH('RIGHT');
            roll.pr:SetRelativeWidth(0.3);
            roll.pane:AddChild(roll.pr);
        else
            roll.pane.frame:Show();
        end

        roll.name:SetColor(ExG:NameColor(v.name));
        roll.name:SetText(v.name);
        roll.option:SetText(store().buttons[v.option].text);
        roll.pr:SetText(v.pr);
    end

    for i = #rolls + 1, #item.pane.rolls do
        item.pane.rolls[i].pane.frame:Hide();
    end
end

local function giveBag(player)
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

function ExG.RollFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Roll Frame']);
    self.frame:SetWidth(300);
    --    self.frame:SetHeight(500);
    --    self.frame:OnHeightSet(500);
    self.frame:SetLayout(nil);
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

function ExG.RollFrame:AddItems(items)
    for _, item in ipairs(items) do
        self.items[item.id] = self.items[item.id] or { accepted = {}, rolls = {} };

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

        renderItem(self, tmp);

        ExG:AcceptItem(item.id);
    end
end

function ExG.RollFrame:AcceptItem(itemId, source)
    local item = self.items[itemId];

    if not item then
        return;
    end

    item.accepted[source] = true;

    item.pane.accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), ExG:Size(item.accepted)));
end

function ExG.RollFrame:GiveItem(itemId)
end

function ExG.RollFrame:DisenchantItem(itemId)
    removePane(self, itemId);
end

function ExG.RollFrame:RollItem(data, unit)
    local item = self.items[data.id];

    if not item then
        return;
    end

    item.rolls[unit] = item.rolls[unit] or {};
    item.rolls[unit].name = unit;
    item.rolls[unit].option = data.option;

    item.pane.accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), ExG:Size(item.accepted)));

    renderRolls(self, item);
end
