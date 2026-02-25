local Size = avUI:NewModule("avUI.Nameplates.Size", "AceHook-3.0")

Size:Enable()

function Size:OnInitialize()
    self.events = CreateFrame("Frame")
end

local function AdjustNameplateSize(unit, nameplate)
    local plate = nameplate or C_NamePlate.GetNamePlateForUnit(unit)

    if not plate then
        return
    end

    local frame = plate.UnitFrame and plate.UnitFrame.HealthBarsContainer

    if not frame or frame:IsForbidden() then
        return
    end

    frame:SetHeight(10)
end

local function AdjustAllNameplateSizes()
    local nameplates = C_NamePlate.GetNamePlates()

    for _, nameplate in ipairs(nameplates) do
        AdjustNameplateSize(nameplate.unitToken, nameplate)
    end
end

function Size:OnEnable()
    self.events:RegisterEvent("NAME_PLATE_UNIT_ADDED")

    self:SecureHookScript(self.events, "OnEvent", function(_, event, unit)
        if event == "NAME_PLATE_UNIT_ADDED" then
            AdjustNameplateSize(unit)
        end
    end)

    self:SecureHook(NamePlateUnitFrameMixin, "UpdateAnchors", function()
        AdjustAllNameplateSizes()
    end)
end

function Size:OnDisable()
    self.events:UnregisterAllEvents()
    self:UnhookAll()
end
