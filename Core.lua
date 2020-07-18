ExG = LibStub('AceAddon-3.0'):NewAddon('ExG', 'AceConsole-3.0', 'AceEvent-3.0', 'AceComm-3.0', 'AceTimer-3.0');

local AceConfig = LibStub('AceConfig-3.0');
local AceConfigDialog = LibStub('AceConfigDialog-3.0');
local AceDB = LibStub('AceDB-3.0');
local Serializer = LibStub('AceSerializer-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

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
        return function() return store().buttons[btnId].text; end;
    end,
    setText = function(btnId)
        return function(_, value) store().buttons[btnId].text = value; end;
    end,
    validateRatio = function(_, value)
        if not tonumber(value) then
            return L['Value must be a number'];
        end
        return true;
    end,
    getRatio = function(btnId)
        return function() return tostring(store().buttons[btnId].ratio); end;
    end,
    setRatio = function(btnId)
        return function(_, value) store().buttons[btnId].ratio = tonumber(value); end;
    end,
    getRoll = function(btnId)
        return function() return store().buttons[btnId].roll; end;
    end,
    setRoll = function(btnId)
        return function(_, value) store().buttons[btnId].roll = value; end;
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
}

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
            width = 0.2,
            validate = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end,
            get = function() return tostring(store().bosses[id].ep); end,
            set = function(_, value) store().bosses[id].ep = tonumber(value); end,
        };
    end,
}

ExG.messages = {
    prefix = {
        announce = 'ExG_Announce',
        accept = 'ExG_Accept',
        roll = 'ExG_Roll',
        pull = 'ExG_Pull',
        share = 'ExG_Share',
    },
    raid = 'RAID',
    warning = 'RAID_WARNING',
    guild = 'GUILD',
    whisper = 'WHISPER',
};

ExG.state = {
    name = '',
    class = '',
    looting = false,
    options = nil,
};

