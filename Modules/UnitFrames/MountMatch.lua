local MountMatch = avUI:NewModule("avUI.UnitFrames.MountUp", "AceHook-3.0", "AceEvent-3.0")

local button, icon
local mountTabIdx = 1

local MSQ = LibStub("Masque", true)
local MasqueGroup = MSQ and MSQ:Group("avUI", "Mount Match")

local function GetTargetMountID()
    if not UnitExists("target") or C_Secrets.ShouldAurasBeSecret() then
        return nil
    end

    local mount

    AuraUtil.ForEachAura("target", "HELPFUL", nil, function(aura)
        if aura and aura.spellId then
            mount = C_MountJournal.GetMountFromSpell(aura.spellId)

            if mount then
                return true
            end
        end
    end, true)

    return mount
end

local function UpdateButton()
    local mountID = GetTargetMountID()

    if not mountID then
        button.mountID = nil
        button:Hide()
        return
    end

    local name, _, mountIcon, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

    if not name then
        button.mountID = nil
        button:Hide()
        return
    end

    button.mountID = mountID
    button.mountName = name
    button.isCollected = isCollected

    icon:SetTexture(mountIcon)

    if isCollected then
        icon:SetDesaturated(false)
        icon:SetVertexColor(1, 1, 1)
    else
        icon:SetDesaturated(true)
        icon:SetVertexColor(0.6, 0.6, 0.6)
    end

    button:Show()
end

local function BuildButton()
    button = CreateFrame("Button", "__avuiMountMatchButton", TargetFrame)
    button:SetSize(28, 28)
    button:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", 0, 0)
    button:SetFrameLevel(TargetFrame:GetFrameLevel() + 10)
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    button:Hide()

    icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")

        if self.mountName then
            GameTooltip:SetText(self.mountName, 1, 1, 1)

            if self.isCollected then
                GameTooltip:AddLine("Click to summon this mount.", 0.2, 1, 0.2, true)
            else
                GameTooltip:AddLine("You haven't collected this mount.", 1, 0.4, 0.4, true)
                GameTooltip:AddLine("Click to open the Mount Journal.", 0.9, 0.9, 0.9, true)
            end
        end

        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("OnClick", function(self)
        if not self.mountID then
            return
        end

        if self.isCollected then
            C_MountJournal.SummonByID(self.mountID)
        else
            if not CollectionsJournal or not CollectionsJournal:IsShown() then
                ToggleCollectionsJournal(mountTabIdx)
            else
                CollectionsJournal_SetTab(CollectionsJournal, mountTabIdx)
            end

            if MountJournalSearchBox then
                MountJournalSearchBox:SetText(self.mountName or "")
            end

            if MountJournal_SelectByMountID then
                MountJournal_SelectByMountID(self.mountID)
            end
        end
    end)

    if MasqueGroup then
        MasqueGroup:AddButton(button, {
            Icon = icon,
            Highlight = button:GetHighlightTexture()
        })
    end
end

function MountMatch:OnInitialize()
    if button then
        button:Hide()
        return
    end

    BuildButton()
end

function MountMatch:OnEnable()
    local function UpdateButtonNotPlayer()
        if UnitIsUnit("target", "player") then
            button:Hide()
            return
        end

        if not UnitExists("target") then
            return
        end

        UpdateButton()
    end

    MountMatch:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateButtonNotPlayer)
    MountMatch:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateButtonNotPlayer)
    MountMatch:RegisterEvent("UNIT_AURA", function(_, unit)
        if unit ~= "target" then
            return
        end

        UpdateButtonNotPlayer()
    end)
end

function MountMatch:OnDisable()
    MountMatch:UnregisterAllEvents()
    MountMatch:UnhookAll()
end
