using CushionChallenge.Core;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class SettingsPanel : MonoBehaviour
    {
        GameObject _root;
        Slider _volume;

        public static SettingsPanel Create(Transform parent)
        {
            var go = new GameObject("Settings");
            go.transform.SetParent(parent);
            return go.AddComponent<SettingsPanel>();
        }

        void Awake()
        {
            _root = new GameObject("Canvas");
            _root.transform.SetParent(transform);
            var canvas = _root.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 30;
            _root.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            _root.AddComponent<GraphicRaycaster>();
            _root.GetComponent<CanvasScaler>().referenceResolution = new Vector2(GameConstants.TargetWidth, GameConstants.TargetHeight);

            var dim = new GameObject("Dim");
            dim.transform.SetParent(_root.transform, false);
            var dimRt = dim.AddComponent<RectTransform>();
            dimRt.anchorMin = Vector2.zero;
            dimRt.anchorMax = Vector2.one;
            dimRt.offsetMin = Vector2.zero;
            dimRt.offsetMax = Vector2.zero;
            dim.AddComponent<Image>().color = new Color(0f, 0f, 0f, 0.6f);

            var title = MakeText(_root.transform, new Vector2(0, 120), 28, true);
            title.text = "설정";

            var volLabel = MakeText(_root.transform, new Vector2(0, 40), 20, false);
            volLabel.text = "볼륨";

            var sliderGo = new GameObject("Volume");
            sliderGo.transform.SetParent(_root.transform, false);
            var srt = sliderGo.AddComponent<RectTransform>();
            srt.anchorMin = srt.anchorMax = new Vector2(0.5f, 0.5f);
            srt.sizeDelta = new Vector2(400, 30);
            srt.anchoredPosition = new Vector2(0, 0);
            var sliderImage = sliderGo.AddComponent<Image>();
            sliderImage.color = new Color(0.3f, 0.3f, 0.35f);
            _volume = sliderGo.AddComponent<Slider>();
            _volume.targetGraphic = sliderImage;
            var handle = new GameObject("Handle", typeof(RectTransform), typeof(Image));
            handle.transform.SetParent(sliderGo.transform, false);
            var handleRect = handle.GetComponent<RectTransform>();
            handleRect.sizeDelta = new Vector2(18, 40);
            handle.GetComponent<Image>().color = Color.white;
            _volume.handleRect = handleRect;
            _volume.minValue = 0;
            _volume.maxValue = 100;
            _volume.value = PortSaveStore.AudioVolumePercent;
            _volume.onValueChanged.AddListener(v => PortSaveStore.AudioVolumePercent = Mathf.RoundToInt(v));

            var close = new GameObject("Close");
            close.transform.SetParent(_root.transform, false);
            var crt = close.AddComponent<RectTransform>();
            crt.anchorMin = crt.anchorMax = new Vector2(0.5f, 0.5f);
            crt.sizeDelta = new Vector2(180, 44);
            crt.anchoredPosition = new Vector2(0, -100);
            close.AddComponent<Image>().color = new Color(0.2f, 0.2f, 0.25f);
            var btn = close.AddComponent<Button>();
            btn.onClick.AddListener(Hide);
            var label = MakeText(close.transform, Vector2.zero, 18, false);
            label.text = "닫기";
            label.alignment = TextAnchor.MiddleCenter;
            var lrt = label.GetComponent<RectTransform>();
            lrt.anchorMin = Vector2.zero;
            lrt.anchorMax = Vector2.one;
            lrt.offsetMin = Vector2.zero;
            lrt.offsetMax = Vector2.zero;
            Hide();
        }

        static Text MakeText(Transform parent, Vector2 pos, int size, bool bold)
        {
            var go = new GameObject("Text");
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.sizeDelta = new Vector2(600, 60);
            rt.anchoredPosition = pos;
            var text = go.AddComponent<Text>();
            GameUiFonts.Apply(text, bold);
            text.fontSize = size;
            text.color = Color.white;
            text.alignment = TextAnchor.MiddleCenter;
            return text;
        }

        public void Toggle()
        {
            if (_root.activeSelf)
                Hide();
            else
                Show();
        }

        public void Show() => _root.SetActive(true);
        public void Hide() => _root.SetActive(false);
    }
}
