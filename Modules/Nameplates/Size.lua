local Size = avUI:NewModule("avUI.Nameplates.Size", "AceHook-3.0", "AceEvent-3.0")

function Size:OnInitialize()
end

local function AdjustNameplateSize(nameplate)
    if not nameplate then
        return
    end

    local frame = nameplate.UnitFrame and nameplate.UnitFrame.HealthBarsContainer

    if not frame or frame:IsForbidden() then
        return
    end

    frame:SetHeight(10)
end

local function AdjustNameplateSizeUnit(unit)
    local nameplate = nameplate or C_NamePlate.GetNamePlateForUnit(unit)

    if not nameplate then
        return
    end

    AdjustNameplateSize(nameplate)
end

local function AdjustAllNameplateSizes()
    local nameplates = C_NamePlate.GetNamePlates()

    for _, nameplate in ipairs(nameplates) do
        AdjustNameplateSize(nameplate)
    end
end

local function OnNameplateAdded(event, unit)
    AdjustNameplateSizeUnit(unit)
end

local function OnUpdateAnchors()
    AdjustAllNameplateSizes()
end

function Size:OnEnable()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", OnNameplateAdded)

    self:SecureHook(NamePlateUnitFrameMixin, "UpdateAnchors", OnUpdateAnchors)
end

function Size:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