ExG.defaults = {
    factionrealm = {
        chars = {},
    },
    char = {
        baseEP = 10,
        baseGP = 10,
        debug = false,
        items = {
            pageSize = 50,
            formula = {
                coef = 7,
                base = 1.5,
                mod = 1,
                head = 0.85,
                neck = 0.75,
                shoulder = 0.75,
                back = 0.75,
                chest = 0.9,
                wrist = 0.75,
                hands = 0.75,
                waist = 0.75,
                legs = 0.9,
                feet = 0.75,
                finger = 0.75,
                trinket = 0.75,
                weaponMH = 1.5,
                weaponOH = 1.3,
                holdableOH = 0.7,
                weapon1H = 1.5,
                weapon2H = 1.8,
                shield = 0.7,
                wand = 0.5,
                ranged = 0.6,
                relic = 0.5,
                thrown = 0.6,
            },
            data = {},
        },
        buttons = {
            count = 2,
            button1 = { enabled = true, id = 'button1', text = 'need', ratio = 1, roll = false },
            button2 = { enabled = false, id = 'button2', text = 'greed', ratio = 0.5, roll = false },
            button3 = { enabled = false, id = 'button3', text = 'offspec', ratio = 0.3, roll = false },
            button4 = { enabled = false, id = 'button4', text = 'gold', ratio = 0, roll = true },
            button5 = { enabled = false, id = 'button5', text = 'free', ratio = 0, roll = true },
            button6 = { enabled = true, id = 'button6', text = 'pass', ratio = 0, roll = false },
        },
        history = {
            pageSize = 50,
            offset = 1,
            source = nil,
            data = {},
            bak = {},
        },
        bosses = {
            [784] = { enable = true, ep = 2 }, --"High Priest Venoxis",
            [785] = { enable = true, ep = 2 }, --"High Priestess Jeklik"
            [786] = { enable = true, ep = 2 }, --"High Priestess Mar'li",
            [787] = { enable = true, ep = 2 }, --"Bloodlord Mandokir",
            [788] = { enable = true, ep = 2 }, --"Edge of Madness",
            [789] = { enable = true, ep = 2 }, --"High Priest Thekal",
            [790] = { enable = true, ep = 2 }, --"Gahz'ranka",
            [791] = { enable = true, ep = 2 }, --"High Priestess Arlokk",
            [792] = { enable = true, ep = 2 }, --"Jin'do the Hexxer",
            [793] = { enable = true, ep = 3 }, --"Hakkar",
            [663] = { enable = true, ep = 5 }, --"Lucifron",
            [664] = { enable = true, ep = 5 }, --"Magmadar",
            [665] = { enable = true, ep = 5 }, --"Gehennas",
            [666] = { enable = true, ep = 5 }, --"Garr",
            [667] = { enable = true, ep = 5 }, --"Shazzrah",
            [668] = { enable = true, ep = 5 }, --"Baron Geddon",
            [669] = { enable = true, ep = 5 }, --"Sulfuron Harbinger",
            [670] = { enable = true, ep = 5 }, --"Golemagg the Incinerator",
            [671] = { enable = true, ep = 5 }, --"Majordomo Executus",
            [672] = { enable = true, ep = 7 }, --"Ragnaros",
            [610] = { enable = true, ep = 7 }, --"Razorgore the Untamed",
            [611] = { enable = true, ep = 7 }, --"Vaelastrasz the Corrupt",
            [612] = { enable = true, ep = 7 }, --"Broodlord Lashlayer",
            [613] = { enable = true, ep = 7 }, --"Firemaw",
            [614] = { enable = true, ep = 7 }, --"Ebonroc",
            [615] = { enable = true, ep = 7 }, --"Flamegor",
            [616] = { enable = true, ep = 7 }, --"Chromaggus",
            [617] = { enable = true, ep = 10 }, --"Nefarian",
            [718] = { enable = true, ep = 3 }, --"Kurinnaxx",
            [719] = { enable = true, ep = 3 }, --"General Rajaxx",
            [720] = { enable = true, ep = 3 }, --"Moam",
            [721] = { enable = true, ep = 3 }, --"Buru the Gorger",
            [722] = { enable = true, ep = 3 }, --"Ayamiss the Hunter",
            [723] = { enable = true, ep = 4 }, --"Ossirian the Unscarred",
            [709] = { enable = true, ep = 10 }, --"The Prophet Skeram",
            [710] = { enable = true, ep = 10 }, --"The Silithid Royalty",
            [711] = { enable = true, ep = 10 }, --"Battleguard Sartura",
            [712] = { enable = true, ep = 10 }, --"Fankriss the Unyielding",
            [713] = { enable = true, ep = 10 }, --"Viscidus",
            [714] = { enable = true, ep = 10 }, --"Princess Huhuran",
            [715] = { enable = true, ep = 10 }, --"The Twin Emperors",
            [716] = { enable = true, ep = 10 }, --"Ouro",
            [717] = { enable = true, ep = 12 }, --"C'Thun",
            [1084] = { enable = true, ep = 5 }, --"Onyxia",
            [1107] = { enable = true, ep = 12 }, --"Anub'Rekhan",
            [1110] = { enable = true, ep = 12 }, --"Grand Widow Faerlina",
            [1116] = { enable = true, ep = 12 }, --"Maexxna",
            [1117] = { enable = true, ep = 12 }, --"Noth the Plaguebringer",
            [1112] = { enable = true, ep = 12 }, --"Heigan the Unclean",
            [1115] = { enable = true, ep = 15 }, --"Loatheb",
            [1113] = { enable = true, ep = 12 }, --"Instructor Razuvious",
            [1109] = { enable = true, ep = 12 }, --"Gothik the Harvester",
            [1121] = { enable = true, ep = 15 }, --"The Four Horsemen",
            [1118] = { enable = true, ep = 12 }, --"Patchwerk",
            [1111] = { enable = true, ep = 12 }, --"Grobbulus",
            [1108] = { enable = true, ep = 12 }, --"Gluth",
            [1120] = { enable = true, ep = 15 }, --"Thaddius",
            [1119] = { enable = true, ep = 15 }, --"Sapphiron",
            [1114] = { enable = true, ep = 15 }, --"Kel'Thuzad"
        },
    },
};

