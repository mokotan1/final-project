using CushionChallenge.Core;
using CushionChallenge.Rules;
using CushionChallenge.Story;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class GameHudPanel : MonoBehaviour
    {
        Text _header;
        Text _line1;
        Text _line2;
        Text _line3;

        public static GameHudPanel Create(Transform parent)
        {
            var go = new GameObject("GameHud");
            go.transform.SetParent(parent);
            return go.AddComponent<GameHudPanel>();
        }

        void Awake()
        {
            var canvasGo = new GameObject("HudCanvas");
            canvasGo.transform.SetParent(transform);
            var canvas = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 5;
            var scaler = canvasGo.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(GameConstants.TargetWidth, GameConstants.TargetHeight);
            canvasGo.AddComponent<GraphicRaycaster>();

            _header = MakeText(canvasGo.transform, new Vector2(20, -20), 24, FontStyle.Bold);
            _line1 = MakeText(canvasGo.transform, new Vector2(20, -52), 20, FontStyle.Normal);
            _line2 = MakeText(canvasGo.transform, new Vector2(20, -78), 18, FontStyle.Normal);
            _line3 = MakeText(canvasGo.transform, new Vector2(20, -104), 16, FontStyle.Normal);
        }

        static Text MakeText(Transform parent, Vector2 anchored, int size, FontStyle style)
        {
            var go = new GameObject("Text");
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.anchorMin = new Vector2(0, 1);
            rt.anchorMax = new Vector2(1, 1);
            rt.pivot = new Vector2(0, 1);
            rt.offsetMin = new Vector2(anchored.x, anchored.y - 120);
            rt.offsetMax = new Vector2(-20, anchored.y);
            var text = go.AddComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            GameUiFonts.Apply(text, style == FontStyle.Bold);
            text.fontSize = size;
            text.fontStyle = style;
            text.color = Color.white;
            text.alignment = TextAnchor.UpperLeft;
            return text;
        }

        public void RefreshEndless(GameModeKind mode, EndlessRulesEngine rules)
        {
            _header.text = GameModeRules.DisplayName(mode);
            _line1.text = $"SCORE {rules.Score}   CHANCES {rules.Chances}";
            if (mode == GameModeKind.Classic)
            {
                _line2.text = $"FOUL CAP {GameModeRules.FoulCap(mode)}   ITEMS OFF";
                _line3.text = rules.RiskShotArmed ? "RISK SHOT ARMED" : "";
                return;
            }

            _line2.text =
                $"ITEM {rules.Items.ItemMeter}/{rules.Items.ItemGoal}   INV {rules.Inventory.Count}   FOUL+{rules.Items.PendingFoulSpawns}";
            _line3.text = rules.RiskShotArmed
                ? "RISK ARMED   [2] risk"
                : rules.PlaceMode
                    ? "PLACE BALL — click table"
                    : rules.RewardChoiceOpen
                        ? "REWARD CHOICE [1][2][3]"
                        : "[1] move [2] risk [3] remove foul when in inventory";
        }

        public void RefreshStory(StoryVersusSession story)
        {
            _header.text = story.MatchOver
                ? (story.PlayerWon ? "STORY WIN" : story.Winner < 0 ? "STORY DRAW" : "STORY LOSE")
                : $"STORY 50   R{story.CurrentRoundNumber}/{StoryConstants.MaxTurns}   PAIR {story.CompletedPairs}";
            _line1.text = $"YOU {story.PlayerScore}   AI {story.AiScore}";
            _line2.text = story.BreakPending
                ? "BREAK"
                : (story.CurrentTurn == StoryTurnSide.Player ? "YOUR TURN" : "AI TURN");
            _line3.text = story.RiskShotActive
                ? "RISK SHOT ACTIVE"
                : (story.TurnBannerPending ? story.TurnBannerText : story.ItemMessage);
        }
    }
}
