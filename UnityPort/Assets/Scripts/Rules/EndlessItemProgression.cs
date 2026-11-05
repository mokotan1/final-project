using System.Collections.Generic;
using CushionChallenge.Core;

namespace CushionChallenge.Rules
{
    /// <summary>rules_process_item_meter / rules_process_classic_foul_pressure (subset).</summary>
    public class EndlessItemProgression
    {
        readonly List<bool> _pendingRewardFoulBonus = new();

        public int ItemMeter { get; set; }
        public int ItemGoal { get; set; } = 3;
        public int MilestoneIndex { get; set; }
        public List<GameItemKind> Inventory { get; } = new();
        public bool PendingRewardChoice => _pendingRewardFoulBonus.Count > 0;
        public int PendingFoulSpawns { get; set; }
        public int FoulCount { get; set; } = 1;
        public int ClassicFoulProgress { get; set; }
        public int ClassicFoulGoalIndex { get; set; }

        public void Reset()
        {
            ItemMeter = 0;
            ItemGoal = 3;
            MilestoneIndex = 0;
            Inventory.Clear();
            _pendingRewardFoulBonus.Clear();
            PendingFoulSpawns = 0;
            FoulCount = 1;
            ClassicFoulProgress = 0;
            ClassicFoulGoalIndex = 0;
        }

        public void ProcessProgression(int earned, GameModeKind mode)
        {
            if (GameModeRules.ItemsEnabled(mode))
                ProcessItemMeter(earned, mode);
            else
                ProcessClassicFoulPressure(mode);
        }

        void ProcessItemMeter(int earned, GameModeKind mode)
        {
            ItemMeter += earned;
            if (ItemMeter < ItemGoal)
                return;

            ItemMeter -= ItemGoal;
            var rewardIndex = MilestoneIndex;
            var reservedChoiceFouls = 0;
            foreach (var bonus in _pendingRewardFoulBonus)
            {
                if (bonus)
                    reservedChoiceFouls++;
            }

            if (rewardIndex < 3)
            {
                var item = GameItemRules.MilestoneItem(rewardIndex);
                if ((int)item > 0)
                    Inventory.Add(item);
                MilestoneIndex++;
            }
            else
            {
                var cap = GameModeRules.FoulCap(mode);
                var foulBonus = FoulCount + PendingFoulSpawns + reservedChoiceFouls < cap;
                _pendingRewardFoulBonus.Add(foulBonus);
                MilestoneIndex++;
            }

            ItemGoal = GameItemRules.NextItemGoal(rewardIndex);
            if (rewardIndex < 3 && FoulCount + PendingFoulSpawns < GameModeRules.FoulCap(mode))
                PendingFoulSpawns++;
        }

        void ProcessClassicFoulPressure(GameModeKind mode)
        {
            int[] goals = { 3, 5, 7 };
            if (ClassicFoulGoalIndex >= goals.Length)
                return;

            ClassicFoulProgress += 1;
            while (ClassicFoulGoalIndex < goals.Length
                   && ClassicFoulProgress >= goals[ClassicFoulGoalIndex])
            {
                ClassicFoulProgress -= goals[ClassicFoulGoalIndex];
                ClassicFoulGoalIndex++;
                var cap = GameModeRules.FoulCap(mode);
                if (FoulCount + PendingFoulSpawns < cap)
                    PendingFoulSpawns++;
            }
        }

        public bool TryConsumeInventory(GameItemKind item)
        {
            var idx = Inventory.IndexOf(item);
            if (idx < 0)
                return false;
            Inventory.RemoveAt(idx);
            return true;
        }

        public bool TryDequeueRewardChoice(out bool grantFoulSpawn)
        {
            grantFoulSpawn = false;
            if (_pendingRewardFoulBonus.Count == 0)
                return false;
            grantFoulSpawn = _pendingRewardFoulBonus[0];
            _pendingRewardFoulBonus.RemoveAt(0);
            return true;
        }
    }
}
