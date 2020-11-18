local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local btnRoll = function(self, pane, item, btn, info1, info2)
    return function()
        item.rolled = true;

        ExG:RollItem({
            id = pane.itemId,
            class = ExG.state.class,
            gp = item.gp,
            option = btn.id,
            slot1 = info1 and info1.link,
            slot2 = info2 and info2.link,
            rnd = random(1, 100),
        });
    end;
end

local btnPass = function(self, pane, item)
    return function()
        item.rolled = true;

        ExG:RollItem({
            id = pane.itemId,
            class = ExG.state.class,
            option = 'button6',
            rnd = random(1, 100),
        });

        if store().items.closeOnPass and not ExG:IsMl() then
            self:RemoveItem(pane.itemId);
        end
    end
end

local onEnter = function(owner, link)
    if link then
        return function()
            GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT');
            GameTooltip:SetHyperlink(link);
            GameTooltip:Show();
        end;
    else
        return function() end;
    end
end;

local onTip = function(owner, class, desc, spec)
    return function()
        GameTooltip:SetOwner(owner, 'ANCHOR_TOP');
        GameTooltip:SetText(desc .. (spec and ': ' .. spec or ''), ExG:ClassColor(class));
        GameTooltip:Show();
    end;
end;

local onRoll = function(owner, name, class, rank, rankId, pr, rnd)
    local guildR, guildG, guildB = ExG:ClassColor('GUILD');
    local raidR, raidG, raidB = ExG:ClassColor('RAID');

    return function()
        GameTooltip:SetOwner(owner, 'ANCHOR_TOP');
        GameTooltip:AddDoubleLine(name, format('%s #%d', rank, rankId), ExG:ClassColor(class));
        GameTooltip:AddDoubleLine(format('PR: %.2f', pr), format('%d :ROLL', rnd), guildR, guildG, guildB, raidR, raidG, raidB);
        GameTooltip:Show();
    end;
end;

local onLeave = function()
    return GameTooltip:Hide();
end;

local onAccepted = function(owner, item)
    return function()
        GameTooltip:SetOwner(owner, 'ANCHOR_TOP');
        GameTooltip:AddLine(L['Undecided yet']);

        for i in pairs(item.accepted) do
            if not item.rolls[i] then
                local info = ExG:RaidInfo(i);
                local r, g, b = ExG:ClassColor(info and info.class or 'DEFAULT');

                GameTooltip:AddLine(i, r, g, b);
            end
        end

        GameTooltip:Show();
    end;
end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

local CLASSES_ORDER = { 'WARRIOR', 'PALADIN', 'HUNTER', 'ROGUE', 'PRIEST', 'DEATHKNIGHT', 'SHAMAN', 'MAGE', 'WARLOCK', 'MONK', 'DRUID', 'DEMONHUNTER', };

local MAX_TIPS = 12;
local MAX_PANES = 10;
local MAX_ROLLS = 10;
local PANE_WIDTH = 200;
local PANE_HEIGH = 371;

local points = {
    button = {
        { point = 'TOPLEFT', rel = 'BOTTOMLEFT', x = 5, y = -32 },
        { point = 'TOPRIGHT', rel = 'BOTTOMRIGHT', x = -5, y = -32 },
        { point = 'TOPLEFT', rel = 'BOTTOMLEFT', x = 5, y = -57 },
        { point = 'TOPRIGHT', rel = 'BOTTOMRIGHT', x = -5, y = -57 },
        { point = 'TOPLEFT', rel = 'BOTTOMLEFT', x = 5, y = -82 },
        { point = 'TOPRIGHT', rel = 'BOTTOMRIGHT', x = -5, y = -82 },
    },
    disenchant = {
        [1] = { point = 'TOPLEFT', rel = 'BOTTOMLEFT', x = 5, y = -57 },
        [2] = { point = 'TOPLEFT', rel = 'BOTTOMLEFT', x = 5, y = -82 },
        [3] = { point = 'TOPLEFT', rel = 'BOTTOMLEFT', x = 5, y = -107 },
    },
};

ExG.RollFrame = {
    frame = nil,
    items = {},
};

local function count(self)
    local res = 0;

    for _, pane in ipairs(self.frame.children) do
        if pane.itemId then
            res = res + 1;
        end
    end

    return res;
