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

local function UpdateExecuteFrame(unit)
    local data = plateData[unit]

    if not data or not data.executeBorder then
        return
    end

    local alpha = UnitHealthPercent(unit, true, executeCurve)
    data.executeBorder:SetAlpha(alpha)
end

local function AddExecuteFrame(unit)
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

    local border = CreateFrame("Frame", nil, frame)
    AttachToFrame(border, frame)
    border:SetFrameLevel(100)
    border:SetAlpha(0) -- start hidden, will be shown when in execute range

    local executeColor = {1, 0, 0, 1}

    local borderTex = border:CreateTexture(nil, "OVERLAY", nil, 6)
    borderTex:SetAllPoints(border)
    borderTex:SetAtlas("UI-HUD-Nameplates-TargetedByEnemy")
    borderTex:SetVertexColor(unpack(executeColor))

    local executeTex = border:CreateTexture(nil, "OVERLAY", nil, 7)
    executeTex:SetPoint("TOPLEFT", border, "TOPLEFT")
    executeTex:SetAtlas("icons_16x16_disease", true)
    executeTex:SetSize(8, 8)
    executeTex:SetVertexColor(unpack(executeColor))

    plateData[unit] = {
        executeBorder = border
    }

    UpdateExecuteFrame(unit)
end

local function RemoveExecuteFrame(unit)
    local data = plateData[unit]

    if not data or not data.executeBorder then
        return
    end

    data.executeBorder:Hide()
    data.executeBorder = nil
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
                local unit = plate.namePlateUnitToken
                
                if unit then
                    AddExecuteFrame(unit)
                end
            end
        elseif event == "NAME_PLATE_UNIT_ADDED" then
            AddExecuteFrame(unit)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            RemoveExecuteFrame(unit)
        elseif event == "UNIT_HEALTH" then
            if unit and unit:find("nameplate") then
                UpdateExecuteFrame(unit)
            end
        end
    end)
end

function Execute:OnDisable()
    self.events:UnregisterAllEvents()
    self:UnhookAll()
end
