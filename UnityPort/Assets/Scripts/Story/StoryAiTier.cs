namespace CushionChallenge.Story
{
    /// <summary>Port of story_ai_difficulty_tier from scr_story_ai.gml.</summary>
    public static class StoryAiTier
    {
        public static int DifficultyTier(
            bool fiftyRoundMatch,
            bool breakPending,
            int roundNumber,
            int playerScore,
            int aiScore)
        {
            if (!fiftyRoundMatch)
                return 1;
            if (breakPending)
                return 1;
            if (roundNumber <= 0)
                return 1;
            var playerLead = playerScore - aiScore;
            if (roundNumber <= 10 && playerLead < StoryConstants.AiCompetitiveGap)
                return 0;
            if (roundNumber >= 40 || playerLead >= StoryConstants.AiSoftLeadEnd)
                return 2;
            return 1;
        }
    }
}
