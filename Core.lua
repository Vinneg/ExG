ExG = LibStub('AceAddon-3.0'):NewAddon('ExG', 'AceConsole-3.0', 'AceEvent-3.0', 'AceComm-3.0', 'AceTimer-3.0');

local AceConfig = LibStub('AceConfig-3.0');
local AceConfigDialog = LibStub('AceConfigDialog-3.0');
local AceDB = LibStub('AceDB-3.0');
local Serializer = LibStub('AceSerializer-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;
local isNumber = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end;

local function tooltipGp(self)
    if not store().showGp then
        return;
    end

    local _, link = self:GetItem();
    local info = ExG:ItemInfo(link);

    if not info then
        return;
    end

    local settings = ExG:PullSettings(info.id);
    local gp = settings and ((settings.spec and settings.spec.gp) or (settings.class and settings.class.gp) or (settings.def and settings.def.gp)) or ExG:CalcGP(info);

    GameTooltip:AddLine(L['ExG Tooltip GP value'](gp), { 1, 1, 1 });
end

local function hyperlinkGp(self, link)
    if not store().showGp then
        return;
    end

    local info = ExG:ItemInfo(link);

    if not info then
        return;
    end

    local settings = ExG:PullSettings(info.id);
    local gp = settings and ((settings.spec and settings.spec.gp) or (settings.class and settings.class.gp) or (settings.def and settings.def.gp)) or ExG:CalcGP(info);

    ItemRefTooltip:AddLine(L['ExG Tooltip GP value'](gp), { 1, 1, 1 });
    ItemRefTooltip:Show();
end

local buttons = {
    validateText = function(_, value)
        if not value then
            return L['Value must be a not empty string'];
        end
        local txt = string.gsub(value, '%s', '');
        if not txt or #txt == 0 then
            return L['Value must be a not empty string'];
        end
        return true;
    end,
    getText = function(btnId)
        return function() return store().buttons.data[btnId].text; end;
    end,
    setText = function(btnId)
        return function(_, value) store().buttons.data[btnId].text = value; end;
    end,
    validateRatio = function(_, value)
        if not tonumber(value) then
            return L['Value must be a number'];
        end
        return true;
    end,
    getRatio = function(btnId)
        return function() return tostring(store().buttons.data[btnId].ratio); end;
    end,
    setRatio = function(btnId)
        return function(_, value) store().buttons.data[btnId].ratio = tonumber(value); end;
    end,
    getRoll = function(btnId)
        return function() return store().buttons.data[btnId].roll; end;
    end,
    setRoll = function(btnId)
        return function(_, value) store().buttons.data[btnId].roll = value; end;
    end,
};

local items = {
    filler = function(order, full)
        return {
            type = 'description',
            name = '',
            order = order,
            width = full or 0.2,
        };
    end,
    type = function(order, name)
        return {
            type = 'input',
            name = L['Items ' .. name],
            order = order,
            width = 0.3,
            validate = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end,
            get = function() return tostring(store().items.formula[name]); end,
            set = function(_, value) store().items.formula[name] = tonumber(value); end,
        }
    end
};

local bosses = {
    filler = function(order)
        return {
            type = 'description',
            name = ' EP',
            order = order,
            width = 0.2,
        };
    end,
    enable = function(order, id)
        return {
            type = 'toggle',
            name = L['ExG Boss ' .. id],
            order = order,
            width = 1.2,
            get = function() return store().bosses[id].enable; end,
            set = function(_, value) store().bosses[id].enable = value; end,
        };
    end,
    bonus = function(order, id)
        return {
            type = 'input',
            name = '',
            order = order,
            width = 0.5,
            validate = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end,
            get = function() return tostring(store().bosses[id].ep); end,
            set = function(_, value) store().bosses[id].ep = tonumber(value); end,
        };
    end,
};

ExG.messages = {
    prefix = {
        announce = 'ExG_Announce',
        accept = 'ExG_Accept',
        roll = 'ExG_Roll',
        distribute = 'ExG_Distribute',
        cancel = 'ExG_Cancel',
        pull = 'ExG_Pull',
        share = 'ExG_Share',
        options = 'ExG_Options',
        version = 'ExG_Version',
        sync = 'ExG_Sync',
        reserve = 'ExG_Reserve',
    },
    raid = 'RAID',
    warning = 'RAID_WARNING',
    guild = 'GUILD',
    whisper = 'WHISPER',
};

ExG.state = {
    name = nil,
    class = nil,
    looting = false,
    options = nil,
    version = nil,
};

ExG.defaults = {
    factionrealm = {
        chars = {},
    },
    char = {
        baseEP = 0,
        baseGP = 10,
        debug = false,
        showGp = true,
        optionFilter = 1,
        channel = 'GUILD',
        items = {
            pageSize = 50,
            threshold = 4,
            closeOnPass = true,
            announce = true,
            passTimer = 60,
            formula = {
                coef = 7,
                base = 1.5,
                mod = 1,
                INVTYPE_HEAD = 0.85,
                INVTYPE_NECK = 0.75,
                INVTYPE_SHOULDER = 0.75,
                INVTYPE_CLOAK = 0.75,
                INVTYPE_CHEST = 0.9,
                INVTYPE_WRIST = 0.75,
                INVTYPE_HAND = 0.75,
                INVTYPE_WAIST = 0.75,
                INVTYPE_LEGS = 0.9,
                INVTYPE_FEET = 0.75,
                INVTYPE_FINGER = 0.75,
                INVTYPE_TRINKET = 0.75,
                INVTYPE_WEAPONMAINHAND = 1.5,
                INVTYPE_WEAPONOFFHAND = 1.3,
                INVTYPE_HOLDABLE = 0.7,
                INVTYPE_WEAPON = 1.5,
                INVTYPE_2HWEAPON = 1.8,
                INVTYPE_SHIELD = 0.7,
                INVTYPE_RANGED = 0.6,
                INVTYPE_WAND = 0.5,
                INVTYPE_RELIC = 0.5,
                INVTYPE_THROWN = 0.6,
            },
            data = {},
            ignore = {
                [20725] = true,
                [18562] = true,
                [21218] = true,
                [21324] = true,
                [21323] = true,
                [22726] = true,
                [22727] = true,
                [22733] = true,
                [22734] = true,
            },
        },
        buttons = {
            count = 2,
            data = {
                button1 = { enabled = true, id = 'button1', text = 'need', ratio = 1, roll = false },
                button2 = { enabled = false, id = 'button2', text = 'greed', ratio = 0.5, roll = false },
                button3 = { enabled = false, id = 'button3', text = 'offspec', ratio = 0.3, roll = false },
                button4 = { enabled = false, id = 'button4', text = 'gold', ratio = 0, roll = true },
                button5 = { enabled = false, id = 'button5', text = 'free', ratio = 0, roll = true },
                button6 = { enabled = true, id = 'button6', text = 'pass', ratio = 0, roll = false },
            },
        },
        history = {
            pageSize = 50,
            offset = 1,
            source = nil,
            data = {},
            bak = {},
        },
        bosses = {
            [784] = { enable = true, ep = 2 }, --'High Priest Venoxis',
            [785] = { enable = true, ep = 2 }, --'High Priestess Jeklik'
            [786] = { enable = true, ep = 2 }, --'High Priestess Mar'li',
            [787] = { enable = true, ep = 2 }, --'Bloodlord Mandokir',
            [788] = { enable = true, ep = 2 }, --'Edge of Madness',
            [789] = { enable = true, ep = 2 }, --'High Priest Thekal',
            [790] = { enable = true, ep = 2 }, --'Gahz'ranka',
            [791] = { enable = true, ep = 2 }, --'High Priestess Arlokk',
            [792] = { enable = true, ep = 2 }, --'Jin'do the Hexxer',
            [793] = { enable = true, ep = 3 }, --'Hakkar',
            [663] = { enable = true, ep = 5 }, --'Lucifron',
            [664] = { enable = true, ep = 5 }, --'Magmadar',
            [665] = { enable = true, ep = 5 }, --'Gehennas',
            [666] = { enable = true, ep = 5 }, --'Garr',
            [667] = { enable = true, ep = 5 }, --'Shazzrah',
            [668] = { enable = true, ep = 5 }, --'Baron Geddon',
            [669] = { enable = true, ep = 5 }, --'Sulfuron Harbinger',
            [670] = { enable = true, ep = 5 }, --'Golemagg the Incinerator',
            [671] = { enable = true, ep = 5 }, --'Majordomo Executus',
            [672] = { enable = true, ep = 7 }, --'Ragnaros',
            [610] = { enable = true, ep = 7 }, --'Razorgore the Untamed',
            [611] = { enable = true, ep = 7 }, --'Vaelastrasz the Corrupt',
            [612] = { enable = true, ep = 7 }, --'Broodlord Lashlayer',
            [613] = { enable = true, ep = 7 }, --'Firemaw',
            [614] = { enable = true, ep = 7 }, --'Ebonroc',
            [615] = { enable = true, ep = 7 }, --'Flamegor',
            [616] = { enable = true, ep = 7 }, --'Chromaggus',
            [617] = { enable = true, ep = 10 }, --'Nefarian',
            [718] = { enable = true, ep = 3 }, --'Kurinnaxx',
            [719] = { enable = true, ep = 3 }, --'General Rajaxx',
            [720] = { enable = true, ep = 3 }, --'Moam',
            [721] = { enable = true, ep = 3 }, --'Buru the Gorger',
            [722] = { enable = true, ep = 3 }, --'Ayamiss the Hunter',
            [723] = { enable = true, ep = 4 }, --'Ossirian the Unscarred',
            [709] = { enable = true, ep = 10 }, --'The Prophet Skeram',
            [710] = { enable = true, ep = 10 }, --'The Silithid Royalty',
            [711] = { enable = true, ep = 10 }, --'Battleguard Sartura',
            [712] = { enable = true, ep = 10 }, --'Fankriss the Unyielding',
            [713] = { enable = true, ep = 10 }, --'Viscidus',
            [714] = { enable = true, ep = 10 }, --'Princess Huhuran',
            [715] = { enable = true, ep = 10 }, --'The Twin Emperors',
            [716] = { enable = true, ep = 10 }, --'Ouro',
            [717] = { enable = true, ep = 12 }, --'C'Thun',
            [1084] = { enable = true, ep = 5 }, --'Onyxia',
            [1107] = { enable = true, ep = 12 }, --'Anub'Rekhan',
            [1110] = { enable = true, ep = 12 }, --'Grand Widow Faerlina',
            [1116] = { enable = true, ep = 12 }, --'Maexxna',
            [1117] = { enable = true, ep = 12 }, --'Noth the Plaguebringer',
            [1112] = { enable = true, ep = 12 }, --'Heigan the Unclean',
            [1115] = { enable = true, ep = 15 }, --'Loatheb',
            [1113] = { enable = true, ep = 12 }, --'Instructor Razuvious',
            [1109] = { enable = true, ep = 12 }, --'Gothik the Harvester',
            [1121] = { enable = true, ep = 15 }, --'The Four Horsemen',
            [1118] = { enable = true, ep = 12 }, --'Patchwerk',
            [1111] = { enable = true, ep = 12 }, --'Grobbulus',
            [1108] = { enable = true, ep = 12 }, --'Gluth',
            [1120] = { enable = true, ep = 15 }, --'Thaddius',
            [1119] = { enable = true, ep = 15 }, --'Sapphiron',
            [1114] = { enable = true, ep = 15 }, --'Kel'Thuzad'
        },
        raid = {
            speedrun = false,
            reserve = {},
        },
        frames = {},
    },
};

ExG.options = {
    type = 'group',
    name = L['ExG'],
    handler = ExG,
    args = {
        general = {
            type = 'group',
            name = L['General'],
            order = 0,
            args = {
                baseEP = {
                    type = 'input',
                    name = L['Base EP'],
                    order = 0,
                    validate = isNumber,
                    get = function() return tostring(store().baseEP); end,
                    set = function(_, value) store().baseEP = tonumber(value); end,
                },
                baseGP = {
                    type = 'input',
                    name = L['Base GP'],
                    order = 10,
                    validate = isNumber,
                    get = function() return tostring(store().baseGP); end,
                    set = function(_, value) store().baseGP = tonumber(value); end,
                },
                showGp = {
                    type = 'toggle',
                    name = L['ExG Show GP'],
                    order = 15,
                    width = 'full',
                    get = function() return store().showGp; end,
                    set = function(_, value) store().showGp = value; end,
                },
                channel = {
                    type = 'select',
                    name = '',
                    order = 16,
                    width = 0.7,
                    style = 'dropdown',
                    values = { RAID = L['RAID'], GUILD = L['GUILD'], OFFICER = L['OFFICER'], },
                    get = function() return store().channel; end,
                    set = function(_, value) store().channel = value; end,
                },
                channelDesc = {
                    type = 'description',
                    name = L['Report channel for EPGP events'],
                    order = 17,
                    width = 1.7,
                },
                shareHeader = {
                    type = 'header',
                    name = L['Share Options'],
                    order = 60,
                },
                filter = {
                    type = 'select',
                    name = '',
                    order = 61,
                    width = 0.7,
                    style = 'dropdown',
                    values = function() local res = {}; for i = 1, GuildControlGetNumRanks() do res[i - 1] = format('%s #%d', GuildControlGetRankName(i), i - 1); end return res; end,
                    get = function() return store().optionFilter; end,
                    set = function(_, value) store().optionFilter = value; end,
                },
                filterDesc = {
                    type = 'description',
                    name = L['Accept option share from this rank and above'],
                    order = 62,
                    width = 1.7,
                },
                shareGuild = {
                    type = 'execute',
                    name = L['Share Options Guild'],
                    order = 67,
                    func = function() ExG:OptionsShare(ExG.messages.guild); end,
                },
                shareRaid = {
                    type = 'execute',
                    name = L['Share Options Raid'],
                    order = 68,
                    func = function() ExG:OptionsShare(ExG.messages.raid); end,
                },
                shareFiller = {
                    type = 'description',
                    name = '',
                    order = 69,
                    width = 'full',
                },
                debugHeader = {
                    type = 'header',
                    name = L['ExG Debug'],
                    order = 70,
                },
                debug = {
                    type = 'toggle',
                    name = L['ExG Debug'],
                    order = 71,
                    disabled = true;
                    get = function() return store().debug; end,
                    set = function(_, value) store().debug = value; end,
                },
                debugFiller = {
                    type = 'description',
                    name = L['ExG Debug Desc'],
                    order = 72,
                    width = 'full',
                },
            },
        },
        items = {
            type = 'group',
            name = L['ExG Items'],
            order = 10,
            args = {
                openItems = {
                    type = 'execute',
                    name = L['Open Items Settings'],
                    order = 0,
                    width = 'full',
                    func = function() ExG.ItemsFrame:Show(); end,
                },
                itemsHeader1 = {
                    type = 'header',
                    name = L['Items Loot Settings'],
                    order = 10,
                },
                threshold = {
                    type = 'select',
                    name = L['Loot Threshold'],
                    order = 11,
                    width = 0.5,
                    style = 'dropdown',
                    values = { [2] = L['Uncommon'], [3] = L['Rare'], [4] = L['Epic'], [5] = L['Legendary'], [6] = L['Artifact'], },
                    get = function() return store().items.threshold; end,
                    set = function(_, value) store().items.threshold = value; end,
                },
                thresholdDesc = {
                    type = 'description',
                    name = L['Loot Threshold Desc'],
                    order = 12,
                    width = 1.7,
                },
                closeOnPass = {
                    type = 'toggle',
                    name = L['Close item on pass'],
                    order = 20,
                    width = 1.2,
                    get = function() return store().items.closeOnPass; end,
                    set = function(_, value) store().items.closeOnPass = value; end,
                },
                closeOnPassFiller = {
                    type = 'description',
                    name = '',
                    order = 21,
                    width = 'full',
                },
                passTimer = {
                    type = 'input',
                    name = L['Autopass timer'],
                    order = 22,
                    validate = isNumber,
                    width = 1.2,
                    get = function() return tostring(store().items.passTimer); end,
                    set = function(_, value) store().items.passTimer = tonumber(value); end,
                },
                passTimerFiller = {
                    type = 'description',
                    name = '',
                    order = 23,
                    width = 'full',
                },
                itemsHeader2 = {
                    type = 'header',
                    name = L['Items Formula'],
                    order = 120,
                },
                itemsFormula = {
                    type = 'description',
                    name = L['Items Formula Desc'],
                    order = 121,
                    width = 'full',
                },
                itemsHeader3 = {
                    type = 'header',
                    name = L['Items Formula Coef'],
                    order = 130,
                },
                itemsCoef = items.type(131, 'coef'),
                itemsFiller1 = items.filler(132),
                itemsBase = items.type(133, 'base'),
                itemsFiller2 = items.filler(134),
                itemsMod = items.type(135, 'mod'),
                itemsFiller3 = items.filler(136, 'full'),
                itemsHead = items.type(137, 'INVTYPE_HEAD'),
                itemsFiller4 = items.filler(138),
                itemsHands = items.type(139, 'INVTYPE_HAND'),
                itemsFiller22 = items.filler(140),
                itemsWeapon1H = items.type(141, 'INVTYPE_WEAPON'),
                itemsFiller25 = items.filler(142),
                itemsShield = items.type(143, 'INVTYPE_SHIELD'),
                itemsFiller6 = items.filler(144, 'full'),
                itemsNeck = items.type(145, 'INVTYPE_NECK'),
                itemsFiller7 = items.filler(146),
                itemsWaist = items.type(147, 'INVTYPE_WAIST'),
                itemsFiller24 = items.filler(148),
                itemsWeapon2H = items.type(149, 'INVTYPE_2HWEAPON'),
                itemsFiller21 = items.filler(150),
                itemsWand = items.type(151, 'INVTYPE_WAND'),
                itemsFiller9 = items.filler(152, 'full'),
                itemsShoulder = items.type(153, 'INVTYPE_SHOULDER'),
                itemsFiller10 = items.filler(154),
                itemsLegs = items.type(155, 'INVTYPE_LEGS'),
                itemsFiller5 = items.filler(156),
                itemsWeaponMH = items.type(157, 'INVTYPE_WEAPONMAINHAND'),
                itemsFiller17 = items.filler(158),
                itemsHoldableOH = items.type(159, 'INVTYPE_HOLDABLE'),
                itemsFiller23 = items.filler(160, 'full'),
                itemsBack = items.type(161, 'INVTYPE_CLOAK'),
                itemsFiller13 = items.filler(162),
                itemsFeet = items.type(163, 'INVTYPE_FEET'),
                itemsFiller8 = items.filler(164),
                itemsWeaponOH = items.type(165, 'INVTYPE_WEAPONOFFHAND'),
                itemsFiller20 = items.filler(166),
                itemsRelic = items.type(167, 'INVTYPE_RELIC'),
                itemsFiller15 = items.filler(168, 'full'),
                itemsChest = items.type(169, 'INVTYPE_CHEST'),
                itemsFiller16 = items.filler(170),
                itemsFinger = items.type(171, 'INVTYPE_FINGER'),
                itemsFiller11 = items.filler(172, 0.7),
                itemsThrown = items.type(173, 'INVTYPE_THROWN'),
                itemsFiller18 = items.filler(174, 'full'),
                itemsWrist = items.type(175, 'INVTYPE_WRIST'),
                itemsFiller19 = items.filler(176),
                itemsTrinket = items.type(177, 'INVTYPE_TRINKET'),
                itemsFiller14 = items.filler(178, 0.7),
                itemsRanged = items.type(179, 'INVTYPE_RANGED'),
                itemsFiller12 = items.filler(180, 'full'),
            },
        },
        history = {
            type = 'group',
            name = L['ExG History'],
            order = 20,
            args = {
                openHistory = {
                    type = 'execute',
                    name = L['Open History'],
                    order = 10,
                    width = 'full',
                    func = function() ExG.HistoryFrame:Show(); end,
                },
                historyHeader1 = {
                    type = 'header',
                    name = L['History Common'],
                    order = 20,
                },
                historyPage = {
                    type = 'input',
                    name = L['History page size'],
                    order = 21,
                    validate = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end,
                    get = function() return tostring(store().history.pageSize); end,
                    set = function(_, value) store().history.pageSize = tonumber(value); end,
                },
                historyHeader2 = {
                    type = 'header',
                    name = L['History Pull Header'],
                    order = 30,
                },
                historyPlayer = {
                    type = 'input',
                    name = L['History source player'],
                    order = 31,
                    validate = function(_, value) local info = ExG:GuildInfo(value); if not info then return L['Player must be in guild']; end return true; end,
                    get = function() return store().history.source; end,
                    set = function(_, value) store().history.source = value; end,
                },
                historyOffset = {
                    type = 'input',
                    name = L['History source offset'],
                    order = 32,
                    validate = function(_, value) local tmp = tonumber(value); if not tmp then return L['Value must be a number']; elseif tmp < 1 then return L['Value must be more than X'](0); end return true; end,
                    get = function() return tostring(store().history.offset); end,
                    set = function(_, value) store().history.offset = tonumber(value); end,
                },
                historyExchange = {
                    type = 'execute',
                    name = L['History Pull'],
                    order = 33,
                    disabled = function() return not store().history.source or not store().history.offset; end,
                    func = function() ExG:HistoryPull(); end,
                },
                historyClear = {
                    type = 'execute',
                    name = L['Clear'],
                    order = 34,
                    func = function() ExG:ClearHistory(); end,
                },
                historyHeader3 = {
                    type = 'header',
                    name = L['Import History'],
                    order = 40,
                },
                importHistory = {
                    type = 'execute',
                    name = L['Import'],
                    order = 41,
                    width = 'full',
                    func = function() ExG:ImportHistory(); end,
                },
            },
        },
        buttons = {
            type = 'group',
            name = L['ExG Buttons'],
            order = 30,
            args = {
                count = {
                    type = 'range',
                    name = L['ExG Buttons'],
                    order = 0,
                    min = 2,
                    max = 6,
                    step = 1,
                    get = function() return store().buttons.count; end,
                    set = function(_, value) local btns = store().buttons; btns.count = value; btns.data.button2.enabled = (value > 2); btns.data.button3.enabled = (value > 3); btns.data.button4.enabled = (value > 4); btns.data.button5.enabled = (value > 5); end,
                },
                button1Header = {
                    type = 'header',
                    name = L['Button 1'],
                    order = 10,
                },
                button1Text = {
                    type = 'input',
                    name = L['Button Text'],
                    order = 11,
                    width = 0.7,
                    validate = buttons.validateText,
                    get = buttons.getText('button1'),
                    set = buttons.setText('button1'),
                },
                button1Ratio = {
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 12,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button1'),
                    set = buttons.setRatio('button1'),
                },
                button1Roll = {
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 13,
                    get = buttons.getRoll('button1'),
                    set = buttons.setRoll('button1'),
                },
                button2Header = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'header',
                    name = L['Button 2'],
                    order = 20,
                },
                button2Text = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 21,
                    width = 0.7,
                    validate = buttons.validateText,
                    get = buttons.getText('button2'),
                    set = buttons.setText('button2'),
                },
                button2Ratio = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 22,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button2'),
                    set = buttons.setRatio('button2'),
                },
                button2Roll = {
                    hidden = function() return store().buttons.count < 3 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 23,
                    get = buttons.getRoll('button2'),
                    set = buttons.setRoll('button2'),
                },
                button3Header = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'header',
                    name = L['Button 3'],
                    order = 30
                },
                button3Text = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 31,
                    width = 0.7,
                    validate = buttons.validateText,
                    get = buttons.getText('button3'),
                    set = buttons.setText('button3'),
                },
                button3Ratio = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 32,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button3'),
                    set = buttons.setRatio('button3'),
                },
                button3Roll = {
                    hidden = function() return store().buttons.count < 4 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 33,
                    get = buttons.getRoll('button3'),
                    set = buttons.setRoll('button3'),
                },
                button4Header = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'header',
                    name = L['Button 4'],
                    order = 40
                },
                button4Text = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 41,
                    width = 0.7,
                    validate = buttons.validateText,
                    get = buttons.getText('button4'),
                    set = buttons.setText('button4'),
                },
                button4Ratio = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 42,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button4'),
                    set = buttons.setRatio('button4'),
                },
                button4Roll = {
                    hidden = function() return store().buttons.count < 5 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 43,
                    get = buttons.getRoll('button4'),
                    set = buttons.setRoll('button4'),
                },
                button5Header = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'header',
                    name = L['Button 5'],
                    order = 50
                },
                button5Text = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'input',
                    name = L['Button Text'],
                    order = 51,
                    width = 0.7,
                    validate = buttons.validateText,
                    get = buttons.getText('button5'),
                    set = buttons.setText('button5'),
                },
                button5Ratio = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'input',
                    name = L['Button Ratio'],
                    order = 52,
                    width = 0.5,
                    validate = buttons.validateRatio,
                    get = buttons.getRatio('button5'),
                    set = buttons.setRatio('button5'),
                },
                button5Roll = {
                    hidden = function() return store().buttons.count < 6 or false; end,
                    type = 'toggle',
                    name = L['Button Roll'],
                    order = 53,
                    get = buttons.getRoll('button5'),
                    set = buttons.setRoll('button5'),
                },
                button6Header = {
                    type = 'header',
                    name = L['Button 6'],
                    order = 60
                },
                button6Text = {
                    type = 'input',
                    name = L['Button Text'],
                    order = 61,
                    width = 0.7,
                    validate = buttons.validateText,
                    get = buttons.getText('button6'),
                    set = buttons.setText('button6'),
                },
            },
        },
        bosses = {
            type = 'group',
            name = L['ExG Bosses'],
            order = 40,
            args = {
                mc = {
                    type = 'group',
                    name = L['ExG Bosses MC'],
                    order = 10,
                    args = {
                        header = {
                            type = 'header',
                            name = L['ExG Bosses MC'],
                            order = 10,
                        },
                        boss663enable = bosses.enable(11, 663),
                        boss663bonus = bosses.bonus(12, 663),
                        boss663filler = bosses.filler(13),
                        boss664enable = bosses.enable(21, 664),
                        boss664bonus = bosses.bonus(22, 664),
                        boss664filler = bosses.filler(23),
                        boss665enable = bosses.enable(31, 665),
                        boss665bonus = bosses.bonus(32, 665),
                        boss665filler = bosses.filler(33),
                        boss666enable = bosses.enable(41, 666),
                        boss666bonus = bosses.bonus(42, 666),
                        boss666filler = bosses.filler(43),
                        boss667enable = bosses.enable(51, 667),
                        boss667bonus = bosses.bonus(52, 667),
                        boss667filler = bosses.filler(53),
                        boss668enable = bosses.enable(61, 668),
                        boss668bonus = bosses.bonus(62, 668),
                        boss668filler = bosses.filler(63),
                        boss669enable = bosses.enable(71, 669),
                        boss669bonus = bosses.bonus(72, 669),
                        boss669filler = bosses.filler(73),
                        boss670enable = bosses.enable(81, 670),
                        boss670bonus = bosses.bonus(82, 670),
                        boss670filler = bosses.filler(83),
                        boss671enable = bosses.enable(91, 671),
                        boss671bonus = bosses.bonus(92, 671),
                        boss671filler = bosses.filler(93),
                        boss672enable = bosses.enable(101, 672),
                        boss672bonus = bosses.bonus(102, 672),
                        boss672filler = bosses.filler(103),
                    },
                },
                bwl = {
                    type = 'group',
                    name = L['ExG Bosses BWL'],
                    order = 20,
                    args = {
                        header = {
                            type = 'header',
                            name = L['ExG Bosses BWL'],
                            order = 10,
                        },
                        boss610enable = bosses.enable(11, 610),
                        boss610bonus = bosses.bonus(12, 610),
                        boss610filler = bosses.filler(13),
                        boss611enable = bosses.enable(21, 611),
                        boss611bonus = bosses.bonus(22, 611),
                        boss611filler = bosses.filler(23),
                        boss612enable = bosses.enable(31, 612),
                        boss612bonus = bosses.bonus(32, 612),
                        boss612filler = bosses.filler(33),
                        boss613enable = bosses.enable(41, 613),
                        boss613bonus = bosses.bonus(42, 613),
                        boss613filler = bosses.filler(43),
                        boss614enable = bosses.enable(51, 614),
                        boss614bonus = bosses.bonus(52, 614),
                        boss614filler = bosses.filler(53),
                        boss615enable = bosses.enable(61, 615),
                        boss615bonus = bosses.bonus(62, 615),
                        boss615filler = bosses.filler(63),
                        boss616enable = bosses.enable(71, 616),
                        boss616bonus = bosses.bonus(72, 616),
                        boss616filler = bosses.filler(73),
                        boss617enable = bosses.enable(81, 617),
                        boss617bonus = bosses.bonus(82, 617),
                        boss617filler = bosses.filler(83),
                    },
                },
                zg = {
                    type = 'group',
                    name = L['ExG Bosses ZG'],
                    order = 30,
                    args = {
                        header = {
                            type = 'header',
                            name = L['ExG Bosses ZG'],
                            order = 10,
                        },
                        boss784enable = bosses.enable(11, 784),
                        boss784bonus = bosses.bonus(12, 784),
                        boss784filler = bosses.filler(13),
                        boss785enable = bosses.enable(21, 785),
                        boss785bonus = bosses.bonus(22, 785),
                        boss785filler = bosses.filler(23),
                        boss786enable = bosses.enable(31, 786),
                        boss786bonus = bosses.bonus(32, 786),
                        boss786filler = bosses.filler(33),
                        boss787enable = bosses.enable(41, 787),
                        boss787bonus = bosses.bonus(42, 787),
                        boss787filler = bosses.filler(43),
                        boss788enable = bosses.enable(51, 788),
                        boss788bonus = bosses.bonus(52, 788),
                        boss788filler = bosses.filler(53),
                        boss789enable = bosses.enable(61, 789),
                        boss789bonus = bosses.bonus(62, 789),
                        boss789filler = bosses.filler(63),
                        boss790enable = bosses.enable(71, 790),
                        boss790bonus = bosses.bonus(72, 790),
                        boss790filler = bosses.filler(73),
                        boss791enable = bosses.enable(81, 791),
                        boss791bonus = bosses.bonus(82, 791),
                        boss791filler = bosses.filler(83),
                        boss792enable = bosses.enable(91, 792),
                        boss792bonus = bosses.bonus(92, 792),
                        boss792filler = bosses.filler(93),
                        boss793enable = bosses.enable(101, 793),
                        boss793bonus = bosses.bonus(102, 793),
                        boss793filler = bosses.filler(103),
                    },
                },
                ak20 = {
                    type = 'group',
                    name = L['ExG Bosses AK20'],
                    order = 40,
                    args = {
                        header = {
                            type = 'header',
                            name = L['ExG Bosses AK20'],
                            order = 10,
                        },
                        boss718enable = bosses.enable(11, 718),
                        boss718bonus = bosses.bonus(12, 718),
                        boss718filler = bosses.filler(13),
                        boss719enable = bosses.enable(21, 719),
                        boss719bonus = bosses.bonus(22, 719),
                        boss719filler = bosses.filler(23),
                        boss720enable = bosses.enable(31, 720),
                        boss720bonus = bosses.bonus(32, 720),
                        boss720filler = bosses.filler(33),
                        boss721enable = bosses.enable(41, 721),
                        boss721bonus = bosses.bonus(42, 721),
                        boss721filler = bosses.filler(43),
                        boss722enable = bosses.enable(51, 722),
                        boss722bonus = bosses.bonus(52, 722),
                        boss722filler = bosses.filler(53),
                        boss723enable = bosses.enable(61, 723),
                        boss723bonus = bosses.bonus(62, 723),
                        boss723filler = bosses.filler(63),
                    },
                },
                ak40 = {
                    type = 'group',
                    name = L['ExG Bosses AK40'],
                    order = 50,
                    args = {
                        header = {
                            type = 'header',
                            name = L['ExG Bosses AK40'],
                            order = 10,
                        },
                        boss709enable = bosses.enable(11, 709),
                        boss709bonus = bosses.bonus(12, 709),
                        boss709filler = bosses.filler(13),
                        boss710enable = bosses.enable(21, 710),
                        boss710bonus = bosses.bonus(22, 710),
                        boss710filler = bosses.filler(23),
                        boss711enable = bosses.enable(31, 711),
                        boss711bonus = bosses.bonus(32, 711),
                        boss711filler = bosses.filler(33),
                        boss712enable = bosses.enable(41, 712),
                        boss712bonus = bosses.bonus(42, 712),
                        boss712filler = bosses.filler(43),
                        boss713enable = bosses.enable(51, 713),
                        boss713bonus = bosses.bonus(52, 713),
                        boss713filler = bosses.filler(53),
                        boss714enable = bosses.enable(61, 714),
                        boss714bonus = bosses.bonus(62, 714),
                        boss714filler = bosses.filler(63),
                        boss715enable = bosses.enable(71, 715),
                        boss715bonus = bosses.bonus(72, 715),
                        boss715filler = bosses.filler(73),
                        boss716enable = bosses.enable(81, 716),
                        boss716bonus = bosses.bonus(82, 716),
                        boss716filler = bosses.filler(83),
                        boss717enable = bosses.enable(91, 717),
                        boss717bonus = bosses.bonus(92, 717),
                        boss717filler = bosses.filler(93),
                    },
                },
                naxx = {
                    type = 'group',
                    name = L['ExG Bosses NAXX'],
                    order = 50,
                    args = {
                        header = {
                            type = 'header',
                            name = L['ExG Bosses NAXX'],
                            order = 10,
                        },
                        boss1107enable = bosses.enable(11, 1107),
                        boss1107bonus = bosses.bonus(12, 1107),
                        boss1107filler = bosses.filler(13),
                        boss1110enable = bosses.enable(21, 1110),
                        boss1110bonus = bosses.bonus(22, 1110),
                        boss1110filler = bosses.filler(23),
                        boss1116enable = bosses.enable(31, 1116),
                        boss1116bonus = bosses.bonus(32, 1116),
                        boss1116filler = bosses.filler(33),
                        boss1117enable = bosses.enable(41, 1117),
                        boss1117bonus = bosses.bonus(42, 1117),
                        boss1117filler = bosses.filler(43),
                        boss1112enable = bosses.enable(51, 1112),
                        boss1112bonus = bosses.bonus(52, 1112),
                        boss1112filler = bosses.filler(53),
                        boss1115enable = bosses.enable(61, 1115),
                        boss1115bonus = bosses.bonus(62, 1115),
                        boss1115filler = bosses.filler(63),
                        boss1113enable = bosses.enable(71, 1113),
                        boss1113bonus = bosses.bonus(72, 1113),
                        boss1113filler = bosses.filler(73),
                        boss1109enable = bosses.enable(81, 1109),
                        boss1109bonus = bosses.bonus(82, 1109),
                        boss1109filler = bosses.filler(83),
                        boss1121enable = bosses.enable(91, 1121),
                        boss1121bonus = bosses.bonus(92, 1121),
                        boss1121filler = bosses.filler(93),
                        boss1118enable = bosses.enable(101, 1118),
                        boss1118bonus = bosses.bonus(102, 1118),
                        boss1118filler = bosses.filler(103),
                        boss1111enable = bosses.enable(111, 1111),
                        boss1111bonus = bosses.bonus(112, 1111),
                        boss1111filler = bosses.filler(113),
                        boss1108enable = bosses.enable(121, 1108),
                        boss1108bonus = bosses.bonus(122, 1108),
                        boss1108filler = bosses.filler(123),
                        boss1120enable = bosses.enable(131, 1120),
                        boss1120bonus = bosses.bonus(132, 1120),
                        boss1120filler = bosses.filler(133),
                        boss1119enable = bosses.enable(141, 1119),
                        boss1119bonus = bosses.bonus(142, 1119),
                        boss1119filler = bosses.filler(143),
                        boss1114enable = bosses.enable(151, 1114),
                        boss1114bonus = bosses.bonus(152, 1114),
                        boss1114filler = bosses.filler(153),
                    },
                },
                other = {
                    type = 'group',
                    name = L['ExG Bosses OTHER'],
                    order = 50,
                    args = {
                        header = {
                            type = 'header',
                            name = L['ExG Bosses OTHER'],
                            order = 10,
                        },
                        boss1084enable = bosses.enable(11, 1084),
                        boss1084bonus = bosses.bonus(12, 1084),
                        boss1084filler = bosses.filler(13),
                    },
                },
            },
        },
        raid = {
            type = 'group',
            name = L['ExG Raid'],
            order = 50,
            args = {
                speedrun = {
                    type = 'toggle',
                    name = L['ExG Raid Speedrun'],
                    order = 15,
                    width = 'full',
                    get = function() return store().raid.speedrun; end,
                    set = function(_, value) store().raid.speedrun = value; end,
                },
            },
        },
    }
};

