local UnitFrames = avUI:NewModule("avUI.UnitFrames")

UnitFrames:Enable()

function UnitFrames:OnInitialize()
    self.framesParty = {"CompactPartyFrameMember1", "CompactPartyFrameMember2", "CompactPartyFrameMember3",
                        "CompactPartyFrameMember4", "CompactPartyFrameMember5"}
    self.framesRaidSplit = {"CompactRaidGroup1Member1", "CompactRaidGroup1Member2", "CompactRaidGroup1Member3",
                            "CompactRaidGroup1Member4", "CompactRaidGroup1Member5", "CompactRaidGroup2Member1",
                            "CompactRaidGroup2Member2", "CompactRaidGroup2Member3", "CompactRaidGroup2Member4",
                            "CompactRaidGroup2Member5", "CompactRaidGroup3Member1", "CompactRaidGroup3Member2",
                            "CompactRaidGroup3Member3", "CompactRaidGroup3Member4", "CompactRaidGroup3Member5",
                            "CompactRaidGroup4Member1", "CompactRaidGroup4Member2", "CompactRaidGroup4Member3",
                            "CompactRaidGroup4Member4", "CompactRaidGroup4Member5", "CompactRaidGroup5Member1",
                            "CompactRaidGroup5Member2", "CompactRaidGroup5Member3", "CompactRaidGroup5Member4",
                            "CompactRaidGroup5Member5", "CompactRaidGroup6Member1", "CompactRaidGroup6Member2",
                            "CompactRaidGroup6Member3", "CompactRaidGroup6Member4", "CompactRaidGroup6Member5",
                            "CompactRaidGroup7Member1", "CompactRaidGroup7Member2", "CompactRaidGroup7Member3",
                            "CompactRaidGroup7Member4", "CompactRaidGroup7Member5", "CompactRaidGroup8Member1",
                            "CompactRaidGroup8Member2", "CompactRaidGroup8Member3", "CompactRaidGroup8Member4",
                            "CompactRaidGroup8Member5"}
    self.framesRaidCombined = {"CompactRaidFrame1", "CompactRaidFrame2", "CompactRaidFrame3", "CompactRaidFrame4",
                               "CompactRaidFrame5", "CompactRaidFrame6", "CompactRaidFrame7", "CompactRaidFrame8",
                               "CompactRaidFrame9", "CompactRaidFrame10", "CompactRaidFrame11", "CompactRaidFrame12",
                               "CompactRaidFrame13", "CompactRaidFrame14", "CompactRaidFrame15", "CompactRaidFrame16",
                               "CompactRaidFrame17", "CompactRaidFrame18", "CompactRaidFrame19", "CompactRaidFrame20",
                               "CompactRaidFrame21", "CompactRaidFrame22", "CompactRaidFrame23", "CompactRaidFrame24",
                               "CompactRaidFrame25", "CompactRaidFrame26", "CompactRaidFrame27", "CompactRaidFrame28",
                               "CompactRaidFrame29", "CompactRaidFrame30", "CompactRaidFrame31", "CompactRaidFrame32",
                               "CompactRaidFrame33", "CompactRaidFrame34", "CompactRaidFrame35", "CompactRaidFrame36",
                               "CompactRaidFrame37", "CompactRaidFrame38", "CompactRaidFrame39", "CompactRaidFrame40"}
end

function UnitFrames:IsPartyOrRaidUnit(unit)
    return type(unit) == "string" and (unit == "player" or unit:match("^party%d$") or unit:match("^raid%d%d?$"))
end

function UnitFrames:GetFrameUnit(frame)
    if not frame or not frame.displayedUnit then
        return nil
    end

    return frame.displayedUnit
end
