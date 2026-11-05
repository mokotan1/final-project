using System.IO;
using System.Text.RegularExpressions;

namespace CushionChallenge.Tests
{
    /// <summary>Minimal parser for tools/run_physics_live_trace.ps1 JSON (no nested-array JsonUtility).</summary>
    public static class GmRunnerTraceJson
    {
        public struct Outcome
        {
            public int Cushions;
            public bool HitTarget;
            public bool Foul;
            public int Score;
        }

        public static bool TryLoad(string path, out Outcome outcome, out int frameCount, out string source)
        {
            outcome = default;
            frameCount = 0;
            source = null;
            if (!File.Exists(path))
                return false;

            var text = File.ReadAllText(path);
            var sourceMatch = Regex.Match(text, "\"source\"\\s*:\\s*\"([^\"]+)\"");
            if (sourceMatch.Success)
                source = sourceMatch.Groups[1].Value;

            var outcomeMatch = Regex.Match(
                text,
                "\"outcome\"\\s*:\\s*\\{[^}]*\"cushions\"\\s*:\\s*(\\d+)[^}]*\"hit_target\"\\s*:\\s*(true|false)[^}]*\"foul\"\\s*:\\s*(true|false)[^}]*\"score\"\\s*:\\s*(\\d+)",
                RegexOptions.Singleline);
            if (!outcomeMatch.Success)
                return false;

            outcome = new Outcome
            {
                Cushions = int.Parse(outcomeMatch.Groups[1].Value),
                HitTarget = outcomeMatch.Groups[2].Value == "true",
                Foul = outcomeMatch.Groups[3].Value == "true",
                Score = int.Parse(outcomeMatch.Groups[4].Value)
            };
            frameCount = Regex.Matches(text, "\"step\"\\s*:").Count;
            return true;
        }
    }
}