ExG.store = {};

function ExG:HandleChatCommand(input)
    local arg = strlower(input or '');

    if strsub(arg, 1, 4) == 'test' then
        local ids = { strsplit(' ', arg) };

        if #ids == 1 then
            return;
        end

        local items = {};

        for i = 2, #ids do
            items[tonumber(ids[i])] = { count = 1, mode = 'inv', };
        end

        self:AnnounceItems(items);
    elseif arg == 'debug' then
        store().debug = not (store().debug or false);

        self:Print(L['Debug mode'](store().debug));
    elseif arg == 'his' then
        self.HistoryFrame:Show();
    elseif arg == 'inv' then
        self.InventoryFrame:Show();
    elseif arg == 'opts' then
        InterfaceOptionsFrame_OpenToCategory(self.state.options);
        InterfaceOptionsFrame_OpenToCategory(self.state.options);
    elseif arg == 'open' then
        self.RosterFrame:Open();
    else
        self:Print('|cff33ff99', L['Usage:'], '|r');
        self:Print('opts|cff33ff99 - ', L['to open Options frame'], '|r');
        self:Print('open|cff33ff99 - ', L['to open Roster frame'], '|r');
        self:Print('his|cff33ff99 - ', L['to open History frame'], '|r');
        self:Print('inv|cff33ff99 - ', L['to open Inventory Roll frame'], '|r');
    end
