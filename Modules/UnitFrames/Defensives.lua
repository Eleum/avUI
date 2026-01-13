local Defensives = avUI:NewModule("avUI.UnitFrames.Defensives", "AceHook-3.0")

Defensives:Enable()

function Defensives:OnInitialize()
end

function Defensives:OnEnable()
    self:SecureHook("CompactUnitFrame_UpdateAuras", function(frame)
        self:ConfigureDefensives(frame)
    end)
end

function Defensives:OnDisable()
    self:UnhookAll()
    self:Restore()
end

function Defensives:ConfigureDefensives(frame)
    if not frame or not frame.unit or UnitInRaid(frame.unit) or not frame.CenterDefensiveBuff or
        frame.CenterDefensiveBuff:IsForbidden() then
        return
    end

    local def = frame.CenterDefensiveBuff;
    local point, _, relativePoint = def:GetPoint(1);

    if (point == "LEFT" and relativePoint == "LEFT") then
        return
    end

    def:ClearPoint("LEFT")
    def:SetPoint("LEFT", frame, "LEFT", -20, 0)

    local scale = 0.75

    if (def:GetScale() == scale) then
        return
    end

    def:SetScale(scale)
end
