using System;
using System.Collections.Generic;
using CushionChallenge.Rules;
using UnityEngine;

namespace CushionChallenge.Story
{
    public enum StoryTurnSide
    {
        Player = 0,
        Ai = 1
    }

    public struct StoryResultDialogue
    {
        public string Id;
        public string Text;
        public string Discount;
    }

    /// <summary>50-round story match state (scr_story_versus.gml subset).</summary>
    public class StoryVersusSession
    {
        public bool Active { get; private set; }
        public bool FiftyRoundMatch { get; private set; } = true;
        public bool IntroMatch { get; set; } = true;
        public bool BreakAssignDialoguePending { get; set; }
        public bool BreakPending { get; set; }
        public bool BreakFollowupAiPending { get; set; }
        public StoryTurnSide BreakBreaker { get; set; } = StoryTurnSide.Player;
        public bool ShotIsBreak { get; set; }
        public int PlayerScore { get; private set; }
        public int AiScore { get; private set; }
        public int CompletedPairs { get; private set; }
        public StoryTurnSide CurrentTurn { get; private set; } = StoryTurnSide.Player;
        public bool MatchOver { get; private set; }
        public int Winner { get; private set; } = -1;
        public bool PlayerWon => Winner == (int)StoryTurnSide.Player;
        public bool PlayerRiskArmed { get; set; }
        public bool AiRiskArmed { get; set; }
        public bool RiskShotActive { get; private set; }
        public bool ItemUsedThisTurn { get; private set; }
        public bool PlaceMode { get; private set; }
        public bool RequestFoulRemoval { get; set; }
        public bool PendingAiRelocate { get; private set; }
        public int FoulBallCountOnTable { get; set; }
        public string ItemMessage { get; private set; } = "";
        float _itemMessageSeconds;

        public int AiRecoveryDuePair { get; private set; } = -1;
        public bool AiRecoveryRiskPending { get; private set; }
        public bool AiRecoveryRiskUsed { get; private set; }
        public int PlayerScoreAtTurnStart { get; set; }
        public bool TurnBannerPending { get; private set; }
        public float TurnBannerSeconds { get; private set; }
        public string TurnBannerText { get; private set; } = "";

        public bool ShotActive { get; private set; }
        public int ShotCushionCount { get; private set; }
        public bool ShotScored { get; private set; }
        public bool ShotPenalized { get; private set; }
        public int ShotPendingPoints { get; private set; }

        public StoryDialogueRuntime Dialogue { get; } = new();
        public StoryReactionCounters ReactionCounters { get; } = new();
        public StoryResultDialogue ResultDialogue { get; private set; }

        readonly List<Vector2> _removedFoulPositions = new();
        public IReadOnlyList<Vector2> RemovedFoulPositions => _removedFoulPositions;

        public int CurrentRoundNumber
        {
            get
            {
                if (!FiftyRoundMatch)
                    return 1;
                if (BreakPending || ShotIsBreak)
                    return 0;
                return Math.Min(StoryConstants.MaxTurns, Math.Max(1, CompletedPairs + 1));
            }
        }

        public void BeginFiftyRoundMatch()
        {
            Active = true;
            FiftyRoundMatch = true;
            MatchOver = false;
            Winner = -1;
            PlayerScore = 0;
            AiScore = 0;
            CompletedPairs = 0;
            BreakPending = true;
            BreakAssignDialoguePending = IntroMatch;
            BreakFollowupAiPending = false;
            ShotIsBreak = false;
            CurrentTurn = StoryTurnSide.Player;
            PlayerRiskArmed = false;
            AiRiskArmed = false;
            ItemUsedThisTurn = false;
            PlaceMode = false;
            AiRecoveryDuePair = -1;
            AiRecoveryRiskPending = false;
            AiRecoveryRiskUsed = false;
            PlayerScoreAtTurnStart = 0;
            TurnBannerPending = false;
            TurnBannerSeconds = 0f;
            ClearShot();
        }

        public void AssignBreakBreaker(StoryTurnSide breaker)
        {
            BreakBreaker = breaker;
            CurrentTurn = breaker;
        }

