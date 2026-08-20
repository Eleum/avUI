local Auras = avUI:NewModule("avUI.UnitFrames.Auras", "AceHook-3.0", "AceEvent-3.0")
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
        color = HexToRGB("#ffd444")
    }
}

local unknownNameCheckRunning = false;

function Auras:OnEnable()
    local function CreateFrameAuraContainer(frame)
        local container = CreateFrame("AuraContainer", nil, frame, "CustomAuraContainerTemplate")

        container:SetSize(1, 1)
        container:SetPoint("CENTER", frame, "CENTER", 0, 0)

        return container
    end

    local function InitializeAuraFrame(frame, aura)
        local function AddParentFrameNameComponent(frame, parentFrame, color)
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
                    fs:SetTextColor(unpack(color or {1, 1, 1}))
                    fs:SetWidth(fsName:GetWidth() + 2) -- offset for outline
                    fs:SetPoint("TOPLEFT", fsName, "TOPLEFT")
                    fs:SetJustifyH(fsName:GetJustifyH())
                    fs:SetJustifyV(fsName:GetJustifyV())

                    return fs
                end
            end

            return nil
        end

        local function AddAuraIconComponent(frame)
            local icon = frame:CreateTexture(nil, "ARTWORK")

            icon:SetAllPoints(frame)
            icon:SetAlpha(1)

            frame:SetIcon(icon)
            frame:SetSize(32, 32)
            frame:SetPoint("CENTER")
            frame:EnableMouse(false)
        end

        local function AddStatusBarComponent(frame, anchorFrame, color)
            local bar = CreateFrame("StatusBar", nil, frame)

            bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
            bar:GetStatusBarTexture():SetVertexColor(unpack(color or {1, 1, 1}))

            bar:SetHeight(1)
            bar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -2)
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

        local fs = AddParentFrameNameComponent(frame, parent, aura.color)

        if fs then
            AddStatusBarComponent(frame, fs, aura.color)
        end
    end

    local function CreateAuraContainerSlot(aura)
        local key = "slot1"
        local filter = "HELPFUL|PLAYER"
        local options = {
            candidateFilters = {
                includeSpellIDs = {
                    [aura.spellId] = true
                }
            },
            initializeFrame = function(frame)
                InitializeAuraFrame(frame, aura)
            end
        }

        return {key, filter, options}
    end

    local function CreateAuraContainer(frame)
        if not frame then
            return
        end

        local container = frame.__avuiAuraContainer

        if container then
            container:Hide()
            container:SetEnabled(false)
            container:SetParent(nil)
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
        local slot = CreateAuraContainerSlot(auras.Atonement)

        container:AddAuraSlot(unpack(slot))
        container:SetUnit(unit)
        container:UpdateAllAuras()

        frame.__avuiAuraContainer = container
    end

    local function RefreshAuraContainers()
        UnitFrames:ForEachCurrentFrame(function(frame)
            CreateAuraContainer(frame)
        end)
    end

    local function RefreshUnknownAuraContainers()
        local function CheckUnknownName(frame)
            local name = frame and frame.GetName and frame:GetName()

            if name then
                local fsName = _G[name .. "Name"]

                if fsName and fsName.IsShown and fsName:IsShown() and fsName.IsForbidden and not fsName:IsForbidden() then
                    local text = fsName.GetText and fsName:GetText() or ""

                    if not issecretvalue(text) and
                        (text == UNKNOWNOBJECT or text == LFG_FOLLOWER_NAME_PREFIX:format(UNKNOWNOBJECT)) then
                        return true
                    end
                end
            end

            return false
        end

        local unknownFound = false

        UnitFrames:ForEachCurrentFrame(function(frame)
            if CheckUnknownName(frame) then
                CreateAuraContainer(frame)
                unknownFound = true
            end
        end)

        if unknownFound then
            unknownNameCheckRunning = true
            C_Timer.After(1, RefreshUnknownAuraContainers)
            return
        end

        unknownNameCheckRunning = false
    end

    local function RefreshAuras()
        RefreshAuraContainers()

        if not unknownNameCheckRunning then
            RefreshUnknownAuraContainers()
        end
    end

    self:RegisterEvent("GROUP_ROSTER_UPDATE", RefreshAuras)
    self:RegisterEvent("RAID_ROSTER_UPDATE", RefreshAuras)
    self:SecureHook("CompactUnitFrame_SetUnit", CreateAuraContainer)
end

function Auras:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