end

local function makeTips(self, pane)
    local SIZE = 12;

    pane.bis = {};

    pane.bis.label = AceGUI:Create('Label');
    pane.bis.label:SetJustifyH('RIGHT');
    pane.bis.label:SetJustifyV('MIDDLE');
    pane.bis.label:SetWidth(30);
    pane.bis.label:SetFont(DEFAULT_FONT, 8);
    pane.bis.label:SetText('BIS');
    pane:AddChild(pane.bis.label);

    pane.bis.label:SetPoint('TOPLEFT', pane.head.frame, 'BOTTOMLEFT', 0, -2);
    pane.bis.label:SetPoint('BOTTOMRIGHT', pane.head.frame, 'BOTTOMLEFT', 0, -12);

    pane.opt = {};

    pane.opt.label = AceGUI:Create('Label');
    pane.opt.label:SetJustifyH('RIGHT');
    pane.opt.label:SetJustifyV('MIDDLE');
    pane.opt.label:SetWidth(30);
    pane.opt.label:SetFont(DEFAULT_FONT, 8);
    pane.opt.label:SetText('OPT');
    pane:AddChild(pane.opt.label);

    pane.opt.label:SetPoint('TOPLEFT', pane.head.frame, 'BOTTOMLEFT', 0, -15);
    pane.opt.label:SetPoint('BOTTOMRIGHT', pane.head.frame, 'BOTTOMLEFT', 0, -25);

    for i = 1, MAX_TIPS do
        pane.bis[i] = AceGUI:Create('Icon');
        pane.bis[i]:SetImageSize(SIZE, SIZE);
        pane.bis[i]:SetWidth(SIZE);
        pane.bis[i]:SetHeight(SIZE);
        pane:AddChild(pane.bis[i]);

        pane.bis[i]:SetPoint('LEFT', pane.bis.label.frame, 'RIGHT', 30 + (i - 1) * (SIZE + 2), 6);

        pane.bis[i].frame:Hide();

        pane.opt[i] = AceGUI:Create('Icon');
        pane.opt[i]:SetImageSize(SIZE, SIZE);
        pane.opt[i]:SetWidth(SIZE);
        pane.opt[i]:SetHeight(SIZE);
        pane:AddChild(pane.opt[i]);

        pane.opt[i]:SetPoint('LEFT', pane.opt.label.frame, 'RIGHT', 30 + (i - 1) * (SIZE + 2), 4);

        pane.opt[i].frame:Hide();
    end
end

