local Defensives = avUI:NewModule("avUI.UnitFrames.Defensives", "AceHook-3.0")

function Defensives:OnInitialize()
end

local function ConfigureDefensives(frame)
    if not frame or not frame.unit or not frame.CenterDefensiveBuff or frame.CenterDefensiveBuff:IsForbidden() or
        frame.__avuiDefensiveBuff then
        return
    end

    local buff = frame.CenterDefensiveBuff;
    local point, _, relativePoint = buff:GetPoint(1);

    buff:ClearPoint("LEFT")
    buff:SetPoint("LEFT", frame, "LEFT", 0, 0)
    buff:SetScale(0.75)

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
    self:SecureHook("CompactUnitFrame_UpdateAuras", ConfigureDefensives)
end

function Defensives:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end
