local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local onEnter = function(owner, link) if link then return function() GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT'); GameTooltip:SetHyperlink(link); GameTooltip:Show(); end; else return function() end; end end;
local onLeave = function() return GameTooltip:Hide(); end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.RollFrame = {
    frame = nil,
    items = {},
    panes
};

local function count(self)
    local res = 0;

    for _, v in ipairs(self.frame.children) do
        if v.itemId then
            res = res + 1;
        end
    end

    return res;
end

local function getButtons(self, pane)
    local points = {
        { point = 'TOPLEFT', frame = pane.name.frame, rel = 'BOTTOMLEFT', x = 5, y = -5 },
        { point = 'TOPRIGHT', frame = pane.name.frame, rel = 'BOTTOMRIGHT', x = -5, y = -5 },
        { point = 'TOPLEFT', frame = pane.name.frame, rel = 'BOTTOMLEFT', x = 5, y = -30 },
        { point = 'TOPRIGHT', frame = pane.name.frame, rel = 'BOTTOMRIGHT', x = -5, y = -30 },
        { point = 'TOPLEFT', frame = pane.name.frame, rel = 'BOTTOMLEFT', x = 5, y = -55 },
        { point = 'TOPRIGHT', frame = pane.name.frame, rel = 'BOTTOMRIGHT', x = -5, y = -55 },
        { point = 'TOPRIGHT', frame = pane.name.frame, rel = 'BOTTOMRIGHT', x = -5, y = -80 },
        { point = 'TOPRIGHT', frame = pane.name.frame, rel = 'BOTTOMRIGHT', x = -5, y = -105 },
    };

    local btns, idx, last = {}, 1, nil;

    for _, v in pairs(store().buttons.data) do
        if v.enabled then
            tinsert(btns, v);
        end
    end

    sort(btns, function(a, b) return a.id < b.id; end);

    for i, v in ipairs(btns) do
        pane[v.id] = AceGUI:Create('Button');
        pane[v.id]:SetText('');
        pane[v.id]:SetWidth((pane.frame:GetWidth() - 15) / 2);
        pane[v.id]:SetDisabled(true);
        pane:AddChild(pane[v.id]);

        local point = points[i];

        pane[v.id]:SetPoint(point.point, point.frame, point.rel, point.x, point.y);

        last = pane[v.id];
        idx = i;
    end

    if ExG:IsMl() then
        pane.dis = AceGUI:Create('Button');
        pane.dis:SetText(L['Disenchant']);
        pane.dis:SetWidth(pane.frame:GetWidth() - 10);
        pane.dis:SetCallback('OnClick', function() self:DisenchantItem(pane.itemId); end);
        pane:AddChild(pane.dis);

        local point = points[ceil(idx / 2) * 2 + 1];

        pane.dis:SetPoint(point.point, point.frame, point.rel, point.x, point.y);

        last = pane.dis;
    end

    return last;
end

local function getRolls(pane)
    pane.rolls = {};

    for i = 1, 10 do
        pane.rolls[i] = pane.rolls[i] or {};

        local roll = pane.rolls[i];

        roll.pane = AceGUI:Create('SimpleGroup');
        roll.pane:SetFullWidth(true);
        roll.pane:SetLayout(nil);
        roll.pane.frame:EnableMouse(true);

        local highlight = roll.pane.frame:CreateTexture(nil, 'HIGHLIGHT');
        highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight');
        highlight:SetAllPoints(true);
        highlight:SetBlendMode('ADD');

        pane:AddChild(roll.pane);

        if i == 1 then
            roll.pane:SetPoint('TOPLEFT', pane.accepted.frame, 'BOTTOMLEFT', 0, -5);
            roll.pane:SetPoint('BOTTOMRIGHT', pane.accepted.frame, 'BOTTOMRIGHT', 0, -23);
        else
            roll.pane:SetPoint('TOPLEFT', pane.rolls[i - 1].pane.frame, 'BOTTOMLEFT', 0, -2);
            roll.pane:SetPoint('BOTTOMRIGHT', pane.rolls[i - 1].pane.frame, 'BOTTOMRIGHT', 0, -20);
        end

        roll.name = roll.pane.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        roll.name:SetFont(DEFAULT_FONT, 10);
        roll.name:ClearAllPoints();
        roll.name:SetPoint('TOPLEFT', 0, 0);
        roll.name:SetPoint('BOTTOMRIGHT', -90, 0);
        roll.name:SetJustifyH('LEFT');
        roll.name:SetJustifyV('CENTER');
        roll.name:SetText('Name');

        roll.option = roll.pane.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        roll.option:SetFont(DEFAULT_FONT, 10);
        roll.option:ClearAllPoints();
        roll.option:SetPoint('TOPLEFT', 0, 0);
        roll.option:SetPoint('BOTTOMRIGHT', -90, 0);
        roll.option:SetJustifyH('RIGHT');
        roll.option:SetJustifyV('CENTER');
        roll.option:SetText('Option');

        roll.pr = roll.pane.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        roll.pr:SetFont(DEFAULT_FONT, 10);
        roll.pr:ClearAllPoints();
        roll.pr:SetPoint('TOPLEFT', roll.pane.frame, 'TOPRIGHT', -80, 0);
        roll.pr:SetPoint('BOTTOMRIGHT', -36, 0);
        roll.pr:SetJustifyH('RIGHT');
        roll.pr:SetJustifyV('CENTER');
        roll.pr:SetText('PR');

        roll.item1 = AceGUI:Create('Icon');
        roll.item1.image:SetAllPoints();
        roll.pane:AddChild(roll.item1);
        roll.item1:SetPoint('TOPLEFT', roll.pane.frame, 'TOPRIGHT', -18, 0);
        roll.item1:SetPoint('BOTTOMRIGHT', roll.pane.frame, 'BOTTOMRIGHT', 0, 0);

        roll.item2 = AceGUI:Create('Icon')
        roll.item2.image:SetAllPoints();
        roll.pane:AddChild(roll.item2);
        roll.item2:SetPoint('TOPLEFT', roll.pane.frame, 'TOPRIGHT', -36, 0);
        roll.item2:SetPoint('BOTTOMRIGHT', roll.pane.frame, 'BOTTOMRIGHT', -18, 0);

        roll.pane.frame:Hide();
    end
