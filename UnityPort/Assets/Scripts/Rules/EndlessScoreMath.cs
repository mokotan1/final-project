using System;
using CushionChallenge.Core;

namespace CushionChallenge.Rules
{
    /// <summary>Port of rules_on_target_hit scoring from scr_game_rules.gml.</summary>
    public static class EndlessScoreMath
    {
        public const int ScoreMax = 999_999_999;

        public static int ZeroCushionStreakPoints(int zeroCushionStreak)
        {
            var streak = Math.Max(0, zeroCushionStreak - 1);
            return Math.Max(0, 100 - 30 * streak);
        }

        public static int CushionPoints(int cushionCount, bool riskShotActive)
        {
            var c = Math.Max(0, cushionCount);
            if (c == 0)
                return 0;
            var multiplier = riskShotActive ? Math.Pow(10, c) : Math.Pow(2, c);
            return (int)(100 * multiplier);
        }

        public static int ProvisionalTargetGain(int cushionCount, int zeroCushionStreak, bool riskShotActive)
        {
            if (cushionCount == 0)
                return ZeroCushionStreakPoints(zeroCushionStreak);
            return CushionPoints(cushionCount, riskShotActive);
        }

        public static int CreditGain(int rawGain, int currentScore, GameModeKind mode)
        {
            if (mode != GameModeKind.Endless)
                return rawGain;
            return Math.Min(rawGain, Math.Max(0, ScoreMax - currentScore));
        }
    }
}
