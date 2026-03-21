local Auras = avUI:NewModule("avUI.Nameplates.Auras", "AceHook-3.0", "AceEvent-3.0")

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

local function ResetAtonementAura(frame)
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

    frame.__avuiAtonementInstanceId = nil
    frame.__avuiStatusTextFont = nil
    frame.__avuiStatusTextColor = nil
end

local function ResetAtonementAuraChecked(frame)
    if frame and frame.__avuiAtonementInstanceId then
        ResetAtonementAura(frame)
    end
end

local function ApplyAtonementAura(frame, auras)
    local ATONEMENT_AURA_ID = 194384

    if auras and auras.addedAuras then
        for _, aura in ipairs(auras.addedAuras) do
            if not frame:IsForbidden() and not issecretvalue(aura.spellId) and aura.spellId == ATONEMENT_AURA_ID and
                not frame.__avuiAtonementInstanceId then
                local name = frame:GetName()

                if name then
                    local textString = _G[name .. "StatusText"]

                    if textString and textString:IsShown() then
                        frame.__avuiAtonementInstanceId = aura.auraInstanceID
                        local font, size, flags = textString:GetFont()
                        frame.__avuiStatusTextFont = {font, size, flags}
                        frame.__avuiStatusTextColor = {textString:GetTextColor()}
                        textString:SetFont(font, size, "OUTLINE")
                        textString:SetTextColor(unpack(HexToRGB("#ffd447")))
                    end
                end

                break
            end
        end
    end

    if auras and auras.removedAuraInstanceIDs and frame.__avuiAtonementInstanceId then
        for _, aura in ipairs(auras.removedAuraInstanceIDs) do
            if aura == frame.__avuiAtonementInstanceId then
                ResetAtonementAura(frame)
                break
            end
        end
    end
end

function Auras:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", ResetAtonementAuraChecked)
    self:RegisterEvent("RAID_ROSTER_UPDATE", ResetAtonementAuraChecked)
    self:SecureHook("CompactUnitFrame_SetUnit", ResetAtonementAuraChecked)
    self:SecureHook("CompactUnitFrame_UpdateAuras", ApplyAtonementAura)
end

function Auras:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
