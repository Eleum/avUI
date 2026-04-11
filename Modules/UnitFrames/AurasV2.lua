local Auras = avUI:NewModule("avUI.Nameplates.Auras.V2", "AceHook-3.0", "AceEvent-3.0")

function Auras:OnInitialize()
end

local auras = {
    Atonement = {
        spellId = 194384,
        sourceUnit = "player",
        colorHex = "#ffd447",
        frameInstanceMarker = "__avuiAtonementInstanceId",
        cleanBeforeApply = true
    }
}

local function HexToRGB(hex)
    hex = hex:gsub("#", "")

    if #hex == 6 then
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        return {r, g, b}
    elseif #hex == 8 then -- includes alpha
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        local a = tonumber(hex:sub(7, 8), 16) / 255
        return {r, g, b, a}
    end
end

local function ResetAura(frame, frameAuraInstanceMarker)
    local name = frame:GetName()

    if name then
        local textFrame = _G[name .. "StatusText"]

        if textFrame then
            local color = frame.__avuiStatusTextColor or {0.5, 0.5, 0.5}
            if frame.__avuiStatusTextFont then
                textFrame:SetFont(unpack(frame.__avuiStatusTextFont))
            else
                textFrame:SetFontObject(GameFontDisable)
            end
            textFrame:SetTextColor(unpack(color))
        end
    end

    frame[frameAuraInstanceMarker] = nil
    frame.__avuiStatusTextFont = nil
    frame.__avuiStatusTextColor = nil
end

local function ResetAuraChecked(frame, appliedAura)
    if frame and appliedAura and appliedAura.frameInstanceMarker and frame[appliedAura.frameInstanceMarker] then
        ResetAura(frame, appliedAura.frameInstanceMarker)
    end
end

local function ResetAtonementAuraChecked(frame)
    ResetAuraChecked(frame, auras.Atonement)
end

local function ApplyAura(frame, blizzAuras, appliedAura)
    if not frame or not blizzAuras or not appliedAura then
        return
    end

    if blizzAuras.addedAuras then
        for _, aura in ipairs(blizzAuras.addedAuras) do
            if not frame:IsForbidden() and not issecretvalue(aura.spellId) and aura.spellId == appliedAura.spellId and
                (not appliedAura.sourceUnit or aura.sourceUnit == appliedAura.sourceUnit) then
                if appliedAura.cleanBeforeApply then
                    ResetAuraChecked(frame, appliedAura)
                end

                local name = frame:GetName()

                if name then
                    local textString = _G[name .. "StatusText"]

                    if textString and textString:IsShown() then
                        if appliedAura.frameInstanceMarker then
                            frame[appliedAura.frameInstanceMarker] = aura.auraInstanceID
                        end

                        local font, size, flags = textString:GetFont()

                        frame.__avuiStatusTextFont = {font, size, flags}
                        frame.__avuiStatusTextColor = {textString:GetTextColor()}

                        textString:SetFont(font, size, "OUTLINE")
                        textString:SetTextColor(unpack(HexToRGB(appliedAura.colorHex)))
                    end
                end

                break
            end
        end
    end

    if appliedAura.frameInstanceMarker then
        local marker = appliedAura.frameInstanceMarker
        local auraInstance = frame[marker]

        if blizzAuras.removedAuraInstanceIDs and auraInstance then
            for _, aura in ipairs(blizzAuras.removedAuraInstanceIDs) do
                if aura == auraInstance or (frame.displayedUnit and UnitIsDeadOrGhost(frame.displayedUnit)) then
                    ResetAura(frame, marker)
                    break
                end
            end
        end
    end
end

local function ApplyAtonementAura(frame, blizzAuras)
    ApplyAura(frame, blizzAuras, auras.Atonement)
end

function Auras:OnEnable()
    self:RegisterEvent("READY_CHECK", ResetAtonementAuraChecked)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", ResetAtonementAuraChecked)
    self:RegisterEvent("RAID_ROSTER_UPDATE", ResetAtonementAuraChecked)
    self:SecureHook("CompactUnitFrame_SetUnit", ResetAtonementAuraChecked)
    self:SecureHook("CompactUnitFrame_UpdateAuras", ApplyAtonementAura)
end

function Auras:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