ExG.options = {
    type = 'group',
    name = L['ExG'],
    handler = ExG,
    args = {
        general = {
            type = 'group',
            name = L['ExG General'],
            order = 0,
            args = {
                baseEP = {
                    type = 'input',
                    name = L['ExG BaseEP'],
                    order = 0,
                    validate = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end,
                    get = function() return tostring(store().baseEP); end,
                    set = function(_, value) store().baseEP = tonumber(value); end,
                },
                baseGP = {
                    type = 'input',
                    name = L['ExG BaseGP'],
                    order = 10,
                    validate = function(_, value) if not tonumber(value) then return L['Value must be a number']; end return true; end,
                    get = function() return tostring(store().baseGP); end,
                    set = function(_, value) store().baseGP = tonumber(value); end,
                },
                debug = {
                    type = 'toggle',
                    name = L['ExG Debug'],
                    order = 70,
                    get = function() return store().debug; end,
                    set = function(_, value) store().debug = value; end,
                },
                debugFiller = {
                    type = 'description',
                    name = L['ExG Debug Desc'],
                    order = 71,
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
                    name = L['Items Formula'],
                    order = 10,
                },
                itemsFormula = {
                    type = 'description',
                    name = L['Items Formula Desc'],
                    order = 20,
                    width = 'full',
                },
                itemsHeader2 = {
                    type = 'header',
                    name = L['Items Formula Coef'],
                    order = 30,
                },
                itemsCoef = items.type(31, 'coef'),
                itemsFiller1 = items.filler(32),
                itemsBase = items.type(33, 'base'),
                itemsFiller2 = items.filler(34),
                itemsMod = items.type(35, 'mod'),
                itemsFiller3 = items.filler(36, 'full'),
                itemsHead = items.type(37, 'head'),
                itemsFiller4 = items.filler(38),
                itemsHands = items.type(39, 'hands'),
                itemsFiller22 = items.filler(40),
                itemsWeapon1H = items.type(41, 'weapon1H'),
                itemsFiller25 = items.filler(42),
                itemsShield = items.type(43, 'shield'),
                itemsFiller6 = items.filler(44, 'full'),
                itemsNeck = items.type(45, 'neck'),
                itemsFiller7 = items.filler(46),
                itemsWaist = items.type(47, 'waist'),
                itemsFiller24 = items.filler(48),
                itemsWeapon2H = items.type(49, 'weapon2H'),
                itemsFiller21 = items.filler(50),
                itemsWand = items.type(51, 'wand'),
                itemsFiller9 = items.filler(52, 'full'),
                itemsShoulder = items.type(53, 'shoulder'),
                itemsFiller10 = items.filler(54),
                itemsLegs = items.type(55, 'legs'),
                itemsFiller5 = items.filler(56),
                itemsWeaponMH = items.type(57, 'weaponMH'),
                itemsFiller17 = items.filler(58),
                itemsHoldableOH = items.type(59, 'holdableOH'),
                itemsFiller23 = items.filler(60, 'full'),
                itemsBack = items.type(61, 'back'),
                itemsFiller13 = items.filler(62),
                itemsFeet = items.type(63, 'feet'),
                itemsFiller8 = items.filler(64),
                itemsWeaponOH = items.type(65, 'weaponOH'),
                itemsFiller20 = items.filler(66),
                itemsRelic = items.type(67, 'relic'),
                itemsFiller15 = items.filler(68, 'full'),
                itemsChest = items.type(69, 'chest'),
                itemsFiller16 = items.filler(70),
                itemsFinger = items.type(71, 'finger'),
                itemsFiller11 = items.filler(72, 0.7),
                itemsThrown = items.type(73, 'thrown'),
                itemsFiller18 = items.filler(74, 'full'),
                itemsWrist = items.type(75, 'wrist'),
                itemsFiller19 = items.filler(76),
                itemsTrinket = items.type(77, 'trinket'),
                itemsFiller14 = items.filler(78, 0.7),
                itemsRanged = items.type(79, 'ranged'),
                itemsFiller12 = items.filler(80, 'full'),
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
                    set = function(_, value) local btns = store().buttons; btns.count = value; btns.button2.enabled = (value > 2); btns.button3.enabled = (value > 3); btns.button4.enabled = (value > 4); btns.button5.enabled = (value > 5); end,
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
                    },
                },
            },
        },
    }
};

