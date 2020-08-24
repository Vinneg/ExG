local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

local function guidEG(self, ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    if (ep or 0) == 0 and (gp or 0) == 0 then
        return;
    end

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'guild',
        target = { name = L['ExG History GUILD'], class = 'GUILD', },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['ExG Guid EG'](ep, gp, desc);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, GetNumGuildMembers() do
        local st = dt + i / 1000;

        local name, _, _, _, _, _, _, officerNote, _, _, class = GetGuildRosterInfo(i);
        local info = { index = i, name = Ambiguate(name, 'all'), class = class, officerNote = officerNote };

        if info.name then
            local old = ExG:GetEG(officerNote);
            local new = ExG:SetEG(info, old.ep + ep, old.gp + gp);

            details[st] = {
                target = { name = info.name, class = info.class, },
                ep = { before = old.ep, after = new.ep, };
                gp = { before = old.gp, after = new.gp, };
                dt = st,
            };
        end
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    self.frame:Hide();
end

local function raidEG(self, ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    if (ep or 0) == 0 and (gp or 0) == 0 then
        return;
    end

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'raid',
        target = { name = L['ExG History RAID'], class = 'RAID', },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['ExG Raid EG'](ep, gp, desc);
        dt = dt,
        details = {},
    };

    local details = {};

    for i = 1, MAX_RAID_MEMBERS do
        local name = GetRaidRosterInfo(i);

        if name then
            local st = dt + i / 1000;

            local info = ExG:GuildInfo(Ambiguate(name, 'all'));

            if info.name then
                local old = ExG:GetEG(info.officerNote);
                local new = ExG:SetEG(info, old.ep + ep, old.gp + gp);

                details[st] = {
                    target = { name = info.name, class = info.class, },
                    ep = { before = old.ep, after = new.ep, };
                    gp = { before = old.gp, after = new.gp, };
                    dt = st,
                };
            end
        end
    end

    store().history.data[dt].details = details;

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    self.frame:Hide();
end

local function unitEG(self, unit, ep, gp, desc)
    ep = (ep or 0);
    gp = (gp or 0);

    local info = ExG:GuildInfo(self.unit);

    if not info then
        return;
    end

    local old = ExG:GetEG(info.officerNote);
    local new, type;

    if ep ~= 0 then
        type = 'EP';
        new = ExG:SetEG(info, old.ep + ep, old.gp);
    elseif gp ~= 0 then
        type = 'GP';
        new = ExG:SetEG(info, old.ep, old.gp + gp);
    end

    if not new then
        return;
    end

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'unit',
        target = { name = unit, class = info.class, },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['Unit Adjust Desc'](type, ep or gp, desc);
        ep = { before = old.ep, after = new.ep, };
        gp = { before = old.gp, after = new.gp, };
        dt = dt,
    };

    ExG:HistoryShare({ data = { [dt] = store().history.data[dt] } });

    self.frame:Hide();
end

ExG.AdjustFrame = {
    frame = nil,
    unit = nil,
};

local function makeFrame(self)
    self.ep = AceGUI:Create('CheckBox');
    self.ep:SetLabel(L['EP']);
    self.ep:SetValue(true);
    self.ep:SetCallback('OnValueChanged', function(value) self.gp:SetValue(not value.checked); end);
    self.frame:AddChild(self.ep);

    self.ep:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -30);
    self.ep:SetPoint('BOTTOMRIGHT', self.frame.frame, 'TOPRIGHT', -5, -50);

    self.gp = AceGUI:Create('CheckBox');
    self.gp:SetLabel(L['GP']);
    self.gp:SetCallback('OnValueChanged', function(value) self.ep:SetValue(not value.checked); end);
    self.frame:AddChild(self.gp);

    self.gp:SetPoint('TOPLEFT', self.ep.frame, 'BOTTOMLEFT', 0, -5);
    self.gp:SetPoint('BOTTOMRIGHT', self.ep.frame, 'BOTTOMRIGHT', 0, -25);

    self.amount = AceGUI:Create('EditBox');
    self.amount:DisableButton(true);
    self.amount:SetWidth(120);
    self.amount:SetHeight(25);
    self.amount:SetLabel(L['Amount']);
    self.frame:AddChild(self.amount);

    self.amount:SetPoint('TOPLEFT', self.gp.frame, 'BOTTOMLEFT', 0, -5);
    self.amount:SetPoint('RIGHT', self.gp.frame, 'RIGHT', 0, 0);

    self.reason = AceGUI:Create('EditBox');
    self.reason:DisableButton(true);
    self.reason:SetWidth(120);
    self.reason:SetHeight(25);
    self.reason:SetLabel(L['Reason']);
    self.frame:AddChild(self.reason);

    self.reason:SetPoint('TOPLEFT', self.amount.frame, 'BOTTOMLEFT', 0, -5);
    self.reason:SetPoint('RIGHT', self.amount.frame, 'RIGHT', 0, 0);

    self.apply = AceGUI:Create('Button');
    self.apply:SetWidth(120);
    self.apply:SetHeight(25);
    self.apply:SetText(L['Ok']);
    self.apply:SetCallback('OnClick', function() self:Adjust(); end);
    self.frame:AddChild(self.apply);

    self.apply:SetPoint('BOTTOMLEFT', self.frame.frame, 'BOTTOMLEFT', 5, 5);
    self.apply:SetPoint('TOPRIGHT', self.frame.frame, 'BOTTOMLEFT', 120, 30);

    self.cancel = AceGUI:Create('Button');
    self.cancel:SetWidth(120);
    self.cancel:SetHeight(25);
    self.cancel:SetText(L['Cancel']);
    self.cancel:SetCallback('OnClick', function() self.frame:Hide(); end);
    self.frame:AddChild(self.cancel);

    self.cancel:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -5, 5);
    self.cancel:SetPoint('TOPLEFT', self.frame.frame, 'BOTTOMRIGHT', -120, 30);
end

function ExG.AdjustFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(self.unit);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(300);
    self.frame:SetHeight(210);
    self.frame:SetCallback('OnClose', function() self.frame:Hide(); end);
    self.frame:Hide();

    makeFrame(self);
end

function ExG.AdjustFrame:Show(unit)
    self.unit = unit;

    if strlower(self.unit) == 'guild' then
        self.frame:SetTitle(L['GUILD']);
    elseif strlower(self.unit) == 'raid' then
        self.frame:SetTitle(L['RAID']);
    else
        self.frame:SetTitle(self.unit);
    end

    self.frame:Show();
end

function ExG.AdjustFrame:Hide()
    self.unit = nil;

    self.frame:Hide();
end

function ExG.AdjustFrame:Adjust()
    if not self.unit then
        return;
    end

    local ep, gp;

    if self.ep:GetValue() then
        ep = tonumber(self.amount:GetText());
    elseif self.gp:GetValue() then
        gp = tonumber(self.amount:GetText());
    end

    local desc = self.reason:GetText();

    if strlower(self.unit) == 'guild' then
        guidEG(self, ep, gp, desc);
    elseif strlower(self.unit) == 'raid' then
        raidEG(self, ep, gp, desc);
    else
        unitEG(self, self.unit, ep, gp, desc);
    end
end
