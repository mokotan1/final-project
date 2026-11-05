using System.Collections;
using CushionChallenge.Gameplay;
using CushionChallenge.UI;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.TestTools;

namespace CushionChallenge.Tests.PlayMode
{
    public class GamePlaySceneInitializationTests
    {
        [UnityTest]
        public IEnumerator GameArtUsesUnlitMaterialWithoutSceneLighting()
        {
            SceneManager.LoadScene("GamePlay", LoadSceneMode.Single);
            yield return null;
            var room = Object.FindFirstObjectByType<GameRoomController>();
            foreach (var name in new[] { "Table", "PlayerBall", "AiBall", "TargetBall", "FoulBallA", "FoulBallB" })
            {
                var renderer = room.transform.Find(name).GetComponent<SpriteRenderer>();
                Assert.IsNotNull(renderer.sharedMaterial, name);
                Assert.AreEqual("Universal Render Pipeline/2D/Sprite-Unlit-Default", renderer.sharedMaterial.shader.name, name);
            }
        }

        [UnityTest]
        public IEnumerator RuntimeSpritesAreReleasedOnSceneUnload()
        {
            SceneManager.LoadScene("GamePlay", LoadSceneMode.Single);
            yield return null;
            var room = Object.FindFirstObjectByType<GameRoomController>();
            var tableSprite = room.transform.Find("Table").GetComponent<SpriteRenderer>().sprite;
            var ballSprite = room.transform.Find("PlayerBall").GetComponent<SpriteRenderer>().sprite;
            SceneManager.LoadScene("MainMenu", LoadSceneMode.Single);
            yield return null;
            yield return null;
            Assert.IsTrue(tableSprite == null, "table sprite should be destroyed");
            Assert.IsTrue(ballSprite == null, "ball sprite should be destroyed");
        }

        [UnityTest]
        public IEnumerator ExistingSceneBallsReceiveKinematicRigidbodiesAndRoomInitializes()
        {
            SceneManager.LoadScene("GamePlay", LoadSceneMode.Single);
            yield return null;

            var room = Object.FindFirstObjectByType<GameRoomController>();
            Assert.IsNotNull(room);
            foreach (var name in new[] { "PlayerBall", "AiBall", "TargetBall", "FoulBallA", "FoulBallB" })
            {
                var ball = room.transform.Find(name);
                Assert.IsNotNull(ball, name);
                var body = ball.GetComponent<Rigidbody2D>();
                Assert.IsNotNull(body, name);
                Assert.AreEqual(RigidbodyType2D.Kinematic, body.bodyType, name);
                Assert.IsNotNull(ball.GetComponent<BilliardBallView>(), name);
            }
            Assert.IsNotNull(room.transform.Find("Cue"));
            Assert.IsNotNull(room.GetComponentInChildren<GameHudPanel>(true));
            var table = room.transform.Find("Table").GetComponent<SpriteRenderer>();
            Assert.IsNotNull(table.sprite, "table sprite");
            Assert.That(table.bounds.size.x, Is.EqualTo(960f).Within(0.1f), "table width");
            Assert.That(table.bounds.center.x, Is.EqualTo(640f).Within(0.1f), "table center x");
            foreach (var name in new[] { "PlayerBall", "AiBall", "TargetBall", "FoulBallA", "FoulBallB" })
            {
                var sprite = room.transform.Find(name).GetComponent<SpriteRenderer>();
                Assert.IsNotNull(sprite.sprite, name + " sprite");
                Assert.That(sprite.bounds.size.x, Is.EqualTo(36f).Within(0.1f), name + " width");
                Assert.Greater(sprite.sortingOrder, table.sortingOrder, name + " sorting");
            }
        }
    }
}