end

local function getPane(self, itemId)
    local pane, blank;

    for i = 1, #self.frame.children do
        local tmp = self.frame.children[i];

        pane = (tmp.itemId == itemId) and tmp or pane;
        blank = not tmp.itemId and tmp or blank;
    end

    print('count = ', #self.frame.children, ', pane = ', pane, ', blank = ', blank);

    if not pane and blank then
        pane = blank;
        pane.itemId = itemId;
    elseif not pane then
        pane = AceGUI:Create('SimpleGroup');
        pane:SetWidth(250);
        pane:SetFullHeight(true);
        pane:SetLayout(nil);
        pane.itemId = itemId;
        self.frame:AddChild(pane);

        if #self.frame.children == 1 then
            pane:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);
            pane:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 10, 10);
        else
            pane:SetPoint('TOPLEFT', self.frame.children[#self.frame.children - 1].frame, 'TOPRIGHT', 5, 0);
            pane:SetPoint('BOTTOMLEFT', self.frame.children[#self.frame.children - 1].frame, 'BOTTOMRIGHT', 5, 0);
        end

        pane.icon = AceGUI:Create('Icon');
        pane.icon:SetImageSize(50, 50);
        pane.icon:SetLabel('0 GP');
        pane.icon:SetCallback('OnLeave', onLeave);
        pane.icon.label:SetAllPoints();
        pane.icon.label:SetJustifyH('RIGHT');
        pane.icon.label:SetJustifyV('CENTER');
        pane:AddChild(pane.icon);

        pane.icon:SetPoint('TOPLEFT', pane.frame, 'TOPLEFT', 0, 0);
        pane.icon:SetPoint('BOTTOMRIGHT', pane.frame, 'TOPRIGHT', 0, -55);

        pane.name = AceGUI:Create('InteractiveLabel');
        pane.name:SetFont(DEFAULT_FONT, 14, 'OUTLINE');
        pane.name:SetJustifyH('CENTER');
        pane.name:SetCallback('OnLeave', onLeave);
        pane:AddChild(pane.name);

        pane.name:SetPoint('TOPLEFT', pane.icon.frame, 'BOTTOMLEFT', 0, -5);
        pane.name:SetPoint('BOTTOMRIGHT', pane.icon.frame, 'BOTTOMRIGHT', 0, -38);

        local last = getButtons(self, pane);

        pane.accepted = AceGUI:Create('Label');
        pane.accepted:SetText('none');
        pane.accepted:SetFullWidth(true);
        pane:AddChild(pane.accepted);

        pane.accepted:SetPoint('TOPLEFT', last.frame, 'BOTTOMLEFT', 0, -5);
        pane.accepted:SetPoint('TOPRIGHT', last.frame, 'BOTTOMRIGHT', 0, -5);

        getRolls(pane);
    end

    self.frame:SetWidth(count(self) * 255 + 15);

    return pane;
end

local function renderButons(self, pane, item, settings)
    for _, v in pairs(store().buttons.data) do
        if pane[v.id] then
            local enabled = true;

            if settings and v.id ~= 'button6' then
                local class = settings[ExG.state.class] or {};
                local def = settings['DEFAULT'] or {};

                enabled = class[v.id] or def[v.id];
            end

            local info = ExG:ItemInfo(pane.itemId);
            local id1, id2 = ExG:Equipped(info.slots);

            pane[v.id]:SetText(enabled and v.text or '');
            pane[v.id]:SetDisabled(not enabled);
            pane[v.id]:SetCallback('OnClick', function() ExG:RollItem({ id = pane.itemId, option = v.id, slot1 = id1, slot2 = id2 }); end);
        end
    end
end

local function renderItem(self, pane)
    if not pane or not pane.itemId then
        return;
    end

    local item = self.items[pane.itemId];

    if not item then
        return;
    end

    local settings = store().items.data[item.id];
    local class = (settings or {})[ExG.state.class] or {};
    local def = (settings or {})['DEFAULT'] or {};

    pane.icon:SetImage(item.texture);
    pane.icon:SetLabel(((class.gp or def.gp) or item.gp) .. ' GP');
    pane.icon:SetCallback('OnEnter', onEnter(pane.icon.frame, item.link));

    renderButons(self, pane, item, settings);

    pane.name:SetText(item.link);
    pane.name:SetCallback('OnEnter', onEnter(pane.name.frame, item.link));

    pane.frame:Show();
end

local function renderItems(self)
    for id, item in pairs(self.items) do
        local pane = getPane(self, id);

        renderItem(self, pane);
    end
end

local function renderRolls(self, pane)
    local item = self.items[pane.itemId];

    if not item then
        for i = 1, #pane.rolls do
            pane.rolls[i].pane.frame:Hide();
        end

        return
    end

    local rolls = {};

    for _, v in pairs(item.rolls) do
        if v.option < 'button6' then
            local info = ExG:GuildInfo(v.name);

            tinsert(rolls, { name = v.name, class = v.class, option = v.option, pr = ExG:GetEG(info.officerNote).pr, slot1 = v.slot1, slot2 = v.slot2, });
        end
    end

    sort(rolls, function(a, b) if a.option < b.option then return true elseif a.option == b.option then return a.pr < a.pr; end; return false; end);

    for i, v in ipairs(rolls) do
        local roll = pane.rolls[i];

        roll.name:SetVertexColor(ExG:ClassColor(v.class));
        roll.name:SetText(v.name);
        roll.option:SetText(store().buttons.data[v.option].text);
        roll.pr:SetText(v.pr);
        roll.item1:SetImage(v.slot1 and v.slot1.texture);
        roll.item1:SetCallback('OnEnter', onEnter(roll.item1.frame, v.slot1 and v.slot1.link));
        roll.item1:SetCallback('OnLeave', onLeave);
        roll.item2:SetImage(v.slot2 and v.slot2.texture);
        roll.item2:SetCallback('OnEnter', onEnter(roll.item2.frame, v.slot2 and v.slot2.link));
        roll.item2:SetCallback('OnLeave', onLeave);

        roll.pane.frame:Show();
    end

    for i = #rolls + 1, #pane.rolls do
        pane.rolls[i].pane.frame:Hide();
    end
end

local function removePane(self, itemId)
    local found = false;

    self.items[itemId] = nil;

    for i = 1, #self.frame.children do
        local pane = self.frame.children[i];

        if pane.itemId == itemId or found then
            pane.itemId = nil;
            found = true;

            if i < #self.frame.children then
                local right = self.frame.children[i + 1];

                pane.itemId = right.itemId;
                right.itemId = nil;

                if pane.itemId then
                    renderItem(self, pane);
                    renderRolls(self, pane);
                else
                    pane.frame:Hide();
                end
            else
                pane.frame:Hide();
            end

            self.frame:SetWidth(count(self) * 255 + 15);
        end
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
    self.frame:SetLayout(nil);
    self.frame:SetCallback('OnClose', function() for id in pairs(self.items) do removePane(ExG.RollFrame, id); end self.frame:Hide(); end);
    self.frame:SetHeight(477);
    self.frame:EnableResize(false);
    self.frame:Hide();
end

function ExG.RollFrame:Show()
    self.frame:Show();
end

function ExG.RollFrame:Hide()
    self.frame:Hide();
end

function ExG.RollFrame:AddItems(gps)
    for id, gp in pairs(gps) do
        self.items[id] = self.items[id] or { accepted = {}, rolls = {} };

        local tmp = self.items[id];
        local info = ExG:ItemInfo(id);
        tmp.id = id;
        tmp.gp = gp;
        tmp.name = info.name;
        tmp.rarity = info.rarity;
        tmp.type = info.type;
        tmp.subtype = info.subtype;
        tmp.loc = info.loc;
        tmp.link = info.link;
        tmp.texture = info.texture;
        tmp.count = (tmp.count or 0) + 1;
        tmp.buttons = info.buttons or {};

        ExG:AcceptItem(id);
    end

    renderItems(self);
end

function ExG.RollFrame:AcceptItem(itemId, source)
    local item = self.items[itemId];

    if not item then
        return;
    end

    item.accepted[source] = true;

    local pane = getPane(self, item.id);

    pane.accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), ExG:Size(item.accepted)));
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
    item.rolls[unit].slot1 = ExG:ItemInfo(data.slot1);
    item.rolls[unit].slot2 = ExG:ItemInfo(data.slot2);

    local pane = getPane(self, item.id);

    pane.accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), ExG:Size(item.accepted)));

    renderRolls(self, pane);
end