end

function ExG:OnInitialize()
    self:TimeOffset();
    self.state.version = GetAddOnMetadata(self.name, 'Version');
    self.state.latestVersion = self.state.version;

    self:RegisterChatCommand('exg', 'HandleChatCommand');

    AceConfig:RegisterOptionsTable('ExGOptions', self.options);
    self.state.options = AceConfigDialog:AddToBlizOptions('ExGOptions', L['ExG']);
    self.store = AceDB:New('ExGStore', self.defaults, true);

    self:RegisterComm(self.messages.prefix.announce, 'handleAnnounceItems');
    self:RegisterComm(self.messages.prefix.accept, 'handleAcceptItem');
    self:RegisterComm(self.messages.prefix.roll, 'handleRollItem');
    self:RegisterComm(self.messages.prefix.distribute, 'handleDistributeItem');
    self:RegisterComm(self.messages.prefix.cancel, 'handleCancelRolls');
    self:RegisterComm(self.messages.prefix.pull, 'handleHistoryPull');
    self:RegisterComm(self.messages.prefix.share, 'handleHistoryShare');
    self:RegisterComm(self.messages.prefix.options, 'handleOptionsShare');
    self:RegisterComm(self.messages.prefix.version, 'handleScanVersions');
    self:RegisterComm(self.messages.prefix.sync, 'handleSync');
    self:RegisterComm(self.messages.prefix.reserve, 'handleReserve');

    self.state.name = UnitName('player');
    self.state.class = select(2, UnitClass('player'));

    self.OptionsFrame:Create();
    self.RosterFrame:Create();
    self.RollFrame:Create();
    self.InventoryFrame:Create();
    self.HistoryFrame:Create();
    self.ItemsFrame:Create();

    self:RegisterEvent('ENCOUNTER_END');
    self:RegisterEvent('LOOT_OPENED');
    self:RegisterEvent('LOOT_CLOSED');

    self:ScheduleTimer('PostInit', 10);

    self:ScheduleTimer('Sync', 20, { type = 'buttons', action = 'request', });
    self:ScheduleTimer('Sync', 22, { type = 'version', action = 'request', version = self.state.version, });
