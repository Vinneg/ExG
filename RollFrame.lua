local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local state = function() return ExG.state; end;
local store = function() return ExG.store.char; end;

local btnRoll = function(self, pane, gp, btn, info1, info2)
    return function()
        ExG:RollItem({
            id = pane.itemId,
            class = ExG.state.class,
            gp = gp,
            option = btn.id,
            slot1 = info1 and info1.link,
            slot2 = info2 and info2.link,
            rnd = random(1, 100),
        });
    end;
end

local btnPass = function(self, pane, btn)
    return function()
        ExG:RollItem({
            id = pane.itemId,
            class = ExG.state.class,
            option = btn.id,
        });

        if store().items.closeOnPass and not ExG:IsMl() then
            self:RemoveItem(pane.itemId);
        end
    end
end

local onEnter = function(owner, link) if link then return function() GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT'); GameTooltip:SetHyperlink(link); GameTooltip:Show(); end; else return function() end; end end;
local onTip = function(owner, class, desc, spec) local r, g, b = ExG:ClassColor(class); return function() GameTooltip:SetOwner(owner, 'ANCHOR_TOP'); GameTooltip:SetText(desc .. (spec and ': ' .. spec or ''), r, g, b); GameTooltip:Show(); end; end;
local onLeave = function() return GameTooltip:Hide(); end;

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

