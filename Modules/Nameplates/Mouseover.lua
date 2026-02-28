local Mouseover = avUI:NewModule("avUI.Nameplates.Mouseover", "AceHook-3.0", "AceEvent-3.0")

local mouseovers = {}

function Mouseover:OnInitialize()
end

local function AddMouseoverFor(event, unit)
    local function AnchorFrameTo(frame, nameplate)
        frame:SetPoint("TOPLEFT", nameplate, "TOPLEFT", 0, 0)
        frame:SetPoint("BOTTOMRIGHT", nameplate, "BOTTOMRIGHT", 0, 0)
    end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)

    if not nameplate then
        return
    end

    local mouseover = mouseovers[unit]

    if not mouseover then
        local frame = CreateFrame("Frame", nil, UIParent)
        AnchorFrameTo(frame, nameplate)
        frame:SetFrameLevel(100)
        frame:EnableMouse(false)
        frame:Hide()

        local tex = frame:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(frame)
        tex:SetAtlas("UI-HUD-Nameplates-TargetedByEnemy")
        tex:SetVertexColor(1, 1, 0, 1) -- yellow tint

        mouseovers[unit] = frame
    else
        mouseover:ClearAllPoints()
        AnchorFrameTo(mouseover, nameplate)
    end
end

local function RemoveMouseoverFor(event, unit)
    local frame = mouseovers[unit]

    if not frame then
        return
    end

    frame:Hide()
    frame:ClearAllPoints()
end

function Mouseover:OnEnable()
    local currentMouseoverUnit = nil

    local function ShowMouseover(unit)
        if mouseovers[unit] then
            mouseovers[unit]:Show()
        end
    end

    local function AddMouseover(unit)
        Mouseover:AddMouseoverFor(unit)

        if UnitIsUnit(unit, "mouseover") then
            ShowMouseover(unit)
        end
    end

    local function HideMouseover(unit)
        if mouseovers[unit] then
            mouseovers[unit]:Hide()
        end
    end

    local function UpdateMouseover()
        if currentMouseoverUnit then
            HideMouseover(currentMouseoverUnit)
            currentMouseoverUnit = nil
        end

        local unit = "mouseover"

        if UnitExists(unit) then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)

            if nameplate and nameplate.unitToken then
                ShowMouseover(nameplate.unitToken)
                currentMouseoverUnit = nameplate.unitToken
            end
        end
    end

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", AddMouseoverFor)
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", RemoveMouseoverFor)
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", UpdateMouseover)

    self.ticker = C_Timer.NewTicker(0.05, UpdateMouseover)
end

function Mouseover:OnDisable()
    self.ticker:Cancel()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