end

function ExG:PostInit()
    local debugTag = store().debug;

    store().debug = false; -- TODO remove after a while
    store().optionFilter = 2; -- TODO remove after a while

    self.state.name = UnitName('player');
    self.state.class = select(2, UnitClass('player'));

    self.store.factionrealm.chars[self.state.name] = self.store.factionrealm.chars[self.state.name] or {};

    local tmp = self.store.factionrealm.chars[self.state.name];
    tmp.name = self.state.name;
    tmp.class = self.state.class;

    GameTooltip:HookScript("OnTooltipSetItem", tooltipGp);
    hooksecurefunc("ChatFrame_OnHyperlinkShow", hyperlinkGp);

    self:Print(format('|cff33ff99Version %s loaded! Server time offset is: %d.%s|r', self.state.version, (self.state.offset or 0) / 60 / 60, debugTag and (' ' .. L['Debug mode'](store().debug)) or ''));
end

function ExG:AnnounceItems(ids)
    local handler = function(id, item)
        return function()
            local info = ExG:ItemInfo(id);

            if not info or not info.id then
                return;
            end

            info.gp = self:CalcGP(info);
            info.count = item.count or 1;
            info.mode = item.mode;

            local data = Serializer:Serialize(info, store().items.data[id] or false);

            if store().debug and not IsInRaid() then
                self:SendCommMessage(self.messages.prefix.announce, data, self.messages.whisper, self.state.name);
            else
                self:SendCommMessage(self.messages.prefix.announce, data, self.messages.raid);
            end
        end
    end;

    for id, item in pairs(ids) do
        local hasOne = self.RollFrame.items[id] and self.RollFrame.items[id].active;
        local ignoreOne = store().items.ignore[id];

        if not hasOne and not ignoreOne then
            local obj = Item:CreateFromItemID(id);
            obj:ContinueOnItemLoad(handler(id, item));
        end
    end
