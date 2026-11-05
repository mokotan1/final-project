using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace CushionChallenge.Editor
{
    /// <summary>Copies GMS PNG sprites referenced from scripts/objects into Resources/GameArt.</summary>
    public static class PortReferencedSpriteImport
    {
        const string GmsRoot = "Assets/../../";
        static readonly Regex SpriteToken = new(@"\bspr_[a-z0-9_]+\b", RegexOptions.IgnoreCase | RegexOptions.Compiled);

        [MenuItem("CushionChallenge/Import Referenced GMS Sprites")]
        public static void ImportReferenced()
        {
            var repoRoot = Path.GetFullPath(Path.Combine(Application.dataPath, "..", ".."));
            var gmsRoots = new[]
            {
                Path.Combine(repoRoot, "scripts"),
                Path.Combine(repoRoot, "objects"),
                Path.Combine(repoRoot, "rooms")
            };
            var referenced = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var root in gmsRoots)
            {
                if (!Directory.Exists(root))
                    continue;
                foreach (var file in Directory.EnumerateFiles(root, "*.*", SearchOption.AllDirectories))
                {
                    if (!file.EndsWith(".gml", StringComparison.OrdinalIgnoreCase)
                        && !file.EndsWith(".yy", StringComparison.OrdinalIgnoreCase))
                        continue;
                    var text = File.ReadAllText(file);
                    foreach (Match match in SpriteToken.Matches(text))
                        referenced.Add(match.Value);
                }
            }

            var spritesDir = Path.Combine(repoRoot, "sprites");
            var destRoot = Path.Combine(Application.dataPath, "Resources", "GameArt");
            var imported = 0;
            var missing = new List<string>();
            foreach (var spr in referenced.OrderBy(s => s))
            {
                var folder = Path.Combine(spritesDir, spr);
                if (!Directory.Exists(folder))
                {
                    missing.Add(spr);
                    continue;
                }

                var png = Directory.GetFiles(folder, "*.png").FirstOrDefault();
                if (png == null)
                {
                    missing.Add(spr);
                    continue;
                }

                var category = Categorize(spr);
                var destDir = Path.Combine(destRoot, category);
                Directory.CreateDirectory(destDir);
                var destFile = Path.Combine(destDir, spr + ".png");
                File.Copy(png, destFile, overwrite: true);
                imported++;
            }

            AssetDatabase.Refresh();
            Debug.Log($"Imported {imported} referenced sprites into Resources/GameArt. Missing: {missing.Count}");
            if (missing.Count > 0)
                Debug.Log(string.Join(", ", missing.Take(20)) + (missing.Count > 20 ? "..." : ""));
        }

        static string Categorize(string spr)
        {
            if (spr.Contains("ball"))
                return "Balls";
            if (spr.Contains("table") || spr.Contains("cue"))
                return "Table";
            if (spr.Contains("mode") || spr.Contains("menu") || spr.Contains("button"))
                return "Menu";
            if (spr.Contains("story") || spr.Contains("opening") || spr.Contains("bartender"))
                return "Opening";
            return "Misc";
        }
    }
}
