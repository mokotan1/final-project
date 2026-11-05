using System.Collections;
using CushionChallenge.Gameplay;
using CushionChallenge.Physics;
using CushionChallenge.Story;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace CushionChallenge.Tests.PlayMode
{
    public class BilliardGmLiveParityTests
    {
        const float PosEpsilon = 0.05f;
        const float VelEpsilon = 0.05f;

        [UnityTest]
        public IEnumerator Fixture_312x15_PlayModeFixedUpdate_MatchesEditModeStepTrace()
        {
            BilliardLiveFixtureTrace.TraceResult play = default;
            yield return RunLivePlayModeTrace(312f, 15f, BallRole.AiStriker, r => play = r);

            var edit = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
            AssertTraceNear(play, edit, "PlayMode vs EditMode");
        }

        static IEnumerator RunLivePlayModeTrace(
            float dir,
            float power,
            BallRole striker,
            System.Action<BilliardLiveFixtureTrace.TraceResult> onDone)
        {
            var root = new GameObject("LiveTracePlayMode");
            TableCushionLayout.EnsureCushions(root.transform);
            var segments = root.GetComponentsInChildren<TableCushionSegment>(true);

            var layout = StoryAiSimulator.FixtureLayout();
            var motors = new System.Collections.Generic.List<BilliardBallMotor>();
            BilliardBallView strikerView = null;

            foreach (var b in layout)
            {
                var go = new GameObject(b.Role.ToString());
                go.transform.SetParent(root.transform, false);
                go.transform.position = new Vector3(b.X, b.Y, 0f);
                var motor = go.AddComponent<BilliardBallMotor>();
                var view = go.AddComponent<BilliardBallView>();
                view.Role = b.Role;
                go.AddComponent<Rigidbody2D>().bodyType = RigidbodyType2D.Kinematic;
                motors.Add(motor);
                if (b.Role == striker)
                    strikerView = view;
            }

            var cushions = 0;
            var hitTarget = false;
            var foul = false;
            var scored = false;
            var ruleLocks = new System.Collections.Generic.Dictionary<int, int>();
            var frames = new System.Collections.Generic.List<BilliardLiveFixtureTrace.TraceFrame>();
            const int ruleLock = 30;

            void OnCloth(BilliardBallMotor m)
            {
                if (m.gameObject != strikerView.gameObject || scored || foul)
                    return;
                cushions++;
            }

            void OnBall(BilliardBallMotor self, BilliardBallMotor other)
            {
                Apply(self, other);
                Apply(other, self);
            }

            void Apply(BilliardBallMotor self, BilliardBallMotor other)
            {
                if (self.GetComponent<BilliardBallView>() != strikerView)
                    return;
                var ov = other.GetComponent<BilliardBallView>();
                if (ov == null)
                    return;
                var key = ov.GetInstanceID();
                if (ruleLocks.TryGetValue(key, out var left) && left > 0)
                    return;
                ruleLocks[key] = ruleLock;
                if (ov.Role == BallRole.Foul)
                    foul = true;
                if (!foul && ov.Role == BallRole.Target)
                {
                    hitTarget = true;
                    scored = true;
                }
            }

            foreach (var m in motors)
            {
                m.OnClothCushionContact += OnCloth;
                m.OnBallContact += OnBall;
            }

            strikerView.Motor.Shoot(Core.GameConstants.LengthDir(dir, power), power);

            var stepEvents = new System.Collections.Generic.List<BilliardLivePhysics.StepEvent>();

            for (var step = 0; step < StoryAiSimulator.MaxSteps; step++)
            {
                foreach (var key in new System.Collections.Generic.List<int>(ruleLocks.Keys))
                {
                    ruleLocks[key]--;
                    if (ruleLocks[key] <= 0)
                        ruleLocks.Remove(key);
                }

                stepEvents.Clear();
                BilliardLivePhysics.StepWorld(motors, segments, stepEvents);
                yield return new WaitForFixedUpdate();

                var ballStates = new BilliardLiveTraceBallState[motors.Count];
                for (var i = 0; i < motors.Count; i++)
                    ballStates[i] = motors[i].CaptureTraceState();
                frames.Add(new BilliardLiveFixtureTrace.TraceFrame
                {
                    Step = step,
                    Balls = ballStates,
                    EventKinds = System.Array.Empty<string>()
                });

                if (motors.TrueForAll(m => !m.IsMoving))
                    break;
            }

            foreach (var m in motors)
            {
                m.OnClothCushionContact -= OnCloth;
                m.OnBallContact -= OnBall;
            }

            UnityEngine.Object.Destroy(root);
            var score = 0;
            onDone?.Invoke(new BilliardLiveFixtureTrace.TraceResult
            {
                DirectionDeg = dir,
                Power = power,
                StrikerRole = striker,
                Frames = frames,
                Outcome = new BilliardLiveTraceOutcome
                {
                    Cushions = cushions,
                    HitTarget = hitTarget,
                    Foul = foul,
                    Score = score
                }
            });
        }

        static void AssertTraceNear(
            BilliardLiveFixtureTrace.TraceResult a,
            BilliardLiveFixtureTrace.TraceResult b,
            string label)
        {
            Assert.AreEqual(a.Outcome.Cushions, b.Outcome.Cushions, label);
            Assert.AreEqual(a.Outcome.HitTarget, b.Outcome.HitTarget, label);
            Assert.AreEqual(a.Outcome.Foul, b.Outcome.Foul, label);
            Assert.AreEqual(a.Frames.Count, b.Frames.Count, label);
            for (var f = 0; f < a.Frames.Count; f++)
            {
                Assert.AreEqual(a.Frames[f].Balls.Length, b.Frames[f].Balls.Length);
                for (var i = 0; i < a.Frames[f].Balls.Length; i++)
                {
                    var ba = a.Frames[f].Balls[i];
                    var bb = b.Frames[f].Balls[i];
                    Assert.AreEqual(ba.Role, bb.Role, $"{label} f{f} role");
                    Assert.That(ba.X, Is.EqualTo(bb.X).Within(PosEpsilon), $"{label} f{f} x");
                    Assert.That(ba.Y, Is.EqualTo(bb.Y).Within(PosEpsilon), $"{label} f{f} y");
                    Assert.That(ba.Vx, Is.EqualTo(bb.Vx).Within(VelEpsilon), $"{label} f{f} vx");
                    Assert.That(ba.Vy, Is.EqualTo(bb.Vy).Within(VelEpsilon), $"{label} f{f} vy");
                }
            }
        }
    }
}
