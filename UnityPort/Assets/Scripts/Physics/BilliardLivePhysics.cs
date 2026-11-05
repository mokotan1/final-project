using System;
using System.Collections.Generic;
using CushionChallenge.Core;
using UnityEngine;

namespace CushionChallenge.Physics
{
    /// <summary>
    /// GameMaker Runner live path: scr_physics physics_ball_step (friction, bounds, pairs) then position += hspeed/vspeed (End Step capture).
    /// obj_cushion instances in this project carry no sprite mask, so segment Collision events do not run in Runner.
    /// </summary>
    public static class BilliardLivePhysics
    {
        public const int CushionLockFrames = 3;
        public const int PairLockFrames = 3;

        public struct StepEvent
        {
            public string Kind;
            public int BallInstanceId;
            public int OtherInstanceId;
        }

        public struct FrameSnapshot
        {
            public int Step;
            public BilliardLiveTraceBallState[] Balls;
            public StepEvent[] Events;
        }

        public static void StepWorld(
            IList<BilliardBallMotor> balls,
            IReadOnlyList<TableCushionSegment> segments,
            IList<StepEvent> eventSink = null)
        {
            _ = segments;
            if (balls == null || balls.Count == 0)
                return;

            var ordered = new List<BilliardBallMotor>(balls);
            ordered.Sort((a, b) => a.PhysicsInstanceId.CompareTo(b.PhysicsInstanceId));

            foreach (var ball in ordered)
            {
                ball.TickCushionLock();
                ball.TickPairLocks();
                ball.ApplyFrictionInternal();
                ball.ResolveTableBoundsInternal(eventSink);
                ball.ScanBallCollisionsInternal(ordered, eventSink);
            }

            foreach (var ball in ordered)
                ball.IntegratePostStep();
        }

        public static FrameSnapshot CaptureFrame(int step, IList<BilliardBallMotor> balls)
        {
            var states = new BilliardLiveTraceBallState[balls.Count];
            for (var i = 0; i < balls.Count; i++)
                states[i] = balls[i].CaptureTraceState();
            return new FrameSnapshot { Step = step, Balls = states, Events = Array.Empty<StepEvent>() };
        }
    }

    public struct BilliardLiveTraceBallState
    {
        public string Role;
        public int InstanceId;
        public float X;
        public float Y;
        public float Vx;
        public float Vy;
        public int CushionLock;
    }

    public struct BilliardLiveTraceOutcome
    {
        public int Cushions;
        public bool HitTarget;
        public bool Foul;
        public int Score;
    }
}
