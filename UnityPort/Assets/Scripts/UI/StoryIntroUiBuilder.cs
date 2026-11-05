using CushionChallenge.Core;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public static class StoryIntroUiBuilder
    {
        public const string IntroCanvasName = "IntroCanvas";
        public const string SpeakerName = "SpeakerText";
        public const string BodyName = "BodyText";
        static readonly Color Cream = new Color32(241, 228, 195, 255);
        static readonly Color Brass = new Color32(214, 169, 82, 255);

        public static bool HasIntroUi(Transform root) => root != null && root.Find(IntroCanvasName) != null;

        public static void Build(Transform root, out Text speaker, out Text body)
        {
            var old = root.Find(IntroCanvasName);
            var existingDialogue = old != null ? old.Find("DialogueScreen") : null;
            if (existingDialogue != null && old.Find("OpeningScreen") != null)
            {
                speaker = existingDialogue.Find(SpeakerName).GetComponent<Text>();
                body = existingDialogue.Find(BodyName).GetComponent<Text>();
                return;
            }
            var go = old != null ? old.gameObject : new GameObject(IntroCanvasName);
            if (old == null) go.transform.SetParent(root, false);
            var canvas = go.GetComponent<Canvas>();
            if (canvas == null) canvas = go.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            var scaler = go.GetComponent<CanvasScaler>();
            if (scaler == null) scaler = go.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1280, 720);
            scaler.matchWidthOrHeight = 0.5f;
            if (go.GetComponent<GraphicRaycaster>() == null) go.AddComponent<GraphicRaycaster>();

            var dialogue = Group(go.transform, "DialogueScreen");
            var bg = go.transform.Find("Bg");
            if (bg != null)
            {
                bg.SetParent(dialogue, false); bg.name = "Night";
                Place((RectTransform)bg, 0, 0, 1280, 720);
                var image = bg.GetComponent<Image>();
                if (image == null) image = bg.gameObject.AddComponent<Image>();
                var texture = Resources.Load<Texture2D>("GameArt/Opening/intro_night_background");
                if (texture != null && Application.isPlaying)
                {
                    var sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(0.5f, 0.5f));
                    image.sprite = sprite;
                    var owner = bg.gameObject.AddComponent<IntroGeneratedSpriteOwner>();
                    owner.sprite = sprite;
                }
                else if (texture != null)
                {
                    var sprites = Resources.LoadAll<Sprite>("GameArt/Opening/intro_night_background");
                    if (sprites.Length > 0) image.sprite = sprites[0];
                }
                image.color = Color.white; image.enabled = true; image.raycastTarget = false;
            }
            else AddTexture(dialogue, "Night", "GameArt/Opening/intro_night_background", 0, 0, 1280, 720);
            AddRect(dialogue, "Dim", 0, 0, 1280, 720, new Color(0, 0, 0, 0.42f));
            AddTexture(dialogue, "Bartender", "GameArt/Opening/intro_bartender", 893.72f, 109.76f, 232.56f, 522.24f);
            AddRect(dialogue, "Panel", 92, 440, 1096, 242, new Color32(15, 35, 32, 240));
            AddRect(dialogue, "Border", 92, 440, 1096, 6, Brass);
            speaker = MakeText(dialogue, SpeakerName, 130, 473, 930, 34, 24, Brass, go.transform.Find(SpeakerName));
            body = MakeText(dialogue, BodyName, 130, 526, 1000, 80, 24, Cream, go.transform.Find(BodyName));
            MakeText(dialogue, "HintText", 130, 640, 600, 28, 13, Cream, go.transform.Find("HintText")).text = "클릭 또는 ENTER";
            MakeText(dialogue, "CounterText", 1040, 639, 120, 28, 13, Brass);

            var opening = Group(go.transform, "OpeningScreen");
            AddTexture(opening, "OpeningImage", "GameArt/Opening/spr_story_opening", 0, 0, 1280, 720);
            AddRect(opening, "HintBackground", 18, 660, 392, 48, new Color(0, 0, 0, 0.75f));
            MakeText(opening, "HintText", 32, 676, 378, 30, 13, Cream).text = "클릭 / ENTER: 시작";
            var prompt = MakeText(opening, "StartPrompt", 410, 650, 460, 50, 24, Cream);
            prompt.alignment = TextAnchor.MiddleCenter;
            prompt.text = "시작하려면 클릭하세요";
            opening.gameObject.SetActive(false);
        }

        static Transform Group(Transform parent, string name)
        {
            var g = new GameObject(name, typeof(RectTransform));
            g.transform.SetParent(parent, false);
            var r = (RectTransform)g.transform;
            r.anchorMin = Vector2.zero; r.anchorMax = Vector2.one;
            r.offsetMin = Vector2.zero; r.offsetMax = Vector2.zero;
            return g.transform;
        }
        static RectTransform Box(Transform parent, string name, float x, float y, float w, float h)
        {
            var g = new GameObject(name, typeof(RectTransform));
            g.transform.SetParent(parent, false);
            var r = (RectTransform)g.transform;
            Place(r, x, y, w, h);
            return r;
        }
        static void Place(RectTransform r, float x, float y, float w, float h)
        {
            r.anchorMin = r.anchorMax = new Vector2(0, 1); r.pivot = new Vector2(0, 1);
            r.anchoredPosition = new Vector2(x, -y); r.sizeDelta = new Vector2(w, h);
        }
        static void AddRect(Transform parent, string name, float x, float y, float w, float h, Color color)
        {
            var image = Box(parent, name, x, y, w, h).gameObject.AddComponent<Image>();
            image.color = color; image.raycastTarget = false;
        }
        static void AddTexture(Transform parent, string name, string path, float x, float y, float w, float h)
        {
            var image = Box(parent, name, x, y, w, h).gameObject.AddComponent<RawImage>();
            image.texture = Resources.Load<Texture2D>(path);
            image.raycastTarget = false;
        }
        static Text MakeText(Transform parent, string name, float x, float y, float w, float h, int size, Color color, Transform existing = null)
        {
            RectTransform rect;
            if (existing != null)
            {
                existing.SetParent(parent, false);
                rect = (RectTransform)existing;
                Place(rect, x, y, w, h);
            }
            else rect = Box(parent, name, x, y, w, h);
            var text = rect.GetComponent<Text>();
            if (text == null) text = rect.gameObject.AddComponent<Text>();
            GameUiFonts.Apply(text); text.fontSize = size; text.color = color;
            text.alignment = TextAnchor.UpperLeft; text.raycastTarget = false;
            text.horizontalOverflow = HorizontalWrapMode.Overflow;
            text.verticalOverflow = VerticalWrapMode.Overflow;
            return text;
        }
    }

    public class IntroGeneratedSpriteOwner : MonoBehaviour
    {
        public Sprite sprite;
        void OnDestroy()
        {
            if (sprite != null) Destroy(sprite);
        }
    }
}
