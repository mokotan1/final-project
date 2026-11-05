using CushionChallenge.Core;
using CushionChallenge.Story;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    public class GameModeAndAiTierTests
    {
        [Test]
        public void FoulCaps()
        {
            Assert.AreEqual(4, GameModeRules.FoulCap(GameModeKind.Classic));
            Assert.AreEqual(6, GameModeRules.FoulCap(GameModeKind.Endless));
        }

        [Test]
        public void AiTierEarlyPlayerLead()
        {
            Assert.AreEqual(0, StoryAiTier.DifficultyTier(true, false, 5, 500, 0));
        }

        [Test]
        public void AiTierLateOrBigLead()
        {
            Assert.AreEqual(2, StoryAiTier.DifficultyTier(true, false, 41, 0, 0));
            Assert.AreEqual(2, StoryAiTier.DifficultyTier(true, false, 10, StoryConstants.AiSoftLeadEnd, 0));
        }
    }
}