local function makeButtons(self, pane)
    local btns = {};

    for _, btn in pairs(store().buttons.data) do
        tinsert(btns, btn);
    end

    sort(btns, function(a, b) return a.id < b.id; end);

    for i, btn in ipairs(btns) do
        pane[i] = AceGUI:Create('Button');
        pane[i]:SetText(btn.text);
        pane[i]:SetWidth((PANE_WIDTH - 15) / 2);
        pane[i]:SetDisabled(true);
        pane:AddChild(pane[i]);

        local point = points.button[i];

        pane[i]:SetPoint(point.point, pane.head.frame, point.rel, point.x, point.y);
    end

    pane.dis = AceGUI:Create('Button');
    pane.dis:SetText(L['Disenchant']);
    pane.dis:SetWidth(PANE_WIDTH - 10);
    pane.dis:SetCallback('OnClick', function() self.Dialog:GiveItem(self.items[pane.itemId], { name = ExG.state.name, class = ExG.state.class, }); end);
    pane:AddChild(pane.dis);

    local point = points.disenchant[ceil(#btns / 2)];

    pane.dis:SetPoint(point.point, pane.head.frame, point.rel, point.x, point.y);

    self.frame:SetHeight(PANE_HEIGH + 25 * ceil(#btns / 2) + 25);
end

local function makeRolls(pane)
    pane.rolls = {};

    for i = 1, MAX_ROLLS do
        pane.rolls[i] = {};

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
        roll.name:SetJustifyV('MIDDLE');
        roll.name:SetText(i);

        roll.option = roll.pane.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        roll.option:SetFont(DEFAULT_FONT, 10);
        roll.option:ClearAllPoints();
        roll.option:SetPoint('TOPLEFT', 0, 0);
        roll.option:SetPoint('BOTTOMRIGHT', -90, 0);
        roll.option:SetJustifyH('RIGHT');
        roll.option:SetJustifyV('MIDDLE');
        roll.option:SetText('Option');

        roll.pr = roll.pane.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
        roll.pr:SetFont(DEFAULT_FONT, 10);
        roll.pr:ClearAllPoints();
        roll.pr:SetPoint('TOPLEFT', roll.pane.frame, 'TOPRIGHT', -80, 0);
        roll.pr:SetPoint('BOTTOMRIGHT', -36, 0);
        roll.pr:SetJustifyH('RIGHT');
        roll.pr:SetJustifyV('MIDDLE');
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

local function makePane(self)
    local pane = AceGUI:Create('SimpleGroup');
    pane:SetWidth(PANE_WIDTH);
    pane:SetLayout(nil);
    self.frame:AddChild(pane);

    pane.head = AceGUI:Create('Icon');
    pane.head:SetImageSize(50, 50);
    pane.head:SetLabel('link');
    pane.head:SetCallback('OnLeave', onLeave);

    pane.cost = pane.head.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
    pane.cost:SetFont(DEFAULT_FONT, 10);
    pane.cost:ClearAllPoints();
    pane.cost:SetPoint('LEFT', 20, 0);
    pane.cost:SetJustifyH('LEFT');
    pane.cost:SetJustifyV('MIDDLE');
    pane.cost:SetText('0 GP');

    pane.count = pane.head.frame:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall');
    pane.count:SetFont(DEFAULT_FONT, 10);
    pane.count:ClearAllPoints();
    pane.count:SetPoint('RIGHT', -20, 0);
    pane.count:SetJustifyH('RIGHT');
    pane.count:SetJustifyV('MIDDLE');
    pane.count:SetText('x 1');

    pane:AddChild(pane.head);

    pane.head:SetPoint('TOPLEFT');
    pane.head:SetPoint('TOPRIGHT');

    makeTips(self, pane);

    makeButtons(self, pane);

    pane.accepted = AceGUI:Create('InteractiveLabel');
    pane.accepted:SetText('none');
    pane.accepted:SetCallback('OnLeave', onLeave);
    pane:AddChild(pane.accepted);

    pane.accepted:SetPoint('TOP', pane.head.frame, 'BOTTOM', 0, -132);
    pane.accepted:SetPoint('LEFT', pane.frame, 'LEFT', 5, 0);
    pane.accepted:SetPoint('RIGHT', pane.frame, 'RIGHT', -5, 0);

    makeRolls(pane);

    self.frame:SetWidth(count(self) * (PANE_WIDTH + 5) + 15);

    if #self.frame.children == 1 then
        pane:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);
        pane:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 10, 10);
    else
        pane:SetPoint('TOPLEFT', self.frame.children[#self.frame.children - 1].frame, 'TOPRIGHT', 5, 0);
        pane:SetPoint('BOTTOMLEFT', self.frame.children[#self.frame.children - 1].frame, 'BOTTOMRIGHT', 5, 0);
    end

    pane.frame:Hide();
end

local function getPane(self, id)
    for i, pane in ipairs(self.frame.children) do
        if (pane and pane.itemId) and not (self.items[pane.itemId] and self.items[pane.itemId].active) then
            pane.itemId = nil;
            pane.frame:Hide();
        end

        if not pane.itemId then
            pane.itemId = id;

            return pane;
        end
    end
end

local function findPane(self, id)
    for i, pane in ipairs(self.frame.children) do
        if pane.itemId == id then
            return pane;
        end
    end
end

local function renderTips(self, pane)
    local scan = function(res, class, id)
        local settings = store().items.data[id];

        if not settings then
            return;
        end

        for i, v in pairs(settings) do
            if strfind(tostring(i), class) then
                if v.bis or v.opt then
                    tinsert(res, { name = i, bis = v.bis, opt = v.opt, });
                end
            end
        end
    end;

    local res = {};

    for i, v in ipairs(CLASSES_ORDER) do
        scan(res, v, pane.itemId);
    end

    for i, v in ipairs(res) do
        local class, spec = strsplit('_', v.name, 2);

        v.class = class;

        class = ExG:Classes()[class];

        v.id = class.id;
        v.desc = L[class.name];

        if spec and class.specs[spec] then
            spec = class.specs[spec];
        else
            spec = nil;
        end

        if spec then
            v.num = spec.id;
            v.spec = spec.name;
            v.icon = spec.icon;
        else
            v.num = 0;
            v.spec = nil;
            v.icon = class.icon;
        end
    end

    sort(res, function(a, b) if a.id < b.id then return true; elseif a.id == b.id then return a.num < b.num; end return false; end);

    local bisIdx, optIdx = 1, 1;

    for i = 1, MAX_TIPS do
        pane.bis[i].frame:Hide();
        pane.opt[i].frame:Hide();
    end

    for i = 1, #res do
        local tip = res[i];

        if tip then
            if tip.bis and bisIdx <= MAX_TIPS then
                pane.bis[bisIdx]:SetImage(tip.icon);
                pane.bis[bisIdx]:SetCallback('OnEnter', onTip(pane.bis[i].frame, tip.class, tip.desc, tip.spec));
                pane.bis[bisIdx]:SetCallback('OnLeave', onLeave);
                pane.bis[bisIdx].frame:Show();

                bisIdx = bisIdx + 1;
            end

            if tip.opt and optIdx <= MAX_TIPS then
                pane.opt[optIdx]:SetImage(tip.icon);
                pane.opt[optIdx]:SetCallback('OnEnter', onTip(pane.opt[i].frame, tip.class, tip.desc, tip.spec));
                pane.opt[optIdx]:SetCallback('OnLeave', onLeave);
                pane.opt[optIdx].frame:Show();

                optIdx = optIdx + 1;
            end
        end
    end
end

local function renderButons(self, item, pane)
    local btns = {};

    for _, btn in pairs(store().buttons.data) do
        tinsert(btns, btn);
    end

    sort(btns, function(a, b)
        if a.enabled and b.enabled then
            return a.id < b.id;
        elseif a.enabled then
            return true;
        elseif b.enabled then
            return false;
        end

        return a.id < b.id;
    end);

    local btnCount = 0;

    for i, btn in ipairs(btns) do
        if btn.enabled then
            btnCount = btnCount + 1;

            local enabled = true;

            if btn.id ~= 'button6' and store().items.data[item.id] then
                local settings = ExG:PullSettings(item.id, true);

                if settings.spec then
                    enabled = settings.spec[btn.id];
                elseif settings.class then
                    enabled = settings.class[btn.id];
                else
                    enabled = settings.def[btn.id];
                end
            end

            pane[i]:SetText(enabled and btn.text or '');
            pane[i]:SetDisabled(not enabled);

            local info1, info2 = ExG:Equipped(item.slots);

            pane[i]:SetCallback('OnClick', btnRoll(self, pane, item, btn, info1, info2));

            pane[i].frame:Show();
        else
            pane[i].frame:Hide();
        end
    end

    local point = points.disenchant[ceil(btnCount / 2)];

    pane.dis:SetPoint(point.point, pane.head.frame, point.rel, point.x, point.y);

    local offset = point.y;

    if ExG:IsMl() then
        pane.dis.frame:Show();

        offset = offset - 25;
    else
        pane.dis.frame:Hide();
    end

    pane.accepted:SetPoint('TOP', pane.head.frame, 'BOTTOM', 0, offset);

    self.frame:SetHeight(PANE_HEIGH + 25 * ceil(btnCount / 2) + (ExG:IsMl() and 25 or 0));
end

local function renderAccepted(self, item, pane)
    pane.accepted:SetCallback('OnEnter', onAccepted(pane.accepted.frame, item));
end

local function renderRolls(self, item, pane)
    if not item then
        for i = 1, #pane.rolls do
            pane.rolls[i].pane.frame:Hide();
        end

        return;
    end

    renderAccepted(self, item, pane);

    local rolls = {};

    for _, roll in pairs(item.rolls) do
        if roll.option < 'button6' then
            local info = ExG:GuildInfo(roll.name);
            local button = roll.option and store().buttons.data[roll.option];

            roll.pr = button and button.roll and roll.rnd or ExG:GetEG(info.officerNote).pr;

            tinsert(rolls, { name = roll.name, class = roll.class, rank = info.rank, rankId = info.rankId, gp = roll.gp, option = roll.option, pr = roll.pr, slot1 = roll.slot1, slot2 = roll.slot2, rnd = roll.rnd, });
        end
    end

    sort(rolls, function(a, b)
        if a.option < b.option then
            return true;
        elseif a.option == b.option then
            return a.pr == b.pr and a.rnd > b.rnd or a.pr > b.pr;
        end;

        return false;
    end);

    for i = 1, min(#rolls, MAX_ROLLS) do
        local tmp = rolls[i];

        local roll = pane.rolls[i];
        local button = tmp.option and store().buttons.data[tmp.option];

        roll.name:SetVertexColor(ExG:ClassColor(tmp.class));
        roll.name:SetText(tmp.name);
        roll.option:SetText(store().buttons.data[tmp.option].text);
        roll.pr:SetText(tmp.pr);
        roll.item1:SetImage(tmp.slot1 and tmp.slot1.texture);
        roll.item1:SetCallback('OnEnter', onEnter(roll.item1.frame, tmp.slot1 and tmp.slot1.link));
        roll.item1:SetCallback('OnLeave', onLeave);
        roll.item2:SetImage(tmp.slot2 and tmp.slot2.texture);
        roll.item2:SetCallback('OnEnter', onEnter(roll.item2.frame, tmp.slot2 and tmp.slot2.link));
        roll.item2:SetCallback('OnLeave', onLeave);

        if ExG:IsMl() then
            roll.pane.frame:SetScript('OnEnter', onRoll(roll.pane.frame, tmp.name, tmp.class, tmp.rank, tmp.rankId, tmp.pr, tmp.rnd));
            roll.pane.frame:SetScript('OnLeave', onLeave);
            roll.pane.frame:SetScript('OnMouseDown', function() self.Dialog:Show(item, tmp); end);
        end

        roll.pane.frame:Show();
    end

    for i = #rolls + 1, #pane.rolls do
        pane.rolls[i].pane.frame:Hide();
    end
end

local function renderItem(self, item)
    if not item then
        return;
    end

    local pane = findPane(self, item.id);

    if not pane then
        return;
    end

    if item.active then
        if not item.gp then
            ExG:Print(L['Critical error occurs']('RollFrame', 'renderItem', 'item.gp = nil'));
        end

        pane.head:SetImage(item.texture);
        pane.cost:SetText(item.gp .. ' GP');
        pane.count:SetText('x ' .. (item.count or 0));
        pane.head:SetLabel(item.link);
        pane.head:SetCallback('OnEnter', onEnter(pane.head.frame, item.link));

        renderTips(self, pane);
        renderButons(self, item, pane);
        renderRolls(self, item, pane);
    else
        pane.itemId = nil;
        pane.frame:Hide();
    end

    self.frame:SetWidth(count(self) * (PANE_WIDTH + 5) + 15);

    pane.frame:Show();

    if count(self) == 0 then
        self.frame:Hide();
    end
end

local function renderItems(self)
    for id, item in pairs(self.items) do
        if not (item and item.id) then
            local pane = findPane(self, id);

            if pane then
                pane.itemId = nil;
                pane.frame:Hide();
            end
        else
            renderItem(self, item);
        end
    end
end

local function disenchantHistory(item)
    local dt, offset = ExG:ServerTime(), 0;

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

    ExG:Report(L['ExG Report Disenchant'](item.link));
end

local function appendHistory(item, roll)
    local button = roll.option and store().buttons.data[roll.option];
    local dt, offset = ExG:ServerTime(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'item',
        target = { name = roll.name, class = roll.class, },
        master = { name = ExG.state.name, class = ExG.state.class, },
        link = item.link;
        dt = dt,
        details = {},
    };

    local info = ExG:GuildInfo(roll.name);
    local old = ExG:GetEG(info.officerNote);
    local new = ExG:SetEG(info, old.ep, old.gp + roll.gp);

    store().history.data[dt].gp = { before = old.gp, after = new.gp, };
    store().history.data[dt].desc = L['ExG History Item'](roll.gp, button.text);

    local i, details = 1, {};

    for unit, v in pairs(item.rolls) do
        local st = dt + i / 1000;

        if v.option < 'button6' then
            details[st] = {
                target = { name = unit, class = v.class, },
                option = v.option,
                pr = v.pr,
                rnd = v.rnd,
                dt = st,
            };
        end

        i = i + 1;
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt], }, });

    ExG:Report(L['ExG Report Item'](roll.name, item.link, roll.gp));
end

function ExG.RollFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Roll Frame']);
    self.frame:SetLayout(nil);
    self.frame:SetCallback('OnClose', function() self:Hide(); end);
    self.frame:SetHeight(471);
    self.frame:EnableResize(false);

    for i = 1, MAX_PANES do
        makePane(self);
    end

    self.Dialog:Create();

    self.frame:Hide();
end

function ExG.RollFrame:Show()
    self.frame:Show();
end

function ExG.RollFrame:Hide()
    if ExG:IsMl() then
        ExG:CancelRolls();
    else
        for id, item in pairs(self.items) do
            if not (item.rolled or false) then
                ExG:RollItem({
                    id = id,
                    class = ExG.state.class,
                    gp = item.gp,
                    option = 'button6',
                    slot1 = nil,
                    slot2 = nil,
                    rnd = random(1, 100),
                });
            end

            self:RemoveItem(id);
        end
    end

    self.Dialog:Hide();

    self.frame:Hide();
end

function ExG.RollFrame:AddItem(item)
    if not (item and item.id) then
        return;
    end

    self.items[item.id] = self.items[item.id] or { count = 1, accepted = {}, rolls = {}, };

    local tmp = self.items[item.id];

    tmp.active = true;
    tmp.id = item.id;
    tmp.count = item.count;
    tmp.mode = item.mode;
    tmp.name = item.name;
    tmp.loc = item.loc;
    tmp.slots = item.slots;
    tmp.link = item.link;
    tmp.texture = item.texture;

    local settings = ExG:PullSettings(item.id);
    local cost = settings and ((settings.spec and settings.spec.gp) or (settings.class and settings.class.gp) or (settings.def and settings.def.gp));
    tmp.gp = cost or item.gp or 0;

    local pane = getPane(self, item.id);

    if pane then
        ExG:AcceptItem(tmp.id);

        renderItems(self);
    end
end

function ExG.RollFrame:AcceptItem(itemId, source)
    if not itemId then
        return;
    end

    self.items[itemId] = self.items[itemId] or { count = 1, accepted = {}, rolls = {}, };

    local item = self.items[itemId];

    item.accepted[source] = true;

    local pane = findPane(self, itemId);

    if pane then
        pane.accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), ExG:Size(item.accepted)));

        renderAccepted(self, item, pane);
    end
