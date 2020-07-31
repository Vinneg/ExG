local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local onEnter = function(owner, link) if link then return function() GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT'); GameTooltip:SetHyperlink(link); GameTooltip:Show(); end; else return function() end; end end;
local onLeave = function() return GameTooltip:Hide(); end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

local MAX_ROLLS = 10;

ExG.RollFrame = {
    frame = nil,
    items = {},
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
        { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -5 },
        { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -5 },
        { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -30 },
        { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -30 },
        { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -55 },
        { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -55 },
        { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -80 },
        { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -105 },
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
        pane.dis:SetCallback('OnClick', function() self:GiveItem(ExG.state.name, ExG.state.class, pane.itemId); end);
        pane:AddChild(pane.dis);

        local point = points[ceil(idx / 2) * 2 + 1];

        pane.dis:SetPoint(point.point, point.frame, point.rel, point.x, point.y);

        last = pane.dis;
    end

    return last;
end

local function getRolls(pane)
    pane.rolls = {};

    for i = 1, MAX_ROLLS do
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
        if not tmp.itemId and not blank then
            blank = tmp;
        end
    end

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

        pane.head = AceGUI:Create('Icon');
        pane.head:SetImageSize(50, 50);
        pane.head:SetLabel('');
        pane.head:SetCallback('OnLeave', onLeave);

        pane.cost = pane.head.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        pane.cost:SetFont(DEFAULT_FONT, 10);
        pane.cost:ClearAllPoints();
        pane.cost:SetPoint('LEFT', 20, 0);
        pane.cost:SetJustifyH('LEFT');
        pane.cost:SetJustifyV('CENTER');
        pane.cost:SetText('0 GP');

        pane.count = pane.head.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        pane.count:SetFont(DEFAULT_FONT, 10);
        pane.count:ClearAllPoints();
        pane.count:SetPoint('RIGHT', -20, 0);
        pane.count:SetJustifyH('RIGHT');
        pane.count:SetJustifyV('CENTER');
        pane.count:SetText('x 1');

        pane:AddChild(pane.head);

        pane.head:SetPoint('TOPLEFT');
        pane.head:SetPoint('TOPRIGHT');

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

            pane[v.id]:SetText(enabled and v.text or '');
            pane[v.id]:SetDisabled(not enabled);

            if v.id == 'button6' then
                pane[v.id]:SetCallback('OnClick', function() ExG:RollItem({ id = pane.itemId, class = ExG.state.class, option = v.id, }); if store().items.closeOnPass and not ExG:IsMl() then self:RemoveItem(pane.itemId); end end);
            else
                local info = ExG:ItemInfo(pane.itemId);
                local id1, id2 = ExG:Equipped(info.slots);

                pane[v.id]:SetCallback('OnClick', function() ExG:RollItem({ id = pane.itemId, class = ExG.state.class, option = v.id, slot1 = id1, slot2 = id2, rnd = random(1, 100) }); end);
            end
        end
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
            local button = v.option and store().buttons.data[v.option];
            local pr = button and button.roll and v.rnd or ExG:GetEG(info.officerNote).pr;

            v.pr = pr;

            tinsert(rolls, { name = v.name, class = v.class, option = v.option, pr = pr, slot1 = v.slot1, slot2 = v.slot2, rnd = v.rnd });
        end
    end

    sort(rolls, function(a, b) if a.option < b.option then return true elseif a.option == b.option then return a.pr < a.pr; end; return false; end);

    for i, v in ipairs(rolls) do
        if i <= MAX_ROLLS then
            local roll = pane.rolls[i];
            local button = v.option and store().buttons.data[v.option];

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

            if ExG:IsMl() then
                roll.pane.frame:SetScript('OnMouseDown', function() self:GiveItem(v.name, v.class, pane.itemId, v.option); end);
            end

            roll.pane.frame:Show();
        end
    end

    for i = #rolls + 1, #pane.rolls do
        pane.rolls[i].pane.frame:Hide();
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
    local class = settings and settings[ExG.state.class] or {};
    local def = settings and settings['DEFAULT'] or {};

    pane.head:SetImage(item.texture);
    pane.cost:SetText(((class.gp or def.gp) or item.gp or 0) .. ' GP');
    pane.count:SetText('x ' .. (item.count or 0));
    pane.head:SetLabel(item.link);
    pane.head:SetCallback('OnEnter', onEnter(pane.head.frame, item.link));

    renderButons(self, pane, item, settings);
    renderRolls(self, pane);

    pane.frame:Show();
end

local function renderItems(self)
    for id in pairs(self.items) do
        local pane = getPane(self, id);

        renderItem(self, pane);
    end
end

local function disenchantHistory(self, itemId)
    local item = self.items[itemId];
    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'dis',
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['ExG History Item Disenchant'],
        link = item.link;
        dt = dt,
    };

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });
end

