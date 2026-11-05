using System.Collections.Generic;
using System.Text;
using CushionChallenge.Core;
using CushionChallenge.Gameplay;
using CushionChallenge.Story;
using UnityEngine;

namespace CushionChallenge.Physics
{
    /// <summary>Deterministic fixture shot trace for GM live vs Unity PlayMode regression.</summary>
    public static class BilliardLiveFixtureTrace
    {
        public struct TraceFrame
        {
            public int Step;
            public BilliardLiveTraceBallState[] Balls;
            public string[] EventKinds;
        }

        public struct TraceResult
        {
            public float DirectionDeg;
            public float Power;
            public BallRole StrikerRole;
            public List<TraceFrame> Frames;
            public BilliardLiveTraceOutcome Outcome;
        }

        const int MaxSteps = StoryAiSimulator.MaxSteps;
        const int RuleContactLockFrames = 30;

        public static TraceResult Run(float directionDeg, float power, BallRole strikerRole)
        {
            var root = new GameObject("BilliardLiveFixtureTrace");
            TableCushionLayout.EnsureCushions(root.transform);
            var segments = root.GetComponentsInChildren<TableCushionSegment>(true);

            var layout = StoryAiSimulator.FixtureLayout();
            var motors = new List<BilliardBallMotor>();
            BilliardBallView striker = null;

            foreach (var b in layout)
            {
                var go = new GameObject(b.Role.ToString());
                go.transform.SetParent(root.transform, false);
                go.transform.position = new Vector3(b.X, b.Y, 0f);
                var motor = go.AddComponent<BilliardBallMotor>();
                var view = go.AddComponent<BilliardBallView>();
                view.Role = b.Role;
                motors.Add(motor);
                if (b.Role == strikerRole)
                    striker = view;
            }

            var cushions = 0;
            var hitTarget = false;
            var foul = false;
            var scoredAfterContact = false;
            var ruleLocks = new Dictionary<int, int>();
            var frames = new List<TraceFrame>();
            var stepEvents = new List<BilliardLivePhysics.StepEvent>();

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
                if (ruleLocks.TryGetValue(key, out var framesLeft) && framesLeft > 0)
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

            foreach (var m in motors)
            {
                m.OnClothCushionContact += OnCloth;
                m.OnBallContact += OnBall;
            }

            striker.Motor.Shoot(GameConstants.LengthDir(directionDeg, power), power);

            for (var step = 0; step < MaxSteps; step++)
            {
                TickRuleLocks(ruleLocks);
                stepEvents.Clear();
                BilliardLivePhysics.StepWorld(motors, segments, stepEvents);

                var kinds = new string[stepEvents.Count];
                for (var i = 0; i < stepEvents.Count; i++)
                    kinds[i] = stepEvents[i].Kind;

                var ballStates = new BilliardLiveTraceBallState[motors.Count];
                for (var i = 0; i < motors.Count; i++)
                    ballStates[i] = motors[i].CaptureTraceState();

                frames.Add(new TraceFrame { Step = step, Balls = ballStates, EventKinds = kinds });

                if (motors.TrueForAll(m => !m.IsMoving))
                    break;
            }

            foreach (var m in motors)
            {
                m.OnClothCushionContact -= OnCloth;
                m.OnBallContact -= OnBall;
            }

            Object.DestroyImmediate(root);

            var score = 0;
            return new TraceResult
            {
                DirectionDeg = directionDeg,
                Power = power,
                StrikerRole = strikerRole,
                Frames = frames,
                Outcome = new BilliardLiveTraceOutcome
                {
                    Cushions = cushions,
                    HitTarget = hitTarget,
                    Foul = foul,
                    Score = score
                }
            };
        }

        public static string ToJson(TraceResult trace)
        {
            var sb = new StringBuilder(8192);
            sb.Append('{');
            sb.Append("\"direction\":").Append(trace.DirectionDeg.ToString("R"));
            sb.Append(",\"power\":").Append(trace.Power.ToString("R"));
            sb.Append(",\"striker\":\"").Append(trace.StrikerRole).Append('"');
            sb.Append(",\"outcome\":{");
            sb.Append("\"cushions\":").Append(trace.Outcome.Cushions);
            sb.Append(",\"hit_target\":").Append(trace.Outcome.HitTarget ? "true" : "false");
            sb.Append(",\"foul\":").Append(trace.Outcome.Foul ? "true" : "false");
            sb.Append(",\"score\":").Append(trace.Outcome.Score);
            sb.Append("},\"frames\":[");
            for (var f = 0; f < trace.Frames.Count; f++)
            {
                if (f > 0) sb.Append(',');
                var frame = trace.Frames[f];
                sb.Append("{\"step\":").Append(frame.Step).Append(",\"events\":[");
                for (var e = 0; e < frame.EventKinds.Length; e++)
                {
                    if (e > 0) sb.Append(',');
                    sb.Append('"').Append(frame.EventKinds[e]).Append('"');
                }

                sb.Append("],\"balls\":[");
                for (var b = 0; b < frame.Balls.Length; b++)
                {
                    if (b > 0) sb.Append(',');
                    var ball = frame.Balls[b];
                    sb.Append('{');
                    sb.Append("\"role\":\"").Append(ball.Role).Append('"');
                    sb.Append(",\"x\":").Append(ball.X.ToString("R"));
                    sb.Append(",\"y\":").Append(ball.Y.ToString("R"));
                    sb.Append(",\"vx\":").Append(ball.Vx.ToString("R"));
                    sb.Append(",\"vy\":").Append(ball.Vy.ToString("R"));
                    sb.Append(",\"lock\":").Append(ball.CushionLock);
                    sb.Append('}');
                }

                sb.Append("]}");
            }

            sb.Append("]}");
            return sb.ToString();
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
