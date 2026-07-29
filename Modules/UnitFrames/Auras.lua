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
        color = HexToRGB("#ffd444"),
        frameInstanceMarker = "__avuiAtonementInstanceId",
        cleanBeforeApply = true
    },
    RenewingMist = {
        spellId = 119611,
        sourceUnit = "player",
        color = HexToRGB("#ffd444"),
        frameInstanceMarker = "__avuiRenewingMistInstanceId",
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
    if frame and appliedAura and appliedAura.frameInstanceMarker and frame[appliedAura.frameInstanceMarker] then
        ResetAura(frame, appliedAura.frameInstanceMarker)
    end
end

local function ResetValidUnitAuraChecked(frame, appliedAura)
    local unit = UnitFrames:GetFrameUnit(frame)

    if not unit or not UnitFrames:IsPartyOrRaidUnit(unit) then
        return
    end

    ResetAuraChecked(frame, appliedAura)
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
    local function ApplyUnitFrameAura(frame, unit)
        local frameUnit = UnitFrames:GetFrameUnit(frame)

        if frameUnit and frameUnit == unit then
            ApplyAura(frame, blizzAuras, appliedAura)
        end
    end

    if not UnitFrames:IsPartyOrRaidUnit(unit) then
        return
    end

    if UnitInRaid(unit) then
        -- TODO: check cvar for raid grouping
        for _, frame in ipairs(UnitFrames.framesRaidSplit) do
            ApplyUnitFrameAura(_G[frame], unit)
        end
    else
        for _, frame in ipairs(UnitFrames.framesParty) do
            ApplyUnitFrameAura(_G[frame], unit)
        end
    end
end

local function ApplyAtonementAura(event, unit, blizzAuras)
    ApplyUnitAura(unit, blizzAuras, auras.Atonement)
end

local function ResetAtonementAura(frame)
    ResetValidUnitAuraChecked(frame, auras.Atonement)
end

local function ApplyRenewingMistAura(event, unit, blizzAuras)
    ApplyUnitAura(unit, blizzAuras, auras.RenewingMist)
end

local function ResetRenewingMistAura(frame)
    ResetValidUnitAuraChecked(frame, auras.RenewingMist)
end

function Auras:OnEnable()
    local function CreateFrameAuraContainer(frame)
        local container = CreateFrame("AuraContainer", nil, frame, "CustomAuraContainerTemplate")

        container:SetSize(1, 1)
        container:SetPoint("CENTER", frame, "CENTER", 0, 0)

        return container
    end

    local function InitializeFrame(frame)
        local function AddParentFrameNameComponent(frame, parentFrame)
            local name = parentFrame.GetName and parentFrame:GetName()

            if name then
                local fsName = _G[name .. "Name"]

                if fsName and fsName.IsShown and fsName:IsShown() then
                    local font, size, flags = fsName:GetFont()
                    local text = fsName.GetText and fsName:GetText() or ""

                    local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontDisable")

                    fs:SetText(text)
                    fs:SetWordWrap(false)
                    fs:SetFont(font, size, "OUTLINE")
                    fs:SetTextColor(unpack(HexToRGB("#ffd444")))
                    fs:SetWidth(fsName:GetWidth())
                    fs:SetPoint("TOPLEFT", fsName, "TOPLEFT")

                    if fsName.GetJustifyH and fsName.SetJustifyH then
                        fs:SetJustifyH(fsName:GetJustifyH())
                    end

                    if fsName.GetJustifyV and fsName.SetJustifyV then
                        fs:SetJustifyV(fsName:GetJustifyV())
                    end

                    return fs
                end
            end

            return nil
        end

        local function AddAuraIconComponent(frame)
            local icon = frame:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(frame)
            icon:SetAlpha(0)

            frame:SetIcon(icon)
            frame:SetSize(32, 32)
            frame:SetPoint("CENTER")
            frame:EnableMouse(false)
        end

        local function AddStatusBarComponent(frame, anchorFrame, color)
            local bar = CreateFrame("StatusBar", nil, frame)

            bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
            bar:GetStatusBarTexture():SetVertexColor(anchorFrame:GetTextColor())

            local height = 1

            bar:SetHeight(height)
            bar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -height)
            bar:SetPoint("LEFT", anchorFrame, "LEFT")
            bar:SetPoint("RIGHT", anchorFrame, "RIGHT")
            bar:SetFrameLevel(frame:GetFrameLevel())

            local options = {}

            if Enum.StatusBarInterpolation then
                options.interpolation = Enum.StatusBarInterpolation.Immediate
            end

            if Enum.StatusBarTimerDirection then
                options.direction = Enum.StatusBarTimerDirection.RemainingTime
            end

            frame:SetDurationBar(bar, options)
        end

        local container = frame.GetParent and frame:GetParent()
        local parent = container and container.GetParent and container:GetParent()

        if not parent then
            return
        end

        local fs = AddParentFrameNameComponent(frame, parent)
        -- AddAuraIconComponent(frame)

        if fs then
            AddStatusBarComponent(frame, fs, fs:GetTextColor())
        end

        -- frame:SetSize(32, 32)

        -- frame.bg = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
        -- frame.bg:SetAllPoints(frame)
        -- frame.bg:SetColorTexture(1, .83, .27, .5)
        -- frame.bg:SetBlendMode("ADD")
        -- frame.bg:SetBlendMode("MOD")
        -- frame.bg:SetBlendMode("BLEND")

        -- frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        -- frame.cooldown:SetAllPoints(frame)
        -- frame:SetDurationCooldown(frame.cooldown)

        -- if frame.SetHideTooltipInCombat then
        --     frame:SetHideTooltipInCombat(true)
        -- end
    end

    local function CreateAuraContainerSlot()
        local key = "slot1"
        local filter = "HELPFUL|PLAYER"
        local options = {
            candidateFilters = {
                includeSpellIDs = {
                    [194384] = true
                }
            },
            initializeFrame = InitializeFrame
        }

        return {key, filter, options}
    end

    local function CreateAuraContainer(frame)
        if not frame then
            return
        end

        local container = frame.__avuiAuraContainer

        if container then
            container:SetParent(nil)
            container:Hide()
            frame.__avuiAuraContainer = nil
        end

        if not frame.IsForbidden or frame:IsForbidden() then
            return
        end

        local unit = UnitFrames:GetFrameUnit(frame)

        if not unit or not UnitFrames:IsPartyOrRaidUnit(unit) then
            return
        end

        local container = CreateFrameAuraContainer(frame)

        local slot = CreateAuraContainerSlot()
        container:AddAuraSlot(unpack(slot))

        container:SetUnit(unit)
        container:UpdateAllAuras()

        frame.__avuiAuraContainer = container
    end

    self:SecureHook("CompactUnitFrame_SetUnit", function(frame)
        CreateAuraContainer(frame)
    end)
end

function Auras:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
