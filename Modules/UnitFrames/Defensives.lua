local Defensives = avUI:NewModule("avUI.UnitFrames.Defensives", "AceHook-3.0")

Defensives:Disable()

function Defensives:OnInitialize()
end

local function ConfigureDefensives(frame)
    if not frame or not frame.CenterDefensiveBuff or frame.CenterDefensiveBuff:IsForbidden() or
        frame.__avuiDefensiveBuff then
        return
    end

    local buff = frame.CenterDefensiveBuff;

    if not buff.__avuiBorder then
        buff.__avuiBorder = buff:CreateTexture(nil, "OVERLAY")

        local border = buff.__avuiBorder

        border:SetAtlas("combattimeline-fx-pause")
        border:SetPoint("TOPLEFT", buff, "TOPLEFT", -6, 6)
        border:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 6, -6)
    end

    frame.__avuiDefensiveBuff = true
end

function Defensives:OnEnable()
    self:SecureHook("CompactUnitFrame_SetUnit", ConfigureDefensives)
end

function Defensives:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end