        /// <summary>scr_story_versus_roll_break_breaker — current GMS source always assigns AI for 50-round intro.</summary>
        public StoryTurnSide RollBreakBreaker() =>
            IntroMatch ? StoryTurnSide.Ai : StoryTurnSide.Ai;

        public bool TryShowBreakAssignDialogue()
        {
            if (!IntroMatch || !BreakAssignDialoguePending)
                return false;
            BreakAssignDialoguePending = false;
            var playerBreaks = BreakBreaker == StoryTurnSide.Player;
            Dialogue.ShowMain(
                "BREAK-ASSIGN",
                "Bartender",
                playerBreaks ? "손님이 브레이크를 치습니다." : "바텐더가 브레이크를 치습니다.",
                2f);
            return true;
        }

        public void Tick(float deltaSeconds)
        {
            Dialogue.Tick(deltaSeconds);
            if (_itemMessageSeconds > 0f)
            {
                _itemMessageSeconds -= deltaSeconds;
                if (_itemMessageSeconds <= 0f)
                    ItemMessage = "";
            }

            if (TurnBannerSeconds > 0f)
            {
                TurnBannerSeconds -= deltaSeconds;
                if (TurnBannerSeconds <= 0f)
                {
                    TurnBannerPending = false;
                    TurnBannerText = "";
                }
            }
        }

        public bool InputLocked() =>
            MatchOver || TurnBannerPending
            || StoryVersusBreakRules.InputLockedByBreakAssign(FiftyRoundMatch && IntroMatch, BreakAssignDialoguePending);

        public bool IsHumanTurn() =>
            Active && !MatchOver && CurrentTurn == StoryTurnSide.Player
            && !ShotActive && !PlaceMode && !InputLocked();

        public bool TryBeginShot(StoryTurnSide striker)
        {
            if (MatchOver || ShotActive || PlaceMode || InputLocked())
                return false;
            if (striker != CurrentTurn)
                return false;

            ShotIsBreak = FiftyRoundMatch && BreakPending;
            ShotActive = true;
            ShotCushionCount = 0;
            ShotScored = false;
            ShotPenalized = false;
            ShotPendingPoints = 0;
            if (striker == StoryTurnSide.Player)
            {
                RiskShotActive = PlayerRiskArmed;
                PlayerRiskArmed = false;
            }
            else
            {
                RiskShotActive = AiRiskArmed;
                AiRiskArmed = false;
            }

            return true;
        }

        public void OnCushionHit(int count)
        {
            if (!ShotActive || MatchOver || ShotScored || ShotPenalized)
                return;
            if (count <= ShotCushionCount)
                return;
            ShotCushionCount = Math.Max(ShotCushionCount, count);
        }

        public void OnTargetHit()
        {
            if (!ShotActive || MatchOver || ShotScored)
                return;
            ShotScored = true;
            if (ShotPenalized)
                return;
            ShotPendingPoints = RiskShotActive
                ? StoryScoreMath.RiskPointsForCushions(ShotCushionCount)
                : StoryScoreMath.NormalPointsForCushions(ShotCushionCount);
        }

        public void OnFoulHit()
        {
            if (!ShotActive || MatchOver || ShotPenalized)
                return;
            if (StoryVersusBreakRules.BreakFoulRulesSuppressed(FiftyRoundMatch && IntroMatch, ShotIsBreak))
                return;
            ShotPenalized = true;
            ShotPendingPoints = 0;
            if (RiskShotActive)
            {
                if (CurrentTurn == StoryTurnSide.Player)
                {
                    PlayerScore = 0;
                    SetItemMessage("파울이야. 위험 샷의 대가로 누적 점수가 0이 됐어.");
                }
                else
                    AiScore = 0;
            }
        }

