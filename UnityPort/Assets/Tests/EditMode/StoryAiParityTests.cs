using CushionChallenge.Story;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    /// <summary>Same initial layout/scores as tools/story_50_runtime_harness.gml AI catch-up block.</summary>
    public class StoryAiParityTests
    {
        [Test]
        public void FixtureHasSixCushionScoringShot()
        {
            var layout = StoryAiSimulator.FixtureLayout();
            var found = false;
            for (var dir = 0; dir < 360; dir += 6)
            {
                foreach (var power in new[] { 6f, 9f, 12f, 15f, 18f })
                {
                    var sim = StoryAiSimulator.Simulate(layout, Gameplay.BallRole.AiStriker, dir, power);
                    if (sim.Foul || !sim.HitTarget || sim.Cushions < 6)
                        continue;
                    found = true;
                    break;
                }

                if (found)
                    break;
            }

            Assert.IsTrue(found, "fixture must include a 6+ cushion scoring path for catch-up AI");
        }

        [Test]
        public void CatchUpPick_ClosesGapWithinCompetitiveBand()
        {
            var layout = StoryAiSimulator.FixtureLayout();
            const int playerScore = 10_000;
            const int aiScore = 5_000;
            var tier = StoryAiTier.DifficultyTier(true, false, 16, playerScore, aiScore);
            Assert.AreEqual(1, tier);

            var pick = StoryAiShotPicker.PickShot(layout, tier, true, playerScore, aiScore);
            Assert.Greater(pick.Power, 0f);
            Assert.GreaterOrEqual(pick.Cushions, 6);
            var projected = aiScore + pick.ExpectedScore;
            Assert.LessOrEqual(System.Math.Abs(projected - playerScore), StoryConstants.AiCompetitiveGap + 1);
        }

        [Test]
        public void AheadPick_HoldsBackExpectedScore()
        {
            var layout = StoryAiSimulator.FixtureLayout();
            var tier = StoryAiTier.DifficultyTier(true, false, 16, 5_000, 10_000);
            Assert.AreEqual(1, tier);
            var pick = StoryAiShotPicker.PickShot(layout, tier, true, 5_000, 10_000);
            Assert.Greater(pick.Power, 0f);
            Assert.LessOrEqual(pick.ExpectedScore, 1_600);
        }

        [Test]
        public void FixtureHasRecoveryFoulCandidate()
        {
            Assert.IsTrue(StoryAiSimulator.FixtureHasRecoveryFoulShot());
        }
    }
}
