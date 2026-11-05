namespace CushionChallenge.Bootstrap
{
    /// <summary>Unity scene names (must match .unity file names under Assets/Scenes).</summary>
    public static class PortScenes
    {
        public const string Boot = "Boot";
        public const string MainMenu = "MainMenu";
        public const string StoryIntro = "StoryIntro";
        public const string GamePlay = "GamePlay";
        public const string SampleScene = "SampleScene";

        public static readonly string[] BuildOrder =
        {
            "Assets/Scenes/Boot.unity",
            "Assets/Scenes/MainMenu.unity",
            "Assets/Scenes/StoryIntro.unity",
            "Assets/Scenes/GamePlay.unity",
            "Assets/Scenes/SampleScene.unity"
        };
    }
}
