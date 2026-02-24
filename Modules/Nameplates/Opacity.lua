local Opacity = avUI:NewModule("avUI.Nameplates.Opacity", "AceHook-3.0")

Opacity:Enable()

function Opacity:OnInitialize()
    self.events = CreateFrame("Frame")
end

function Opacity:OnEnable()
    self.events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self.events:RegisterEvent("PLAYER_TARGET_CHANGED")

    self:SecureHookScript(self.events, "OnEvent", function(_, event, unit)
        if event == "NAME_PLATE_UNIT_ADDED" then
            self:AdjustTargetOpacity(unit)
        elseif event == "PLAYER_TARGET_CHANGED" then
            self:ResetTargetOpacity()
        end
    end)
end

function Opacity:OnDisable()
    self.events:UnregisterAllEvents()
    self:UnhookAll()
end

function Opacity:AdjustTargetOpacity(unit, nameplate)
    local nameplate = nameplate or C_NamePlate.GetNamePlateForUnit(unit)

    if not nameplate or not nameplate.unitToken or not nameplate.UnitFrame then
        return
    end

    local unit = nameplate.unitToken
    local frame = nameplate.UnitFrame

    if UnitExists("target") and not UnitIsDeadOrGhost("target") then
        if UnitIsUnit(unit, "target") then
            frame:SetAlpha(1)
        else
            frame:SetAlpha(0.75)
        end
    else
        frame:SetAlpha(1)
    end
end

function Opacity:ResetTargetOpacity()
    local nameplates = C_NamePlate.GetNamePlates()

    for _, nameplate in ipairs(nameplates) do
        self:AdjustTargetOpacity(nameplate.unitToken, nameplate)
    end
end
