using CushionChallenge.Bootstrap;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace CushionChallenge.Editor
{
    public static class PortBuild
    {
        const string ProductName = "CushionChallengeUnityPort";

        public static void PerformBuild()
        {
            var scenes = PortScenes.BuildOrder;
            var outDir = Path.Combine(Application.dataPath, "..", "Builds", "Windows");
            Directory.CreateDirectory(outDir);
            var location = Path.Combine(outDir, ProductName + ".exe");
            var report = BuildPipeline.BuildPlayer(scenes, location, BuildTarget.StandaloneWindows64, BuildOptions.None);
            if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded)
                throw new System.Exception("Unity build failed: " + report.summary.result);
        }
    }
}
