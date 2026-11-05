namespace CushionChallenge.Core
{
    public enum GameModeKind
    {
        Endless = 0,
        Classic = 1,
        StoryFiftyRound = 2
    }

    public static class GameModeRules
    {
        public static int FoulCap(GameModeKind mode) =>
            mode == GameModeKind.Classic ? 4 : 6;

        public static bool ItemsEnabled(GameModeKind mode) =>
            mode != GameModeKind.Classic;

        public static string BestScoreKey(GameModeKind mode) =>
            mode == GameModeKind.Classic ? "best_score_classic" : "best_score_endless";

        public static string DisplayName(GameModeKind mode) =>
            mode == GameModeKind.Classic ? "CLASSIC" : mode == GameModeKind.Endless ? "ENDLESS" : "STORY";
    }
}
