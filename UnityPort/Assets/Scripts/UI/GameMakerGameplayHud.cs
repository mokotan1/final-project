using CushionChallenge.Core;
using CushionChallenge.Rules;
using CushionChallenge.Story;
using CushionChallenge.UI;
using UnityEngine;

namespace CushionChallenge.Gameplay
{
    /// <summary>Draw_64 HUD subset at GameMaker GUI coordinates (1280×720).</summary>
    public class GameMakerGameplayHud : MonoBehaviour
    {
        GameRoomController _room;
        CueAimController _cue;
        GUIStyle _label;
        GUIStyle _labelGold;
        float _powerNormalized;

        public static GameMakerGameplayHud Ensure(GameRoomController room)
        {
            var existing = room.GetComponent<GameMakerGameplayHud>();
            if (existing != null)
                return existing;
            return room.gameObject.AddComponent<GameMakerGameplayHud>();
        }

        void Awake()
        {
            _room = GetComponent<GameRoomController>();
            _cue = GetComponentInChildren<CueAimController>(true);
            BuildStyles();
        }

        void BuildStyles()
        {
            _label = new GUIStyle
            {
                font = GameUiFonts.Body,
                fontSize = 14,
                normal = { textColor = Color.white },
                alignment = TextAnchor.UpperLeft
            };
            _labelGold = new GUIStyle(_label)
            {
                normal = { textColor = new Color(0.835f, 0.659f, 0.333f) }
            };
        }

        void Update()
        {
            if (_cue == null)
                _cue = GetComponentInChildren<CueAimController>(true);
            _powerNormalized = 0f;
            if (_cue != null && _cue.TryGetPowerNormalized(out var power))
                _powerNormalized = power;
        }

        void OnGUI()
        {
            if (_room == null)
                return;
            var scale = new Vector2(Screen.width / (float)GameConstants.TargetWidth, Screen.height / (float)GameConstants.TargetHeight);
            var matrix = GUI.matrix;
            GUI.matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, new Vector3(scale.x, scale.y, 1f));
            if (_room.Mode == GameModeKind.StoryFiftyRound)
                DrawStoryHud(_room.StorySession);
            else
                DrawEndlessHud(_room.Mode, _room.EndlessRules);
            GUI.matrix = matrix;
        }

        public StoryVersusSession StorySession => _room?.StorySession;
        public EndlessRulesEngine EndlessRules => _room?.EndlessRules;

        void DrawStoryHud(StoryVersusSession story)
        {
            if (story == null)
                return;
            var guiW = GameConstants.TargetWidth;
            var intro = story.IntroMatch;
            if (intro)
                DrawIntroTopBar(guiW, story);
            else
                DrawStandardStoryTopBar(guiW, story);
            DrawShopStrip(guiW, story);
        }

        void DrawIntroTopBar(float guiW, StoryVersusSession story)
        {
            var powerLeft = 24f;
            var powerRight = Mathf.Clamp(guiW * 0.27f, 250f, 330f);
            var panelLeft = powerRight + 16f;
            var panelRight = guiW - 18f;
            var columnW = (panelRight - panelLeft - 28f) / 3f;
            var column1 = panelLeft + 14f;
            var column2 = column1 + columnW;
            var column3 = column2 + columnW;

            DrawPanel(powerLeft, 8f, powerRight, 76f);
            GUI.Label(new Rect(powerLeft + 14f, 12f, powerRight - powerLeft - 28f, 24f), "파워", _labelGold);
            DrawMeter(powerLeft + 14f, 50f, powerRight - 14f, 66f, _powerNormalized);

            DrawPanel(panelLeft, 8f, panelRight, 76f);
            var roundLabel = story.BreakPending ? "브레이크"
                : $"{story.CurrentRoundNumber}/{StoryConstants.MaxTurns}";
            var turnLabel = story.CurrentTurn == StoryTurnSide.Player ? "손님 차례" : "바텐더 차례";
            var diff = story.PlayerScore - story.AiScore;
            var diffLabel = diff == 0 ? "동점" : $"차이 {Mathf.Abs(diff)}{(diff > 0 ? "↑" : "↓")}";
            GUI.Label(new Rect(column1, 11f, columnW - 12f, 24f), "합 " + roundLabel, _label);
            GUI.Label(new Rect(column2, 11f, columnW - 12f, 24f), "손님 " + story.PlayerScore, _label);
            GUI.Label(new Rect(column3, 11f, columnW - 12f, 24f), "바텐더 " + story.AiScore, _label);
            GUI.Label(new Rect(column1, 43f, columnW - 12f, 24f), diffLabel, _labelGold);
            GUI.Label(new Rect(column2, 43f, columnW - 12f, 24f), turnLabel, _labelGold);
            GUI.Label(new Rect(column3, 43f, columnW - 12f, 24f), "H 도움말", _label);
        }

