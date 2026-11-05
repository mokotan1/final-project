using CushionChallenge.Core;
using CushionChallenge.Rules;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    public class EndlessItemProgressionTests
    {
        [Test]
        public void MilestoneGrantsMoveThenRemoveThenRisk()
        {
            var items = new EndlessItemProgression();
            items.ProcessProgression(3, GameModeKind.Endless);
            Assert.AreEqual(1, items.Inventory.Count);
            Assert.AreEqual(GameItemKind.Move, items.Inventory[0]);
            Assert.AreEqual(5, items.ItemGoal);
            items.ProcessProgression(5, GameModeKind.Endless);
            Assert.AreEqual(2, items.Inventory.Count);
            Assert.AreEqual(GameItemKind.RemoveFoul, items.Inventory[1]);
        }

        [Test]
        public void ClassicModeSpawnsFoulPressure()
        {
            var items = new EndlessItemProgression();
            items.ProcessProgression(1, GameModeKind.Classic);
            items.ProcessProgression(1, GameModeKind.Classic);
            items.ProcessProgression(1, GameModeKind.Classic);
            Assert.AreEqual(1, items.PendingFoulSpawns);
        }

        [Test]
        public void FourthMilestoneQueuesRewardChoice()
        {
            var items = new EndlessItemProgression();
            items.ProcessProgression(3, GameModeKind.Endless);
            items.ProcessProgression(5, GameModeKind.Endless);
            items.ProcessProgression(7, GameModeKind.Endless);
            items.ProcessProgression(8, GameModeKind.Endless);
            Assert.IsTrue(items.PendingRewardChoice);
            Assert.IsTrue(items.TryDequeueRewardChoice(out var foulBonus));
            Assert.IsFalse(items.PendingRewardChoice);
        }
    }
}
