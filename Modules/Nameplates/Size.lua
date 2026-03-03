local Size = avUI:NewModule("avUI.Nameplates.Size", "AceHook-3.0", "AceEvent-3.0")

function Size:OnInitialize()
end

local function SetHealthBarHeight(frame)
    if not frame or not frame.healthBar or frame:IsForbidden() then
        return
    end

    frame:SetHeight(10)
end

function Size:OnEnable()
    self:SecureHook(PixelUtil, "SetHeight", SetHealthBarHeight)
end

function Size:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll()
end
