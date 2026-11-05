using CushionChallenge.Story;
using NUnit.Framework;

namespace CushionChallenge.Tests.EditMode
{
    public class StoryAiSimulatorTests
    {
        [Test]
        public void FixtureLayout_HasScoringAiShot()
        {
            Assert.IsTrue(StoryAiSimulator.FixtureHasScoringShot());
        }

        [Test]
        public void PickShot_OnFixture_ReturnsFinitePower()
        {
            var layout = StoryAiSimulator.FixtureLayout();
            var pick = StoryAiShotPicker.PickShot(layout, tier: 1, fiftyRound: true, 0, 0);
            Assert.Greater(pick.Power, 0f);
        }
    }
}
