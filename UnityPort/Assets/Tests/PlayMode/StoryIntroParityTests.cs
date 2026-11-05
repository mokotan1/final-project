using System.Collections;
using CushionChallenge.UI;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.TestTools;
using UnityEngine.UI;

namespace CushionChallenge.Tests.PlayMode
{
    public class StoryIntroParityTests
    {
        [UnityTest]
        public IEnumerator IntroShowsDialogueThenSeparateOpeningPrompt()
        {
            const string key = "story.story_intro_seen";
            var hadKey = PlayerPrefs.HasKey(key);
            var oldValue = PlayerPrefs.GetInt(key, 0);
            try
            {
                SceneManager.LoadScene("StoryIntro");
                yield return null;
                var canvas = GameObject.Find("StoryIntro/IntroCanvas").transform;
                var dialogue = canvas.Find("DialogueScreen");
                var opening = canvas.Find("OpeningScreen");
                Assert.IsNotNull(dialogue);
                Assert.IsTrue(dialogue.gameObject.activeSelf);
                Assert.IsFalse(opening.gameObject.activeSelf);
                Assert.AreEqual("바텐더", dialogue.Find("SpeakerText").GetComponent<Text>().text);
                Assert.AreEqual("어서 와요. 처음 보는 얼굴이네요.", dialogue.Find("BodyText").GetComponent<Text>().text);
                StoryIntroUiBuilder.Build(canvas.parent, out var speaker, out var body);
                Assert.AreSame(dialogue.Find("SpeakerText").GetComponent<Text>(), speaker);
                Assert.AreSame(dialogue.Find("BodyText").GetComponent<Text>(), body);
                Assert.AreEqual(2, canvas.childCount, "repeated build must not add groups");
                var controller = canvas.parent.GetComponent<StoryIntroController>();
                for (int i = 0; i < 4; i++) controller.SendMessage("Advance");
                Assert.AreEqual("그땐 원래 값만 받죠.\n50합 뒤 점수로 승부해요. 목표 공을 맞히면 점수예요.", body.text);
                controller.SendMessage("Advance");
                controller.SendMessage("Advance");
                Assert.AreEqual("StoryIntro", SceneManager.GetActiveScene().name);
                Assert.IsFalse(dialogue.gameObject.activeSelf);
                Assert.IsTrue(opening.gameObject.activeSelf);
                controller.SendMessage("Advance");
                yield return null;
                Assert.AreEqual("GamePlay", SceneManager.GetActiveScene().name);
            }
            finally
            {
                if (hadKey) PlayerPrefs.SetInt(key, oldValue);
                else PlayerPrefs.DeleteKey(key);
                PlayerPrefs.Save();
            }
        }
    }
}
