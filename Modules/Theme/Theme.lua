local Theme = avUI:NewModule("avUI.Theme", "AceHook-3.0")

-- credits to SUI and mUI for auras styling

Theme:Enable()

Theme.COLORS = {
    BLACK = {0, 0, 0},
    DARK_GRAY = {0.15, 0.15, 0.15},
    GRAY = {0.3, 0.3, 0.3},
    LIGHT_GRAY = {0.5, 0.5, 0.5},
    INACTIVE = {0.5, 0.5, 0.5},
    DIM_WHITE = {0.8, 0.8, 0.8}
}
Theme.MAIN_COLOR = Theme.COLORS.DARK_GRAY
Theme.SECONDARY_COLOR = Theme.COLORS.GRAY

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

    self:SecureHookScript(PlayerFrame, "OnUpdate", function()
        self:StylePlayerStatus()
    end)

    hooksecurefunc("UnitFrameHealthBar_Update", function(statusBar)
        self:StyleHealthBar(statusBar)
    end)

    hooksecurefunc("HealthBar_OnValueChanged", function(statusBar)
        self:StyleHealthBar(statusBar)
    end)

    self:SecureHook(TomTom, "ShowHideCoordBlock", function()
        self:StyleTomTom()
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
    self:StyleStatusTrackingBars()
    self:StyleChatFrame()
    self:StyleCharacterFrame()
    self:StyleTooltips()
    self:StyleBags()
    self:StyleTomTom()
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
            leftEndCap:SetVertexColor(unpack(self.MAIN_COLOR))
        end

        if rightEndCap then
            rightEndCap:SetVertexColor(unpack(self.MAIN_COLOR))
        end
    end

    local function StyleBorderArt()
        -- Style the border art of the main action bar
        local borderArt = MainActionBar.BorderArt

        if borderArt then
            borderArt:SetVertexColor(unpack(self.MAIN_COLOR))
        end
    end

    local function StyleHorizontalDividers()
        if MainActionBar.HorizontalDividersPool then
            local color = self.SECONDARY_COLOR;

            for divider, _ in MainActionBar.HorizontalDividersPool:EnumerateActive() do
                if divider then
                    divider:SetVertexColor(unpack(color))
                end
            end
        end
    end

    StyleEndCaps()
    StyleBorderArt()
    StyleHorizontalDividers()
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

    PlayerCastingBarFrame.Border:SetVertexColor(unpack(self.MAIN_COLOR))
    
    self:SecureHookScript(PlayerCastingBarFrame, "OnEvent", function(frame, a)
        frame.Icon:Show()
    end)
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

    TargetFrameSpellBar.Border:SetVertexColor(unpack(self.MAIN_COLOR))
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
    
    FocusFrameSpellBar.Border:SetVertexColor(unpack(self.MAIN_COLOR))
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
        self:StyleAuraButton(aura)
    end
end

function Theme:StyleTargetAuras()
    for aura, _ in TargetFrame.auraPools:GetPool("TargetBuffFrameTemplate"):EnumerateActive() do
        self:StyleAuraButton(aura)
    end
end

function Theme:StyleFocusAuras()
    for aura, _ in FocusFrame.auraPools:GetPool("TargetBuffFrameTemplate"):EnumerateActive() do
        self:StyleAuraButton(aura)
    end
end

function Theme:StyleMinimap()
    local tex = MinimapCompassTexture

    if tex then
        tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
    end
end

function Theme:StyleObjectiveTrackers()
    local frames = {ObjectiveTrackerFrame, CampaignQuestObjectiveTracker, ScenarioObjectiveTracker,
                    QuestObjectiveTracker, WorldQuestObjectiveTracker, AchievementObjectiveTracker,
                    ProfessionsRecipeTracker}

    for _, f in pairs(frames) do
        local tex = f.Header.Background

        if tex then
            tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end
end

function Theme:StyleStatusTrackingBars()
    local frames = {MainStatusTrackingBarContainer, SecondaryStatusTrackingBarContainer}

    for _, frame in pairs(frames) do
        local tex = frame.BarFrameTexture

        if tex then
            tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end
end

function Theme:StyleButton(button)
    if button.NormalTexture then
        button.NormalTexture:SetVertexColor(unpack(self.MAIN_COLOR))
    end

    if button.PushedTexture then
        button.PushedTexture:SetVertexColor(unpack(self.COLORS.LIGHT_GRAY))
    end

    if button.HighlightTexture then
        button.HighlightTexture:SetVertexColor(unpack(self.SECONDARY_COLOR))
    end
end

function Theme:StyleAuraButton(aura)
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

    if aura.TempEnchantBorder then
        aura.TempEnchantBorder:Hide()
    end
end

function Theme:StyleHealthBar(statusBar)
    if not statusBar or not statusBar.unit then
        return
    end

    statusBar:SetStatusBarDesaturated(1)

    local unit = statusBar.unit

    if UnitIsPlayer(unit) and UnitIsConnected(unit) then
        local _, class = UnitClass(unit)

        if class then
            local color = RAID_CLASS_COLORS[class]
            statusBar:SetStatusBarColor(color.r, color.g, color.b)
        end
    elseif UnitIsPlayer(unit) and not UnitIsConnected(unit) then
        statusBar:SetStatusBarColor(unpack(self.COLORS.INACTIVE));
    else
        if UnitExists(unit) then
            if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
                statusBar:SetStatusBarColor(unpack(self.COLORS.INACTIVE))
            elseif not UnitIsTapDenied(unit) then
                local reaction = UnitReaction(unit, "player")

                if reaction then
                    local color = FACTION_BAR_COLORS[reaction]

                    if color then
                        statusBar:SetStatusBarColor(color.r, color.g, color.b)
                    end
                end
            end
        end
    end
end

function Theme:StyleChatFrame()
    local function StyleChatTabs()
        local texs = {"Left", "Middle", "Right"}

        for i = 1, NUM_CHAT_WINDOWS do
            local frame = _G["ChatFrame" .. i .. "Tab"]

            if frame then
                for _, part in pairs(texs) do
                    local tex = frame[part]

                    if tex then
                        tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
                    end
                end
            end
        end
    end

    local function StyleChatEditBox()
        local texs = {ChatFrame1EditBoxLeft, ChatFrame1EditBoxMid, ChatFrame1EditBoxRight}

        for _, part in pairs(texs) do
            local tex = part

            if tex then
                tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
            end
        end
    end

    ChatFrame1Background:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
    ChatFrame1ButtonFrameBackground:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
    StyleChatTabs()
    StyleChatEditBox()
end

function Theme:StyleCharacterFrame()
    local function StyleBackground()
        local color = self.MAIN_COLOR;

        local texs = {"Background", "Bg"}

        for _, part in pairs(texs) do
            local tex = CharacterFrame[part]

            if tex then
                tex:SetVertexColor(unpack(color));
            end
        end

        texs = {"TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "TopLeftCorner", "TopRightCorner", "BottomLeftCorner",
                "BottomRightCorner"}

        for _, part in pairs(texs) do
            local tex = CharacterFrame.NineSlice[part]

            if tex then
                tex:SetVertexColor(unpack(color));
            end
        end

        CharacterStatsPane.ClassBackground:SetVertexColor(unpack(color));

        local frames = {"ItemLevelCategory", "AttributesCategory", "EnhancementsCategory"}

        for _, part in pairs(frames) do
            local frame = CharacterStatsPane[part]

            if frame and frame.Background then
                frame.Background:SetVertexColor(unpack(color));
            end
        end

        local insetColor = self.SECONDARY_COLOR;

        CharacterFrameInsetRight.Bg:SetVertexColor(unpack(insetColor));

        local insets = {CharacterFrameInset.NineSlice, CharacterFrameInsetRight.NineSlice}
        local insetTexs = {"TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "TopLeftCorner", "TopRightCorner",
                           "BottomLeftCorner", "BottomRightCorner"}

        for _, inset in pairs(insets) do
            for _, part in pairs(insetTexs) do
                local tex = inset[part]

                if tex then
                    tex:SetVertexColor(unpack(insetColor));
                end
            end
        end

        local borders =
            {"Top", "TopLeft", "TopRight", "Left", "Right", "Bottom", "BottomLeft", "BottomRight", "Bottom2"}

        for _, part in pairs(borders) do
            local tex = _G["PaperDollInnerBorder" .. part]

            if tex then
                tex:SetVertexColor(unpack(insetColor));
            end
        end
    end

    local function StylePaperDoll()
        local function StyleEquipmentSlots()
            local color = self.COLORS.DARK_GRAY;

            local texs = {CharacterHeadSlotFrame, CharacterNeckSlotFrame, CharacterShoulderSlotFrame,
                          CharacterBackSlotFrame, CharacterChestSlotFrame, CharacterShirtSlotFrame,
                          CharacterTabardSlotFrame, CharacterWristSlotFrame, CharacterHandsSlotFrame,
                          CharacterWaistSlotFrame, CharacterLegsSlotFrame, CharacterFeetSlotFrame,
                          CharacterFinger0SlotFrame, CharacterFinger1SlotFrame, CharacterTrinket0SlotFrame,
                          CharacterTrinket1SlotFrame, CharacterMainHandSlotFrame, CharacterSecondaryHandSlotFrame,
                          CharacterRangedSlotFrame}

            for _, tex in pairs(texs) do
                if tex then
                    tex:SetVertexColor(unpack(color));
                end
            end

            -- style auto-named regions for main hand and off hand slots
            local function StyleOtherRegions()
                local frames = {CharacterMainHandSlot, CharacterSecondaryHandSlot, MainActionBar}

                for _, frame in pairs(frames) do
                    for i = 1, frame:GetNumRegions() do
                        local region = select(i, frame:GetRegions())

                        if region and region.SetVertexColor then
                            region:SetVertexColor(unpack(color));
                        end
                    end
                end
            end

            StyleOtherRegions()
        end

        local function StyleTabs()
            PaperDollSidebarTab1.TabBg:SetVertexColor(unpack(self.SECONDARY_COLOR));
            PaperDollSidebarTab2.TabBg:SetVertexColor(unpack(self.SECONDARY_COLOR));
            PaperDollSidebarTab3.TabBg:SetVertexColor(unpack(self.SECONDARY_COLOR));
        end

        StyleEquipmentSlots()
        StyleTabs()
    end

    local function StyleTabs()
        local tabs = {"CharacterFrameTab1", "CharacterFrameTab2", "CharacterFrameTab3"}
        local parts = {"Left", "Middle", "Right"}

        for _, tab in pairs(tabs) do
            for _, part in pairs(parts) do
                local tex = _G[tab][part]

                if tex then
                    tex:SetVertexColor(unpack(self.SECONDARY_COLOR))
                end
            end
        end
    end

    StyleBackground()
    StylePaperDoll()
    StyleTabs()
end

function Theme:StyleTooltips()
    local function StyleTooltip(tooltip)
        if tooltip then

            if tooltip.NineSlice then
                local texs = {"TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "TopLeftCorner", "TopRightCorner",
                              "BottomLeftCorner", "BottomRightCorner"}

                for _, part in pairs(texs) do
                    local tex = tooltip.NineSlice[part]

                    if tex then
                        tex:SetVertexColor(unpack(self.MAIN_COLOR))
                    end
                end

                if tooltip.NineSlice.Center then
                    tooltip.NineSlice.Center:SetVertexColor(unpack(self.COLORS.BLACK))
                end
            end

            if tooltip.CompareHeader then
                local compare = tooltip.CompareHeader

                for i = 1, compare:GetNumRegions() do
                    local region = select(i, compare:GetRegions())

                    if region and region:GetObjectType() == "Texture" then
                        region:SetVertexColor(unpack(self.SECONDARY_COLOR));
                    end
                end
            end
        end
    end

    local tooltips = {GameTooltip, ItemRefTooltip}

    for _, tooltip in pairs(tooltips) do
        self:SecureHookScript(tooltip, "OnShow", function()
            StyleTooltip(tooltip)
        end)
    end

    tooltips = {"ShoppingTooltip", "ItemRefShoppingTooltip"}

    for _, tooltipName in pairs(tooltips) do
        local tooltip = _G[tooltipName]

        for i = 1, 2 do
            local tooltip = _G[tooltipName .. i]

            if tooltip then
                self:SecureHookScript(tooltip, "OnShow", function()
                    StyleTooltip(tooltip)
                end)
            end
        end
    end
end

function Theme:StyleBags()
    local function StyleBagSlots(frame, color)
        self:SecureHookScript(frame, "OnUpdate", function(f)
            for button, _ in f.itemButtonPool:EnumerateActive() do
                local tex = button.NormalTexture

                if tex then
                    tex:SetVertexColor(unpack(self.MAIN_COLOR));
                end
            end
        end)
    end

    local function StyleBorder(frame, color)
        if not frame then
            return
        end

        local texs = {"Left", "Middle", "Right"}

        for _, part in pairs(texs) do
            local tex = frame[part]

            if tex then
                tex:SetVertexColor(unpack(color));
            end
        end
    end

    local combined = ContainerFrameCombinedBags

    self:StyleNineSlice(combined.NineSlice, self.MAIN_COLOR)
    self:StyleBg(combined.Bg, self.COLORS.BLACK)
    StyleBagSlots(combined, self.MAIN_COLOR)

    for i = 1, 6 do
        local frame = _G["ContainerFrame" .. i]

        if frame then
            self:StyleNineSlice(frame["NineSlice"], self.MAIN_COLOR)
            self:StyleBg(frame["Bg"], self.COLORS.BLACK)
            StyleBagSlots(frame, self.MAIN_COLOR)
        end
    end

    StyleBorder(ContainerFrameCombinedBags.MoneyFrame.Border, self.COLORS.GRAY)
    StyleBorder(ContainerFrame1MoneyFrame.Border, self.COLORS.GRAY)
    StyleBorder(BackpackTokenFrame.Border, self.COLORS.GRAY)
end

function Theme:StyleNineSlice(frame, color)
    if not frame then
        return
    end

    local texs = {"TopEdge", "BottomEdge", "Center", "LeftEdge", "RightEdge", "TopLeftCorner", "TopRightCorner",
                  "BottomLeftCorner", "BottomRightCorner"}

    for _, part in pairs(texs) do
        local tex = frame[part]

        if tex then
            tex:SetVertexColor(unpack(color));
        end
    end
end

function Theme:StyleBg(frame, color)
    if not frame then
        return
    end

    local texs = {"TopSection", "BottomEdge", "BottomLeft", "BottomRight"}

    for _, part in pairs(texs) do
        local tex = frame[part]

        if tex then
            tex:SetVertexColor(unpack(color));
        end
    end
end

function Theme:StyleTomTom()
    local texs = {"LeftEdge", "RightEdge", "TopEdge", "BottomEdge", "TopLeftCorner", "TopRightCorner",
                  "BottomLeftCorner", "BottomRightCorner"}

    for _, part in pairs(texs) do
        local tex = TomTomBlock[part]

        if tex then
            tex:SetVertexColor(unpack(self.COLORS.DARK_GRAY))
        end
    end
end
