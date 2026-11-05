using System.Collections.Generic;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using CushionChallenge.Story;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    /// <summary>
    /// Fixed layout (story_ai_fixture_ball_snapshot) and shot inputs shared with
    /// tools/story_ai_fixture_sim.py and tools/story_50_runtime_harness.gml.
    /// </summary>
    public class StoryAiDeterministicInputTests
    {
        static readonly (float dir, float power)[] HarnessProbeShots =
        {
            (312f, 15f),
            (180f, 12f),
            (90f, 18f),
        };

        [Test]
        public void FixtureLayout_MatchesGameMakerSnapshotCoordinates()
        {
            var layout = StoryAiSimulator.FixtureLayout();
            Assert.AreEqual(5, layout.Count);
            AssertBall(layout, BallRole.Player, 380, 350);
            AssertBall(layout, BallRole.AiStriker, 900, 350);
            AssertBall(layout, BallRole.Target, 640, 260);
        }

        [Test]
        public void SixCushionFixtureProbe_MatchesGameMakerHarness()
        {
            var layout = StoryAiSimulator.FixtureLayout();
            var r = StoryAiSimulator.Simulate(layout, BallRole.AiStriker, 312f, 15f);
            Assert.IsFalse(r.Foul);
            Assert.IsTrue(r.HitTarget);
            Assert.GreaterOrEqual(r.Cushions, 6);
        }

        [Test]
        public void ProbeShots_ProduceStableSimSignatures()
        {
            var layout = StoryAiSimulator.FixtureLayout();
            var signatures = new List<string>();
            foreach (var (dir, power) in HarnessProbeShots)
            {
                var r = StoryAiSimulator.Simulate(layout, BallRole.AiStriker, dir, power);
                signatures.Add($"{dir:0}:{power:0}:{r.Cushions}:{r.HitTarget}:{r.Foul}");
            }

            CollectionAssert.AreEqual(
                new[]
                {
                    "312:15:6:True:False",
                    "180:12:0:False:False",
                    "90:18:7:False:False",
                },
                signatures);
        }

        static void AssertBall(IReadOnlyList<StoryAiSimulator.SimBall> layout, BallRole role, float x, float y)
        {
            foreach (var b in layout)
            {
                if (b.Role != role)
                    continue;
                Assert.AreEqual(x, b.X, 0.01f);
                Assert.AreEqual(y, b.Y, 0.01f);
                Assert.AreEqual(GameConstants.BallRadius, b.R, 0.01f);
                return;
            }

            Assert.Fail($"missing role {role}");
        }
    }
}
