local Theme = avUI:NewModule("avUI.Theme", "AceHook-3.0")

-- credits to SUI and mUI for auras styling

Theme:Enable()

Theme.COLORS = {
    BLACK = {0, 0, 0},
    DARK_GRAY = {0.15, 0.15, 0.15},
    GRAY = {0.3, 0.3, 0.3},
    LIGHT_GRAY = {0.5, 0.5, 0.5}
}

Theme.BUTTONS = {
    STANDARD_BARS = 12,
    MULTI_BARS = 12,
    PET_BARS = 10
}

function Theme:OnInitialize()
    self.events = CreateFrame("Frame")
end

function Theme:OnEnable()
    self:ApplyTheme()

    self.events:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.events:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.events:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self.events:RegisterEvent("WEAPON_ENCHANT_CHANGED")
    self.events:RegisterUnitEvent("UNIT_AURA", "player", "target", "focus")

    self:SecureHookScript(self.events, "OnEvent", function(_, event, unit)
        if event == "PLAYER_ENTERING_WORLD" then
            self:StylePlayerAuras()
        elseif event == "UNIT_AURA" and unit == "player" then
            self:StylePlayerAuras()
        elseif event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_AURA" and unit == "target") then
            self:StyleTargetAuras()
        elseif event == "PLAYER_FOCUS_CHANGED" or (event == "UNIT_AURA" and unit == "focus") then
            self:StyleFocusAuras()
        end
    end)

    self:SecureHookScript(PlayerFrame, "OnUpdate", function(_)
        self:StylePlayerStatus()
    end)
end

function Theme:OnDisable()
    self.events:UnregisterAllEvents()
    self:UnhookAll()
end

function Theme:ApplyTheme()
    self:StylePlayerFrame()
    self:StyleMainActionBar()
    self:StyleBarButtons()
    self:StyleTargetFrame()
    self:StyleFocusFrame()
    self:StylePetFrame()
    self:StyleCompactPartyFrame()
    self:StyleMinimap()
    self:StyleObjectiveTrackers()
end

function Theme:StyleBarButtons()
    local function StyleActionBar(barNum)
        -- Style all buttons in a standard action bar (buttons 1-12)
        for i = 1, self.BUTTONS.STANDARD_BARS do
            local button = _G["ActionButton" .. i]

            if button then
                self:StyleButton(button)
            end
        end
    end

    local function StyleMultiBar(barName)
        -- Style all buttons in a MultiBar
        for i = 1, self.BUTTONS.MULTI_BARS do
            local button = _G["MultiBar" .. barName .. "Button" .. i]

            if button then
                self:StyleButton(button)
            end
        end
    end

    local function StyleStanceBar()
        -- Style all buttons in the Stance Bar
        for i = 1, self.BUTTONS.STANDARD_BARS do
            local button = _G["StanceButton" .. i]

            if button then
                self:StyleButton(button)
            end
        end
    end

    local function StylePetBar(barName)
        -- Style all buttons in the Pet Action Bar
        for i = 1, self.BUTTONS.PET_BARS do
            local button = _G["PetActionButton" .. i]

            if button then
                self:StyleButton(button)
            end
        end
    end

    -- Style all standard action bars (1-6)
    for barNum = 1, 6 do
        StyleActionBar(barNum)
    end

    -- Style all multi bars
    local multiBarNames = {
        [1] = "Left",
        [2] = "Right",
        [3] = "BottomLeft",
        [4] = "BottomRight",
        [5] = "5",
        [6] = "6"
    }

    for _, barName in pairs(multiBarNames) do
        StyleMultiBar(barName)
    end

    StyleStanceBar()
    StylePetBar()
end

function Theme:StyleMainActionBar()
    local function StyleEndCaps()
        -- Style the left and right end caps of the main action bar
        local leftEndCap = MainActionBar.EndCaps.LeftEndCap
        local rightEndCap = MainActionBar.EndCaps.RightEndCap

        if leftEndCap then
            leftEndCap:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end

        if rightEndCap then
            rightEndCap:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end

    local function StyleBorderArt()
        -- Style the border art of the main action bar
        local borderArt = MainActionBar.BorderArt

        if borderArt then
            borderArt:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end

    StyleEndCaps()
    StyleBorderArt()
