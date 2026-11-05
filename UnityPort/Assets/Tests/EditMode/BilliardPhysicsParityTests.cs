using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using CushionChallenge.Physics;
using NUnit.Framework;
using UnityEngine;

namespace CushionChallenge.Tests
{
    /// <summary>EditMode parity checks against scr_physics / rm_game cushions.</summary>
    public class BilliardPhysicsParityTests
    {        [Test]
        public void TableAndBallConstantsMatchGameMakerDefaults()
        {
            Assert.AreEqual(16f, GameConstants.BallRadius, 0.001f);
            Assert.AreEqual(0.045f, GameConstants.BallFriction, 0.001f);
            Assert.AreEqual(0.08f, GameConstants.BallStopSpeed, 0.001f);
            Assert.AreEqual(0.96f, GameConstants.BallRestitution, 0.001f);
            Assert.AreEqual(210f, GameConstants.TableLeft);
            Assert.AreEqual(140f, GameConstants.TableTop);
            Assert.AreEqual(1070f, GameConstants.TableRight);
            Assert.AreEqual(560f, GameConstants.TableBottom);
        }

        [Test]
        public void CushionLayoutMatchesGameMakerRoomInstances()
        {
            var root = new GameObject("CushionTestRoot");
            try
            {
                TableCushionLayout.EnsureCushions(root.transform);
                var segments = root.GetComponentsInChildren<TableCushionSegment>(true);
                Assert.AreEqual(4, segments.Length);

                var top = System.Array.Find(segments, s => s.name == "CushionTop");
                Assert.NotNull(top);
                Assert.AreEqual(TableCushionOrientation.Horizontal, top.Orientation);
                Assert.AreEqual(210f, top.WorldBounds.xMin, 0.5f);
                Assert.AreEqual(1070f, top.WorldBounds.xMax, 0.5f);
                Assert.AreEqual(124f, top.WorldBounds.yMin, 0.5f);
                Assert.AreEqual(156f, top.WorldBounds.yMax, 0.5f);
            }
            finally
            {
                Object.DestroyImmediate(root);
            }
        }

        [Test]
        public void LengthDir_312x15_MatchesGameMakerRunnerStep0AfterFriction()
        {
            var v = GameConstants.LengthDir(312f, 15f);
            var vx = v.x;
            var vy = v.y;
            GameMakerFloat.ApplyFriction(ref vx, ref vy, GameConstants.BallFriction, GameConstants.BallStopSpeed);
            Assert.AreEqual(10.006850f, vx, 0.000001f);
            Assert.AreEqual(11.113729f, vy, 0.000001f);
            var trace = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            var striker = System.Array.Find(trace.Frames[0].Balls, b => b.Role == "AiStriker");
            Assert.AreEqual(striker.X, GameMakerFloat.F32(900f + vx), 0.0001f);
        }

        [Test]
        public void LengthDir_MatchesGameMakerLengthdir()
        {
            var v = GameConstants.LengthDir(90f, 10f);
            Assert.AreEqual(0f, v.x, 0.001f);
            Assert.AreEqual(-10f, v.y, 0.001f);
            var probe = GameConstants.LengthDir(312f, 15f);
            Assert.AreEqual(15f * Mathf.Cos(312f * Mathf.Deg2Rad), probe.x, 0.001f);
            Assert.AreEqual(-15f * Mathf.Sin(312f * Mathf.Deg2Rad), probe.y, 0.001f);
        }

        [Test]
        public void CushionReflectionMatchesGameMakerAxisFlip()
        {
            var v = new Vector2(6f, 8f);
            var h = BilliardCushionPhysics.ApplyReflection(v, TableCushionOrientation.Horizontal, GameConstants.BallRestitution);
            Assert.AreEqual(6f, h.x, 0.001f);
            Assert.AreEqual(-8f * GameConstants.BallRestitution, h.y, 0.001f);

            var vert = BilliardCushionPhysics.ApplyReflection(v, TableCushionOrientation.Vertical, GameConstants.BallRestitution);
            Assert.AreEqual(-6f * GameConstants.BallRestitution, vert.x, 0.001f);
            Assert.AreEqual(8f, vert.y, 0.001f);
        }
    }
}
