local Health = avUI:NewModule("avUI.UnitFrames.Health", "AceHook-3.0")

Health:Enable()

function Health:OnInitialize()
    Health.frame = CreateFrame("Frame")
    Health.frames = {"PartyFrameMember1", "PartyFrameMember2", "PartyFrameMember3", "PartyFrameMember4",
                     "PartyFrameMember5", "PartyFramePet1", "PartyFramePet2", "PartyFramePet3", "PartyFramePet4",
                     "PartyFramePet5", "RaidFrame1", "RaidFrame2", "RaidFrame3", "RaidFrame4", "RaidFrame5",
                     "RaidFrame6", "RaidFrame7", "RaidFrame8", "RaidFrame9", "RaidFrame10", "RaidFrame11",
                     "RaidFrame12", "RaidFrame13", "RaidFrame14", "RaidFrame15", "RaidFrame16", "RaidFrame17",
                     "RaidFrame18", "RaidFrame19", "RaidFrame20", "RaidFrame21", "RaidFrame22", "RaidFrame23",
                     "RaidFrame24", "RaidFrame25", "RaidFrame26", "RaidFrame27", "RaidFrame28", "RaidFrame29",
                     "RaidFrame30", "RaidFrame31", "RaidFrame32", "RaidFrame33", "RaidFrame34", "RaidFrame35",
                     "RaidFrame36", "RaidFrame37", "RaidFrame38", "RaidFrame39", "RaidFrame40", "RaidGroup1Member1",
                     "RaidGroup1Member2", "RaidGroup1Member3", "RaidGroup1Member4", "RaidGroup1Member5",
                     "RaidGroup2Member1", "RaidGroup2Member2", "RaidGroup2Member3", "RaidGroup2Member4",
                     "RaidGroup2Member5", "RaidGroup3Member1", "RaidGroup3Member2", "RaidGroup3Member3",
                     "RaidGroup3Member4", "RaidGroup3Member5", "RaidGroup4Member1", "RaidGroup4Member2",
                     "RaidGroup4Member3", "RaidGroup4Member4", "RaidGroup4Member5", "RaidGroup5Member1",
                     "RaidGroup5Member2", "RaidGroup5Member3", "RaidGroup5Member4", "RaidGroup5Member5",
                     "RaidGroup6Member1", "RaidGroup6Member2", "RaidGroup6Member3", "RaidGroup6Member4",
                     "RaidGroup6Member5", "RaidGroup7Member1", "RaidGroup7Member2", "RaidGroup7Member3",
                     "RaidGroup7Member4", "RaidGroup7Member5", "RaidGroup8Member1", "RaidGroup8Member2",
                     "RaidGroup8Member3", "RaidGroup8Member4", "RaidGroup8Member5"}
end

function Health:OnEnable()
    Health:SecureHook("CompactUnitFrame_UpdateHealPrediction", function(frame)
        Health:SetKindaPreciseHealth(frame)
        Health:SetAbsorbs(frame)
    end)
    Health:SecureHook("CompactUnitFrame_UpdateStatusText", function(frame)
        Health:SetKindaPreciseHealth(frame)
    end)

    Health.frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    Health:HookScript(Health.frame, "OnEvent", function(self, event, unit)
        Health:UpdateHealth()
    end)

    Health:UpdateHealth()
end

function Health:OnDisable()
    Health:UnhookAll()
    Health:Restore()
end

function Health:UpdateHealth()
    for _, frame in pairs(Health.frames) do
        local gFrame = _G["Compact" .. frame]

        if gFrame then
            Health:SetKindaPreciseHealth(gFrame)
        end
    end
end

function Health:SetKindaPreciseHealth(frame)
    if true then
        -- calc doesn't work on secrets, return
        return
    end

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

