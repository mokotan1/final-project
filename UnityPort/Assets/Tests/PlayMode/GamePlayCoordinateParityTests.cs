using System.Collections;
using CushionChallenge.Gameplay;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.TestTools;

namespace CushionChallenge.Tests.PlayMode
{
    public class GamePlayCoordinateParityTests
    {
        [UnityTest]
        public IEnumerator BallDisplayTracksGameMakerCoordinatesWithoutMovingPhysics()
        {
            SceneManager.LoadScene("GamePlay", LoadSceneMode.Single);
            yield return null;
            var room = Object.FindFirstObjectByType<GameRoomController>();
            var ball = room.transform.Find("TargetBall");
            Assert.That(ball.position.x, Is.EqualTo(640).Within(0.01f));
            Assert.That(ball.position.y, Is.EqualTo(260).Within(0.01f));
            var visual = ball.Find("GmVisual");
            Assert.IsNotNull(visual, "a separate visual must preserve the GM physics transform");
            Assert.That(visual.position.y, Is.EqualTo(460).Within(0.01f));
            ball.position = new Vector3(650, 480, 0);
            yield return null;
            Assert.That(ball.position.y, Is.EqualTo(480).Within(0.01f));
            Assert.That(visual.position.x, Is.EqualTo(650).Within(0.01f));
            Assert.That(visual.position.y, Is.EqualTo(240).Within(0.01f));
            Assert.IsFalse(ball.GetComponent<SpriteRenderer>().enabled, "do not draw the physics transform");
            Assert.IsTrue(visual.GetComponent<SpriteRenderer>().enabled);
            ball.gameObject.SetActive(false);
            Assert.IsFalse(visual.gameObject.activeInHierarchy);
            ball.gameObject.SetActive(true);
            yield return null;
            Assert.IsTrue(visual.gameObject.activeInHierarchy);
        }

        [Test]
        public void ScreenWorldAndGameMakerRoomCoordinatesAreInverses()
        {
            var room = new Vector3(520, 480, 0);
            Assert.AreEqual(new Vector3(520, 240, 0), GameMakerDisplay.ToDisplay(room));
            Assert.AreEqual(room, GameMakerDisplay.ToRoom(GameMakerDisplay.ToDisplay(room)));
        }

        [UnityTest]
        public IEnumerator TableBoundsMatchGameMakerRoomBackground()
        {
            SceneManager.LoadScene("GamePlay", LoadSceneMode.Single);
            yield return null;
            var room = Object.FindFirstObjectByType<GameRoomController>();
            var bounds = room.transform.Find("Table").GetComponent<SpriteRenderer>().bounds;
            Assert.That(bounds.center.x, Is.EqualTo(640).Within(0.01f));
            Assert.That(bounds.center.y, Is.EqualTo(370).Within(0.01f));
            Assert.That(bounds.size.y, Is.EqualTo(520).Within(0.01f));
        }
    }
}
