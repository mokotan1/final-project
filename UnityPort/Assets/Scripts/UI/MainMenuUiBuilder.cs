using System;
using CushionChallenge.Core;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public static class MainMenuUiBuilder
    {
        public const string MenuCanvasName = "MenuCanvas";

        public static bool HasMenuUi(Transform menuRoot) =>
            menuRoot != null && menuRoot.Find(MenuCanvasName) != null;

        public static void Build(Transform menuRoot, Action<GameModeKind> onModeSelected, Action onSettings)
        {
            if (HasMenuUi(menuRoot))
                return;

            var canvasGo = new GameObject(MenuCanvasName);
            canvasGo.transform.SetParent(menuRoot, false);
            var canvas = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvasGo.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            canvasGo.GetComponent<CanvasScaler>().referenceResolution = new Vector2(GameConstants.TargetWidth, GameConstants.TargetHeight);
            canvasGo.AddComponent<GraphicRaycaster>();

            var bg = CreateImage(canvas.transform, "Background", LoadSprite("Menu/spr_mode_select_bg"));
            Stretch(bg.rectTransform);

            CreateModeButton(canvas.transform, "Story", LoadSprite("Menu/spr_mode_select_story"), new Vector2(640, 420), GameModeKind.StoryFiftyRound, onModeSelected);
            CreateModeButton(canvas.transform, "Endless", LoadSprite("Menu/spr_mode_select_endless"), new Vector2(420, 320), GameModeKind.Endless, onModeSelected);
            CreateModeButton(canvas.transform, "Classic", LoadSprite("Menu/spr_mode_select_classic"), new Vector2(860, 320), GameModeKind.Classic, onModeSelected);

            var settingsGo = new GameObject("SettingsButton");
            settingsGo.transform.SetParent(canvas.transform, false);
            var srt = settingsGo.AddComponent<RectTransform>();
            srt.anchorMin = new Vector2(1, 1);
            srt.anchorMax = new Vector2(1, 1);
            srt.pivot = new Vector2(1, 1);
            srt.sizeDelta = new Vector2(120, 48);
            srt.anchoredPosition = new Vector2(-20, -20);
            settingsGo.AddComponent<Image>().color = new Color(0.15f, 0.15f, 0.2f, 0.9f);
            var sbtn = settingsGo.AddComponent<Button>();
            sbtn.onClick.AddListener(() =>
            {
                PortAudio.PlaySfx("snd_ui_click", 0.5f);
                onSettings?.Invoke();
            });
            var st = new GameObject("Label").AddComponent<Text>();
            st.transform.SetParent(settingsGo.transform, false);
            GameUiFonts.Apply(st);
            st.text = "설정";
            st.fontSize = 18;
            st.color = Color.white;
            st.alignment = TextAnchor.MiddleCenter;
            var strt = st.GetComponent<RectTransform>();
            strt.anchorMin = Vector2.zero;
            strt.anchorMax = Vector2.one;
            strt.offsetMin = Vector2.zero;
            strt.offsetMax = Vector2.zero;
        }

        static Sprite LoadSprite(string path) =>
            Resources.Load<Sprite>("GameArt/" + path);

        static Image CreateImage(Transform parent, string name, Sprite sprite)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent, false);
            var img = go.AddComponent<Image>();
            img.sprite = sprite;
            img.preserveAspect = true;
            return img;
        }

        static void Stretch(RectTransform rt)
        {
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;
        }

        static void CreateModeButton(
            Transform parent,
            string label,
            Sprite sprite,
            Vector2 pos,
            GameModeKind mode,
            Action<GameModeKind> onModeSelected)
        {
            var go = new GameObject(label);
            go.transform.SetParent(parent, false);
            var rt = go.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(220, 80);
            rt.anchoredPosition = pos - new Vector2(GameConstants.TargetWidth * 0.5f, GameConstants.TargetHeight * 0.5f);
            var img = go.AddComponent<Image>();
            img.sprite = sprite;
            img.preserveAspect = true;
            var btn = go.AddComponent<Button>();
            btn.onClick.AddListener(() =>
            {
                PortAudio.PlaySfx("snd_ui_click", 0.5f);
                onModeSelected?.Invoke(mode);
            });
        }
    }
}
