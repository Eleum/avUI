local Mouseover = avUI:NewModule("avUI.Nameplates.Mouseover", "AceHook-3.0")

Mouseover:Enable()

local mouseovers = {}

function Mouseover:OnInitialize()
    self.events = CreateFrame("Frame")
end

local function AddMouseoverFor(unit)
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

local function RemoveMouseoverFor(unit)
    local frame = mouseovers[unit]

    if not frame then
        return
    end

    frame:Hide()
    frame:ClearAllPoints()
end

function Mouseover:OnEnable()
    self.events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self.events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self.events:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

    local lastCheckAt = 0
    local checkIntervalSeconds = 0.05
    local currentMouseoverUnit = nil

    local function AddMouseover(unit)
        Mouseover:AddMouseoverFor(unit)

        if UnitIsUnit(unit, "mouseover") then
            ShowMouseover(unit)
        end
    end

    local function ShowMouseover(unit)
        if mouseovers[unit] then
            mouseovers[unit]:Show()
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

    local function UpdateNoLongerMouseover(elapsed)
        lastCheckAt = lastCheckAt + elapsed

        if lastCheckAt >= checkIntervalSeconds then
            lastCheckAt = 0
            UpdateMouseover()
        end
    end

    self:SecureHookScript(self.events, "OnEvent", function(_, event, unit)
        if event == "NAME_PLATE_UNIT_ADDED" then
            AddMouseoverFor(unit)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            RemoveMouseoverFor(unit)
        elseif event == "UPDATE_MOUSEOVER_UNIT" then
            UpdateMouseover()
        end
    end)

    self:SecureHookScript(self.events, "OnUpdate", function(self, elapsed)
        UpdateNoLongerMouseover(elapsed)
    end)
end

function Mouseover:OnDisable()
    self.events:UnregisterAllEvents()
    self:UnhookAll()
end
