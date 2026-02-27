local Opacity = avUI:NewModule("avUI.Nameplates.Opacity", "AceHook-3.0", "AceEvent-3.0")

function Opacity:OnInitialize()
end

local function AdjustTargetOpacity(nameplate)
    if not nameplate or not nameplate.unitToken or not nameplate.UnitFrame then
        return
    end

    local unit = nameplate.unitToken
    local frame = nameplate.UnitFrame

    if UnitExists("target") and not UnitIsDeadOrGhost("target") then
        if UnitIsUnit(unit, "target") then
            frame:SetAlpha(1)
        else
            frame:SetAlpha(0.80)
        end
    else
        frame:SetAlpha(1)
    end
end

local function AdjustTargetOpacityUnit(event, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)

    AdjustTargetOpacity(nameplate)
end

local function ResetTargetOpacity()
    local nameplates = C_NamePlate.GetNamePlates()

    for _, nameplate in ipairs(nameplates) do
        AdjustTargetOpacity(nameplate)
    end
end

function Opacity:OnEnable()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", AdjustTargetOpacityUnit)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", ResetTargetOpacity)
end

function Opacity:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
