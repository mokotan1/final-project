using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using NUnit.Framework;
using UnityEngine;

namespace CushionChallenge.Tests
{
    public class ApplicationBallSpawnerTests
    {
        [Test]
        public void InitialLayout_SpawnsPlayerTargetAndFoulCountFromRules()
        {
            var layout = ApplicationBallSpawner.BuildInitialLayout(2, new System.Random(99));
            Assert.That(layout.Count, Is.EqualTo(4));
            Assert.That(CountRole(layout, BallRole.Player), Is.EqualTo(1));
            Assert.That(CountRole(layout, BallRole.Target), Is.EqualTo(1));
            Assert.That(CountRole(layout, BallRole.Foul), Is.EqualTo(2));
            foreach (var spawn in layout)
                Assert.IsTrue(GameConstants.PlayableContains(spawn.Position));
        }

        static int CountRole(IReadOnlyList<ApplicationBallSpawner.SpawnRequest> layout, BallRole role)
        {
            var count = 0;
            foreach (var spawn in layout)
            {
                if (spawn.Role == role)
                    count++;
            }

            return count;
        }
    }
}
