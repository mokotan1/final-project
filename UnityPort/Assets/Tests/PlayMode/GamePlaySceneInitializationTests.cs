using System.Collections;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using CushionChallenge.Rules;
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
            foreach (var renderer in room.GetComponentsInChildren<SpriteRenderer>(true))
            {
                if (renderer.sprite == null)
                    continue;
                Assert.IsNotNull(renderer.sharedMaterial, renderer.gameObject.name);
                Assert.AreEqual("Universal Render Pipeline/2D/Sprite-Unlit-Default", renderer.sharedMaterial.shader.name,
                    renderer.gameObject.name);
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
            SessionRequest.PendingMode = GameModeKind.Endless;
            SessionRequest.EndlessSpawnSeed = 4242;
            SceneManager.LoadScene("GamePlay", LoadSceneMode.Single);
            yield return null;

            var room = Object.FindFirstObjectByType<GameRoomController>();
            Assert.IsNotNull(room);
            foreach (var name in new[] { "PlayerBall", "TargetBall" })
            {
                var ball = room.transform.Find(name);
                Assert.IsNotNull(ball, name);
                var body = ball.GetComponent<Rigidbody2D>();
                Assert.IsNotNull(body, name);
                Assert.AreEqual(RigidbodyType2D.Kinematic, body.bodyType, name);
                Assert.IsNotNull(ball.GetComponent<BilliardBallView>(), name);
                Assert.IsNotNull(ball.Find("GmVisual"), name + " visual");
            }

            var ai = room.transform.Find("AiBall");
            if (ai != null)
                Assert.IsFalse(ai.gameObject.activeSelf, "endless mode must not keep AI striker active");

            Assert.IsNotNull(room.transform.Find("Cue"));
            Assert.IsNotNull(room.GetComponent<GameMakerGameplayHud>());
            var table = room.transform.Find("Table").GetComponent<SpriteRenderer>();
            Assert.IsNotNull(table.sprite, "table sprite");
            Assert.That(table.bounds.size.x, Is.EqualTo(960f).Within(0.1f), "table width");
            Assert.That(table.bounds.center.x, Is.EqualTo(640f).Within(0.1f), "table center x");
            foreach (var ball in room.GetComponentsInChildren<BilliardBallView>(true))
            {
                if (!ball.gameObject.activeSelf)
                    continue;
                var visual = ball.transform.Find("GmVisual");
                Assert.IsNotNull(visual, ball.name + " gm visual");
                var sprite = visual.GetComponent<SpriteRenderer>();
                Assert.IsNotNull(sprite.sprite, ball.name + " sprite");
                Assert.That(sprite.bounds.size.x, Is.EqualTo(36f).Within(0.1f), ball.name + " width");
                Assert.Greater(sprite.sortingOrder, table.sortingOrder, ball.name + " sorting");
            }
        }
    }
}
