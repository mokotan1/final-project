using System.IO;
using CushionChallenge.Story;
using NUnit.Framework;
using UnityEngine;

namespace CushionChallenge.Tests
{
    public class StoryDialogueLoadTests
    {
        [Test]
        public void StreamingDialogueLoadsOpeningLine()
        {
            var path = Path.Combine(Application.streamingAssetsPath, "story_dialogue.json");
            Assume.That(File.Exists(path), Is.True, "story_dialogue.json must be copied to StreamingAssets");
            StoryDialogueDatabase.EnsureLoaded();
            Assert.IsTrue(StoryDialogueDatabase.TryGet("OPN-01", out var entry));
            Assert.IsNotEmpty(entry.line);
            Assert.Greater(StoryDialogueDatabase.Entries.Count, 50);
        }
    }
}