end

function ExG:handleAnnounceItems(_, message, _, sender)
    if not self:IsMl(sender) then
        return;
    end

    local success, item, settings = Serializer:Deserialize(message);

    if not success then
        return
    end

    if store().items.announce and self:IsMl() then
        SendChatMessage(format('ExG: Разыгрывается %s!', item.link), self.messages.raid);
    end

    store().items.data[item.id] = settings;

    self.RollFrame:AddItem(item);
    self.RollFrame:Open();
end

function ExG:AcceptItem(itemId)
    local data = Serializer:Serialize(itemId);

    if store().debug and not IsInRaid() then
        self:SendCommMessage(self.messages.prefix.accept, data, self.messages.whisper, self.state.name);
    else
        self:SendCommMessage(self.messages.prefix.accept, data, self.messages.raid);
    end
end

function ExG:handleAcceptItem(_, message, _, sender)
    local success, itemId = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:AcceptItem(itemId, sender);
end

function ExG:RollItem(item)
    local data = Serializer:Serialize(item);

    if store().debug and not IsInRaid() then
        self:SendCommMessage(self.messages.prefix.roll, data, self.messages.whisper, self.state.name);
    else
        self:SendCommMessage(self.messages.prefix.roll, data, self.messages.raid);
    end
end

function ExG:handleRollItem(_, message, _, sender)
    local success, item = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:RollItem(item, sender);