end

function ExG.RollFrame:RollItem(data, unit)
    if not (data and data.id) then
        return;
    end

    self.items[data.id] = self.items[data.id] or { count = 1, accepted = {}, rolls = {}, };

    local item = self.items[data.id];

    item.rolls[unit] = item.rolls[unit] or {};
    item.rolls[unit].name = unit;
    item.rolls[unit].class = data.class;
    item.rolls[unit].gp = data.gp;
    item.rolls[unit].option = data.option;
    item.rolls[unit].rnd = item.rolls[unit].rnd or data.rnd;
    item.rolls[unit].slot1 = ExG:LinkInfo(data.slot1);
    item.rolls[unit].slot2 = ExG:LinkInfo(data.slot2);

    local pane = findPane(self, item.id);

    if pane then
        pane.accepted:SetText(L['Pretenders'](ExG:Size(item.rolls), ExG:Size(item.accepted)));

        renderRolls(self, item, pane);
    end
end

function ExG.RollFrame:DistributeItem(unit, itemId)
    if not itemId then
        return;
    end

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

function ExG.RollFrame:CancelRolls()
    self.items = {};

    for i = 1, #self.frame.children do
        local pane = self.frame.children[i];

        pane.itemId = nil;
        pane.frame:Hide();
    end

    self.Dialog:Hide();

    self.frame:Hide();
