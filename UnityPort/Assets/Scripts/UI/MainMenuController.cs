using CushionChallenge.Bootstrap;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class MainMenuController : MonoBehaviour
    {
        SettingsPanel _settings;

        void Start()
        {
            PortSceneCamera.EnsureMainCamera();
            PortUiRuntime.EnsureEventSystem();
            _settings = SettingsPanel.Create(transform);
            if (!MainMenuUiBuilder.HasMenuUi(transform))
                MainMenuUiBuilder.Build(transform, OnModeSelected, () => _settings.Toggle());
            else
                BindSavedMenu();
        }

        void BindSavedMenu()
        {
            BindMode("Story", GameModeKind.StoryFiftyRound);
            BindMode("Endless", GameModeKind.Endless);
            BindMode("Classic", GameModeKind.Classic);
            var settingsButton = transform.Find("MenuCanvas/SettingsButton").GetComponent<Button>();
            settingsButton.onClick.AddListener(() =>
            {
                PortAudio.PlaySfx("snd_ui_click", 0.5f);
                _settings.Toggle();
            });
        }

        void BindMode(string name, GameModeKind mode)
        {
            var button = transform.Find("MenuCanvas/" + name).GetComponent<Button>();
            button.onClick.AddListener(() =>
            {
                PortAudio.PlaySfx("snd_ui_click", 0.5f);
                OnModeSelected(mode);
            });
        }

        void OnModeSelected(GameModeKind mode)
        {
            SessionRequest.StoryIntroMatch = mode == GameModeKind.StoryFiftyRound && !PortSaveStore.StoryFirstMatchDone;
            SceneFlow.LoadGamePlay(mode);
        }
    }
}
