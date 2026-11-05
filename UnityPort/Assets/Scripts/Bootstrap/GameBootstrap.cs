using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using CushionChallenge.UI;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace CushionChallenge.Bootstrap
{
    public static class GameBootstrap
    {
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void AfterSceneLoad()
        {
            var scene = SceneManager.GetActiveScene();
            if (scene.name == PortScenes.Boot)
                return;
            if (Object.FindAnyObjectByType<GameRoomController>() != null)
                return;
            if (Object.FindAnyObjectByType<MainMenuController>() != null)
                return;
            if (Object.FindAnyObjectByType<StoryIntroController>() != null)
                return;
            if (Object.FindAnyObjectByType<BootSceneController>() != null)
                return;

            if (scene.name != PortScenes.SampleScene)
                return;

            if (PortSaveStore.StoryIntroSeen || PortSaveStore.StoryFirstMatchDone)
            {
                var go = new GameObject("MainMenu");
                go.AddComponent<MainMenuController>();
            }
            else
            {
                var intro = new GameObject("StoryIntro");
                intro.AddComponent<StoryIntroController>();
            }
        }
    }
}
