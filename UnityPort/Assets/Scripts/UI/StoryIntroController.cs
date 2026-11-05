using CushionChallenge.Bootstrap;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public class StoryIntroController : MonoBehaviour
    {
        readonly (string id, string speaker, string line)[] _lines =
        {
            ("OPN-01", "바텐더", "어서 와요. 처음 보는 얼굴이네요."),
            ("OPN-02", "플레이어", "당구대가 있네요?"),
            ("OPN-03", "바텐더", "한 판 어때요? 이기면 오늘 술값을 깎아 드릴게요."),
            ("OPN-04", "플레이어", "지면요?"),
            ("OPN-05", "바텐더", "그땐 원래 값만 받죠. 50합 뒤 점수로 승부해요. 목표 공을 맞히면 점수예요."),
            ("OPN-06", "플레이어", "좋아요. 한 판 하죠.")
        };

        int _index;
        Text _speaker;
        Text _body;
        Text _counter;
        Text _prompt;
        GameObject _dialogueScreen;
        GameObject _openingScreen;
        float _inputLock = 0.25f;

        void Start()
        {
            PortSceneCamera.EnsureMainCamera();
            PortUiRuntime.EnsureEventSystem();
            StoryIntroUiBuilder.Build(transform, out _speaker, out _body);
            var canvas = transform.Find(StoryIntroUiBuilder.IntroCanvasName);
            // A serialized canvas from an older scene may coexist until end of frame.
            foreach (Transform child in transform)
                if (child.name == StoryIntroUiBuilder.IntroCanvasName && child.gameObject.activeSelf)
                    canvas = child;
            _dialogueScreen = canvas.Find("DialogueScreen").gameObject;
            _openingScreen = canvas.Find("OpeningScreen").gameObject;
            _counter = _dialogueScreen.transform.Find("CounterText").GetComponent<Text>();
            _prompt = _openingScreen.transform.Find("StartPrompt").GetComponent<Text>();
            ShowLine();
        }

        void Update()
        {
            if (_openingScreen.activeSelf)
            {
                var color = _prompt.color;
                color.a = 0.15f + 0.85f * (0.5f + 0.5f * Mathf.Sin(Time.realtimeSinceStartup * 6f));
                _prompt.color = color;
            }
            if (_inputLock > 0f)
            {
                _inputLock -= Time.deltaTime;
                return;
            }

            var kb = Keyboard.current;
            var mouse = Mouse.current;
            var advance = mouse != null && mouse.leftButton.wasPressedThisFrame
                          || kb != null && (kb.spaceKey.wasPressedThisFrame || kb.enterKey.wasPressedThisFrame);
            if (!advance)
                return;

            Advance();
        }

        void Advance()
        {
            _index++;
            if (_index > _lines.Length)
            {
                PortSaveStore.StoryIntroSeen = true;
                SessionRequest.StoryIntroMatch = true;
                SceneFlow.LoadGamePlay(GameModeKind.StoryFiftyRound);
                return;
            }

            if (_index == _lines.Length)
            {
                _dialogueScreen.SetActive(false);
                _openingScreen.SetActive(true);
            }
            else ShowLine();
            PortAudio.PlaySfx("snd_ui_click", 0.5f);
        }

        void ShowLine()
        {
            var line = _lines[_index];
            _speaker.text = line.speaker;
            if (line.id == "OPN-05")
            {
                var split = line.line.IndexOf(". ", System.StringComparison.Ordinal);
                _body.text = split >= 0 ? line.line.Substring(0, split + 1) + "\n" + line.line.Substring(split + 2) : line.line;
            }
            else _body.text = line.line;
            _body.rectTransform.anchoredPosition = new Vector2(130, -(line.id == "OPN-05" ? 512 : 535));
            _counter.text = (_index + 1) + "/" + _lines.Length;
        }
    }
}
