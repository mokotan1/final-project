using System.Collections.Generic;
using CushionChallenge.Core;
using CushionChallenge.Physics;
using UnityEngine;

namespace CushionChallenge.Gameplay
{
    /// <summary>scr_application_commands.gml — application_spawn_ball / application_spawn_initial_balls.</summary>
    public static class ApplicationBallSpawner
    {
        public readonly struct SpawnRequest
        {
            public SpawnRequest(BallRole role, Vector2 position)
            {
                Role = role;
                Position = position;
            }

            public BallRole Role { get; }
            public Vector2 Position { get; }
        }

        public static IReadOnlyList<SpawnRequest> BuildInitialLayout(int foulCount, System.Random rng)
        {
            var list = new List<SpawnRequest>(2 + foulCount);
            var player = TrySpawn(BallRole.Player, null, list, rng);
            if (player == null)
                return list;
            list.Add(player.Value);
            var target = TrySpawn(BallRole.Target, list, list, rng);
            if (target != null)
                list.Add(target.Value);
            for (var i = 0; i < foulCount; i++)
            {
                var foul = TrySpawn(BallRole.Foul, list, list, rng);
                if (foul != null)
                    list.Add(foul.Value);
            }

            return list;
        }

        static SpawnRequest? TrySpawn(
            BallRole role,
            IReadOnlyList<SpawnRequest> playerTargetOnly,
            IReadOnlyList<SpawnRequest> occupied,
            System.Random rng)
        {
            var bounds = GameConstants.TablePlayableRect;
            const float radius = GameConstants.BallRadius;
            Vector2? playerPos = null;
            Vector2? targetPos = null;
            if (playerTargetOnly != null)
            {
                foreach (var ball in playerTargetOnly)
                {
                    if (ball.Role == BallRole.Player)
                        playerPos = ball.Position;
                    else if (ball.Role == BallRole.Target)
                        targetPos = ball.Position;
                }
            }

            for (var attempt = 0; attempt < 40; attempt++)
            {
                var x = (float)(bounds.xMin + radius + rng.NextDouble() * (bounds.width - radius * 2));
                var y = (float)(bounds.yMin + radius + rng.NextDouble() * (bounds.height - radius * 2));
                var pos = new Vector2(x, y);
                if (role == BallRole.Foul && playerPos.HasValue && targetPos.HasValue)
                {
                    var player = playerPos.Value;
                    var target = targetPos.Value;
                    var vx = target.x - player.x;
                    var vy = target.y - player.y;
                    var len2 = Mathf.Max(1f, vx * vx + vy * vy);
                    var t = Mathf.Clamp01(((pos.x - player.x) * vx + (pos.y - player.y) * vy) / len2);
                    var lx = player.x + t * vx;
                    var ly = player.y + t * vy;
                    if (Vector2.Distance(pos, new Vector2(lx, ly)) < 48f)
                        continue;
                }

                if (!IsClear(pos, radius, occupied))
                    continue;
                return new SpawnRequest(role, pos);
            }

            return null;
        }

        static bool IsClear(Vector2 pos, float radius, IReadOnlyList<SpawnRequest> occupied)
        {
            foreach (var other in occupied)
            {
                if (Vector2.Distance(pos, other.Position) < radius + GameConstants.BallRadius + 4f)
                    return false;
            }

            return true;
        }
    }
}
