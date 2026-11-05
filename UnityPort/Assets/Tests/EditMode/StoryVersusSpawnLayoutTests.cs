using CushionChallenge.Gameplay;
using NUnit.Framework;
using UnityEngine;

namespace CushionChallenge.Tests
{
    public class StoryVersusSpawnLayoutTests
    {
        [Test]
        public void IntroMatch_UsesRackCoordinatesFromGameMaker()
        {
            var layout = StoryVersusSpawnLayout.BuildLayout(introMatch: true);
            Assert.That(Find(layout, BallRole.Target), Is.EqualTo(new Vector2(640, 350)));
            Assert.That(Find(layout, BallRole.Foul, 0), Is.EqualTo(new Vector2(608, 350)));
            Assert.That(Find(layout, BallRole.Foul, 1), Is.EqualTo(new Vector2(624, 322)));
        }

        [Test]
        public void StandardMatch_UsesStoryTableLayoutFromGameMaker()
        {
            var layout = StoryVersusSpawnLayout.BuildLayout(introMatch: false);
            Assert.That(Find(layout, BallRole.Target), Is.EqualTo(new Vector2(640, 260)));
            Assert.That(Find(layout, BallRole.Foul, 0), Is.EqualTo(new Vector2(520, 480)));
            Assert.That(Find(layout, BallRole.Foul, 1), Is.EqualTo(new Vector2(760, 480)));
        }

        static Vector2 Find(System.Collections.Generic.IReadOnlyList<StoryVersusSpawnLayout.BallSpawn> layout, BallRole role, int index = 0)
        {
            var seen = 0;
            foreach (var ball in layout)
            {
                if (ball.Role != role)
                    continue;
                if (seen == index)
                    return ball.Position;
                seen++;
            }

            Assert.Fail($"missing {role} #{index}");
            return default;
        }
    }
}
