using System.Collections.Generic;
using CushionChallenge.Core;
using UnityEngine;

namespace CushionChallenge.Gameplay
{
    public static class BallPlacementUtility
    {
        public static bool IsPositionClear(Vector2 pos, float radius, BilliardBallView ignore, IEnumerable<BilliardBallView> balls)
        {
            if (!GameConstants.PlayableContains(pos))
                return false;
            foreach (var ball in balls)
            {
                if (ball == null || !ball.gameObject.activeSelf || ball == ignore)
                    continue;
                var other = (Vector2)ball.transform.position;
                if (Vector2.Distance(pos, other) < radius + GameConstants.BallRadius + 2f)
                    return false;
            }

            return true;
        }
    }
}
