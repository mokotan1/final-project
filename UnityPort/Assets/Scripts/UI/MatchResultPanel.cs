using CushionChallenge.Core;
using CushionChallenge.Rules;
using CushionChallenge.Story;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class MatchResultPanel : MonoBehaviour
    {
        Text _title;
        Text _score;
        Text _best;
        Text _status;
        Button _menuBtn;

        public static MatchResultPanel Create(Transform parent, System.Action onMenu)
        {
            var go = new GameObject("MatchResult");
            go.transform.SetParent(parent);
            var panel = go.AddComponent<MatchResultPanel>();
            panel.Build(onMenu);
            go.SetActive(false);
            return panel;
        }

        void Build(System.Action onMenu)
        {
            var canvasGo = new GameObject("ResultCanvas");
            canvasGo.transform.SetParent(transform);
            var canvas = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 20;
            canvasGo.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            canvasGo.GetComponent<CanvasScaler>().referenceResolution = new Vector2(GameConstants.TargetWidth, GameConstants.TargetHeight);
            canvasGo.AddComponent<GraphicRaycaster>();

            var dim = new GameObject("Dim");
            dim.transform.SetParent(canvasGo.transform, false);
            var dimRt = dim.AddComponent<RectTransform>();
            dimRt.anchorMin = Vector2.zero;
            dimRt.anchorMax = Vector2.one;
            dimRt.offsetMin = Vector2.zero;
            dimRt.offsetMax = Vector2.zero;
            dim.AddComponent<Image>().color = new Color(0f, 0f, 0f, 0.55f);

            _title = MakeCentered(canvasGo.transform, 0, 120, 32, FontStyle.Bold);
            _score = MakeCentered(canvasGo.transform, 0, 40, 28, FontStyle.Normal);
            _best = MakeCentered(canvasGo.transform, 0, 0, 24, FontStyle.Normal);
            _status = MakeCentered(canvasGo.transform, 0, -50, 22, FontStyle.Italic);

            var btnGo = new GameObject("MenuButton");
            btnGo.transform.SetParent(canvasGo.transform, false);
            var btnRt = btnGo.AddComponent<RectTransform>();
            btnRt.anchorMin = btnRt.anchorMax = new Vector2(0.5f, 0.5f);
            btnRt.sizeDelta = new Vector2(220, 48);
            btnRt.anchoredPosition = new Vector2(0, -120);
            var img = btnGo.AddComponent<Image>();
            img.color = new Color(0.2f, 0.2f, 0.25f, 0.95f);
            _menuBtn = btnGo.AddComponent<Button>();
            _menuBtn.targetGraphic = img;
            _menuBtn.onClick.AddListener(() => onMenu?.Invoke());
            var label = MakeCentered(btnGo.transform, 0, 0, 20, FontStyle.Bold);
            label.text = "MENU";
            label.alignment = TextAnchor.MiddleCenter;
            var lrt = label.GetComponent<RectTransform>();
            lrt.anchorMin = Vector2.zero;
            lrt.anchorMax = Vector2.one;
            lrt.offsetMin = Vector2.zero;
            lrt.offsetMax = Vector2.zero;
        }

        static Text MakeCentered(Transform parent, float x, float y, int size, FontStyle style)
        {
            var go = new GameObject("Text");
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.sizeDelta = new Vector2(900, 60);
            rt.anchoredPosition = new Vector2(x, y);
            var text = go.AddComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            GameUiFonts.Apply(text, style == FontStyle.Bold);
            text.fontSize = size;
            text.fontStyle = style;
            text.color = Color.white;
            text.alignment = TextAnchor.MiddleCenter;
            return text;
        }

        public void ShowEndless(EndlessRulesEngine rules)
        {
            _title.text = "RESULT";
            _score.text = $"SCORE {rules.Score}";
            _best.text = $"BEST {rules.BestScore}";
            if (rules.Score > rules.BestScore || rules.NewBestShown)
                _status.text = "NEW BEST";
            else if (rules.BestScore > rules.Score)
                _status.text = $"TO BEST {rules.BestScore - rules.Score}";
            else
                _status.text = "";
            gameObject.SetActive(true);
        }

        public void ShowStory(StoryVersusSession story)
        {
            _title.text = story.PlayerWon ? "YOU WIN" : story.Winner < 0 ? "DRAW" : "YOU LOSE";
            _score.text = $"YOU {story.PlayerScore}   AI {story.AiScore}";
            _best.text = story.ResultDialogue.Discount ?? "";
            _status.text = story.ResultDialogue.Text ?? "";
            gameObject.SetActive(true);
        }

        public void Hide() => gameObject.SetActive(false);
    }
}
