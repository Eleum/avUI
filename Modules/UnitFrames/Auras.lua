local Auras = avUI:NewModule("avUI.Nameplates.Auras.V2", "AceHook-3.0", "AceEvent-3.0")
local UnitFrames = avUI:GetModule("avUI.UnitFrames")

function Auras:OnInitialize()
end

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

local auras = {
    Atonement = {
        spellId = 194384,
        sourceUnit = "player",
        color = HexToRGB("#ffd447"),
        frameInstanceMarker = "__avuiAtonementInstanceId",
        cleanBeforeApply = true
    }
}

local function ResetAura(frame, frameAuraInstanceMarker)
    if not frame or not frame.GetName then
        return
    end

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
    local unit = UnitFrames:GetFrameUnit(frame)

    if not unit or not UnitFrames:IsPartyOrRaidUnit(unit) then
        return
    end

    if appliedAura and appliedAura.frameInstanceMarker and frame[appliedAura.frameInstanceMarker] then
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
                        textString:SetTextColor(unpack(appliedAura.color))
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

local function ApplyUnitAura(unit, blizzAuras, appliedAura)
    if not UnitFrames:IsPartyOrRaidUnit(unit) then
        return
    end

    if UnitInRaid(unit) then
        for i = 1, MAX_RAID_MEMBERS do
            local frame = _G["CompactRaidFrame" .. i]
            local frameUnit = UnitFrames:GetFrameUnit(frame)

            if frameUnit and frameUnit == unit then
                ApplyAura(frame, blizzAuras, appliedAura)
                return
            end
        end
    else
        for i = 1, 5 do
            local frame = _G["CompactPartyFrameMember" .. i]
            local frameUnit = UnitFrames:GetFrameUnit(frame)

            if frameUnit and frameUnit == unit then
                ApplyAura(frame, blizzAuras, appliedAura)
                return
            end
        end
    end
end

local function ApplyAtonementAura(event, unit, blizzAuras)
    ApplyUnitAura(unit, blizzAuras, auras.Atonement)
end

function Auras:OnEnable()
    self:RegisterEvent("UNIT_AURA", ApplyAtonementAura)
    self:SecureHook("CompactUnitFrame_SetUnit", ResetAtonementAuraChecked)
end

function Auras:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