end

function ExG:DistributeItem(unit, itemId)
    local data = Serializer:Serialize(unit, itemId);

    if store().debug and not IsInRaid() then
        self:SendCommMessage(self.messages.prefix.distribute, data, self.messages.whisper, self.state.name);
    else
        self:SendCommMessage(self.messages.prefix.distribute, data, self.messages.raid);
    end
end

function ExG:handleDistributeItem(_, message, _, sender)
    local success, unit, itemId = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:DistributeItem(unit, itemId);
end

function ExG:CancelRolls()
    if store().debug and not IsInRaid() then
        self:SendCommMessage(self.messages.prefix.cancel, 'cancel', self.messages.whisper, self.state.name);
    else
        self:SendCommMessage(self.messages.prefix.cancel, 'cancel', self.messages.raid);
    end
end

function ExG:handleCancelRolls(_, message, _, sender)
    if not self:IsMl(sender) then
        return;
    end

    self.RollFrame:CancelRolls();
end

function ExG:HistoryPull()
    if not store().history.source or not store().history.offset then
        return;
    end

    self:Print(L['History pulled']({ source = store().history.source, offset = store().history.offset }));

    local data = Serializer:Serialize({ offset = store().history.offset });

    self:SendCommMessage(self.messages.prefix.pull, data, self.messages.whisper, store().history.source);
