avUI = LibStub("AceAddon-3.0"):NewAddon("avUI")

function avUI:OnInitialize()
end

function avUI:OnEnable()
    self:EnableModule("avUI.Nameplates.Size")
    self:EnableModule("avUI.Nameplates.Opacity")
end

function avUI:OnDisable()
end