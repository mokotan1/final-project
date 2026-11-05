using System.Collections.Generic;
using CushionChallenge.Core;
using CushionChallenge.Rules;
using UnityEngine;

namespace CushionChallenge.Story
{
    /// <summary>scr_story_ai turn prep: recovery risk, item purchases, pass-turn (subset).</summary>
    public static class StoryAiTurnPlanner
    {
        public struct TurnPlan
        {
            public bool PassTurn;
            public bool Shoot;
            public float DirectionDeg;
            public float Power;
            public bool RefundRecoveryRisk;
        }

        public static TurnPlan PlanAiTurn(
            StoryVersusSession story,
            IReadOnlyList<StoryAiSimulator.SimBall> layout,
            Vector2 aiPos)
        {
            if (story.ArmRecoveryRiskIfDue())
                return default;

            StoryAiPick pick;
            if (story.AiRecoveryRiskPending)
            {
                pick = PickRecoveryFoulShot(layout);
                if (pick.Power <= 0f)
                    pick = default;
            }
            else
                pick = StoryAiShotPicker.PickShot(
                    layout,
                    story.AiDifficultyTier(),
                    story.FiftyRoundMatch,
                    story.PlayerScore,
                    story.AiScore);

            if (story.AiRecoveryRiskPending && pick.Power <= 0f)
            {
                story.CancelRecoveryRiskPurchase();
                return new TurnPlan { PassTurn = true };
            }

            if (!story.AiRecoveryRiskPending && ConsiderAiItems(story, layout, aiPos, pick))
            {
                pick = StoryAiShotPicker.PickShot(
                    layout,
                    story.AiDifficultyTier(),
                    story.FiftyRoundMatch,
                    story.PlayerScore,
                    story.AiScore);
            }

            if (pick.Power <= 0f)
                return new TurnPlan { PassTurn = true };

            var dir = pick.DirectionDeg;
            if (story.AiDifficultyTier() == 0 && !story.AiRecoveryRiskPending)
                dir += UnityEngine.Random.Range(-6f, 6f);

            return new TurnPlan
            {
                Shoot = true,
                DirectionDeg = dir,
                Power = pick.Power
            };
        }

        static StoryAiPick PickRecoveryFoulShot(IReadOnlyList<StoryAiSimulator.SimBall> layout)
        {
            var hasFoul = false;
            foreach (var b in layout)
            {
                if (b.Role == Gameplay.BallRole.Foul)
                    hasFoul = true;
            }

            if (!hasFoul)
                return default;

            var bestValue = int.MinValue;
            StoryAiPick best = default;
            float[] powers = { 6f, 9f, 12f, 15f, 18f };
            for (var dir = 0; dir < 360; dir += 6)
            {
                foreach (var power in powers)
                {
                    var sim = StoryAiSimulator.Simulate(layout, Gameplay.BallRole.AiStriker, dir, power);
                    if (!sim.Foul)
                        continue;
                    var foulSamples = 0;
                    float[] offsets = { -1f, -0.5f, 0f, 0.5f, 1f };
                    foreach (var off in offsets)
                    {
                        var near = StoryAiSimulator.Simulate(layout, Gameplay.BallRole.AiStriker, dir + off, power);
                        if (near.Foul)
                            foulSamples++;
                    }

                    if (foulSamples < 3)
                        continue;
                    var value = foulSamples * 1000;
                    if (!sim.HitTarget)
                        value += 5000;
                    else
                        value -= StoryScoreMath.NormalPointsForCushions(sim.Cushions);
                    if (value <= bestValue)
                        continue;
                    bestValue = value;
                    best = new StoryAiPick { DirectionDeg = dir, Power = power, Cushions = sim.Cushions };
                }
            }

            return best;
        }

        static bool ConsiderAiItems(
            StoryVersusSession story,
            IReadOnlyList<StoryAiSimulator.SimBall> layout,
            Vector2 aiPos,
            StoryAiPick pick)
        {
            if (story.AiDifficultyTier() == 0 || story.BreakPending || story.ItemUsedThisTurn)
                return false;

            var lead = story.PlayerScore - story.AiScore;
            var aggressive = lead >= StoryConstants.AiItemAggroLead;
            var lowScore = pick.Power <= 0f || pick.ExpectedScore < (aggressive ? 800 : 400);
            var bounds = GameConstants.TablePlayableRect;
            var nearWall = aiPos.x - bounds.xMin < 90f || bounds.xMax - aiPos.x < 90f
                           || aiPos.y - bounds.yMin < 90f || bounds.yMax - aiPos.y < 90f;
            var foulBlocks = CountFouls(layout) > 0 && lowScore && pick.Power > 0f;

            if (foulBlocks && story.TryPurchaseItem(GameItemKind.RemoveFoul, false, false))
                return true;
            if (lowScore && nearWall && story.TryPurchaseItem(GameItemKind.Move, false, false))
                return true;
            if (lead >= StoryConstants.AiRiskLead && story.AiScore >= 3200
                && story.TryPurchaseItem(GameItemKind.RiskShot, false, false))
                return true;
            return false;
        }

        static int CountFouls(IReadOnlyList<StoryAiSimulator.SimBall> layout)
        {
            var n = 0;
            foreach (var b in layout)
            {
                if (b.Role == Gameplay.BallRole.Foul)
                    n++;
            }

            return n;
        }
    }
}
