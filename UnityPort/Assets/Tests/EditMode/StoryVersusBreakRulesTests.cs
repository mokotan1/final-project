using CushionChallenge.Story;
using NUnit.Framework;

namespace CushionChallenge.Tests
{
    public class StoryVersusBreakRulesTests
    {
        [Test]
        public void BreakFoulRulesSuppressed_MatchesGameMakerPredicate()
        {
            Assert.IsTrue(StoryVersusBreakRules.BreakFoulRulesSuppressed(true, true));
            Assert.IsFalse(StoryVersusBreakRules.BreakFoulRulesSuppressed(true, false));
            Assert.IsFalse(StoryVersusBreakRules.BreakFoulRulesSuppressed(false, true));
        }

        [Test]
        public void TryShowBreakAssignDialogue_UsesBreakAssignCopy()
        {
            var session = new StoryVersusSession();
            session.IntroMatch = true;
            session.BeginFiftyRoundMatch();
            session.AssignBreakBreaker(StoryTurnSide.Ai);
            Assert.IsTrue(session.BreakAssignDialoguePending);
            Assert.IsTrue(session.TryShowBreakAssignDialogue());
            Assert.IsFalse(session.BreakAssignDialoguePending);
            Assert.IsTrue(session.Dialogue.HasVisibleDialogue);
        }
    }
}
