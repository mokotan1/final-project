using CushionChallenge.Rules;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class EndlessRewardChoicePanel : MonoBehaviour
    {
        Text _prompt;
        GameObject _root;

        public static EndlessRewardChoicePanel Create(Transform parent)
        {
            var go = new GameObject("EndlessRewardChoice");
            go.transform.SetParent(parent);
            return go.AddComponent<EndlessRewardChoicePanel>();
        }

        void Awake()
        {
            _root = new GameObject("Canvas");
            _root.transform.SetParent(transform);
            var canvas = _root.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 15;
            _root.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            _root.GetComponent<CanvasScaler>().referenceResolution = new Vector2(1280, 720);
            _root.AddComponent<GraphicRaycaster>();

            var dim = new GameObject("Dim");
            dim.transform.SetParent(_root.transform, false);
            var dimRt = dim.AddComponent<RectTransform>();
            dimRt.anchorMin = Vector2.zero;
            dimRt.anchorMax = Vector2.one;
            dimRt.offsetMin = Vector2.zero;
            dimRt.offsetMax = Vector2.zero;
            dim.AddComponent<Image>().color = new Color(0f, 0f, 0f, 0.35f);

            _prompt = MakeText(_root.transform, new Vector2(0, 80), 22);
            _prompt.alignment = TextAnchor.MiddleCenter;
            _prompt.text = "보상 선택 [1] 이동  [2] 위험 샷  [3] 파울 제거";

            MakeButton(_root.transform, "[1] Move", new Vector2(-240, -40), () => OnPick?.Invoke(GameItemKind.Move));
            MakeButton(_root.transform, "[2] Risk", new Vector2(0, -40), () => OnPick?.Invoke(GameItemKind.RiskShot));
            MakeButton(_root.transform, "[3] Remove", new Vector2(240, -40), () => OnPick?.Invoke(GameItemKind.RemoveFoul));
            Hide();
        }

        public System.Action<GameItemKind> OnPick;

        static Text MakeText(Transform parent, Vector2 pos, int size)
        {
            var go = new GameObject("Text");
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.sizeDelta = new Vector2(1100, 80);
            rt.anchoredPosition = pos;
            var text = go.AddComponent<Text>();
            GameUiFonts.Apply(text);
            text.fontSize = size;
            text.color = Color.white;
            return text;
        }

        static void MakeButton(Transform parent, string label, Vector2 pos, System.Action onClick)
        {
            var go = new GameObject(label);
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.sizeDelta = new Vector2(200, 48);
            rt.anchoredPosition = pos;
            var img = go.AddComponent<Image>();
            img.color = new Color(0.15f, 0.15f, 0.2f, 0.95f);
            var btn = go.AddComponent<Button>();
            btn.onClick.AddListener(() => onClick());
            var text = MakeText(go.transform, Vector2.zero, 18);
            text.text = label;
            text.alignment = TextAnchor.MiddleCenter;
            var trt = text.GetComponent<RectTransform>();
            trt.anchorMin = Vector2.zero;
            trt.anchorMax = Vector2.one;
            trt.offsetMin = Vector2.zero;
            trt.offsetMax = Vector2.zero;
        }

        public void Show() => _root.SetActive(true);
        public void Hide() => _root.SetActive(false);
    }
}
