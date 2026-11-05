using CushionChallenge.Core;
using CushionChallenge.Rules;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    public class EndlessScoreMathTests
    {
        [Test]
        public void ZeroCushionStreakMatchesReadme()
        {
            Assert.AreEqual(100, EndlessScoreMath.ZeroCushionStreakPoints(1));
            Assert.AreEqual(70, EndlessScoreMath.ZeroCushionStreakPoints(2));
            Assert.AreEqual(40, EndlessScoreMath.ZeroCushionStreakPoints(3));
            Assert.AreEqual(10, EndlessScoreMath.ZeroCushionStreakPoints(4));
            Assert.AreEqual(0, EndlessScoreMath.ZeroCushionStreakPoints(5));
        }

        [Test]
        public void CushionDoublingAndRisk()
        {
            Assert.AreEqual(200, EndlessScoreMath.CushionPoints(1, false));
            Assert.AreEqual(400, EndlessScoreMath.CushionPoints(2, false));
            Assert.AreEqual(1_000, EndlessScoreMath.CushionPoints(1, true));
        }

        [Test]
        public void EndlessCapCredits()
        {
            var credited = EndlessScoreMath.CreditGain(500, EndlessScoreMath.ScoreMax - 100, GameModeKind.Endless);
            Assert.AreEqual(100, credited);
        }
    }
}
