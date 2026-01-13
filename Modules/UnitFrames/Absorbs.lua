local Absorbs = avUI:NewModule("avUI.UnitFrames.Absorbs", "AceHook-3.0")
local UnitFrames = avUI:GetModule("avUI.UnitFrames")

Absorbs:Enable()

function Absorbs:OnInitialize()
end

function Absorbs:OnEnable()
    self:SecureHook("CompactUnitFrame_UpdateHealPrediction", function(frame)
        self:SetAbsorbs(frame)
    end)
end

function Absorbs:OnDisable()
    self:UnhookAll()
    self:Restore()
end

function Absorbs:SetAbsorbs(frame)
    if not frame or frame:IsForbidden() or not frame.unit or not UnitIsConnected(frame.unit) or not frame.displayedUnit or
        UnitIsDeadOrGhost(frame.displayedUnit) then
        return
    end

    local absorbFrame = frame.totalAbsorb -- absorb background
    local absorbOverlay = frame.totalAbsorbOverlay -- absorb lines texture

    local unit = frame.unit;
    local maxHealth = UnitHealthMax(unit)
    local absorbs = UnitGetTotalAbsorbs(unit)
    local healthLevel = frame.healthBar:GetFrameLevel()

    -- Use the calculator API
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

        -- local getSuccessA, result1A = pcall(function()
        --     return calc:GetPredictedValues()
        -- end)
        -- if getSuccessA then
        --     DevTool:AddData(result1A, "values")
        -- end
    end

    Health:ShowOverAbsorbFrame(frame, absorbFrame, maxHealth, absorbs, isClamped)
    Health:ShowOverAbsorbOverlay(frame, absorbOverlay, maxHealth, absorbs, isClamped)

    absorbFrame:SetAlphaFromBoolean(isClamped, 0, 1)
    absorbOverlay:SetAlphaFromBoolean(isClamped, 0, 1)
end

function Absorbs:ShowOverAbsorbFrame(frame, absorbFrame, maxHealth, absorbValue, isClamped)
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

function Absorbs:ShowOverAbsorbOverlay(frame, overlay, maxHealth, absorbValue, isClamped)
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