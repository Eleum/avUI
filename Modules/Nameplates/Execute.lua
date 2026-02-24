local Execute = avUI:NewModule("avUI.Nameplates.Execute", "AceHook-3.0")

Execute:Enable()

function Execute:OnInitialize()
    self.events = CreateFrame("Frame")
end

local EXECUTE_THRESHOLD = 0.2

-- Curve: outputs 1.0 below execute threshold, 0.0 above
local executeCurve = C_CurveUtil.CreateCurve()
executeCurve:SetType(Enum.LuaCurveType.Step)
executeCurve:ClearPoints()
executeCurve:AddPoint(0.00, 1.0)
executeCurve:AddPoint(EXECUTE_THRESHOLD, 0.0) -- hard drop at threshold
executeCurve:AddPoint(1.00, 0.0) -- clamp to 0 for rest of health range

local plateData = {}

local function UpdatePlate(unit)
    local data = plateData[unit]

    if not data then
        return
    end

    local alpha = UnitHealthPercent(unit, true, executeCurve)
    data.executeBorder:SetAlpha(alpha)
end

local function SetupPlate(unit)
    local function AttachToFrame(frame, anchor)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -4, 4)
        frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
    end

    if not UnitCanAttack("player", unit) then
        return
    end

    local plate = C_NamePlate.GetNamePlateForUnit(unit)

    if not plate then
        return
    end

    local frame = plate.UnitFrame and plate.UnitFrame.HealthBarsContainer

    if not frame then
        return
    end

    if plateData[unit] then
        local border = plateData[unit].executeBorder
        AttachToFrame(border, frame)
        border:Show()
    else
        local border = CreateFrame("Frame", nil, UIParent)
        AttachToFrame(border, frame)
        border:SetAlpha(0) -- hidden by default

        local executeColor = {0, 1, 1, 1} -- cyan color

        local tex = border:CreateTexture(nil, "OVERLAY", nil, 6)
        tex:SetAllPoints(border)
        tex:SetAtlas("UI-HUD-Nameplates-TargetedByEnemy")
        tex:SetVertexColor(unpack(executeColor))

        local tex1 = border:CreateTexture(nil, "OVERLAY", nil, 7)
        tex1:SetPoint("TOPLEFT", border, "TOPLEFT")
        tex1:SetAtlas("icons_16x16_disease", true)
        tex1:SetDesaturation(1) -- remove atlas color
        tex1:SetScale(0.5)
        tex1:SetVertexColor(unpack(executeColor))

        plateData[unit] = {
            executeBorder = border
        }
    end

    UpdatePlate(unit)
end

local function TeardownPlate(unit)
    local data = plateData[unit]

    if not data then
        return
    end

    data.executeBorder:Hide()
end

function Execute:OnEnable()
    self.events:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self.events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self.events:RegisterEvent("UNIT_HEALTH")

    self.events:SetScript("OnEvent", function(self, event, unit)
        if event == "PLAYER_ENTERING_WORLD" then
            wipe(plateData)
            for _, plate in pairs(C_NamePlate.GetNamePlates()) do
                local u = plate.namePlateUnitToken
                if u then
                    SetupPlate(u)
                end
            end
        elseif event == "NAME_PLATE_UNIT_ADDED" then
            SetupPlate(unit)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            TeardownPlate(unit)
        elseif event == "UNIT_HEALTH" then
            if unit and unit:find("nameplate") then
                UpdatePlate(unit)
            end
        end
    end)
end

function Execute:OnDisable()
    self.events:UnregisterAllEvents()
    self:UnhookAll()
end