        public void EndShot()
        {
            if (!ShotActive)
                return;

            var shotTurn = CurrentTurn;
            var points = ShotScored && !ShotPenalized ? ShotPendingPoints : 0;
            var foul = ShotPenalized;
            var wasBreak = FiftyRoundMatch && ShotIsBreak;
            var recoveryRiskShot = shotTurn == StoryTurnSide.Ai && AiRecoveryRiskPending && RiskShotActive;

            if (ShotScored && !ShotPenalized)
                AddScore(shotTurn, ShotPendingPoints);

            if (recoveryRiskShot)
            {
                AiRecoveryRiskUsed = true;
                AiRecoveryRiskPending = false;
            }
            else if (AiRecoveryRiskPending)
                AiRecoveryRiskPending = false;

            if (!MatchOver)
                StoryReactiveDialogue.ReactToShot(
                    ReactionCounters,
                    Dialogue,
                    shotTurn,
                    points,
                    foul,
                    PlayerScore,
                    AiScore,
                    FiftyRoundMatch,
                    IntroMatch);

            ClearShotFields();
            ItemUsedThisTurn = false;

            if (!FiftyRoundMatch)
                return;

            if (wasBreak)
            {
                BreakPending = false;
                CurrentTurn = Opposite(BreakBreaker);
                BreakFollowupAiPending = BreakBreaker == StoryTurnSide.Player;
                QueueTurnBanner("브레이크 후");
                return;
            }

            if (shotTurn == StoryTurnSide.Ai && BreakFollowupAiPending)
            {
                BreakFollowupAiPending = false;
                CurrentTurn = StoryTurnSide.Player;
                PlayerScoreAtTurnStart = PlayerScore;
                QueueTurnBanner("플레이어 턴");
                return;
            }

            if (shotTurn == StoryTurnSide.Player)
            {
                if (FiftyRoundMatch)
                    TryScheduleAiRecoveryRisk(PlayerScoreAtTurnStart > 0 ? PlayerScoreAtTurnStart : PlayerScore);
                CurrentTurn = StoryTurnSide.Ai;
                QueueTurnBanner("AI 턴");
                return;
            }

            CompletedPairs++;
            MaybeShowTurnMilestone();
            if (CompletedPairs >= StoryConstants.MaxTurns)
            {
                FinalizeMatch();
                return;
            }

            CurrentTurn = StoryTurnSide.Player;
            PlayerScoreAtTurnStart = PlayerScore;
            QueueTurnBanner($"R{CurrentRoundNumber}");
        }

        public void PassTurnNoShot()
        {
            if (MatchOver || ShotActive)
                return;

            ItemUsedThisTurn = false;
            AiRiskArmed = false;
            if (!FiftyRoundMatch)
                return;

            if (BreakPending && CurrentTurn == StoryTurnSide.Ai)
            {
                BreakPending = false;
                ShotIsBreak = false;
                CurrentTurn = Opposite(BreakBreaker);
                QueueTurnBanner("브레이크 패스");
                return;
            }

            if (BreakFollowupAiPending)
            {
                BreakFollowupAiPending = false;
                CurrentTurn = StoryTurnSide.Player;
                PlayerScoreAtTurnStart = PlayerScore;
                QueueTurnBanner("플레이어 턴");
                return;
            }

            CompletedPairs++;
            if (CompletedPairs >= StoryConstants.MaxTurns)
            {
                FinalizeMatch();
                return;
            }

            CurrentTurn = StoryTurnSide.Player;
            PlayerScoreAtTurnStart = PlayerScore;
            MaybeShowTurnMilestone();
            QueueTurnBanner($"R{CurrentRoundNumber}");
        }

        public void TryScheduleAiRecoveryRisk(int playerScoreBefore)
        {
            if (!FiftyRoundMatch || BreakPending || AiRecoveryRiskUsed || AiRecoveryDuePair >= 0)
                return;
            if (PlayerScore >= playerScoreBefore)
                return;
            if (AiScore - PlayerScore < StoryConstants.AiRiskLead)
                return;
            AiRecoveryDuePair = Math.Min(StoryConstants.MaxTurns, CurrentRoundNumber + UnityEngine.Random.Range(0, 10));
        }

