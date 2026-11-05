using System;
using System.Collections.Generic;
using CushionChallenge.Core;
using UnityEngine;

namespace CushionChallenge.Rules
{
    /// <summary>Endless/classic run state — port of scr_game_rules shot lifecycle (expanded).</summary>
    public class EndlessRulesEngine
    {
        public GameModeKind Mode { get; set; } = GameModeKind.Endless;
        public int Score { get; private set; }
        public int BestScore { get; private set; }
        public int Chances { get; private set; } = 3;
        public bool RiskShotArmed { get; set; }
        public bool ShotActive { get; private set; }
        public int ShotCushionCount { get; private set; }
        public bool ShotScored { get; private set; }
        public bool ShotPenalized { get; private set; }
        public int ShotPendingPoints { get; private set; }
        public int ZeroCushionStreak { get; private set; }
        public bool RiskShotActive { get; private set; }
        public bool GameOver { get; private set; }
        public float GameOverDelaySeconds { get; private set; }
        public bool NewBestShown { get; private set; }
        public bool PlaceMode { get; private set; }
        public bool PlaceFromItem { get; private set; }
        public bool RewardChoiceOpen { get; private set; }
        public EndlessItemProgression Items { get; } = new();

        public IReadOnlyList<GameItemKind> Inventory => Items.Inventory;

        public void ResetRun(int bestScore = -1)
        {
            Score = 0;
            BestScore = bestScore >= 0 ? bestScore : PortSaveStore.LoadBestScore(Mode);
            Chances = 3;
            Items.Reset();
            RiskShotArmed = false;
            ClearShot();
            GameOver = false;
            GameOverDelaySeconds = 0f;
            NewBestShown = false;
            PlaceMode = GameModeRules.ItemsEnabled(Mode);
            PlaceFromItem = false;
            RewardChoiceOpen = false;
        }

        public void Tick(float deltaSeconds)
        {
            if (GameOverDelaySeconds > 0f)
                GameOverDelaySeconds = Math.Max(0f, GameOverDelaySeconds - deltaSeconds);
        }

        public bool ResultReady => GameOver && GameOverDelaySeconds <= 0f;

        public void TryOpenRewardChoice(bool ballsStopped)
        {
            if (!GameModeRules.ItemsEnabled(Mode) || !ballsStopped || GameOver || ShotActive
                || !Items.PendingRewardChoice || RewardChoiceOpen)
                return;
            RewardChoiceOpen = true;
        }

        public bool TryChooseReward(GameItemKind item)
        {
            if (!RewardChoiceOpen || ShotActive || GameOver)
                return false;
            if (item is not (GameItemKind.Move or GameItemKind.RiskShot or GameItemKind.RemoveFoul))
                return false;

            Items.Inventory.Add(item);
            Items.TryDequeueRewardChoice(out var foulBonus);
            var cap = GameModeRules.FoulCap(Mode);
            if (foulBonus && Items.FoulCount + Items.PendingFoulSpawns < cap)
                Items.PendingFoulSpawns++;

            RewardChoiceOpen = Items.PendingRewardChoice;
            PortAudio.PlaySfx("snd_item", 0.55f);
            return true;
        }

        public bool TryBeginShot()
        {
            if (GameOver || ShotActive || PlaceMode || Items.PendingRewardChoice)
                return false;
            ShotActive = true;
            ShotCushionCount = 0;
            ShotScored = false;
            ShotPenalized = false;
            ShotPendingPoints = 0;
            RiskShotActive = RiskShotArmed;
            RiskShotArmed = false;
            return true;
        }

        public void OnTargetHit(int cushionCount)
        {
            if (!ShotActive || GameOver || ShotScored)
                return;
            ShotCushionCount = Math.Max(ShotCushionCount, cushionCount);
            ShotScored = true;
            if (ShotPenalized)
                return;
            var raw = EndlessScoreMath.ProvisionalTargetGain(ShotCushionCount, ZeroCushionStreak, RiskShotActive);
            ShotPendingPoints = EndlessScoreMath.CreditGain(raw, Score, Mode);
        }

        public void OnFoulHit(bool riskShotWasActive)
        {
            if (!ShotActive || GameOver || ShotPenalized)
                return;
            ShotPenalized = true;
            ShotPendingPoints = 0;
            if (riskShotWasActive || RiskShotActive)
            {
                Score = 0;
                Items.ItemMeter = 0;
            }
        }

        public void EndShot()
        {
            if (!ShotActive)
                return;

            if (ShotScored && !ShotPenalized)
            {
                if (Mode == GameModeKind.Endless)
                    Score = Math.Min(EndlessScoreMath.ScoreMax, Score + ShotPendingPoints);
                else
                    Score += ShotPendingPoints;

                if (ShotCushionCount == 0)
                    ZeroCushionStreak++;
                else
                    ZeroCushionStreak = 0;

                Chances = 3;
                var earned = Math.Min(2, ShotCushionCount) + (RiskShotActive ? 1 : 0);
                Items.ProcessProgression(earned, Mode);
                if (Score > BestScore)
                {
                    BestScore = Score;
                    NewBestShown = true;
                    PortSaveStore.SaveBestScore(Mode, BestScore);
                }
            }
            else
            {
                ZeroCushionStreak = 0;
                Chances = Math.Max(0, Chances - 1);
                if (ShotPenalized && !RiskShotActive)
                    Items.ProcessProgression(1, Mode);
            }

            if (Chances <= 0)
                FinishGame();

            ClearShot();
        }

        public bool TryUseInventoryItem(GameItemKind item)
        {
            if (GameOver || ShotActive || !Items.TryConsumeInventory(item))
                return false;
            switch (item)
            {
                case GameItemKind.RiskShot:
                    if (!RiskShotArmed)
                    {
                        RiskShotArmed = true;
                        PortAudio.PlaySfx("snd_item", 0.6f);
                    }

                    return true;
                case GameItemKind.Move:
                    PlaceMode = true;
                    PlaceFromItem = true;
                    PortAudio.PlaySfx("snd_item", 0.6f);
                    return true;
                case GameItemKind.RemoveFoul:
                    PortAudio.PlaySfx("snd_item", 0.6f);
                    return true;
            }

            return false;
        }

        public bool TryFinishPlaceMode(Vector2 pos, bool positionClear)
        {
            if (!PlaceMode || !positionClear)
                return false;
            PlaceMode = false;
            PlaceFromItem = false;
            return true;
        }

        void FinishGame()
        {
            GameOver = true;
            GameOverDelaySeconds = 0.5f;
            BestScore = Math.Max(BestScore, Score);
            PortSaveStore.SaveBestScore(Mode, BestScore);
        }

        void ClearShot()
        {
            ShotActive = false;
            ShotCushionCount = 0;
            ShotScored = false;
            ShotPenalized = false;
            ShotPendingPoints = 0;
            RiskShotActive = false;
        }
    }
}
