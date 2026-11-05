using UnityEngine;

namespace CushionChallenge.Core
{
    /// <summary>PlayerPrefs mirror of GameMaker cushion_foul_void_save.ini (UnityPort only).</summary>
    public static class PortSaveStore
    {
        const string BestEndless = "record.best_score_endless";
        const string BestClassic = "record.best_score_classic";
        const string BestLegacy = "record.best_score";
        const string AudioVolume = "record.audio_volume";
        const string Language = "record.language";
        const string KeyStoryIntroSeen = "story.story_intro_seen";
        const string KeyStoryFirstMatchDone = "story.story_first_match_done";

        public static int LoadBestScore(GameModeKind mode)
        {
            var key = GameModeRules.BestScoreKey(mode);
            var value = PlayerPrefs.GetInt(key, 0);
            if (value == 0 && mode == GameModeKind.Endless)
                value = PlayerPrefs.GetInt(BestLegacy, 0);
            return value;
        }

        public static void SaveBestScore(GameModeKind mode, int score)
        {
            var key = GameModeRules.BestScoreKey(mode);
            PlayerPrefs.SetInt(key, score);
            if (mode == GameModeKind.Endless)
                PlayerPrefs.SetInt(BestLegacy, score);
            PlayerPrefs.Save();
        }

        public static int AudioVolumePercent
        {
            get => PlayerPrefs.GetInt(AudioVolume, 100);
            set
            {
                PlayerPrefs.SetInt(AudioVolume, Mathf.Clamp(value, 0, 100));
                PlayerPrefs.Save();
            }
        }

        public static int LanguageIndex
        {
            get => PlayerPrefs.GetInt(Language, 0);
            set
            {
                PlayerPrefs.SetInt(Language, value);
                PlayerPrefs.Save();
            }
        }

        public static bool StoryIntroSeen
        {
            get => PlayerPrefs.GetInt(KeyStoryIntroSeen, 0) > 0;
            set
            {
                PlayerPrefs.SetInt(KeyStoryIntroSeen, value ? 1 : 0);
                PlayerPrefs.Save();
            }
        }

        public static bool StoryFirstMatchDone
        {
            get => PlayerPrefs.GetInt(KeyStoryFirstMatchDone, 0) > 0;
            set
            {
                PlayerPrefs.SetInt(KeyStoryFirstMatchDone, value ? 1 : 0);
                PlayerPrefs.Save();
            }
        }
    }
}
