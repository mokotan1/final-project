using System;
using CushionChallenge.Story;

namespace CushionChallenge.Story
{
    /// <summary>Matches scr_story_versus.gml and tools/story_fifty_round_logic.py.</summary>
    public static class StoryScoreMath
    {
        public static int Clamp(int value, int min, int max) =>
            Math.Max(min, Math.Min(max, value));

        public static int Add(int current, int points)
        {
            var cur = Clamp(current, 0, StoryConstants.ScoreMax);
            var pts = Clamp(points, 0, StoryConstants.ScoreMax);
            if (pts >= StoryConstants.ScoreMax - cur)
                return StoryConstants.ScoreMax;
            return cur + pts;
        }

        public static int RiskPointsForCushions(int cushions)
        {
            var c = Math.Max(0, cushions);
            if (c >= 7)
                return StoryConstants.ScoreMax;
            return 100 * (int)Math.Pow(10, c);
        }

        public static int NormalPointsForCushions(int cushions)
        {
            var c = Math.Max(0, cushions);
            if (c <= 0)
                return 100;
            var remaining = StoryConstants.ScoreMax;
            var points = 100;
            for (var i = 0; i < c; i++)
            {
                if (points >= remaining)
                    return StoryConstants.ScoreMax;
                if (points > remaining / 2)
                    return StoryConstants.ScoreMax;
                points *= 2;
            }
            return Math.Min(points, StoryConstants.ScoreMax);
        }
    }
}
