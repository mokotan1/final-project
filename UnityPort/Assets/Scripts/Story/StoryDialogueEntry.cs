using System;

namespace CushionChallenge.Story
{
    [Serializable]
    public class StoryDialogueEntry
    {
        public string id;
        public string chapter;
        public string stage;
        public string trigger;
        public string speaker;
        public string line;
        public string direction;
    }
}
