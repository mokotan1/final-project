using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class StoryDialoguePanel : MonoBehaviour
    {
        Text _speaker;
        Text _line;

        void Awake()
        {
            var canvasGo = new GameObject("DialogueCanvas");
            canvasGo.transform.SetParent(transform);
            var canvas = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvasGo.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            canvasGo.GetComponent<CanvasScaler>().referenceResolution = new Vector2(1280, 720);
            canvasGo.AddComponent<GraphicRaycaster>();

            var panel = new GameObject("Panel");
            panel.transform.SetParent(canvasGo.transform, false);
            var panelRt = panel.AddComponent<RectTransform>();
            panelRt.anchorMin = new Vector2(0.05f, 0.02f);
            panelRt.anchorMax = new Vector2(0.95f, 0.22f);
            panelRt.offsetMin = Vector2.zero;
            panelRt.offsetMax = Vector2.zero;
            panel.AddComponent<Image>().color = new Color(0f, 0f, 0f, 0.75f);

            _speaker = CreateText(panel.transform, "Speaker", new Vector2(20, -10), 22, FontStyle.Bold);
            _line = CreateText(panel.transform, "Line", new Vector2(20, -40), 18, FontStyle.Normal);
            Hide();
        }

        static Text CreateText(Transform parent, string name, Vector2 anchored, int size, FontStyle style)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.anchorMin = new Vector2(0, 1);
            rt.anchorMax = new Vector2(1, 1);
            rt.pivot = new Vector2(0, 1);
            rt.offsetMin = new Vector2(anchored.x, anchored.y - 80);
            rt.offsetMax = new Vector2(-20, anchored.y);
            var text = go.AddComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            text.fontSize = size;
            text.fontStyle = style;
            text.color = Color.white;
            text.alignment = TextAnchor.UpperLeft;
            text.horizontalOverflow = HorizontalWrapMode.Wrap;
            return text;
        }

        public void Show(string speaker, string line)
        {
            _speaker.text = speaker ?? "";
            _line.text = line ?? "";
            gameObject.SetActive(true);
        }

        public void Hide()
        {
            if (_speaker != null)
            {
                _speaker.text = "";
                _line.text = "";
            }
        }
    }
}
