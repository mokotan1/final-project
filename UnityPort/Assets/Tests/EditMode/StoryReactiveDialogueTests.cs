using CushionChallenge.Story;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    public class StoryReactiveDialogueTests
    {
        [Test]
        public void PlayerFoulAlternatesIds()
        {
            var counters = new StoryReactionCounters();
            var dialogue = new StoryDialogueRuntime();
            StoryReactiveDialogue.ReactToShot(counters, dialogue, StoryTurnSide.Player, 0, true, 100, 50, true, true);
            StoryReactiveDialogue.ReactToShot(counters, dialogue, StoryTurnSide.Player, 0, true, 100, 50, true, true);
            Assert.AreEqual(2, counters.PlayerFoul);
        }

        [Test]
        public void ResultDialogueWinLoseDraw()
        {
            var win = StoryVersusSession.BuildResultDialogue((int)StoryTurnSide.Player);
            Assert.AreEqual("RESULT-WIN", win.Id);
            var lose = StoryVersusSession.BuildResultDialogue((int)StoryTurnSide.Ai);
            Assert.AreEqual("RESULT-LOSE", lose.Id);
            var draw = StoryVersusSession.BuildResultDialogue(-1);
            Assert.AreEqual("RESULT-DRAW", draw.Id);
        }

        [Test]
        public void FiftyRoundTurnAlternatesAfterPair()
        {
            var session = new StoryVersusSession();
            session.BeginFiftyRoundMatch();
            session.AssignBreakBreaker(StoryTurnSide.Ai);
            Assert.IsTrue(session.TryBeginShot(StoryTurnSide.Ai));
            session.OnTargetHit();
            session.EndShot();
            session.Tick(StoryConstants.TurnBannerSeconds + 0.1f);
            Assert.AreEqual(StoryTurnSide.Player, session.CurrentTurn);

            Assert.IsTrue(session.TryBeginShot(StoryTurnSide.Player));
            session.OnTargetHit();
            session.EndShot();
            session.Tick(StoryConstants.TurnBannerSeconds + 0.1f);
            Assert.AreEqual(StoryTurnSide.Ai, session.CurrentTurn);

            Assert.IsTrue(session.TryBeginShot(StoryTurnSide.Ai));
            session.OnTargetHit();
            session.EndShot();
            session.Tick(StoryConstants.TurnBannerSeconds + 0.1f);
            Assert.AreEqual(StoryTurnSide.Player, session.CurrentTurn);
            Assert.AreEqual(1, session.CompletedPairs);
        }
    }
}
