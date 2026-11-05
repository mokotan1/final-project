using System.IO;
using System.Linq;
using CushionChallenge.Bootstrap;
using NUnit.Framework;
using UnityEditor;

namespace CushionChallenge.Tests
{
    public class PortSceneSetupTests
    {
        [Test]
        public void BuildSettingsListsPortScenesInOrderWithBootFirst()
        {
            var enabled = EditorBuildSettings.scenes.Where(s => s.enabled).Select(s => s.path).ToArray();
            CollectionAssert.AreEqual(PortScenes.BuildOrder, enabled);
        }

        [Test]
        public void PortSceneAssetsExistOnDisk()
        {
            foreach (var path in PortScenes.BuildOrder)
            {
                var full = Path.GetFullPath(Path.Combine(UnityEngine.Application.dataPath, "..", path));
                Assert.IsTrue(File.Exists(full), "Missing scene file: " + path);
            }
        }

        [Test]
        public void SceneFlowConstantsMatchGameMakerRoomNamesConceptually()
        {
            Assert.AreEqual("Boot", PortScenes.Boot);
            Assert.AreEqual("MainMenu", PortScenes.MainMenu);
            Assert.AreEqual("StoryIntro", PortScenes.StoryIntro);
            Assert.AreEqual("GamePlay", PortScenes.GamePlay);
        }
    }
}
