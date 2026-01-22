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

    -- credits to DandersFrames for the logic below

    local absorbFrame = frame.totalAbsorb -- absorb background
    local absorbOverlay = frame.totalAbsorbOverlay -- absorb lines texture
    local absorbGlow = frame.overAbsorbGlow

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

    local myOverAbsorbFrame = Absorbs:ShowOverAbsorbFrame(frame, absorbFrame, maxHealth, absorbs, isClamped)
    Absorbs:ShowOverAbsorbOverlay(frame, absorbOverlay, maxHealth, absorbs, isClamped)
    Absorbs:ShowOverAbsorbGlow(frame, myOverAbsorbFrame, absorbs, isClamped)
end

function Absorbs:ShowOverAbsorbFrame(frame, absorbFrame, maxHealth, absorbValue, isClamped)
    if not frame or not frame.healthBar or not absorbFrame then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.myOverAbsorbFrame then
        frame.myOverAbsorbFrame = CreateFrame("StatusBar", nil, frame.healthBar)
        frame.myOverAbsorbFrame:SetAllPoints(frame.healthBar)
        frame.myOverAbsorbFrame:SetFrameLevel(frame.healthBar:GetFrameLevel())
        frame.myOverAbsorbFrame:SetMinMaxValues(0, 1)
        frame.myOverAbsorbFrame:EnableMouse(false)
        frame.myOverAbsorbFrame:SetReverseFill(true)
        frame.myOverAbsorbFrame:SetStatusBarTexture(7539076); -- background health shield texture

        local texture = frame.myOverAbsorbFrame:GetStatusBarTexture();
        texture:SetDrawLayer("ARTWORK", ARTWORK_BASE_LEVEL - 2)

        frame.myOverAbsorbFrame:Show();
    end

    local overAbsorbFrame = frame.myOverAbsorbFrame

    overAbsorbFrame:SetMinMaxValues(0, maxHealth)
    overAbsorbFrame:SetValue(absorbValue)
    overAbsorbFrame:SetAlphaFromBoolean(isClamped, 1, 0)
    absorbFrame:SetAlphaFromBoolean(isClamped, 0, 1)

    return overAbsorbFrame
end

function Absorbs:ShowOverAbsorbOverlay(frame, absorbOverlay, maxHealth, absorbValue, isClamped)
    if not frame or not frame.healthBar or not absorbOverlay then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.myOverAbsorbOverlay then
        frame.myOverAbsorbOverlay = CreateFrame("StatusBar", nil, frame.healthBar)
        frame.myOverAbsorbOverlay:SetAllPoints(frame.healthBar)
        frame.myOverAbsorbOverlay:SetFrameLevel(frame.healthBar:GetFrameLevel())
        frame.myOverAbsorbOverlay:SetMinMaxValues(0, 1)
        frame.myOverAbsorbOverlay:EnableMouse(false)
        frame.myOverAbsorbOverlay:SetReverseFill(true)

        frame.myOverAbsorbOverlay:Show()
    end

    -- apparently have to set every time because it would not properly stretch in StatusBar frames?
    frame.myOverAbsorbOverlay:SetStatusBarTexture(7539079) -- diagonal lines health shield texture
    local texture = frame.myOverAbsorbOverlay:GetStatusBarTexture()
    texture:SetHorizTile(true)
    texture:SetVertTile(true)
    texture:SetDrawLayer("ARTWORK", ARTWORK_BASE_LEVEL - 1)

    local overAbsorbOverlay = frame.myOverAbsorbOverlay

    overAbsorbOverlay:SetMinMaxValues(0, maxHealth)
    overAbsorbOverlay:SetValue(absorbValue)
    overAbsorbOverlay:SetAlphaFromBoolean(isClamped, 1, 0)
    absorbOverlay:SetAlphaFromBoolean(isClamped, 0, 1)

    return overAbsorbOverlay
end

function Absorbs:ShowOverAbsorbGlow(frame, myOverAbsorbFrame, absorbValue, isClamped)
    if not frame or not frame.healthBar then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.myOverAbsorbGlow and myOverAbsorbFrame then
        frame.myOverAbsorbGlow = frame:CreateTexture(nil, "ARTWORK", nil, ARTWORK_BASE_LEVEL - 1)

        frame.myOverAbsorbGlow:SetAtlas("RaidFrame-Shield-Overshield", true)
        frame.myOverAbsorbGlow:SetBlendMode("ADD")

        local texture = myOverAbsorbFrame:GetStatusBarTexture();
        frame.myOverAbsorbGlow:SetPoint("TOPRIGHT", texture, "TOPLEFT", 9, 2)
        frame.myOverAbsorbGlow:SetPoint("BOTTOMRIGHT", texture, "BOTTOMLEFT", 9, -2)
    end

    local overAbsorbGlow = frame.myOverAbsorbGlow

    overAbsorbGlow:SetAlphaFromBoolean(isClamped, 1, 0)

    if frame.overAbsorbGlow then
        frame.overAbsorbGlow:SetAlphaFromBoolean(isClamped, 0, 1)
    end

    return overAbsorbGlow
end