end

function ExG:handleHistoryPull(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    local res = self:CopyHistory(data);

    self:HistoryShare(res, sender);
end

function ExG:HistoryShare(source, target)
    local data = Serializer:Serialize(source);

    if target then
        self:SendCommMessage(self.messages.prefix.share, data, self.messages.whisper, target);
    else
        self:SendCommMessage(self.messages.prefix.share, data, self.messages.guild);
    end
end

function ExG:handleHistoryShare(_, message, _, sender)
    local success, source = Serializer:Deserialize(message);

    if not success then
        return
    end

    for i, v in pairs(source.data) do
        store().history.data[i] = v;
    end

    if source.count and source.min and source.max then
        self:Print(L['History imported'](source));
    end
end

function ExG:OptionsShare(channel)
    local data = Serializer:Serialize(store().baseEP, store().baseGP, store().optionFilter, store().channel, store().items.threshold, store().items.formula, store().items.data, store().buttons, store().bosses);

    self:Print(L['Options sending'](channel or self.messages.guild));

    self:SendCommMessage(self.messages.prefix.options, data, channel or self.messages.guild, nil, 'NORMAL', function(name, sent, total) if (sent == total) then self:Print(L['Options sent'](channel or self.messages.guild)); end; end);
end

function ExG:handleOptionsShare(_, message, _, sender)
    local success, baseEP, baseGP, optionFilter, channel, itemsThreshold, itemsFormula, itemsData, buttons, bosses = Serializer:Deserialize(message);

    if not success then
        return
    end

    if sender == self.state.name then
        return;
    end

    local info = self:GuildInfo(sender);

    if (info and info.rankId or 99) > store().optionFilter then
        self:Print(L['Options ignored'](sender));

        return;
    end

    self:Print(L['Options received'](sender));

    store().baseEP = baseEP;
    store().baseGP = baseGP;
    store().optionFilter = optionFilter;
    store().channel = channel;
    store().items.threshold = itemsThreshold;
    store().items.formula = itemsFormula;
    store().items.data = itemsData;
    store().buttons = buttons;
    store().bosses = bosses;
end

function ExG:ScanVersions(msg, target)
    local data = Serializer:Serialize(msg);

    if target then
        self:SendCommMessage(self.messages.prefix.version, data, self.messages.whisper, target);
    else
        self:SendCommMessage(self.messages.prefix.version, data, self.messages.raid);
    end
end

function ExG:handleScanVersions(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    if data.event == 'request' then
        self:ScanVersions({ event = 'response', version = self.state.version, }, sender);
    elseif data.event == 'response' then
        self.RosterFrame.VersionDialog:Update({ name = sender, version = data.version, });
    end
end

local syncHandlers = {
    version = function(self, data, sender)
        if data.action == 'request' then
            if self.state.latestVersion > data.version then
                self:Sync({ type = 'version', action = 'response', version = self.state.latestVersion, }, sender);
            elseif self.state.latestVersion < data.version then
                self.state.latestVersion = data.version;

                self:Print(L['New Version available'](self.state.latestVersion));
            end
        elseif data.action == 'response' then
            if self.state.latestVersion < data.version then
                self.state.latestVersion = data.version;

                self:Print(L['New Version available'](self.state.latestVersion));
            end
        end
    end,
    buttons = function(self, data, sender)
        if data.action == 'request' then
            local info = self:GuildInfo();

            if (info and info.rankId or 99) > store().optionFilter then
                return;
            end

            self:Sync({ type = 'buttons', action = 'response', buttons = store().buttons, }, sender);
        elseif data.action == 'response' then
            local info = self:GuildInfo(sender);

            if (info and info.rankId or 99) > store().optionFilter then
                return;
            end

            store().buttons = data.buttons;
        end
    end
};

function ExG:Sync(msg, target)
    local data = Serializer:Serialize(msg);

    if target then
        self:SendCommMessage(self.messages.prefix.sync, data, self.messages.whisper, target);
    else
        self:SendCommMessage(self.messages.prefix.sync, data, self.messages.guild);
    end
end

function ExG:handleSync(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    if sender == self.state.name then
        return;
    end

    if data.type and syncHandlers[data.type] then
        syncHandlers[data.type](self, data, sender);
    end
end

function ExG:Reserve(msg)
    local data = Serializer:Serialize(msg);

    self:SendCommMessage(self.messages.prefix.reserve, data, self.messages.guild);
end

function ExG:handleReserve(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    if data.action == 'join' and self:IsMl() then
        store().raid.reserve[sender] = true;

        self:Reserve({ action = 'sync', reserve = store().raid.reserve, });
    elseif data.action == 'leave' and self:IsMl() then
        store().raid.reserve[sender] = nil;

        self:Reserve({ action = 'sync', reserve = store().raid.reserve, });
    elseif data.action == 'sync' then
        store().raid.reserve = data.reserve;

        self.RosterFrame:Refresh();
    end
end

function ExG:ENCOUNTER_END(_, id, _, _, _, success)
    if success == 0 then
        return;
    end

    if not self:IsMl() then
        return;
    end

    local boss = store().bosses[id];

    if not (boss and boss.enable) then
        return;
    end

    local dt, offset = ExG:ServerTime(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'boss',
        target = { name = L['ExG History RAID'], class = 'RAID', },
        master = { name = self.state.name, class = self.state.class, },
        desc = L['ExG History Boss End'](L['ExG Boss ' .. id], boss.ep),
        dt = dt,
        details = {},
    };

    local details = {};
    local ignore = {};
    local i = 0;

    for i = 1, MAX_RAID_MEMBERS do
        local name = GetRaidRosterInfo(i);

        if name then
            name = Ambiguate(name, 'all');
            ignore[name] = true;

            local info = self:GuildInfo(name);

            if info then
                local st = dt + i / 1000;
                local old = self:GetEG(info.officerNote);
                local new = self:SetEG(info, old.ep + boss.ep, old.gp);

                details[st] = {
                    target = { name = info.name, class = info.class, },
                    ep = { before = old.ep, after = new.ep, },
                    dt = st,
                };
            end
        end
    end

    for name, v in pairs(store().raid.reserve) do
        i = i + 1;

        local info = self:GuildInfo(name);

        if v and info and (not ignore[name]) then
            local st = dt + i / 1000;
            local old = self:GetEG(info.officerNote);
            local new = self:SetEG(info, old.ep + boss.ep, old.gp);

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, },
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    self:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    self:Report(L['ExG Report Boss'](L['ExG Boss ' .. id], boss.ep));
end

function ExG:LOOT_OPENED()
    self.state.looting = true;

    if store().raid.speedrun then
        return;
    end

    if not self:IsMl() then
        return;
    end

    local ids = {};

    for i = 1, GetNumLootItems() do
        if LootSlotHasItem(i) then
            local info = self:LinkInfo(GetLootSlotLink(i));

            if info then
                local itemData = store().items.data[info.id];

                if info.rarity >= store().items.threshold or itemData then
                    ids[info.id] = (ids[info.id] or { count = 0, mode = 'loot', });
                    ids[info.id].count = ids[info.id].count + 1;
                end
            end
        end
    end

    if self:Size(ids) == 0 then
        return;
    end

    self:AnnounceItems(ids);
end

function ExG:LOOT_CLOSED()
    self.state.looting = false;
end