ExG.store = {};

function ExG:HandleChatCommand(input)
    local arg = strlower(input or '');

    if arg == 'ony' then
        self:ENCOUNTER_END(0, 1084, 0, 0, 0, true)
    elseif arg == 'announce' then
        local tmp1 = self:ItemInfo(GetInventoryItemLink('player', 1));
        tmp1.buttons = self:ItemOptions(tmp1);
        tmp1.gp = self:ItemGP(tmp1);
        local tmp2 = self:ItemInfo(GetInventoryItemLink('player', 2));
        tmp2.buttons = self:ItemOptions(tmp2);
        tmp2.gp = self:ItemGP(tmp2);

        self:AnnounceItems({ tmp1, tmp2 })
    elseif arg == 'his' then
        self.HistoryFrame:Show();
    elseif arg == 'inv' then
        self.InventoryFrame:Show();
    elseif arg == 'opts' then
        InterfaceOptionsFrame_OpenToCategory(self.state.options);
        InterfaceOptionsFrame_OpenToCategory(self.state.options);
    elseif arg == 'open' then
        self.RosterFrame:Show();
    else
        self:Print('|cff33ff99', L['Usage:'], '|r');
        self:Print('opts|cff33ff99 - ', L['to open Options frame'], '|r');
        self:Print('open|cff33ff99 - ', L['to open Roster frame'], '|r');
    end
end

function ExG:OnInitialize()
    self:RegisterChatCommand('exg', 'HandleChatCommand');

    AceConfig:RegisterOptionsTable('ExGOptions', self.options);
    self.state.options = AceConfigDialog:AddToBlizOptions('ExGOptions', L['ExG']);
    self.store = AceDB:New('ExGStore', self.defaults, true);

    self:RegisterComm(self.messages.prefix.announce, 'handleAnnounceItems');
    self:RegisterComm(self.messages.prefix.roll, 'handleRollItem');
    self:RegisterComm(self.messages.prefix.accept, 'handleAcceptItem');
    self:RegisterComm(self.messages.prefix.pull, 'handleHistoryPull');
    self:RegisterComm(self.messages.prefix.share, 'handleHistoryShare');

    self.state.name = UnitName('player');
    self.state.class = select(2, UnitClass('player'));

    self.RosterFrame:Create();
    self.RollFrame:Create();
    self.InventoryFrame:Create();
    self.HistoryFrame:Create();
    self.ItemsFrame:Create();

    self:RegisterEvent('ENCOUNTER_END');
    self:RegisterEvent('LOOT_OPENED');
    self:RegisterEvent('LOOT_CLOSED');

    self:ScheduleTimer('PostInit', 10);
end

function ExG:PostInit()
    self.state.name = UnitName('player');
    self.state.class = select(2, UnitClass('player'));

    self.store.factionrealm.chars[self.state.name] = self.store.factionrealm.chars[self.state.name] or {};

    local tmp = self.store.factionrealm.chars[self.state.name];
    tmp.name = self.state.name;
    tmp.class = self.state.class;

    local version = GetAddOnMetadata(self.name, 'Version');

    self:Print('|cff33ff99Version ', version, ' loaded!|r');
end

function ExG:AnnounceItems(items)
    local data = Serializer:Serialize(items);

    self:SendCommMessage(self.messages.prefix.announce, data, self.messages.raid);
end

function ExG:handleAnnounceItems(_, message, _, sender)
    if not self:IsMl(sender) then
        return;
    end

    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:AddItems(data);
    self.RollFrame:Show();
end

function ExG:AcceptItem(itemId)
    local data = Serializer:Serialize(itemId);

    self:SendCommMessage(self.messages.prefix.accept, data, self.messages.raid);
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

    self:SendCommMessage(self.messages.prefix.roll, data, self.messages.raid);
end

