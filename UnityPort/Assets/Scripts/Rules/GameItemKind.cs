namespace CushionChallenge.Rules
{
    /// <summary>scr_game_rules rules_item_*</summary>
    public enum GameItemKind
    {
        Move = 1,
        RiskShot = 2,
        RemoveFoul = 3
    }

    public static class GameItemRules
    {
        public static int StoryPrice(GameItemKind item, bool playerSide)
        {
            if (playerSide)
            {
                return item switch
                {
                    GameItemKind.Move => 200,
                    GameItemKind.RiskShot => 800,
                    GameItemKind.RemoveFoul => 400,
                    _ => -1
                };
            }

            return item switch
            {
                GameItemKind.Move => 800,
                GameItemKind.RiskShot => 3200,
                GameItemKind.RemoveFoul => 1600,
                _ => -1
            };
        }

        public static string DisplayName(GameItemKind item) =>
            item switch
            {
                GameItemKind.Move => "Move",
                GameItemKind.RiskShot => "Risk Shot",
                GameItemKind.RemoveFoul => "Remove Foul",
                _ => "Unknown"
            };

        public static GameItemKind MilestoneItem(int milestoneIndex) =>
            milestoneIndex switch
            {
                0 => GameItemKind.Move,
                1 => GameItemKind.RemoveFoul,
                2 => GameItemKind.RiskShot,
                _ => (GameItemKind)(-1)
            };

        public static int NextItemGoal(int milestoneIndex) =>
            milestoneIndex switch
            {
                < 2 => milestoneIndex == 0 ? 5 : 7,
                _ => 8
            };
    }
}