        void DrawStandardStoryTopBar(float guiW, StoryVersusSession story)
        {
            DrawPanel(18f, 8f, guiW - 18f, 76f);
            var turnLabel = story.CurrentTurn == StoryTurnSide.Player ? "손님 차례" : "바텐더 차례";
            GUI.Label(new Rect(32f, 14f, 400f, 24f),
                $"손님 {story.PlayerScore}   바텐더 {story.AiScore}   {turnLabel}", _label);
        }

        void DrawShopStrip(float guiW, StoryVersusSession story)
        {
            if (!story.IsHumanTurn())
                return;
            var y = 86f;
            DrawPanel(18f, y, guiW - 18f, y + 68f);
            GUI.Label(new Rect(32f, y + 10f, guiW - 64f, 48f),
                "[1] 이동 200   [2] 위험 800   [3] 파울 제거 400   Space 스킵", _labelGold);
            if (!string.IsNullOrEmpty(story.ItemMessage))
                GUI.Label(new Rect(32f, y + 36f, guiW - 64f, 24f), story.ItemMessage, _label);
        }

        void DrawEndlessHud(GameModeKind mode, EndlessRulesEngine rules)
        {
            if (rules == null)
                return;
            var guiW = GameConstants.TargetWidth;
            var powerLeft = 24f;
            var powerRight = Mathf.Clamp(guiW * 0.22f, 220f, 280f);
            DrawPanel(powerLeft, 8f, powerRight, 76f);
            GUI.Label(new Rect(powerLeft + 14f, 12f, 120f, 24f), "POWER", _labelGold);
            DrawMeter(powerLeft + 14f, 50f, powerRight - 14f, 66f, _powerNormalized);

            DrawPanel(powerRight + 16f, 8f, guiW - 18f, 76f);
            var header = GameModeRules.DisplayName(mode);
            GUI.Label(new Rect(powerRight + 30f, 12f, 500f, 24f), header, _labelGold);
            GUI.Label(new Rect(powerRight + 30f, 38f, guiW - powerRight - 48f, 24f),
                $"SCORE {rules.Score}   CHANCES {rules.Chances}   BEST {rules.BestScore}", _label);
            if (GameModeRules.ItemsEnabled(mode))
            {
                GUI.Label(new Rect(powerRight + 30f, 56f, guiW - powerRight - 48f, 24f),
                    $"ITEM {rules.Items.ItemMeter}/{rules.Items.ItemGoal}  INV {rules.Inventory.Count}  FOUL+{rules.Items.PendingFoulSpawns}",
                    _label);
            }
        }

        static void DrawPanel(float left, float top, float right, float bottom)
        {
            var dark = new Color(0.039f, 0.09f, 0.106f);
            DrawSolidRect(left, top, right, bottom, dark);
        }

        static void DrawMeter(float left, float top, float right, float bottom, float normalized)
        {
            DrawSolidRect(left, top, right, bottom, new Color(0.165f, 0.235f, 0.247f));
            var fillRight = left + (right - left) * Mathf.Clamp01(normalized);
            DrawSolidRect(left, top, fillRight, bottom, new Color(0.929f, 0.733f, 0.298f));
        }

        static void DrawSolidRect(float left, float top, float right, float bottom, Color color)
        {
            var prev = GUI.color;
            GUI.color = color;
            GUI.DrawTexture(new Rect(left, top, right - left, bottom - top), Texture2D.whiteTexture);
            GUI.color = prev;
        }
    }
}
