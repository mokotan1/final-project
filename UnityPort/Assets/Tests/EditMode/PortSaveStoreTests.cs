using CushionChallenge.Core;
using CushionChallenge.Rules;
using NUnit.Framework;
using UnityEngine;

namespace CushionChallenge.Tests
{
    public class PortSaveStoreTests
    {
        [SetUp]
        public void SetUp()
        {
            PlayerPrefs.DeleteKey("record.best_score_endless");
            PlayerPrefs.DeleteKey("record.best_score_classic");
            PlayerPrefs.DeleteKey("record.best_score");
        }

        [Test]
        public void BestScoreRoundTrip()
        {
            PortSaveStore.SaveBestScore(GameModeKind.Endless, 12345);
            Assert.AreEqual(12345, PortSaveStore.LoadBestScore(GameModeKind.Endless));
            Assert.AreEqual(12345, PlayerPrefs.GetInt("record.best_score", 0));
        }
    }
}
