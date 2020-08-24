local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local store = function() return ExG.store.char; end;

ExG.DecayFrame = {
    frame = nil,
};

local function makeFrame(self)
    self.amount = AceGUI:Create('EditBox');
    self.amount:DisableButton(true);
    self.amount:SetWidth(120);
    self.amount:SetHeight(25);
    self.amount:SetLabel(L['Percent']);
    self.frame:AddChild(self.amount);

    self.amount:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 5, -30);
    self.amount:SetPoint('RIGHT', self.frame.frame, 'RIGHT', -5, 0);

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

function ExG.DecayFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(self.unit);
    self.frame:SetLayout(nil);
    self.frame:EnableResize(false);
    self.frame:SetWidth(300);
    self.frame:SetHeight(107);
    self.frame:SetCallback('OnClose', function() self.frame:Hide(); end);
    self.frame:Hide();

    makeFrame(self);
end

function ExG.DecayFrame:Show()
    self.frame:SetTitle(L['Guild Decay']);

    self.frame:Show();
end

function ExG.DecayFrame:Hide()
    self.frame:Hide();
end

function ExG.DecayFrame:Adjust()
    local decay = tonumber(self.amount:GetText());

    if not decay then
        return;
    end

    decay = 1 - decay / 100;

    local dt, offset = time(), 0;

    while store().history.data[dt + offset / 1000] do
        offset = offset + 1;
    end

    dt = dt + offset / 1000;

    store().history.data[dt] = {
        type = 'guild',
        target = { name = L['ExG History GUILD'], class = 'GUILD', },
        master = { name = ExG.state.name, class = ExG.state.class, },
        desc = L['Guild Decay Desc'](store().mass.decay);
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
            local new = ExG:SetEG(info, floor(old.ep * decay), floor(old.gp * decay));

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

    self:Hide();
end