local function appendHistory(self, unit, class, itemId, option)
    local item = self.items[itemId];
    local button = option and store().buttons.data[option];
    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'item',
        target = { name = unit, class = class, },
        master = { name = ExG.state.name, class = ExG.state.class, },
        link = item.link;
        dt = dt,
        details = {},
    };

    local gp = item.gp * button.ratio;

    local info = ExG:GuildInfo(unit);
    local old = ExG:GetEG(info.officerNote);
    local new = ExG:SetEG(info, old.ep, old.gp + gp);

    store().history.data[dt].gp = { before = old.gp, after = new.gp, };
    store().history.data[dt].desc = L['ExG History Item'](gp, button.text);

    local i, details = 1, {};

    for unit, v in pairs(item.rolls) do
        local st = dt + i / 1000;

        button = store().buttons.data[v.text];

        details[st] = {
            target = { name = unit, class = v.class, },
            option = v.option,
            pr = v.pr,
            dt = st,
        };

        i = i + 1;
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });
end

function ExG.RollFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Roll Frame']);
    self.frame:SetLayout(nil);
    self.frame:SetCallback('OnClose', function() for id in pairs(self.items) do ExG:RollItem({ id = id, class = ExG.state.class, option = 'button6', }); self:RemoveItem(id); end self.frame:Hide(); end);
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

function ExG.RollFrame:AddItems(items)
    for id, v in pairs(items) do
        self.items[id] = self.items[id] or { count = 1, accepted = {}, rolls = {} };

        local tmp = self.items[id];

        local settings = store().items.data[id];
        local class = settings and settings[ExG.state.class] or {};
        local def = settings and settings['DEFAULT'] or {};

        tmp.id = id;
        tmp.count = v;
        tmp.settings = class or def;
        tmp.gp = class.gp or def.gp;

        ExG:AcceptItem(id);

        local obj = Item:CreateFromItemID(tmp.id);
        obj:ContinueOnItemLoad(function()
            local info = ExG:ItemInfo(id);

            local tmp = self.items[id];
            tmp.gp = tmp.gp or ExG:CalcGP(id);
            tmp.name = info.name;
            tmp.loc = info.loc;
            tmp.link = info.link;
            tmp.texture = info.texture;
            tmp.count = info.count;

            renderItems(self);
        end);
    end
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

function ExG.RollFrame:GiveItem(unit, class, itemId, option)
    if not ExG.state.looting then
        return;
    end

    local info = ExG:ItemInfo(itemId);

    if not info then
        return;
    end

    local lootIndex, unitIndex

    for i = 1, GetNumLootItems() do
        local tmp = ExG:ItemInfo(GetLootSlotLink(i));

        lootIndex = tmp and info.id == tmp.id and i or lootIndex;
    end

    if not lootIndex then
        return;
    end

    for i = 1, MAX_RAID_MEMBERS do
        local name = GetMasterLootCandidate(lootIndex, i);

        unitIndex = name and unit == Ambiguate(name, 'all') and i or unitIndex;
    end

    if not unitIndex then
        return;
    end

    GiveMasterLoot(lootIndex, unitIndex);

    if not option then
        disenchantHistory(self, itemId);
    else
        appendHistory(self, unit, class, itemId, option);
    end

    ExG:DistributeItem(unit, itemId);
end

function ExG.RollFrame:RemoveItem(itemId)
    local found = false;

    for i = 1, #self.frame.children do
        local pane = self.frame.children[i];

        if pane.itemId == itemId or found then
            pane.itemId = nil;
            found = true;

            if i < #self.frame.children then
                local right = self.frame.children[i + 1];

                pane.itemId = right.itemId;
                right.itemId = nil;
            else
                pane.itemId = nil;
            end

            if pane.itemId then
                renderItem(self, pane);
            else
                pane.frame:Hide();
            end

            self.frame:SetWidth(count(self) * 255 + 15);
        end
    end

    self.items[itemId] = nil;

    self.frame:SetWidth(count(self) * 255 + 15);

    if count(self) == 0 then
        self.frame:Hide();
    end
end

function ExG.RollFrame:RollItem(data, unit)
    local item = self.items[data.id];

    if not item then
        return;
    end

    item.rolls[unit] = item.rolls[unit] or {};
    item.rolls[unit].name = unit;
    item.rolls[unit].class = data.class;
    item.rolls[unit].option = data.option;
    item.rolls[unit].rnd = item.rolls[unit].rnd or data.rnd;
    item.rolls[unit].slot1 = ExG:ItemInfo(data.slot1);
    item.rolls[unit].slot2 = ExG:ItemInfo(data.slot2);

    local pane = getPane(self, item.id);

    pane.accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), ExG:Size(item.accepted)));

    renderRolls(self, pane);
end

function ExG.RollFrame:DistributeItem(unit, itemId)
    local item = self.items[itemId];

    if not item then
        return;
    end

    item.count = item.count - 1;

    if (item.count or 0) == 0 then
        self:RemoveItem(itemId);
    else
        item.rolls[unit] = nil;
        renderItems(self);
    end
end
