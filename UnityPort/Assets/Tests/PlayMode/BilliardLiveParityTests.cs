using System.Collections;
using CushionChallenge.Gameplay;
using CushionChallenge.Physics;
using NUnit.Framework;
using UnityEngine.TestTools;

namespace CushionChallenge.Tests.PlayMode
{
    /// <summary>PlayMode FixedUpdate path must match EditMode BilliardLivePhysics stepping.</summary>
    public class BilliardLiveParityTests
    {
        [UnityTest]
        public IEnumerator Fixture_312x15_LiveProbe_MatchesEditModeLiveTrace()
        {
            BilliardLiveShotProbe.Outcome live = default;
            yield return BilliardLiveShotProbe.RunFixtureShot(312f, 15f, BallRole.AiStriker, r => live = r);

            var edit = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            Assert.AreEqual(edit.Outcome.Cushions, live.Cushions, live.Signature);
            Assert.AreEqual(edit.Outcome.HitTarget, live.HitTarget, live.Signature);
            Assert.AreEqual(edit.Outcome.Foul, live.Foul, live.Signature);
        }
    }
}
