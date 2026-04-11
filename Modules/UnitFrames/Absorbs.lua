local Absorbs = avUI:NewModule("avUI.UnitFrames.Absorbs", "AceHook-3.0")

-- credits to DandersFrames for the absorbs logic

function Absorbs:OnInitialize()
end

local function CreateOverlayFrame(frame)
    local overlay = CreateFrame("StatusBar", nil, frame.healthBar)

    overlay:SetAllPoints(frame.healthBar)
    overlay:SetFrameLevel(frame.healthBar:GetFrameLevel())
    overlay:SetMinMaxValues(0, 1)
    overlay:EnableMouse(false)
    overlay:SetReverseFill(true)
    overlay:SetStatusBarTexture(0)

    return overlay
end

local function ShowOverAbsorb(frame, blizzAbsorbFrame, maxHealth, absorbValue, isClamped)
    if not frame or not frame.healthBar or not blizzAbsorbFrame then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.__avuiOverAbsorb then
        frame.__avuiOverAbsorb = CreateOverlayFrame(frame)

        local tex = frame.__avuiOverAbsorb:GetStatusBarTexture();

        tex:SetDrawLayer("ARTWORK", ARTWORK_BASE_LEVEL - 2)
        tex:SetAtlas("RaidFrame-Shield-Fill", true)
    end

    local overAbsorb = frame.__avuiOverAbsorb

    overAbsorb:SetMinMaxValues(0, maxHealth)
    overAbsorb:SetValue(absorbValue)
    overAbsorb:SetAlphaFromBoolean(isClamped, 1, 0)
    blizzAbsorbFrame:SetAlphaFromBoolean(isClamped, 0, 1)

    return overAbsorb
end

local function ShowOverAbsorbOverlay(frame, blizzAbsorbOverlay, maxHealth, absorbValue, isClamped)
    if not frame or not frame.healthBar or not blizzAbsorbOverlay then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.__avuiOverAbsorbOverlay then
        frame.__avuiOverAbsorbOverlay = CreateOverlayFrame(frame)

        local tex = frame.__avuiOverAbsorbOverlay:GetStatusBarTexture()

        tex:SetDrawLayer("ARTWORK", ARTWORK_BASE_LEVEL - 1)
        tex:SetAtlas("RaidFrame-Shield-Overlay", true)
        tex:SetHorizTile(true)
        tex:SetVertTile(true)
    end

    local overAbsorbOverlay = frame.__avuiOverAbsorbOverlay

    overAbsorbOverlay:SetMinMaxValues(0, maxHealth)
    overAbsorbOverlay:SetValue(absorbValue)
    overAbsorbOverlay:SetAlphaFromBoolean(isClamped, 1, 0)
    blizzAbsorbOverlay:SetAlphaFromBoolean(isClamped, 0, 1)

    return overAbsorbOverlay
end

local function ShowOverAbsorbGlow(frame, avuiOverAbsorbFrame, absorbValue, isClamped)
    if not frame or not frame.healthBar then
        return
    end

    local ARTWORK_BASE_LEVEL = -6 -- dispel overlay

    if not frame.__avuiOverAbsorbGlow and avuiOverAbsorbFrame then
        frame.__avuiOverAbsorbGlow = frame:CreateTexture(nil, "ARTWORK", nil, ARTWORK_BASE_LEVEL - 1)

        frame.__avuiOverAbsorbGlow:SetAtlas("RaidFrame-Shield-Overshield", true)
        frame.__avuiOverAbsorbGlow:SetBlendMode("ADD")

        local texture = avuiOverAbsorbFrame:GetStatusBarTexture();
        frame.__avuiOverAbsorbGlow:SetPoint("TOPRIGHT", texture, "TOPLEFT", 9, 2)
        frame.__avuiOverAbsorbGlow:SetPoint("BOTTOMRIGHT", texture, "BOTTOMLEFT", 9, -2)
    end

    local overAbsorbGlow = frame.__avuiOverAbsorbGlow

    overAbsorbGlow:SetAlphaFromBoolean(isClamped, 1, 0)

    if frame.overAbsorbGlow then
        frame.overAbsorbGlow:SetAlphaFromBoolean(isClamped, 0, 1)
    end

    return overAbsorbGlow
end

local function SetAbsorbs(frame)
    if not frame or frame:IsForbidden() or not frame.unit then
        return
    end

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

        -- Set clamp mode (default to 1 = Missing Health)
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

    local overAbsorbFrame = ShowOverAbsorb(frame, absorbFrame, maxHealth, absorbs, isClamped)
    ShowOverAbsorbOverlay(frame, absorbOverlay, maxHealth, absorbs, isClamped)
    ShowOverAbsorbGlow(frame, overAbsorbFrame, absorbs, isClamped)
end

function Absorbs:OnEnable()
    self:SecureHook("CompactUnitFrame_UpdateHealPrediction", SetAbsorbs)
end

function Absorbs:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
