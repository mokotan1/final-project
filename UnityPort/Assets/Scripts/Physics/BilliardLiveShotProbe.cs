using System.Collections;
using System.Collections.Generic;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using CushionChallenge.Story;
using UnityEngine;

namespace CushionChallenge.Physics
{
    /// <summary>
    /// Runs a fixed-layout shot with live BilliardBallMotor physics (PlayMode / harness).
    /// Outcome fields align with story_ai_simulate_shot_from_balls and tools/story_50_runtime_harness.gml.
    /// </summary>
    public static class BilliardLiveShotProbe
    {
        public struct Outcome
        {
            public int Cushions;
            public bool HitTarget;
            public bool Foul;
            public int ExpectedScore;

            public string Signature =>
                $"{Cushions}:{HitTarget}:{Foul}:{ExpectedScore}";
        }

        const int MaxFixedSteps = StoryAiSimulator.MaxSteps;
        const int RuleContactLockFrames = 30;

        public static IEnumerator RunFixtureShot(
            float directionDeg,
            float power,
            BallRole strikerRole,
            System.Action<Outcome> onComplete)
        {
            var root = new GameObject("BilliardLiveShotProbe");
            TableCushionLayout.EnsureCushions(root.transform);
            BilliardPhysicsWorld.Ensure(root.transform).BindCushions(root.transform);

            var layout = StoryAiSimulator.FixtureLayout();
            var views = new List<BilliardBallView>();
            BilliardBallView striker = null;

            foreach (var b in layout)
            {
                var go = new GameObject(b.Role.ToString());
                go.transform.SetParent(root.transform, false);
                go.transform.position = new Vector3(b.X, b.Y, 0f);
                go.AddComponent<SpriteRenderer>();
                var motor = go.AddComponent<BilliardBallMotor>();
                var view = go.AddComponent<BilliardBallView>();
                view.Role = b.Role;
                go.AddComponent<Rigidbody2D>().bodyType = RigidbodyType2D.Kinematic;
                views.Add(view);
                if (b.Role == strikerRole)
                    striker = view;
            }

            if (striker == null)
            {
                Object.Destroy(root);
                onComplete?.Invoke(default);
                yield break;
            }

            var cushions = 0;
            var hitTarget = false;
            var foul = false;
            var scoredAfterContact = false;
            var ruleLocks = new Dictionary<int, int>();

            void OnCloth(BilliardBallMotor motor)
            {
                if (motor.gameObject != striker.gameObject || scoredAfterContact || foul)
                    return;
                cushions++;
            }

            void OnBall(BilliardBallMotor self, BilliardBallMotor other)
            {
                var selfView = self.GetComponent<BilliardBallView>();
                var otherView = other.GetComponent<BilliardBallView>();
                if (selfView == null || otherView == null)
                    return;
                ApplyContact(selfView, otherView);
                ApplyContact(otherView, selfView);
            }

            void ApplyContact(BilliardBallView strikerSide, BilliardBallView other)
            {
                if (strikerSide != striker)
                    return;
                var key = other.GetInstanceID();
                if (ruleLocks.TryGetValue(key, out var frames) && frames > 0)
                    return;
                ruleLocks[key] = RuleContactLockFrames;

                if (other.Role == BallRole.Foul)
                    foul = true;
                if (!foul && other.Role == BallRole.Target)
                {
                    hitTarget = true;
                    scoredAfterContact = true;
                }
            }

            foreach (var v in views)
            {
                v.Motor.OnClothCushionContact += OnCloth;
                v.Motor.OnBallContact += OnBall;
            }

            var dir = GameConstants.LengthDir(directionDeg, 1f);
            striker.Motor.Shoot(dir, power);

            for (var step = 0; step < MaxFixedSteps; step++)
            {
                TickRuleLocks(ruleLocks);
                var moving = false;
                foreach (var v in views)
                {
                    if (v.Motor.IsMoving)
                        moving = true;
                }

                if (!moving)
                    break;
                yield return new WaitForFixedUpdate();
            }

            foreach (var v in views)
            {
                v.Motor.OnClothCushionContact -= OnCloth;
                v.Motor.OnBallContact -= OnBall;
            }

            Object.Destroy(root);

            var score = hitTarget && !foul
                ? StoryScoreMath.NormalPointsForCushions(cushions)
                : 0;
            onComplete?.Invoke(new Outcome
            {
                Cushions = cushions,
                HitTarget = hitTarget,
                Foul = foul,
                ExpectedScore = score
            });
        }

        static void TickRuleLocks(Dictionary<int, int> locks)
        {
            if (locks.Count == 0)
                return;
            var keys = new List<int>(locks.Keys);
            foreach (var key in keys)
            {
                locks[key]--;
                if (locks[key] <= 0)
                    locks.Remove(key);
            }
        }
    }
}