function ExG:handleRollItem(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    self.RollFrame:RollItem(data, sender);
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

    self:SendCommMessage(self.messages.prefix.share, data, self.messages.whisper, target);
end

function ExG:handleHistoryShare(_, message, _, sender)
    local success, data = Serializer:Deserialize(message);

    if not success then
        return
    end

    for i, v in pairs(data.data) do
        store().history.data[i] = v;
    end

    self:Print(L['History imported'](data));
end

function ExG:ScanLoot()
    local result = {};

    local count = GetNumLootItems();

    for i = 1, count do
        local link = GetLootSlotLink(i);

        if link then
            local tmp = self:ItemInfo(link);

            if tmp.rarity > 3 then
                result[tmp.id] = tmp;
            end
        end
    end

    return result;
end

function ExG:ItemOptions(itemInfo)
    return {
        store().buttons.button1,
        store().buttons.button2,
        store().buttons.button3,
        store().buttons.button4,
        store().buttons.button5,
        store().buttons.button6,
    };
end

function ExG:ItemGP(itemInfo)
    return self:CalcGP(itemInfo);
end

function ExG:ENCOUNTER_END(_, id, _, _, _, success)
    self:Print('ENCOUNTER_END: id = ', id, ', success = ', success);

    if not success then
        return;
    end

    local boss = store().bosses[id];

    local dt = time();

    store().history.data[dt] = {
        type = 'boss',
        target = { name = L['ExG History RAID'], class = 'RAID', },
        master = { name = self.state.name, class = self.state.class, },
        desc = L['ExG History Boss End'](L['ExG Boss ' .. id], boss.ep),
        ep = {},
        gp = {},
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, _, class = GetRaidRosterInfo(i);

        if name then
            name = Ambiguate(name, 'all');

            local st = dt + i / 1000;
            self:Print('st = ', st);

            local info = self:GuildInfo(name);
            local old = self:FromString(info.officerNote);
            local new = self:SetString(info, old.ep + boss.ep, old.gp);

            details[st] = {
                target = { name = name, class = class, },
                desc = L['ExG History Boss End Personal'](L['ExG Boss ' .. id], boss.ep),
                ep = { before = old.ep, after = new.ep, },
                gp = { before = old.gp, after = new.gp, },
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;
end

function ExG:LOOT_OPENED()
    self.state.looting = true;

    if not self:IsInRaid() then
        return;
    end

    self:Print('GetNumLootItems = ' .. GetNumLootItems());

    local links = {};
    local count = GetNumLootItems();

    for i = 1, count do
        self:Print('LOOT_OPENED, ' .. i);

        if LootSlotHasItem(i) then
            local ItemInfo = self:ItemInfo(GetLootSlotLink(i));

            tinsert(links, ItemInfo);
        end
    end

    self:AnnounceItems(links);
end

function ExG:LOOT_CLOSED()
    self.state.looting = false;
end

function ExG:ImportHistory()
    local tmp = {};

    for i, v in pairs(store().history.data) do
        if not v.type == 'old' then
            tmp[i] = v;
        end
    end

    store().history.data = tmp;

    local imported = 0;

    for _, v in ipairs(TRAFFIC) do
        local target = v[1];
        local master = v[2];

        local dt = tonumber(v[9] or 1000);
        local offset = 0;

        while store().history.data[dt + offset / 1000] do
            offset = offset + 1;
        end

        dt = dt + offset / 1000;

        local targetInfo = ExG:GuildInfo(target);
        local masterInfo = ExG:GuildInfo(master);

        store().history.data[dt] = {
            type = 'old',
            target = { name = target, class = targetInfo and targetInfo.class or strupper(target), },
            master = { name = master, class = masterInfo and masterInfo.class or strupper(master), },
            desc = v[3],
            ep = { before = v[4], after = v[5], },
            gp = { before = v[6], after = v[7], },
            link = v[8] or '',
            dt = dt,
        };

        imported = imported + 1;
    end

    self:Print(L['Total imported'](imported));
end

function ExG:CopyHistory(settings)
    local res = {};
    local min, max, count = nil, nil, 0;
    local limit = time() - settings.offset * 86400;

    for i, v in pairs(store().history.data) do
        if (i >= limit) then
            res[i] = v;

            min = math.min(min or i, i);
            max = math.max(max or i, i);
            count = count + 1;
        end
    end

    return { data = res, count = count, min = min, max = max };
end

function ExG:ClearHistory()
    store().history.bak = store().history.data;
    store().history.data = {};
end

