local ExG = LibStub('AceAddon-3.0'):GetAddon('ExG');

local AceGUI = LibStub('AceGUI-3.0');
local LSM = LibStub('LibSharedMedia-3.0');
local L = LibStub('AceLocale-3.0'):GetLocale('ExG');

local DEFAULT_FONT = LSM.MediaTable.font[LSM:GetDefault('font')];

ExG.RosterFrame = {
    frame = nil,
    list = nil,
};

function ExG.RosterFrame:Create()
    self.frame = AceGUI:Create('Window');
    self.frame:SetTitle(L['ExG']);
    self.frame:SetLayout(nil);
    --    self.frame:SetCallback('OnClose', function(widget) AceGUI:Release(widget); end)
    self.frame:Hide();

    local group = AceGUI:Create('SimpleGroup');
    group:SetFullWidth(true);
    group:SetFullHeight(true);
    group:SetLayout('Fill');

    self.frame:AddChild(group);

    group:SetPoint('TOPLEFT', self.frame.frame, 'TOPLEFT', 10, -30);
    group:SetPoint('BOTTOMRIGHT', self.frame.frame, 'BOTTOMRIGHT', -10, 30);

    self.list = AceGUI:Create('ScrollFrame');
    self.list:SetFullWidth(true);
    self.list:SetFullHeight(true);
    self.list:SetLayout('List');

    group:AddChild(self.list);
end

function ExG.RosterFrame:Show()
    self.frame:Show();

    self:RenderList();
end

function ExG.RosterFrame:Hide()
    self.frame:Hide();
end

function ExG.RosterFrame:RenderList()
    self.list:ReleaseChildren();

    if not IsInGuild() then
        return;
    end

    local roster = {};

    local ttlMembers = GetNumGuildMembers();

    for i = 1, ttlMembers do
        local name, rank, _, level, classLoc, _, _, offNote, isOnline, _, class = GetGuildRosterInfo(i);

        local eg = ExG:GetEG(offNote);

        tinsert(roster, { name = Ambiguate(name, 'all'), rank = rank, level = level, class = class, classLoc = classLoc, offNote = offNote, isOnline = isOnline, ep = eg.ep, gp = eg.gp });
    end

    sort(roster, function(a, b) return (a.name or '') < (b.name or ''); end);

    for _, v in ipairs(roster) do
        self:RenderItem(v);
    end
end

function ExG.RosterFrame:RenderItem(item)
    local row = AceGUI:Create('SimpleGroup');
    row:SetFullWidth(true);
    row:SetLayout('Flow');

    self.list:AddChild(row);

    local name = AceGUI:Create('InteractiveLabel');
    name:SetFont(DEFAULT_FONT, 12);
    name:SetColor(ExG:ClassColor(item.class));
    name:SetText(item.name);
    name:SetRelativeWidth(0.4);
    name:SetFullHeight(true);
    name:SetHighlight('Interface\\BUTTONS\\UI-Listbox-Highlight.blp')
    name:SetCallback('OnClick', function() end);
    row:AddChild(name);

    local ep = AceGUI:Create('Label');
    ep:SetFont(DEFAULT_FONT, 12);
    ep:SetText(item.ep);
    ep:SetRelativeWidth(0.3);
    ep:SetFullHeight(true);
    row:AddChild(ep);

    local gp = AceGUI:Create('Label');
    gp:SetFont(DEFAULT_FONT, 12);
    gp:SetText(item.gp);
    gp:SetRelativeWidth(0.3);
    gp:SetFullHeight(true);
    row:AddChild(gp);
end

function ExG.RosterFrame:Ajust(player)
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
