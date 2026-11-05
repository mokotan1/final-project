using System.Collections.Generic;
using UnityEngine;

namespace CushionChallenge.Gameplay
{
    /// <summary>scr_story_versus.gml — story_versus_spawn_layout / story_versus_spawn_ball_at.</summary>
    public static class StoryVersusSpawnLayout
    {
        public readonly struct BallSpawn
        {
            public BallSpawn(BallRole role, Vector2 position)
            {
                Role = role;
                Position = position;
            }

            public BallRole Role { get; }
            public Vector2 Position { get; }
        }

        public static IReadOnlyList<BallSpawn> BuildLayout(bool introMatch)
        {
            var list = new List<BallSpawn>(5)
            {
                new(BallRole.Player, new Vector2(380, 350)),
                new(BallRole.AiStriker, new Vector2(900, 350))
            };
            if (introMatch)
            {
                list.Add(new(BallRole.Target, new Vector2(640, 350)));
                list.Add(new(BallRole.Foul, new Vector2(608, 350)));
                list.Add(new(BallRole.Foul, new Vector2(624, 322)));
            }
            else
            {
                list.Add(new(BallRole.Target, new Vector2(640, 260)));
                list.Add(new(BallRole.Foul, new Vector2(520, 480)));
                list.Add(new(BallRole.Foul, new Vector2(760, 480)));
            }

            return list;
        }
    }
}
