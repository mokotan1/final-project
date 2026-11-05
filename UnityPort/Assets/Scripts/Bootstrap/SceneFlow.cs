using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using UnityEngine.SceneManagement;

namespace CushionChallenge.Bootstrap
{
    public static class SceneFlow
    {
        public static void LoadInitialFromBoot()
        {
            if (!PortSaveStore.StoryIntroSeen && !PortSaveStore.StoryFirstMatchDone)
                LoadStoryIntro();
            else
                LoadMainMenu();
        }

        public static void LoadMainMenu() => SceneManager.LoadScene(PortScenes.MainMenu);

        public static void LoadStoryIntro() => SceneManager.LoadScene(PortScenes.StoryIntro);

        public static void LoadGamePlay(GameModeKind mode)
        {
            SessionRequest.PendingMode = mode;
            SceneManager.LoadScene(PortScenes.GamePlay);
        }
    }
}
