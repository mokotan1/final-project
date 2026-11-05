namespace CushionChallenge.Story
{
    /// <summary>scr_story_versus.gml — story_versus_break_foul_rules_suppressed and break assign dialogue.</summary>
    public static class StoryVersusBreakRules
    {
        public static bool BreakFoulRulesSuppressed(bool fiftyRoundMatch, bool shotIsBreak) =>
            fiftyRoundMatch && shotIsBreak;

        public static bool InputLockedByBreakAssign(bool fiftyRoundMatch, bool breakAssignDialoguePending) =>
            fiftyRoundMatch && breakAssignDialoguePending;
    }
}
