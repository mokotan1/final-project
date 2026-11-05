using UnityEngine;

namespace CushionChallenge.Bootstrap
{
    /// <summary>Entry scene: routes to story intro or main menu (GameMaker rm_story_intro / rm_menu).</summary>
    public class BootSceneController : MonoBehaviour
    {
        void Start() => SceneFlow.LoadInitialFromBoot();
    }
}
