using CushionChallenge.Story;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    public class StoryScoreMathTests
    {
        [Test]
        public void RiskPointsMatchGml()
        {
            Assert.AreEqual(100, StoryScoreMath.RiskPointsForCushions(0));
            Assert.AreEqual(1_000, StoryScoreMath.RiskPointsForCushions(1));
            Assert.AreEqual(10_000, StoryScoreMath.RiskPointsForCushions(2));
            Assert.AreEqual(100_000_000, StoryScoreMath.RiskPointsForCushions(6));
            Assert.AreEqual(StoryConstants.ScoreMax, StoryScoreMath.RiskPointsForCushions(7));
        }

        [Test]
        public void AddSaturatesAtMax()
        {
            Assert.AreEqual(StoryConstants.ScoreMax, StoryScoreMath.Add(StoryConstants.ScoreMax - 1, 1));
            Assert.AreEqual(StoryConstants.ScoreMax, StoryScoreMath.Add(StoryConstants.ScoreMax, 1));
        }
    }
}