        public bool ArmRecoveryRiskIfDue()
        {
            if (!FiftyRoundMatch || BreakPending || AiRecoveryRiskUsed || AiRecoveryRiskPending)
                return false;
            if (AiRecoveryDuePair < 0 || CurrentRoundNumber < AiRecoveryDuePair)
                return false;
            if (!TryPurchaseItem(GameItemKind.RiskShot, false, true))
                return false;
            AiRecoveryRiskPending = true;
            return true;
        }

        public void CancelRecoveryRiskPurchase()
        {
            AiRecoveryRiskPending = false;
            AiRiskArmed = false;
            var refund = GameItemRules.StoryPrice(GameItemKind.RiskShot, false);
            AiScore = StoryScoreMath.Add(AiScore, refund);
            ItemUsedThisTurn = false;
        }

        void QueueTurnBanner(string text)
        {
            TurnBannerPending = true;
            TurnBannerSeconds = StoryConstants.TurnBannerSeconds;
            TurnBannerText = text;
        }

        void FinalizeMatch()
        {
            PlayerScore = StoryScoreMath.Clamp(PlayerScore, 0, StoryConstants.ScoreMax);
            AiScore = StoryScoreMath.Clamp(AiScore, 0, StoryConstants.ScoreMax);
            if (PlayerScore > AiScore)
                Winner = (int)StoryTurnSide.Player;
            else if (AiScore > PlayerScore)
                Winner = (int)StoryTurnSide.Ai;
            else
                Winner = -1;
            MatchOver = true;
            Active = false;
            ResultDialogue = BuildResultDialogue();
            if (FiftyRoundMatch)
                Core.PortSaveStore.StoryFirstMatchDone = true;
        }

        public static StoryResultDialogue BuildResultDialogue(int winner)
        {
            if (winner == (int)StoryTurnSide.Player)
            {
                return new StoryResultDialogue
                {
                    Id = "RESULT-WIN",
                    Text = "졌다. 오늘 술값은 전액 깎아줄게. 다음엔 안 봐준다.",
                    Discount = "술값: 전액 할인"
                };
            }

            if (winner == (int)StoryTurnSide.Ai)
            {
                return new StoryResultDialogue
                {
                    Id = "RESULT-LOSE",
                    Text = "이번 판은 내 승리야. 술값은 원래대로 받는다.",
                    Discount = "술값: 할인 없음"
                };
            }

            return new StoryResultDialogue
            {
                Id = "RESULT-DRAW",
                Text = "끝까지 팽팽했네. 술값은 반값으로 하자.",
                Discount = "술값: 반값"
            };
        }

        StoryResultDialogue BuildResultDialogue() => BuildResultDialogue(Winner);

        void MaybeShowTurnMilestone()
        {
            var round = CompletedPairs;
            if (round == 25)
                QueueTurnLine("TURN-25", "절반 지났어요. 이제부터는 점수 차가 술값보다 크게 느껴질 거예요.", 4f);
            else if (round == 40)
                QueueTurnLine("TURN-40", "40합이에요. 남은 합마다 한 번의 실수가 바로 승패로 갈 수 있어요.", 4f);
            else if (round == 50)
                QueueTurnLine("TURN-50", "마지막 합이에요. 이 차례 끝나면 점수판으로 승부가 납니다.", 5f);
        }

        void QueueTurnLine(string id, string text, float seconds) =>
            Dialogue.QueueReaction(id, text, seconds);

        void AddScore(StoryTurnSide side, int points)
        {
            if (side == StoryTurnSide.Player)
                PlayerScore = StoryScoreMath.Add(PlayerScore, points);
            else
                AiScore = StoryScoreMath.Add(AiScore, points);
        }

