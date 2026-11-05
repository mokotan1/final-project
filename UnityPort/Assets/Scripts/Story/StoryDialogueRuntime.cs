using System.Collections.Generic;
using UnityEngine;

namespace CushionChallenge.Story
{
    public struct StoryDialogueLine
    {
        public string Id;
        public string Speaker;
        public string Text;
        public float Seconds;
    }

    /// <summary>story_versus_queue_reaction + main dialogue timers.</summary>
    public class StoryDialogueRuntime
    {
        readonly Queue<StoryDialogueLine> _reactions = new();
        public string ActiveReactionId { get; private set; } = "";
        public string ActiveReactionText { get; private set; } = "";
        float _reactionSecondsLeft;
        public string MainDialogueId { get; private set; } = "";
        public string MainSpeaker { get; private set; } = "";
        public string MainText { get; private set; } = "";
        float _mainSecondsLeft;

        public bool HasVisibleDialogue =>
            _mainSecondsLeft > 0f || _reactionSecondsLeft > 0f;

        public bool SkippableActive =>
            _mainSecondsLeft > 0f || _reactionSecondsLeft > 0f;

        public void ShowMain(string id, string speaker, string text, float seconds)
        {
            MainDialogueId = id ?? "";
            MainSpeaker = speaker ?? "";
            MainText = text ?? "";
            _mainSecondsLeft = seconds;
        }

        public void QueueReaction(string id, string text, float seconds, string speaker = "Bartender")
        {
            if (string.IsNullOrEmpty(id) || seconds <= 0f)
                return;
            var reading = Mathf.Clamp(1f + text.Length * 0.04f, 2f, 4f);
            var line = new StoryDialogueLine
            {
                Id = id,
                Speaker = speaker,
                Text = text,
                Seconds = Mathf.Min(seconds, reading)
            };
            if (_reactionSecondsLeft <= 0f && _mainSecondsLeft <= 0f && _reactions.Count == 0)
                StartReaction(line);
            else
                _reactions.Enqueue(line);
        }

        public void Tick(float deltaSeconds)
        {
            if (_mainSecondsLeft > 0f)
            {
                _mainSecondsLeft -= deltaSeconds;
                if (_mainSecondsLeft <= 0f)
                    ClearMain();
            }

            if (_mainSecondsLeft > 0f)
                return;

            if (_reactionSecondsLeft > 0f)
            {
                _reactionSecondsLeft -= deltaSeconds;
                if (_reactionSecondsLeft <= 0f)
                    AdvanceReaction();
            }
        }

        public bool Skip()
        {
            if (!SkippableActive)
                return false;
            if (_mainSecondsLeft > 0f)
            {
                ClearMain();
                return true;
            }

            _reactionSecondsLeft = 0f;
            AdvanceReaction();
            return true;
        }

        void StartReaction(StoryDialogueLine line)
        {
            ActiveReactionId = line.Id;
            ActiveReactionText = line.Text;
            _reactionSecondsLeft = line.Seconds;
        }

        void AdvanceReaction()
        {
            ActiveReactionId = "";
            ActiveReactionText = "";
            _reactionSecondsLeft = 0f;
            if (_reactions.Count == 0)
                return;
            StartReaction(_reactions.Dequeue());
        }

        void ClearMain()
        {
            _mainSecondsLeft = 0f;
            MainDialogueId = "";
            MainSpeaker = "";
            MainText = "";
        }

        public bool TryGetDisplay(out string speaker, out string text)
        {
            if (_mainSecondsLeft > 0f)
            {
                speaker = MainSpeaker;
                text = MainText;
                return true;
            }

            if (_reactionSecondsLeft > 0f)
            {
                speaker = "Bartender";
                text = ActiveReactionText;
                return true;
            }

            speaker = "";
            text = "";
            return false;
        }
    }
}
