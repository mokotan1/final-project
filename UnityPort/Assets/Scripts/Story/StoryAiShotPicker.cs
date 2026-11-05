using System.Collections.Generic;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using UnityEngine;

namespace CushionChallenge.Story
{
    public struct StoryAiPick
    {
        public float DirectionDeg;
        public float Power;
        public int Cushions;
        public int ExpectedScore;
    }

    /// <summary>Simplified port of story_ai_pick_shot (no items / recovery risk).</summary>
    public static class StoryAiShotPicker
    {
        const int FoulWeightMid = 250;
        const int FoulWeightHard = 400;

        public static StoryAiPick PickShot(
            IReadOnlyList<StoryAiSimulator.SimBall> layout,
            int tier,
            bool fiftyRound,
            int playerScore,
            int aiScore)
        {
            var powers = tier == 0 ? new[] { 6f, 9f, 12f } : new[] { 6f, 9f, 12f, 15f, 18f };
            var foulWeight = tier == 2 ? FoulWeightHard : FoulWeightMid;
            var playerLead = playerScore - aiScore;
            var needSamples = tier == 0 ? 1 : (fiftyRound && playerLead >= StoryConstants.AiCompetitiveGap ? 2 : 3);

            var bestFound = false;
            var best = default(StoryAiPick);
            var bestValue = float.MinValue;

            var fallback = default(StoryAiPick);
            var fallbackValue = float.MinValue;

            var aiPos = FindStriker(layout);
            var softCandidates = new List<(StoryAiPick pick, float rank)>();

            for (var dir = 0; dir < 360; dir += 6)
            {
                foreach (var power in powers)
                {
                    var sim = StoryAiSimulator.Simulate(layout, BallRole.AiStriker, dir, power);
                    var fallbackPoints = sim.Cushions >= StoryAiSimulator.MinCushions
                        ? ExpectedPoints(sim.Cushions)
                        : 0;
                    var foulRisk = RayFoulRisk(aiPos, dir, layout);
                    var fallbackRank = RankFallback(fallbackPoints, sim, foulRisk, tier, fiftyRound, playerScore, aiScore, foulWeight);
                    if (fallbackRank > fallbackValue)
                    {
                        fallbackValue = fallbackRank;
                        fallback = new StoryAiPick
                        {
                            DirectionDeg = dir,
                            Power = power,
                            Cushions = sim.Cushions,
                            ExpectedScore = fallbackPoints
                        };
                    }

                    if (sim.Foul || !sim.HitTarget || sim.Cushions < StoryAiSimulator.MinCushions)
                        continue;

                    var validSamples = 0;
                    var scoreSum = 0f;
                    var offsets = new[] { -1f, -0.5f, 0f, 0.5f, 1f };
                    foreach (var off in offsets)
                    {
                        var near = off == 0f
                            ? sim
                            : StoryAiSimulator.Simulate(layout, BallRole.AiStriker, dir + off, power);
                        if (!near.Foul && near.HitTarget && near.Cushions >= StoryAiSimulator.MinCushions)
                        {
                            validSamples++;
                            scoreSum += ExpectedPoints(near.Cushions);
                        }
                    }

                    if (validSamples < needSamples)
                        continue;

                    var avgScore = scoreSum / offsets.Length;
                    var value = avgScore - foulRisk * (tier == 0 ? 40f : foulWeight);
                    if (tier != 0 && fiftyRound)
                    {
                        var afterGap = Mathf.Abs(aiScore + ExpectedPoints(sim.Cushions) - playerScore);
                        var outside = Mathf.Max(0f, afterGap - StoryConstants.AiCompetitiveGap);
                        value = -2f * outside + 0.5f * Mathf.Min(avgScore, StoryConstants.AiCompetitiveGap)
                                + 100f * validSamples - foulRisk * foulWeight;
                    }
                    else if (tier == 2)
                        value += 100f * Mathf.Max(0, sim.Cushions - 1);

                    if (tier == 0)
                    {
                        softCandidates.Add((new StoryAiPick
                        {
                            DirectionDeg = dir,
                            Power = power,
                            Cushions = sim.Cushions,
                            ExpectedScore = ExpectedPoints(sim.Cushions)
                        }, value));
                        continue;
                    }

                    if (value > bestValue)
                    {
                        bestFound = true;
                        bestValue = value;
                        best = new StoryAiPick
                        {
                            DirectionDeg = dir,
                            Power = power,
                            Cushions = sim.Cushions,
                            ExpectedScore = ExpectedPoints(sim.Cushions)
                        };
                    }
                }
            }

            if (tier == 0 && softCandidates.Count > 0)
            {
                softCandidates.Sort((a, b) => b.rank.CompareTo(a.rank));
                var choice = Mathf.Min(softCandidates.Count - 1, Random.Range(1, Mathf.Min(3, softCandidates.Count) + 1));
                return softCandidates[choice].pick;
            }

            return bestFound ? best : fallback;
        }

        static float RankFallback(
            int fallbackPoints,
            StoryAiSimulator.SimResult sim,
            float foulRisk,
            int tier,
            bool fiftyRound,
            int playerScore,
            int aiScore,
            int foulWeight)
        {
            var rank = fallbackPoints - (sim.Foul ? 100000f : 0f) - foulRisk * foulWeight;
            if (tier == 0)
                rank = fallbackPoints - foulRisk * 40f;
            else if (fiftyRound)
            {
                var gap = Mathf.Abs(aiScore + fallbackPoints - playerScore);
                rank = -2f * Mathf.Max(0f, gap - StoryConstants.AiCompetitiveGap)
                       + 0.5f * Mathf.Min(fallbackPoints, StoryConstants.AiCompetitiveGap)
                       - (sim.Foul ? 100000f : 0f)
                       - foulRisk * foulWeight;
            }

            return rank;
        }

        static int ExpectedPoints(int cushions) => StoryScoreMath.NormalPointsForCushions(cushions);

        static Vector2 FindStriker(IReadOnlyList<StoryAiSimulator.SimBall> layout)
        {
            foreach (var b in layout)
            {
                if (b.Role == BallRole.AiStriker)
                    return new Vector2(b.X, b.Y);
            }

            return Vector2.zero;
        }

        static float RayFoulRisk(Vector2 aiPos, float dirDeg, IReadOnlyList<StoryAiSimulator.SimBall> layout)
        {
            const float rayLen = 900f;
            var end = aiPos + GameConstants.LengthDir(dirDeg, rayLen);
            var ex = end.x;
            var ey = end.y;
            var risk = 0f;
            foreach (var b in layout)
            {
                if (b.Role != BallRole.Foul)
                    continue;
                var d = DistPointToSegment(b.X, b.Y, aiPos.x, aiPos.y, ex, ey);
                if (d < 40f)
                    risk += 1f - d / 40f;
            }

            return Mathf.Clamp01(risk);
        }

        static float DistPointToSegment(float px, float py, float x1, float y1, float x2, float y2)
        {
            var dx = x2 - x1;
            var dy = y2 - y1;
            var len2 = dx * dx + dy * dy;
            if (len2 <= 0f)
                return Mathf.Sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));
            var t = Mathf.Clamp01(((px - x1) * dx + (py - y1) * dy) / len2);
            var cx = x1 + t * dx;
            var cy = y1 + t * dy;
            return Mathf.Sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy));
        }
    }
}