local CLASSES = {
    WARRIOR = {
        id = 1,
        name = 'WARRIOR',
        icon = 626008,
        specs = {
            ARMS = {
                id = 1,
                name = 'ARMS',
                icon = 132349,
            },
            FURY = {
                id = 2,
                name = 'FURY',
                icon = 132347,
            },
            PROT = {
                id = 3,
                name = 'PROT',
                icon = 132341,
            },
        },
        scan = function()
            local _, _, prot = GetTalentTabInfo(3);

            if prot > 10 then
                return 'PROT';
            end

            local _, _, arms = GetTalentTabInfo(1);
            local _, _, fury = GetTalentTabInfo(2);

            if arms > fury then
                return 'ARMS';
            elseif arms < fury then
                return 'FURY';
            end

            return nil;
        end,
    },
    PALADIN = {
        id = 2,
        name = 'PALADIN',
        icon = 626003,
        specs = {
            HOLY = {
                id = 1,
                name = 'HOLY',
                icon = 135920,
            },
            PROT = {
                id = 2,
                name = 'PROT',
                icon = 135880,
            },
            RETRI = {
                id = 3,
                name = 'RETRI',
                icon = 135873,
            },
        },
        scan = function()
            local _, _, holy = GetTalentTabInfo(1);
            local _, _, prot = GetTalentTabInfo(2);
            local _, _, retri = GetTalentTabInfo(3);

            if holy > prot and holy > retri then
                return 'HOLY';
            elseif prot > holy and prot > retri then
                return 'PROT';
            elseif retri > holy and retri > prot then
                return 'RETRI';
            end

            return nil;
        end,
    },
    HUNTER = {
        id = 3,
        name = 'HUNTER',
        icon = 626000,
        specs = {
            BM = {
                id = 1,
                name = 'BM',
                icon = 132164,
            },
            MM = {
                id = 2,
                name = 'MM',
                icon = 132222,
            },
            SURV = {
                id = 3,
                name = 'SURV',
                icon = 132215,
            },
        },
        scan = function()
            return nil;
        end,
    },
    ROGUE = {
        id = 4,
        name = 'ROGUE',
        icon = 626005,
        specs = {
            ASSASSIN = {
                id = 1,
                name = 'ASSASSIN',
                icon = 132292,
            },
            COMBAT = {
                id = 2,
                name = 'COMBAT',
                icon = 132090,
            },
            SUBTLETY = {
                id = 3,
                name = 'SUBTLETY',
                icon = 132089,
            },
        },
        scan = function()
            return nil;
        end,
    },
    PRIEST = {
        id = 5,
        name = 'PRIEST',
        icon = 626004,
        specs = {
            DISC = {
                id = 1,
                name = 'DISC',
                icon = 135987,
            },
            HOLY = {
                id = 2,
                name = 'HOLY',
                icon = 626004,
            },
            SHADOW = {
                id = 3,
                name = 'SHADOW',
                icon = 136207,
            },
        },
        scan = function()
            local _, _, shadow = GetTalentTabInfo(3);

            if shadow > 30 then
                return 'SHADOW';
            end

            return 'HOLY';
        end,
    },
    DEATHKNIGHT = {
        id = 6,
        name = 'DEATHKNIGHT',
        icon = 0,
        specs = {
            DISC = {
                id = 1,
                icon = 0,
            },
            HOLY = {
                id = 2,
                icon = 0,
            },
            SHADOW = {
                id = 3,
                icon = 0,
            },
        },
        scan = function()
            return nil;
        end,
    },
    SHAMAN = {
        id = 7,
        name = 'SHAMAN',
        icon = 626006,
        specs = {
            ELEM = {
                id = 1,
                name = 'ELEM',
                icon = 136048,
            },
            ENH = {
                id = 2,
                name = 'ENH',
                icon = 136114,
            },
            RESTOR = {
                id = 3,
                name = 'RESTOR',
                icon = 136052,
            },
        },
        scan = function()
            local _, _, elem = GetTalentTabInfo(1);
            local _, _, enh = GetTalentTabInfo(2);
            local _, _, restor = GetTalentTabInfo(3);

            if restor > elem and restor > enh then
                return 'RESTOR';
            elseif elem > restor and elem > enh then
                return 'ELEM';
            elseif enh > restor and enh > elem then
                return 'ENH';
            end

            return nil;
        end,
    },
    MAGE = {
        id = 8,
        name = 'MAGE',
        icon = 626001,
        specs = {
            ARCANE = {
                id = 1,
                name = 'ARCANE',
                icon = 135932,
            },
            FIRE = {
                id = 2,
                name = 'FIRE',
                icon = 135812,
            },
            FROST = {
                id = 3,
                name = 'FROST',
                icon = 135846,
            },
        },
        scan = function()
            local _, _, fire = GetTalentTabInfo(2);
            local _, _, frost = GetTalentTabInfo(3);

            if fire > frost then
                return 'FIRE';
            elseif frost > fire then
                return 'FROST';
            end

            return nil;
        end,
    },
    WARLOCK = {
        id = 9,
        name = 'WARLOCK',
        icon = 626007,
        specs = {
            AFFLI = {
                id = 1,
                name = 'AFFLI',
                icon = 136145,
            },
            DEMON = {
                id = 2,
                name = 'DEMON',
                icon = 136172,
            },
            DESTR = {
                id = 3,
                name = 'DESTR',
                icon = 136186,
            },
        },
        scan = function()
            return nil;
        end,
    },
    MONK = {
        id = 10,
        name = 'MONK',
        icon = 0,
        specs = {
            AFFLI = {
                id = 1,
                name = 'DESTR',
                icon = 0,
            },
            DEMON = {
                id = 2,
                name = 'DESTR',
                icon = 0,
            },
            DESTR = {
                id = 3,
                name = 'DESTR',
                icon = 0,
            },
        },
        scan = function()
            return nil;
        end,
    },
    DRUID = {
        id = 11,
        name = 'DRUID',
        icon = 625999,
        specs = {
            BALANCE = {
                id = 1,
                name = 'BALANCE',
                icon = 136096,
            },
            FERAL = {
                id = 2,
                name = 'FERAL',
                icon = 132276,
            },
            RESTOR = {
                id = 3,
                name = 'RESTOR',
                icon = 136041,
            },
        },
        scan = function()
            local _, _, heal = GetTalentTabInfo(3);

            if heal > 15 then
                return 'RESTOR';
            end

            local _, _, balance = GetTalentTabInfo(1);
            local _, _, feral = GetTalentTabInfo(2);

            if balance > feral then
                return 'BALANCE';
            elseif feral > balance then
                return 'FERAL';
            end

            return nil;
        end,
    },
    DEMONHUNTER = {
        id = 12,
        name = 'DEMONHUNTER',
        icon = 0,
        specs = {
            AFFLI = {
                id = 1,
                name = 'RESTOR',
                icon = 0,
            },
            DEMON = {
                id = 2,
                name = 'RESTOR',
                icon = 0,
            },
            DESTR = {
                id = 3,
                name = 'RESTOR',
                icon = 0,
            },
        },
        scan = function()
            return nil;
        end,
    },
};

local CLASSES_ORDER = { 'WARRIOR', 'PALADIN', 'HUNTER', 'ROGUE', 'PRIEST', 'DEATHKNIGHT', 'SHAMAN', 'MAGE', 'WARLOCK', 'MONK', 'DRUID', 'DEMONHUNTER', };

local function getClassSpec()
    local class = ExG.state.class;
    local spec = CLASSES[class] and CLASSES[class].scan() or nil;

    return spec and (class .. '_' .. spec) or class;
end

local MAX_TIPS = 12;
local MAX_ROLLS = 10;
local PANE_WIDTH = 200;
local PANE_HEIGH = 371;

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