end

function Theme:StyleCompactPartyFrame()
    local function StyleBorderFrame()
        -- Style the border frame of the Compact Party Frame
        local frame = CompactPartyFrameBorderFrame.Background

        if frame then
            frame:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end

    StyleBorderFrame()
end

function Theme:StylePlayerFrame()
    local function StyleFrame()
        local textures = {PlayerFrame.PlayerFrameContainer.FrameTexture,
                          PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture}

        for _, tex in pairs(textures) do
            if tex then
                tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
            end
        end
    end

    local function StyleFrameContent()
        local textures = {PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture,
                          PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon,
                          PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop.RestTexture}

        for _, tex in pairs(textures) do
            if tex then
                tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
            end
        end
    end

    StyleFrame()
    StyleFrameContent()
end

function Theme:StylePlayerStatus()
    local tex = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture

    if tex then
        local r, g, b, a = tex:GetVertexColor()
        tex:SetVertexColor(r, g, b, a * 0.25)
    end
end

function Theme:StyleTargetFrame()
    local function StyleFrame()
        local tex = TargetFrame.TargetFrameContainer.FrameTexture

        if tex then
            tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end

    local function StyleFrameContent()
        local tex = TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor

        if tex then
            tex:Hide()
        end
    end

    StyleFrame()
    StyleFrameContent()
end

function Theme:StyleFocusFrame()
    local function StyleFrame()
        local tex = FocusFrame.TargetFrameContainer.FrameTexture

        if tex then
            tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end

    local function StyleFrameContent()
        local tex = FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor

        if tex then
            tex:Hide()
        end
    end

    StyleFrame()
    StyleFrameContent()
end

function Theme:StylePetFrame()
    local tex = PetFrameTexture

    if tex then
        tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
    end
end

function Theme:StylePlayerAuras()
    for index, _ in pairs(BuffFrame.auraFrames) do
        local aura = select(index, BuffFrame.AuraContainer:GetChildren())
        self:StyleAura(aura)
    end
end

function Theme:StyleTargetAuras()
    for aura, _ in TargetFrame.auraPools:GetPool("TargetBuffFrameTemplate"):EnumerateActive() do
        self:StyleAura(aura)
    end
end

function Theme:StyleFocusAuras()
    for aura, _ in FocusFrame.auraPools:GetPool("TargetBuffFrameTemplate"):EnumerateActive() do
        self:StyleAura(aura)
    end
end

function Theme:StyleMinimap()
    local tex = MinimapCompassTexture

    if tex then
        tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
    end
end

function Theme:StyleObjectiveTrackers()
    local frames = {"ObjectiveTrackerFrame", "CampaignQuestObjectiveTracker", "QuestObjectiveTracker",
                    "WorldQuestObjectiveTracker", "AchievementObjectiveTracker", "ProfessionsRecipeTracker"}

    for _, f in pairs(frames) do
        local frame = _G[f].Header.Background

        if frame then
            frame:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end
end

function Theme:StyleButton(button)
    -- Set button border to black
    if button.NormalTexture then
        button.NormalTexture:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
    end

    -- Set pushed state border to black
    if button.PushedTexture then
        button.PushedTexture:SetVertexColor(unpack(self.COLORS.LIGHT_GRAY))
    end

    -- Set highlight border to black
    if button.HighlightTexture then
        button.HighlightTexture:SetVertexColor(unpack(self.COLORS.GRAY))
    end
end

function Theme:StyleAura(aura)
    -- Validate frame and icon exist
    if not aura or not aura.Icon then
        return
    end

    -- Create and apply border texture
    if not aura.myBorder then
        aura.myBorder = aura:CreateTexture(nil, "OVERLAY")
    end

    local border = aura.myBorder

    border:SetTexture([[Interface\AddOns\avUI\Media\Textures\border.png]])
    border:SetPoint("TOPLEFT", aura.Icon, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", aura.Icon, "BOTTOMRIGHT", 1, -1)
    border:SetVertexColor(unpack(self.COLORS.DARK_GRAY))

    -- Apply mask to clip sharp corners on the icon
    if aura.Icon.SetMask then
        aura.Icon:SetMask([[Interface\AddOns\avUI\Media\Textures\border_mask.png]])
    end
end
