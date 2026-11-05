using CushionChallenge.Gameplay;
using CushionChallenge.Physics;
using NUnit.Framework;
using System.IO;
using UnityEngine;

namespace CushionChallenge.Tests
{
    public class BilliardGmLiveTraceTests
    {
        static string GoldenPath => Path.Combine(
            Application.dataPath,
            "Tests",
            "Fixtures",
            "gm_live_physics_312_15.json");

        static string GameMakerRunnerGoldenPath => Path.Combine(
            Application.dataPath,
            "Tests",
            "Fixtures",
            "gm_live_physics_312_15_gm_runner.json");

        [Test]
        public void Fixture_312x15_LiveTrace_MatchesGameMakerRunner_OutcomeAndFrames()
        {
            Assert.IsTrue(
                GmRunnerTraceJson.TryLoad(GameMakerRunnerGoldenPath, out var gmOutcome, out var gmFrames, out var source),
                "Missing or invalid GM runner golden — run tools/run_physics_live_trace.ps1");
            Assert.AreEqual("gamemaker_runner", source);

            var trace = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            Assert.AreEqual(gmOutcome.Cushions, trace.Outcome.Cushions, "cushions");
            Assert.AreEqual(gmOutcome.HitTarget, trace.Outcome.HitTarget, "hit_target");
            Assert.AreEqual(gmOutcome.Foul, trace.Outcome.Foul, "foul");
            Assert.That(
                Mathf.Abs(gmFrames - trace.Frames.Count),
                Is.AtMost(2),
                "frame count should match GM Runner within settle tail");
        }

        [Test]
        [Explicit("Exports a candidate trace for manual review; it never updates the baseline.")]
        public void ExportGolden_312x15_ForPythonMirror()
        {
            var trace = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            var candidatePath = Path.Combine(Path.GetTempPath(), "cushion_challenge_unity_trace_312_15_candidate.json");
            File.WriteAllText(candidatePath, BilliardLiveFixtureTrace.ToJson(trace));
            TestContext.Progress.WriteLine("Candidate trace: " + candidatePath);
            Assert.IsTrue(File.Exists(candidatePath));
        }

        [Test]
        public void Fixture_312x15_StepTrace_IsDeterministic()
        {
            var a = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            var b = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            Assert.AreEqual(BilliardLiveFixtureTrace.ToJson(a), BilliardLiveFixtureTrace.ToJson(b));
        }

        [Test]
        public void Fixture_312x15_StepTrace_MatchesExportedGoldenFile()
        {
            Assert.IsTrue(File.Exists(GoldenPath), "Missing Unity baseline fixture; review a candidate before replacing it");
            var golden = File.ReadAllText(GoldenPath);
            var trace = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            var current = BilliardLiveFixtureTrace.ToJson(trace);
            Assert.AreEqual(golden, current);
        }
    }
}
