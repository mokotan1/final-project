using CushionChallenge.Core;
using CushionChallenge.Rules;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    public class EndlessRewardChoiceTests
    {
        [Test]
        public void ChooseRewardAddsInventoryAndCloses()
        {
            var rules = new EndlessRulesEngine { Mode = GameModeKind.Endless };
            rules.ResetRun();
            rules.Items.ProcessProgression(3, GameModeKind.Endless);
            rules.Items.ProcessProgression(5, GameModeKind.Endless);
            rules.Items.ProcessProgression(7, GameModeKind.Endless);
            rules.Items.ProcessProgression(8, GameModeKind.Endless);
            rules.TryOpenRewardChoice(true);
            Assert.IsTrue(rules.RewardChoiceOpen);
            Assert.IsTrue(rules.TryChooseReward(GameItemKind.RiskShot));
            Assert.AreEqual(4, rules.Inventory.Count);
            Assert.That(rules.Inventory, Does.Contain(GameItemKind.RiskShot));
            Assert.IsFalse(rules.RewardChoiceOpen);
        }
    }
}
