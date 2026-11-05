using System;
using System.Collections.Generic;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using UnityEngine;

namespace CushionChallenge.Story
{
    /// <summary>Headless shot simulation — mirrors tools/story_ai_fixture_sim.py and scr_story_ai simulate.</summary>
    public static class StoryAiSimulator
    {
        public const int MinCushions = 2;
        public const int MaxSteps = 720;

        public struct SimBall
        {
            public BallRole Role;
            public float X, Y, Vx, Vy, R;
        }

        public struct SimResult
        {
            public int Cushions;
            public bool HitTarget;
            public bool Foul;
        }

        public static SimResult Simulate(IReadOnlyList<SimBall> layout, BallRole strikerRole, float directionDeg, float power)
        {
            var balls = new SimBall[layout.Count];
            for (var i = 0; i < layout.Count; i++)
                balls[i] = layout[i];

            var striker = -1;
            for (var i = 0; i < balls.Length; i++)
            {
                if (balls[i].Role == strikerRole)
                {
                    striker = i;
                    break;
                }
            }

            if (striker < 0)
                return default;

            var vel = GameConstants.LengthDir(directionDeg, power);
            balls[striker].Vx = vel.x;
            balls[striker].Vy = vel.y;

            var state = new SimResult();

            for (var step = 0; step < MaxSteps; step++)
            {
                var moving = false;
                for (var i = 0; i < balls.Length; i++)
                {
                    ref var b = ref balls[i];
                    var mag = Mathf.Sqrt(b.Vx * b.Vx + b.Vy * b.Vy);
                    if (mag > GameConstants.BallStopSpeed)
                    {
                        moving = true;
                        var next = Mathf.Max(0f, mag - GameConstants.BallFriction);
                        var scale = next / mag;
                        b.Vx *= scale;
                        b.Vy *= scale;
                    }
                    else
                    {
                        b.Vx = 0f;
                        b.Vy = 0f;
                    }

                    b.X += b.Vx;
                    b.Y += b.Vy;
                }

                if (!moving)
                    break;

                for (var i = 0; i < balls.Length; i++)
                    ResolveBounds(ref balls[i], i, striker, ref state);

                for (var i = 0; i < balls.Length; i++)
                {
                    for (var j = i + 1; j < balls.Length; j++)
                    {
                        if (Distance(balls[i], balls[j]) <= balls[i].R + balls[j].R)
                            PairCollide(ref balls[i], ref balls[j], i, j, striker, ref state);
                    }
                }
            }

            return state;
        }

        public static List<SimBall> SnapshotFromScene()
        {
            var list = new List<SimBall>();
            foreach (var view in UnityEngine.Object.FindObjectsByType<BilliardBallView>(FindObjectsSortMode.None))
            {
                var pos = view.transform.position;
                list.Add(new SimBall
                {
                    Role = view.Role,
                    X = pos.x,
                    Y = pos.y,
                    Vx = 0f,
                    Vy = 0f,
                    R = GameConstants.BallRadius
                });
            }

            return list;
        }

        static float Distance(SimBall a, SimBall b) =>
            Mathf.Sqrt((a.X - b.X) * (a.X - b.X) + (a.Y - b.Y) * (a.Y - b.Y));

        static void ResolveBounds(ref SimBall b, int index, int striker, ref SimResult state)
        {
            var hit = false;
            if (b.X - b.R < GameConstants.TableLeft)
            {
                b.X = GameConstants.TableLeft + b.R;
                b.Vx = Mathf.Abs(b.Vx) * GameConstants.BallRestitution;
                hit = true;
            }
            else if (b.X + b.R > GameConstants.TableRight)
            {
                b.X = GameConstants.TableRight - b.R;
                b.Vx = -Mathf.Abs(b.Vx) * GameConstants.BallRestitution;
                hit = true;
            }

            if (b.Y - b.R < GameConstants.TableTop)
            {
                b.Y = GameConstants.TableTop + b.R;
                b.Vy = Mathf.Abs(b.Vy) * GameConstants.BallRestitution;
                hit = true;
            }
            else if (b.Y + b.R > GameConstants.TableBottom)
            {
                b.Y = GameConstants.TableBottom - b.R;
                b.Vy = -Mathf.Abs(b.Vy) * GameConstants.BallRestitution;
                hit = true;
            }

            if (hit && index == striker && !state.HitTarget && !state.Foul)
                state.Cushions++;
        }

        static void PairCollide(ref SimBall a, ref SimBall b, int i, int j, int striker, ref SimResult state)
        {
            var dx = b.X - a.X;
            var dy = b.Y - a.Y;
            var dist = Mathf.Sqrt(dx * dx + dy * dy);
            var min = a.R + b.R;
            if (dist >= min)
                return;
            if (dist <= 0.0001f)
            {
                dx = 1f;
                dy = 0f;
                dist = 1f;
            }
            else
            {
                dx /= dist;
                dy /= dist;
            }

            var overlap = min - dist;
            a.X -= dx * overlap * 0.5f;
            a.Y -= dy * overlap * 0.5f;
            b.X += dx * overlap * 0.5f;
            b.Y += dy * overlap * 0.5f;

            var rel = (a.Vx - b.Vx) * dx + (a.Vy - b.Vy) * dy;
            if (rel <= 0f)
                return;

            var impulse = rel * GameConstants.BallRestitution;
            a.Vx -= impulse * dx;
            a.Vy -= impulse * dy;
            b.Vx += impulse * dx;
            b.Vy += impulse * dy;

            if (i == striker || j == striker)
            {
                var other = i == striker ? b : a;
                if (other.Role == BallRole.Foul)
                    state.Foul = true;
                if (!state.HitTarget && !state.Foul && other.Role == BallRole.Target)
                    state.HitTarget = true;
            }
        }

        public static List<SimBall> FixtureLayout()
        {
            return new List<SimBall>
            {
                new() { Role = BallRole.Player, X = 380, Y = 350, R = GameConstants.BallRadius },
                new() { Role = BallRole.AiStriker, X = 900, Y = 350, R = GameConstants.BallRadius },
                new() { Role = BallRole.Target, X = 640, Y = 260, R = GameConstants.BallRadius },
                new() { Role = BallRole.Foul, X = 520, Y = 480, R = GameConstants.BallRadius },
                new() { Role = BallRole.Foul, X = 760, Y = 480, R = GameConstants.BallRadius }
            };
        }

        public static bool FixtureHasScoringShot()
        {
            var layout = FixtureLayout();
            var powers = new[] { 6f, 9f, 12f, 15f, 18f };
            for (var dir = 0; dir < 360; dir += 6)
            {
                foreach (var p in powers)
                {
                    var r = Simulate(layout, BallRole.AiStriker, dir, p);
                    if (r.Foul || !r.HitTarget)
                        continue;
                    if (r.Cushions >= MinCushions)
                        return true;
                }
            }

            return false;
        }

        public static bool FixtureHasRecoveryFoulShot()
        {
            var layout = FixtureLayout();
            var powers = new[] { 6f, 9f, 12f, 15f, 18f };
            for (var dir = 0; dir < 360; dir += 6)
            {
                foreach (var p in powers)
                {
                    if (Simulate(layout, BallRole.AiStriker, dir, p).Foul)
                        return true;
                }
            }

            return false;
        }
    }
}
