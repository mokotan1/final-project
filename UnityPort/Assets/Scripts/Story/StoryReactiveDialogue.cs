namespace CushionChallenge.Story
{
    public class StoryReactionCounters
    {
        public int PlayerFoul;
        public int PlayerMiss;
        public int PlayerHigh;
        public int Close;
        public int BartenderFoul;
        public int BartenderHigh;
    }

    /// <summary>story_versus_react_to_shot (intro match only).</summary>
    public static class StoryReactiveDialogue
    {
        public static void ReactToShot(
            StoryReactionCounters counters,
            StoryDialogueRuntime dialogue,
            StoryTurnSide turn,
            int points,
            bool foul,
            int playerScore,
            int aiScore,
            bool fiftyRoundMatch,
            bool introMatch)
        {
            if (!introMatch)
                return;

            string id;
            string text;
            if (turn == StoryTurnSide.Player)
            {
                if (foul)
                {
                    if (counters.PlayerFoul % 2 == 0)
                    {
                        id = "EVT-PLAYER-FOUL-01";
                        text = "붉은 공에 닿았네요. 승부가 저한테 기울겠는데요?";
                    }
                    else
                    {
                        id = "EVT-PLAYER-FOUL-02";
                        text = "아쉬운 실수예요. 제가 그 틈을 놓칠 것 같나요?";
                    }

                    counters.PlayerFoul++;
                }
                else if (points <= 0)
                {
                    if (counters.PlayerMiss % 2 == 0)
                    {
                        id = "EVT-PLAYER-MISS-01";
                        text = "빈손이네요? 제 차례엔 공이 좀 움직일 겁니다.";
                    }
                    else
                    {
                        id = "EVT-PLAYER-MISS-02";
                        text = "그 공은 아쉽네요. 자, 이번엔 제가 보여 드리죠.";
                    }

                    counters.PlayerMiss++;
                }
                else if (points > 1000)
                {
                    if (counters.PlayerHigh % 2 == 0)
                    {
                        id = "EVT-PLAYER-HIGH-01";
                        text = "잠깐, 그 각도를 읽었다고요? 생각보다 훨씬 잘 치시네요.";
                    }
                    else
                    {
                        id = "EVT-PLAYER-HIGH-02";
                        text = "그 점수는 예상 밖인데요. 제가 슬슬 진지해져야겠어요.";
                    }

                    counters.PlayerHigh++;
                }
                else if (aiScore > 0
                         && (fiftyRoundMatch || (playerScore < 300 && aiScore < 300))
                         && System.Math.Abs(playerScore - aiScore) <= StoryConstants.AiCloseMatchDiff)
                {
                    PickCloseLine(counters, out id, out text);
                }
                else
                {
                    id = "EVT-PLAYER-SCORE-01";
                    text = "좋은 샷이에요. 각도를 잘 읽으셨네요.";
                }
            }
            else
            {
                if (foul)
                {
                    if (counters.BartenderFoul % 2 == 0)
                    {
                        id = "EVT-BARTENDER-FOUL-01";
                        text = "제 실수예요. 이번엔 당신이 웃을 차례군요.";
                    }
                    else
                    {
                        id = "EVT-BARTENDER-FOUL-02";
                        text = "이런, 붉은 공이라니. 방심한 값을 치렀네요.";
                    }

                    counters.BartenderFoul++;
                }
                else if (points > 1000)
                {
                    if (counters.BartenderHigh % 2 == 0)
                    {
                        id = "EVT-BARTENDER-HIGH-01";
                        text = "봤죠? 이 테이블에선 제가 조금 더 익숙합니다.";
                    }
                    else
                    {
                        id = "EVT-BARTENDER-HIGH-02";
                        text = "벽을 몇 번이나 거쳤죠. 술값 계산이 다시 재밌어지네요.";
                    }

                    counters.BartenderHigh++;
                }
                else if (points > 0 && playerScore > 0
                         && (fiftyRoundMatch || (playerScore < 300 && aiScore < 300))
                         && System.Math.Abs(playerScore - aiScore) <= StoryConstants.AiCloseMatchDiff)
                {
                    PickCloseLine(counters, out id, out text);
                }
                else if (points > 0)
                {
                    id = "EVT-BARTENDER-SCORE-01";
                    text = "깔끔하게 들어갔죠? 제 점수도 올라갑니다.";
                }
                else
                {
                    id = "EVT-BARTENDER-MISS-01";
                    text = "이런, 제 공도 말을 안 듣네요. 이번엔 당신 차례예요.";
                }
            }

            dialogue.QueueReaction(id, text, 4f);
        }

        static void PickCloseLine(StoryReactionCounters counters, out string id, out string text)
        {
            if (counters.Close % 2 == 0)
            {
                id = "EVT-CLOSE-01";
                text = "점수 차가 1,600점 이내네요. 이제 한 번의 쿠션이 승부를 바꿔요.";
            }
            else
            {
                id = "EVT-CLOSE-02";
                text = "바로 뒤에 있군요. 좋아요, 이래야 승부답죠.";
            }

            counters.Close++;
        }
    }
}
