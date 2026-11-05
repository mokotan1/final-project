using System.Collections;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.TestTools;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System.Collections.Generic;

namespace CushionChallenge.Tests.PlayMode
{
    public class MainMenuSceneButtonTests
    {
        IEnumerator SelectMode(string buttonName, GameModeKind expected)
        {
            SceneManager.LoadScene("MainMenu");
            yield return null;
            var button = GameObject.Find("MainMenu/MenuCanvas/" + buttonName).GetComponent<Button>();
            button.onClick.Invoke();
            yield return null;
            Assert.AreEqual("GamePlay", SceneManager.GetActiveScene().name);
            Assert.AreEqual(expected, SessionRequest.PendingMode);
        }

        [UnityTest] public IEnumerator StoryStartsGame() => SelectMode("Story", GameModeKind.StoryFiftyRound);
        [UnityTest] public IEnumerator EndlessStartsGame() => SelectMode("Endless", GameModeKind.Endless);
        [UnityTest] public IEnumerator ClassicStartsGame() => SelectMode("Classic", GameModeKind.Classic);

        [UnityTest]
        public IEnumerator SettingsClickTogglesExactlyOnce()
        {
            SceneManager.LoadScene("MainMenu");
            yield return null;
            var root = GameObject.Find("MainMenu");
            var canvas = root.transform.Find("Settings/Canvas").gameObject;
            var button = root.transform.Find("MenuCanvas/SettingsButton").GetComponent<Button>();
            Assert.IsFalse(canvas.activeSelf);
            button.onClick.Invoke();
            Assert.IsTrue(canvas.activeSelf, "one click must open, not toggle twice");
            button.onClick.Invoke();
            Assert.IsFalse(canvas.activeSelf);
        }

        [UnityTest]
        public IEnumerator SettingsControlsReceivePointerRaycasts()
        {
            SceneManager.LoadScene("MainMenu");
            yield return null;
            var root = GameObject.Find("MainMenu");
            root.transform.Find("MenuCanvas/SettingsButton").GetComponent<Button>().onClick.Invoke();
            yield return null;
            Canvas.ForceUpdateCanvases();
            var panel = root.transform.Find("Settings/Canvas");
            foreach (var name in new[] { "Close", "Volume" })
            {
                var control = panel.Find(name);
                var pointer = new PointerEventData(EventSystem.current)
                {
                    position = RectTransformUtility.WorldToScreenPoint(null, control.position)
                };
                var hits = new List<RaycastResult>();
                EventSystem.current.RaycastAll(pointer, hits);
                Assert.IsTrue(hits.Exists(hit => hit.gameObject.transform == control || hit.gameObject.transform.IsChildOf(control)),
                    name + " must receive pointer raycasts");
            }
            var slider = panel.Find("Volume").GetComponent<Slider>();
            var oldValue = slider.value;
            var rect = (RectTransform)slider.transform;
            var click = new PointerEventData(EventSystem.current)
            {
                position = RectTransformUtility.WorldToScreenPoint(null, rect.TransformPoint(new Vector3(-rect.rect.width * 0.25f, 0, 0))),
                button = PointerEventData.InputButton.Left
            };
            slider.OnPointerDown(click);
            var actualValue = slider.value;
            slider.value = oldValue;
            Assert.That(actualValue, Is.InRange(20f, 30f), "clicking slider changes volume");
        }
    }
}
