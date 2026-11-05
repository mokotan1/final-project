using System.IO;
using CushionChallenge.Bootstrap;
using CushionChallenge.Gameplay;
using CushionChallenge.Physics;
using CushionChallenge.UI;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem.UI;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;

namespace CushionChallenge.Editor
{
    public static class PortSceneSetup
    {
        const string ScenesFolder = "Assets/Scenes";
        const string BootScenePath = ScenesFolder + "/Boot.unity";

        [InitializeOnLoadMethod]
        static void EnsureScenesOnEditorLoad()
        {
            if (Application.isBatchMode)
                return;
            if (EditorApplication.isPlayingOrWillChangePlaymode)
                return;
            if (AssetDatabase.LoadAssetAtPath<SceneAsset>(BootScenePath) != null)
                return;
            EditorApplication.delayCall += () =>
            {
                if (AssetDatabase.LoadAssetAtPath<SceneAsset>(BootScenePath) != null)
                    return;
                PerformSetup();
            };
        }

        [MenuItem("Cushion Challenge/Setup Port Scenes")]
        public static void SetupFromMenu() => PerformSetup();

        public static void PerformSetup()
        {
            Directory.CreateDirectory(Path.Combine(Application.dataPath, "Scenes"));

            CreateBootScene();
            CreateMainMenuScene();
            CreateStoryIntroScene();
            CreateGamePlayScene();

            ApplyBuildSettings();
            AssetDatabase.SaveAssets();
            Debug.Log("Port scenes created/updated. Boot is the player start scene.");
        }

        static void CreateBootScene()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            AddGlobalLight2DIfNeeded();
            var boot = new GameObject("Boot");
            boot.AddComponent<BootSceneController>();
            SaveScene(scene, PortScenes.Boot);
        }

        static void CreateMainMenuScene()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            AddGlobalLight2DIfNeeded();
            ConfigureMainCamera();
            AddEventSystem();

            var menuRoot = new GameObject("MainMenu");
            menuRoot.AddComponent<MainMenuController>();
            MainMenuUiBuilder.Build(menuRoot.transform, _ => { }, () => { });

            SaveScene(scene, PortScenes.MainMenu);
        }

        static void CreateStoryIntroScene()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            AddGlobalLight2DIfNeeded();
            ConfigureMainCamera();
            AddEventSystem();

            var introRoot = new GameObject("StoryIntro");
            introRoot.AddComponent<StoryIntroController>();
            StoryIntroUiBuilder.Build(introRoot.transform, out _, out _);

            SaveScene(scene, PortScenes.StoryIntro);
        }

        static void CreateGamePlayScene()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            AddGlobalLight2DIfNeeded();
            ConfigureMainCamera();
            AddEventSystem();

            var room = new GameObject("GameRoom");
            var controller = room.AddComponent<GameRoomController>();

            var table = new GameObject("Table");
            table.transform.SetParent(room.transform, false);
            table.AddComponent<SpriteRenderer>();
            TableCushionLayout.EnsureCushions(room.transform);

            foreach (var ballName in new[] { "PlayerBall", "AiBall", "TargetBall", "FoulBallA", "FoulBallB" })
            {
                var ball = new GameObject(ballName);
                ball.transform.SetParent(room.transform, false);
                ball.AddComponent<SpriteRenderer>();
            }

            var uiRoot = new GameObject("RuntimeUi");
            uiRoot.transform.SetParent(room.transform, false);

            var cue = new GameObject("Cue");
            cue.transform.SetParent(room.transform, false);
            cue.AddComponent<CueAimController>();

            var dialogue = new GameObject("StoryDialogue");
            dialogue.transform.SetParent(room.transform, false);
            dialogue.AddComponent<StoryDialoguePanel>();

            SaveScene(scene, PortScenes.GamePlay);
            _ = controller;
        }

        static void ConfigureMainCamera()
        {
            var camGo = new GameObject("Main Camera");
            camGo.tag = "MainCamera";
            var cam = camGo.AddComponent<Camera>();
            camGo.AddComponent<AudioListener>();
            PortSceneCamera.ApplyToExisting(cam);
        }

        static void AddEventSystem()
        {
            var es = new GameObject("EventSystem");
            es.AddComponent<EventSystem>();
            es.AddComponent<InputSystemUIInputModule>();
        }

        static void AddGlobalLight2DIfNeeded()
        {
            if (Object.FindAnyObjectByType<Light2D>() != null)
                return;
            var lightGo = new GameObject("Global Light 2D");
            lightGo.AddComponent<Light2D>();
        }

        static void SaveScene(Scene scene, string sceneName)
        {
            var path = $"{ScenesFolder}/{sceneName}.unity";
            EditorSceneManager.SaveScene(scene, path);
        }

        static void ApplyBuildSettings()
        {
            var entries = new EditorBuildSettingsScene[PortScenes.BuildOrder.Length];
            for (var i = 0; i < PortScenes.BuildOrder.Length; i++)
            {
                var path = PortScenes.BuildOrder[i];
                entries[i] = new EditorBuildSettingsScene(path, true);
            }

            EditorBuildSettings.scenes = entries;

            var productSettings = AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/ProjectSettings.asset");
            if (productSettings.Length > 0)
            {
                var so = new SerializedObject(productSettings[0]);
                var defaultScene = so.FindProperty("templateDefaultScene");
                if (defaultScene != null)
                {
                    defaultScene.stringValue = "Assets/Scenes/Boot.unity";
                    so.ApplyModifiedPropertiesWithoutUndo();
                }
            }
        }
    }
}
