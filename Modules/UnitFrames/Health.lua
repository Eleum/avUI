local Health = avUI:NewModule("avUI.UnitFrames.Health", "AceHook-3.0")
local UnitFrames = avUI:GetModule("avUI.UnitFrames")

Health:Disable()

function Health:OnInitialize()
    self.frame = CreateFrame("Frame")
end

function Health:OnEnable()
    self:SecureHook("CompactUnitFrame_UpdateHealPrediction", function(frame)
        self:SetKindaPreciseHealth(frame)
        self:SetAbsorbs(frame)
    end)
    self:SecureHook("CompactUnitFrame_UpdateStatusText", function(frame)
        self:SetKindaPreciseHealth(frame)
    end)

    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    self:HookScript(self.frame, "OnEvent", function(_, event, unit)
        self:UpdateHealth()
    end)

    self:UpdateHealth()
end

function Health:OnDisable()
    self:UnhookAll()
    self:Restore()
end

function Health:UpdateHealth()
    for _, frame in pairs(UnitFrames.frames) do
        local gFrame = _G["Compact" .. frame]

        if gFrame then
            self:SetKindaPreciseHealth(gFrame)
        end
    end
end

function Health:SetKindaPreciseHealth(frame)
    if (not frame) or frame:IsForbidden() or not frame.statusText or not frame.optionTable.displayStatusText or
        not frame.unit or not UnitIsConnected(frame.unit) or not frame.displayedUnit or
        UnitIsDeadOrGhost(frame.displayedUnit) then
        return
    end

    local healthTextOption = C_CVar.GetCVar("raidFramesHealthText")

    if healthTextOption == "perc" and UnitHealthMax(frame.displayedUnit) > 0 then
        local health = UnitHealth(frame.unit)
        local absorb = UnitGetTotalAbsorbs(frame.unit)
        local healAbsorb = UnitGetTotalHealAbsorbs(frame.unit)
        local maxHealth = UnitHealthMax(frame.unit)

        local value = math.ceil((health + absorb - healAbsorb) / maxHealth * 100)

        frame.statusText:SetFormattedText("%d%%", value);
    end
end