        public bool TryPurchaseItem(GameItemKind item, bool playerSide, bool recovery = false)
        {
            if (playerSide)
            {
                if (!IsHumanTurn())
                    return false;
            }
            else if (CurrentTurn != StoryTurnSide.Ai || ShotActive)
            {
                return false;
            }

            if (ItemUsedThisTurn)
                return false;

            if (!playerSide && item == GameItemKind.RiskShot && !recovery
                && PlayerScore - AiScore < StoryConstants.AiRiskLead)
                return false;

            var price = GameItemRules.StoryPrice(item, playerSide);
            if (price < 0)
                return false;
            var score = playerSide ? PlayerScore : AiScore;
            if (score < price)
            {
                if (playerSide)
                    SetCantAffordMessage(item);
                return false;
            }

            var applied = false;
            switch (item)
            {
                case GameItemKind.Move:
                    if (playerSide)
                    {
                        PlaceMode = true;
                        SetItemMessage("200점을 내고 공을 옮겼어. 이동 자체로 점수는 없어.");
                        applied = true;
                    }
                    else
                    {
                        PendingAiRelocate = true;
                        applied = true;
                    }

                    break;
                case GameItemKind.RiskShot:
                    if (playerSide && !PlayerRiskArmed)
                    {
                        PlayerRiskArmed = true;
                        SetItemMessage("800점을 내고 위험 샷을 골랐어. 100×10^쿠션이야. 7쿠션 이상은 점수 상한.");
                        applied = true;
                    }
                    else if (!playerSide && !AiRiskArmed)
                    {
                        AiRiskArmed = true;
                        applied = true;
                    }

                    break;
                case GameItemKind.RemoveFoul:
                    if (FoulBallCountOnTable > 0)
                    {
                        RequestFoulRemoval = true;
                        if (playerSide)
                            SetItemMessage("400점을 내고 이번 턴 동안 파울 공을 모두 치웠어.");
                        applied = true;
                    }

                    break;
            }

            if (!applied)
                return false;

            if (playerSide)
            {
                PlayerScore = StoryScoreMath.Clamp(PlayerScore - price, 0, StoryConstants.ScoreMax);
                if (!recovery)
                    TryScheduleAiRecoveryRisk(score);
            }
            else
                AiScore = StoryScoreMath.Clamp(AiScore - price, 0, StoryConstants.ScoreMax);

            ItemUsedThisTurn = true;
            Core.PortAudio.PlaySfx("snd_item", 0.6f);
            return true;
        }

        public void NoteRemovedFoul(Vector2 pos) =>
            _removedFoulPositions.Add(pos);

        public void RestoreRemovedFouls()
        {
            _removedFoulPositions.Clear();
            RequestFoulRemoval = false;
        }

        public void AbortActiveShot()
        {
            ClearShotFields();
            ItemUsedThisTurn = false;
        }

        public bool ConsumePendingAiRelocate()
        {
            if (!PendingAiRelocate)
                return false;
            PendingAiRelocate = false;
            return true;
        }

        public bool TryFinishPlaceMode()
        {
            if (!PlaceMode)
                return false;
            PlaceMode = false;
            return true;
        }

        void SetCantAffordMessage(GameItemKind item)
        {
            switch (item)
            {
                case GameItemKind.Move:
                    SetItemMessage("공 이동은 200점이야. 지금 점수로는 살 수 없네.");
                    break;
                case GameItemKind.RiskShot:
                    SetItemMessage("위험 샷은 800점이야. 지금 점수로는 살 수 없네.");
                    break;
                case GameItemKind.RemoveFoul:
                    SetItemMessage("파울 제거는 400점이야. 지금 점수로는 살 수 없네.");
                    break;
            }
        }

        public void SetItemMessage(string text)
        {
            ItemMessage = text;
            _itemMessageSeconds = 3f;
        }

        void ClearShotFields()
        {
            ShotActive = false;
            ShotIsBreak = false;
            RiskShotActive = false;
            ShotPendingPoints = 0;
            ShotCushionCount = 0;
            ShotScored = false;
            ShotPenalized = false;
        }

        void ClearShot()
        {
            ClearShotFields();
            ShotActive = false;
        }

        public int AiDifficultyTier() =>
            StoryAiTier.DifficultyTier(FiftyRoundMatch, BreakPending, CurrentRoundNumber, PlayerScore, AiScore);

        static StoryTurnSide Opposite(StoryTurnSide turn) =>
            turn == StoryTurnSide.Player ? StoryTurnSide.Ai : StoryTurnSide.Player;
    }
}
