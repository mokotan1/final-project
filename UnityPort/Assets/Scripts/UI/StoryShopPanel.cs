using CushionChallenge.Rules;
using CushionChallenge.Story;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class StoryShopPanel : MonoBehaviour
    {
        Text _hint;
        Text _message;

        public static StoryShopPanel Create(Transform parent)
        {
            var go = new GameObject("StoryShop");
            go.transform.SetParent(parent);
            return go.AddComponent<StoryShopPanel>();
        }

        void Awake()
        {
            var canvasGo = new GameObject("ShopCanvas");
            canvasGo.transform.SetParent(transform);
            var canvas = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 8;
            canvasGo.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            canvasGo.GetComponent<CanvasScaler>().referenceResolution = new Vector2(1280, 720);

            _hint = MakeText(canvasGo.transform, new Vector2(20, -620), 16);
            _hint.text = "[1] Move 200  [2] Risk 800  [3] Remove foul 400   (player turn only)";
            _message = MakeText(canvasGo.transform, new Vector2(20, -650), 18);
        }

        static Text MakeText(Transform parent, Vector2 pos, int size)
        {
            var go = new GameObject("Text");
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.anchorMin = new Vector2(0, 1);
            rt.anchorMax = new Vector2(1, 1);
            rt.pivot = new Vector2(0, 1);
            rt.offsetMin = new Vector2(pos.x, pos.y - 40);
            rt.offsetMax = new Vector2(-20, pos.y);
            var text = go.AddComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            text.fontSize = size;
            text.color = new Color(1f, 0.95f, 0.7f);
            text.alignment = TextAnchor.UpperLeft;
            return text;
        }

        public void Refresh(StoryVersusSession story)
        {
            _message.text = story.ItemMessage ?? "";
            if (!string.IsNullOrEmpty(story.ItemMessage))
                _message.color = Color.white;
            else if (story.PlaceMode)
                _message.text = "Click table to place your ball";
            else if (story.PlayerRiskArmed)
                _message.text = "Risk shot armed for next shot";
        }
    }
}