local function getTips(self, pane)
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

local function getButtons(self, pane)
    local points = {
        button = {
            { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -32 },
            { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -32 },
            { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -57 },
            { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -57 },
            { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -82 },
            { point = 'TOPRIGHT', frame = pane.head.frame, rel = 'BOTTOMRIGHT', x = -5, y = -82 },
        },
        disenchant = {
            [1] = { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -57 },
            [2] = { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -82 },
            [3] = { point = 'TOPLEFT', frame = pane.head.frame, rel = 'BOTTOMLEFT', x = 5, y = -107 },
        },
    };

    local btns, last = {}, nil;

    for _, btn in pairs(store().buttons.data) do
        if btn.enabled then
            tinsert(btns, btn);
        end
    end

    sort(btns, function(a, b) return a.id < b.id; end);

    for i, btn in ipairs(btns) do
        pane[btn.id] = AceGUI:Create('Button');
        pane[btn.id]:SetText('');
        pane[btn.id]:SetWidth((PANE_WIDTH - 15) / 2);
        pane[btn.id]:SetDisabled(true);
        pane:AddChild(pane[btn.id]);

        local point = points.button[i];

        pane[btn.id]:SetPoint(point.point, point.frame, point.rel, point.x, point.y);

        last = pane[btn.id];
    end

    if ExG:IsMl() then
        pane.dis = AceGUI:Create('Button');
        pane.dis:SetText(L['Disenchant']);
        pane.dis:SetWidth(PANE_WIDTH - 10);
        pane.dis:SetCallback('OnClick', function() self.Dialog:GiveItem(self.items[pane.itemId], { name = ExG.state.name, class = ExG.state.class, }); end);
        pane:AddChild(pane.dis);

        local point = points.disenchant[ceil(#btns / 2)];

        pane.dis:SetPoint(point.point, point.frame, point.rel, point.x, point.y);

        last = pane.dis;
    end

    self.frame:SetHeight(PANE_HEIGH + 25 * ceil(#btns / 2) + (ExG:IsMl() and 25 or 0));

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
        roll.name:SetJustifyV('MIDDLE');
        roll.name:SetText('Name');

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
        pane:SetWidth(PANE_WIDTH);
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

        getTips(self, pane);

        local last = getButtons(self, pane);

        pane.accepted = AceGUI:Create('Label');
        pane.accepted:SetText('none');
        pane.accepted:SetFullWidth(true);
        pane:AddChild(pane.accepted);

        pane.accepted:SetPoint('TOP', last.frame, 'BOTTOM', 0, -5);
        pane.accepted:SetPoint('LEFT', pane.frame, 'LEFT', 5, 0);
        pane.accepted:SetPoint('RIGHT', pane.frame, 'RIGHT', -5, 0);

        getRolls(pane);
    end

    self.frame:SetWidth(count(self) * (PANE_WIDTH + 5) + 15);

    if count(self) == 0 then
        self.frame:Hide();
    end

    return pane;
end

local function renderTips(self, pane, settings)
    local scan = function(res, class)
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
        scan(res, v);
    end

    for i, v in ipairs(res) do
        local class, spec = strsplit('_', v.name, 2);

        v.class = class;

        class = CLASSES[class];

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

local function renderButons(self, pane, settings)
    local item = self.items[pane.itemId];

    for _, btn in pairs(store().buttons.data) do
        if pane[btn.id] then
            local enabled = true;

            if settings and btn.id ~= 'button6' then
                local spec = settings[getClassSpec()];
                local class = settings[ExG.state.class];
                local def = settings['DEFAULT'] or {};

                if spec then
                    enabled = spec[btn.id];
                elseif class then
                    enabled = class[btn.id];
                else
                    enabled = def[btn.id];
                end
            end

            pane[btn.id]:SetText(enabled and btn.text or '');
            pane[btn.id]:SetDisabled(not enabled);

            local info1, info2 = ExG:Equipped(item.slots);

            pane[btn.id]:SetCallback('OnClick', btnRoll(self, pane, item.gp, btn, info1, info2));
        end
    end
end

local function renderRolls(self, pane)
    local item = self.items[pane.itemId];

    if not item then
        for i = 1, #pane.rolls do
            pane.rolls[i].pane.frame:Hide();
        end

        return;
    end

    local rolls = {};

    for _, roll in pairs(item.rolls) do
        if roll.option < 'button6' then
            local info = ExG:GuildInfo(roll.name);
            local button = roll.option and store().buttons.data[roll.option];
            local pr = button and button.roll and roll.rnd or ExG:GetEG(info.officerNote).pr;

            tinsert(rolls, { name = roll.name, class = roll.class, gp = roll.gp, option = roll.option, pr = pr, slot1 = roll.slot1, slot2 = roll.slot2, rnd = roll.rnd });
        end
    end

    sort(rolls, function(a, b)
        if a.option < b.option then
            return true;
        elseif a.option == b.option then
            return a.pr > b.pr;
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
            roll.pane.frame:SetScript('OnMouseDown', function() self.Dialog:Show(item, tmp); end); -- self:GiveItem(tmp.name, tmp.class, pane.itemId, tmp.option);
        end

        roll.pane.frame:Show();
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
    local spec = settings and settings[getClassSpec()] or {};
    local class = settings and settings[ExG.state.class] or {};
    local def = settings and settings['DEFAULT'] or {};

    pane.head:SetImage(item.texture);
    pane.cost:SetText((spec.gp or class.gp or def.gp or item.gp or 0) .. ' GP');
    pane.count:SetText('x ' .. (item.count or 0));
    pane.head:SetLabel(item.link);
    pane.head:SetCallback('OnEnter', onEnter(pane.head.frame, item.link));

    renderTips(self, pane, settings);
    renderButons(self, pane, settings);
    renderRolls(self, pane);

    pane.frame:Show();
end

local function renderItems(self)
    for id in pairs(self.items) do
        local pane = getPane(self, id);

        renderItem(self, pane);
    end
end

local function disenchantHistory(item)
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

local function appendHistory(item, roll)
    local button = roll.option and store().buttons.data[roll.option];
    local dt, offset = time(), 0;

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

    local gp = item.gp * button.ratio;

    local info = ExG:GuildInfo(roll.name);
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
    self.frame:SetHeight(471);
    self.frame:EnableResize(false);
    self.frame:Hide();

    self.Dialog:Create();
end

function ExG.RollFrame:Show()
    self.frame:Show();
end

function ExG.RollFrame:Hide()
    self.Dialog:Hide();

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
        tmp.gp = class.gp or def.gp;

        ExG:AcceptItem(id);

        local obj = Item:CreateFromItemID(id);
        obj:ContinueOnItemLoad(function()
            local info = ExG:ItemInfo(id);

            local tmp = self.items[id];
            tmp.gp = tmp.gp or ExG:CalcGP(id);
            tmp.name = info.name;
            tmp.loc = info.loc;
            tmp.slots = info.slots;
            tmp.link = info.link;
            tmp.texture = info.texture;

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

            self.frame:SetWidth(count(self) * (PANE_WIDTH + 5) + 15);
        end
    end

    self.items[itemId] = nil;

    self.frame:SetWidth(count(self) * (PANE_WIDTH + 5) + 15);

    if count(self) == 0 then
        self.frame:Hide();
    end

    if self.Dialog.item and self.Dialog.item.id == itemId then
        self.Dialog:Hide();
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
    item.rolls[unit].gp = data.gp;
    item.rolls[unit].option = data.option;
    item.rolls[unit].rnd = item.rolls[unit].rnd or data.rnd;
    item.rolls[unit].slot1 = ExG:LinkInfo(data.slot1);
    item.rolls[unit].slot2 = ExG:LinkInfo(data.slot2);

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

ExG.RollFrame.Dialog = {
    frame = nil,
    item = nil,
    roll = nil,
};

local function renderDialog(self)
    local main = store().buttons.data[self.roll.option];

    self.frame.head:SetText(L['Unit will receive item'](self.roll.name, self.item.link));
    self.frame.main:SetText(format('%s - %d GP', main.text, floor(self.roll.gp * main.ratio)));
    self.frame.main:SetCallback('OnClick', function() self:GiveItem(self.item, self.roll); end);

    local btns = {};

    for _, btn in pairs(store().buttons.data) do
        if btn.enabled and btn.id ~= 'button6' and btn.id ~= self.roll.option then
            tinsert(btns, btn);
        end
    end

    sort(btns, function(a, b) return a.id < b.id; end);

    for i, btn in ipairs(btns) do
        self.frame.btn[i]:SetText(format('%s\n%d GP', btn.text, floor(self.roll.gp * btn.ratio)));
        self.frame.btn[i]:SetCallback('OnClick', function() self:GiveItem(self.item, { name = self.roll.name, class = self.roll.class, option = btn.id, }); end);
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
    if not ExG.state.looting then
        return;
    end

    if not item or not roll then
        return;
    end

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

    if not roll.option then
        disenchantHistory(item);
    else
        appendHistory(item, roll);
    end

    ExG:DistributeItem(roll.name, item.id);
end