end

function ExG.RollFrame:RemoveItem(itemId)
    if not itemId then
        return;
    end

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

            if not pane.itemId then
                pane.frame:Hide();
            end
        end
    end

    self.items[itemId] = nil;

    renderItems(self);

    if count(self) == 0 then
        self.frame:Hide();
    end

    if self.Dialog.item and self.Dialog.item.id == itemId then
        self.Dialog:Hide();
    end
end

ExG.RollFrame.Dialog = {
    frame = nil,
    item = nil,
    roll = nil,
};

local function renderDialog(self)
    local onClick = function(item, roll)
        return function() self:GiveItem(item, roll); end
    end;

    local main = store().buttons.data[self.roll.option];
    local gp = floor(self.roll.gp * main.ratio);

    self.frame.head:SetText(L['Unit will receive item'](self.roll.name, self.item.link));
    self.frame.main:SetText(format('%s - %d GP', main.text, gp));
    self.frame.main:SetCallback('OnClick', onClick(self.item, { name = self.roll.name, class = self.roll.class, gp = gp, option = self.roll.option, }));

    local btns = {};

    for _, btn in pairs(store().buttons.data) do
        if btn.enabled and btn.id ~= 'button6' and btn.id ~= self.roll.option then
            tinsert(btns, btn);
        end
    end

    sort(btns, function(a, b) return a.id < b.id; end);

    for i, btn in ipairs(btns) do
        gp = floor(self.roll.gp * btn.ratio);

        self.frame.btn[i]:SetText(format('%s\n%d GP', btn.text, gp));
        self.frame.btn[i]:SetCallback('OnClick', onClick(self.item, { name = self.roll.name, class = self.roll.class, gp = gp, option = btn.id, }));
    end