function Health:SetAbsorbs(frame)
    if not frame or frame:IsForbidden() or not frame.unit or not UnitIsConnected(frame.unit) or not frame.displayedUnit or
        UnitIsDeadOrGhost(frame.displayedUnit) then
        return
    end

    local absorbFrame = frame.totalAbsorb -- absorb background
    local overlay = frame.totalAbsorbOverlay -- absorb lines texture
    local glow = frame.overAbsorbGlow

    if absorbFrame then
        -- absorbFrame:Hide()
    end
    if overlay then
        -- overlay:Hide()
    end
    if glow then
        -- glow:Hide()
    end

    local unit = frame.unit;
    local maxHealth = UnitHealthMax(unit)
    local absorbs = UnitGetTotalAbsorbs(unit)
    local healthLevel = frame.healthBar:GetFrameLevel()

    -- Use the calculator API for ATTACHED mode
    local attachedAbsorbs = absorbs
    local isClamped = false

    -- Create/reuse the calculator
    if CreateUnitHealPredictionCalculator and unit then
        if not frame.absorbCalculator then
            frame.absorbCalculator = CreateUnitHealPredictionCalculator()
        end
        local calc = frame.absorbCalculator

        -- Set clamp mode from settings (default to 1 = Missing Health)
        local clampMode = 1
        pcall(function()
            calc:SetDamageAbsorbClampMode(clampMode)
        end)

        -- Populate the calculator
        UnitGetDetailedHealPrediction(unit, nil, calc)

        -- Get clamped absorbs and clamped bool
        local getSuccess, result1, result2 = pcall(function()
            return calc:GetDamageAbsorbs()
        end)
        if getSuccess and result1 then
            -- attachedAbsorbs = result1
            isClamped = result2 -- This is a secret bool in M+
        end
    end

    Health:ShowOverAbsorbFrame(frame, absorbFrame, maxHealth, absorbs, isClamped)
    Health:ShowOverAbsorbOverlay(frame, overlay, maxHealth, absorbs, isClamped)

    absorbFrame:SetAlphaFromBoolean(isClamped, 0, 1)
    overlay:SetAlphaFromBoolean(isClamped, 0, 1)
end

function Health:ShowOverAbsorbFrame(frame, absorbFrame, maxHealth, absorbValue, isClamped)
    if not frame or not frame.healthBar or not absorbFrame or not absorbFrame.GetTextureFileID then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.overAbsorbFrame then
        frame.overAbsorbFrame = CreateFrame("StatusBar", nil, frame.healthBar)
        frame.overAbsorbFrame:SetAllPoints(frame.healthBar)
        frame.overAbsorbFrame:SetFrameLevel(frame.healthBar:GetFrameLevel())
        frame.overAbsorbFrame:SetMinMaxValues(0, 1)
        frame.overAbsorbFrame:EnableMouse(false)
        frame.overAbsorbFrame:SetReverseFill(true)
        frame.overAbsorbFrame:SetStatusBarTexture(7539076); -- background health shield texture

        local texture = frame.overAbsorbFrame:GetStatusBarTexture();
        texture:SetDrawLayer("ARTWORK", ARTWORK_BASE_LEVEL - 2)

        frame.overAbsorbFrame:Show();
    end

    local overAbsorbFrame = frame.overAbsorbFrame

    overAbsorbFrame:SetMinMaxValues(0, maxHealth)
    overAbsorbFrame:SetValue(absorbValue)
    overAbsorbFrame:SetAlphaFromBoolean(isClamped, 1, 0)

    return overAbsorbFrame
end

function Health:ShowOverAbsorbOverlay(frame, overlay, maxHealth, absorbValue, isClamped)
    if not frame or not frame.healthBar or not overlay or not overlay.GetTextureFileID then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.overAbsorbOverlay then
        frame.overAbsorbOverlay = CreateFrame("StatusBar", nil, frame.healthBar)
        frame.overAbsorbOverlay:SetAllPoints(frame.healthBar)
        frame.overAbsorbOverlay:SetFrameLevel(frame.healthBar:GetFrameLevel())
        frame.overAbsorbOverlay:SetMinMaxValues(0, 1)
        frame.overAbsorbOverlay:EnableMouse(false)
        frame.overAbsorbOverlay:SetReverseFill(true)

        frame.overAbsorbOverlay:Show()
    end

     -- apparently have to set every time because it would not properly stretch in StatusBar frames?
    frame.overAbsorbOverlay:SetStatusBarTexture(7539079) -- diagonal lines health shield texture
    local texture = frame.overAbsorbOverlay:GetStatusBarTexture()
    texture:SetHorizTile(true)
    texture:SetVertTile(true)
    texture:SetDrawLayer("ARTWORK", ARTWORK_BASE_LEVEL - 1)

    local overAbsorbOverlay = frame.overAbsorbOverlay

    overAbsorbOverlay:SetMinMaxValues(0, maxHealth)
    overAbsorbOverlay:SetValue(absorbValue)
    overAbsorbOverlay:SetAlphaFromBoolean(isClamped, 1, 0)

    return overAbsorbOverlay
end
