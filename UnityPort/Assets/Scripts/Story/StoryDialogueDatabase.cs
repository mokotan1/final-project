using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace CushionChallenge.Story
{
    public static class StoryDialogueDatabase
    {
        static List<StoryDialogueEntry> _entries;
        static Dictionary<string, StoryDialogueEntry> _byId;

        public static IReadOnlyList<StoryDialogueEntry> Entries
        {
            get
            {
                EnsureLoaded();
                return _entries;
            }
        }

        public static bool TryGet(string id, out StoryDialogueEntry entry)
        {
            EnsureLoaded();
            return _byId.TryGetValue(id, out entry);
        }

        public static void EnsureLoaded()
        {
            if (_entries != null)
                return;

            var path = Path.Combine(Application.streamingAssetsPath, "story_dialogue.json");
            if (!File.Exists(path))
            {
                _entries = new List<StoryDialogueEntry>();
                _byId = new Dictionary<string, StoryDialogueEntry>();
                Debug.LogWarning($"Story dialogue missing at {path}");
                return;
            }

            var json = File.ReadAllText(path);
            var wrapper = JsonUtility.FromJson<StoryDialogueListWrapper>(WrapArray(json));
            _entries = wrapper.items ?? new List<StoryDialogueEntry>();
            _byId = new Dictionary<string, StoryDialogueEntry>();
            foreach (var e in _entries)
            {
                if (e?.id != null && !_byId.ContainsKey(e.id))
                    _byId[e.id] = e;
            }
        }

        static string WrapArray(string jsonArray)
        {
            return "{\"items\":" + jsonArray + "}";
        }

        [Serializable]
        class StoryDialogueListWrapper
        {
            public List<StoryDialogueEntry> items;
        }
    }
}