end

function ExG.RollFrame.Dialog:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['Roll Dialog Frame']);
    self.frame:SetLayout('Flow');
    self.frame:SetCallback('OnClose', function() end);
    self.frame:SetWidth(310);
    self.frame:SetHeight(135);
    self.frame:EnableResize(false);

    self.frame.head = AceGUI:Create('Label');
    self.frame.head:SetFullWidth(true);
    self.frame.head:SetHeight(25);
    self.frame.head:SetJustifyH('CENTER');
    self.frame:AddChild(self.frame.head);

    self.frame.main = AceGUI:Create('Button');
    self.frame.main:SetFullWidth(true);
    self.frame.main:SetHeight(25);
    self.frame.main:SetText('25');
    self.frame:AddChild(self.frame.main);

    self.frame.btn = {};

    if store().buttons.count > 2 then
        local rwidth = 1 / (store().buttons.count - 2);

        for i = 1, store().buttons.count - 2 do
            self.frame.btn[i] = AceGUI:Create('Button');
            self.frame.btn[i]:SetRelativeWidth(rwidth);
            self.frame.btn[i]:SetHeight(50);
            self.frame.btn[i]:SetText(i);
            self.frame:AddChild(self.frame.btn[i]);
        end
    end

    self.frame:Hide();
end

function ExG.RollFrame.Dialog:Show(item, roll)
    if not item or not roll then
        self.frame:Hide();

        return;
    end

    self.item = item;
    self.roll = roll;

    renderDialog(self);

    self.frame:Show();
end

function ExG.RollFrame.Dialog:Hide()
    self.item = nil;
    self.roll = nil;

    self.frame:Hide();
end

function ExG.RollFrame.Dialog:GiveItem(item, roll)
    if item.mode == 'loot' and not ExG.state.looting then
        return;
    end

    if not CanEditOfficerNote() then
        return;
    end

    if not item or not roll then
        return;
    end

    if item.mode == 'loot' then
        local lootIndex, unitIndex

        for i = 1, GetNumLootItems() do
            local tmp = ExG:LinkInfo(GetLootSlotLink(i));

            lootIndex = tmp and item.id == tmp.id and i or lootIndex;
        end

        if not lootIndex then
            return;
        end

        for i = 1, MAX_RAID_MEMBERS do
            local name = GetMasterLootCandidate(lootIndex, i);

            unitIndex = name and roll.name == Ambiguate(name, 'all') and i or unitIndex;
        end

        if not unitIndex then
            return;
        end

        GiveMasterLoot(lootIndex, unitIndex);
    end

    if not roll.option then
        disenchantHistory(item);
    else
        appendHistory(item, roll);
    end

    ExG:DistributeItem(roll.name, item.id);

    self:Hide();
end
