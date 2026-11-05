using System.Collections.Generic;
using CushionChallenge.Core;
using UnityEngine;

namespace CushionChallenge.Physics
{
    [RequireComponent(typeof(CircleCollider2D))]
    public class BilliardBallMotor : MonoBehaviour
    {
        public float Radius = GameConstants.BallRadius;
        public float Friction = GameConstants.BallFriction;
        public float StopSpeed = GameConstants.BallStopSpeed;
        public float Restitution = GameConstants.BallRestitution;

        public Vector2 Velocity { get; private set; }
        public bool IsMoving => Velocity.sqrMagnitude > StopSpeed * StopSpeed;
        public int CushionLockFramesRemaining { get; private set; }
        public int PhysicsInstanceId { get; private set; }

        readonly Dictionary<int, int> _pairLock = new();
        CircleCollider2D _collider;
        static int _nextPhysicsId = 1;

        void Awake()
        {
            PhysicsInstanceId = _nextPhysicsId++;
            _collider = GetComponent<CircleCollider2D>();
            _collider.radius = Radius;
            BilliardPhysicsWorld.Ensure();
        }

        public void Shoot(Vector2 direction, float power)
        {
            if (power <= 0f || direction.sqrMagnitude < 0.0001f)
            {
                Velocity = Vector2.zero;
                return;
            }

            var deg = Mathf.Atan2(-direction.y, direction.x) * Mathf.Rad2Deg;
            Velocity = GameConstants.LengthDir(deg, power);
        }

        public void Stop()
        {
            Velocity = Vector2.zero;
        }

        internal void IntegratePostStep()
        {
            var p = transform.position;
            transform.position = new Vector3(
                GameMakerFloat.F32(p.x + Velocity.x),
                GameMakerFloat.F32(p.y + Velocity.y),
                p.z);
        }

        internal void TickCushionLock()
        {
            if (CushionLockFramesRemaining > 0)
                CushionLockFramesRemaining--;
        }

        internal void TickPairLocks()
        {
            if (_pairLock.Count == 0)
                return;
            var keys = new List<int>(_pairLock.Keys);
            foreach (var k in keys)
            {
                _pairLock[k]--;
                if (_pairLock[k] <= 0)
                    _pairLock.Remove(k);
            }
        }

        internal void ApplyFrictionInternal()
        {
            var vx = Velocity.x;
            var vy = Velocity.y;
            GameMakerFloat.ApplyFriction(ref vx, ref vy, Friction, StopSpeed);
            Velocity = new Vector2(vx, vy);
        }

        internal void ResolveTableBoundsInternal(IList<BilliardLivePhysics.StepEvent> events)
        {
            var pos = transform.position;
            var hit = false;
            var counted = false;

            if (pos.x - Radius < GameConstants.TableLeft)
            {
                pos.x = GameConstants.TableLeft + Radius;
                Velocity = new Vector2(GameMakerFloat.Abs(Velocity.x) * Restitution, Velocity.y);
                hit = true;
            }
            else if (pos.x + Radius > GameConstants.TableRight)
            {
                pos.x = GameConstants.TableRight - Radius;
                Velocity = new Vector2(-GameMakerFloat.Abs(Velocity.x) * Restitution, Velocity.y);
                hit = true;
            }

            if (pos.y - Radius < GameConstants.TableTop)
            {
                pos.y = GameConstants.TableTop + Radius;
                Velocity = new Vector2(Velocity.x, GameMakerFloat.Abs(Velocity.y) * Restitution);
                hit = true;
            }
            else if (pos.y + Radius > GameConstants.TableBottom)
            {
                pos.y = GameConstants.TableBottom - Radius;
                Velocity = new Vector2(Velocity.x, -GameMakerFloat.Abs(Velocity.y) * Restitution);
                hit = true;
            }

            transform.position = pos;

            if (hit && CushionLockFramesRemaining <= 0)
            {
                CushionLockFramesRemaining = BilliardLivePhysics.CushionLockFrames;
                counted = true;
                events?.Add(new BilliardLivePhysics.StepEvent
                {
                    Kind = "cloth_cushion",
                    BallInstanceId = PhysicsInstanceId
                });
                OnClothCushionContact?.Invoke(this);
            }
        }

        internal void ResolveCushionSegmentsInternal(
            IReadOnlyList<TableCushionSegment> segments,
            IList<BilliardLivePhysics.StepEvent> events)
        {
            if (CushionLockFramesRemaining > 0)
                return;

            var center = (Vector2)transform.position;
            foreach (var seg in segments)
            {
                if (seg == null || !TableCushionSegment.CircleOverlaps(center, Radius, seg.WorldBounds))
                    continue;

                Velocity = BilliardCushionPhysics.ApplyReflection(Velocity, seg.Orientation, Restitution);
                CushionLockFramesRemaining = BilliardLivePhysics.CushionLockFrames;
                events?.Add(new BilliardLivePhysics.StepEvent
                {
                    Kind = "segment_cushion",
                    BallInstanceId = PhysicsInstanceId
                });
                OnSegmentCushionContact?.Invoke(this);
                break;
            }
        }

        internal void ScanBallCollisionsInternal(
            IList<BilliardBallMotor> ordered,
            IList<BilliardLivePhysics.StepEvent> events)
        {
            foreach (var other in ordered)
            {
                if (other == null || other == this)
                    continue;
                var dist = Vector2.Distance(transform.position, other.transform.position);
                if (dist <= Radius + other.Radius)
                    TryResolveBallPair(other, events);
            }
        }

        void TryResolveBallPair(BilliardBallMotor other, IList<BilliardLivePhysics.StepEvent> events)
        {
            var key = other.PhysicsInstanceId;
            if (_pairLock.TryGetValue(key, out var frames) && frames > 0)
                return;

            var a = (Vector2)transform.position;
            var b = (Vector2)other.transform.position;
            Vector2 delta = b - a;
            var dist = delta.magnitude;
            var min = Radius + other.Radius;
            if (dist >= min)
                return;

            if (dist <= 0.0001f)
                delta = Vector2.right;
            else
                delta /= dist;

            var overlap = min - dist;
            transform.position = (Vector3)(a - delta * overlap * 0.5f);
            other.transform.position = (Vector3)(b + delta * overlap * 0.5f);

            var rel = Vector2.Dot(Velocity - other.Velocity, delta);
            if (rel <= 0f)
                return;

            var restitution = Mathf.Min(Restitution, other.Restitution);
            var impulse = rel * restitution;
            Velocity = Velocity - delta * impulse;
            other.Velocity = other.Velocity + delta * impulse;
            _pairLock[key] = BilliardLivePhysics.PairLockFrames;
            other._pairLock[PhysicsInstanceId] = BilliardLivePhysics.PairLockFrames;
            events?.Add(new BilliardLivePhysics.StepEvent
            {
                Kind = "ball",
                BallInstanceId = PhysicsInstanceId,
                OtherInstanceId = other.PhysicsInstanceId
            });
            OnBallContact?.Invoke(this, other);
        }

        public BilliardLiveTraceBallState CaptureTraceState()
        {
            var role = GetComponent<Gameplay.BilliardBallView>()?.Role.ToString() ?? name;
            var pos = transform.position;
            return new BilliardLiveTraceBallState
            {
                Role = role,
                InstanceId = PhysicsInstanceId,
                X = pos.x,
                Y = pos.y,
                Vx = Velocity.x,
                Vy = Velocity.y,
                CushionLock = CushionLockFramesRemaining
            };
        }

        /// <summary>Cloth bounds cushion (physics_resolve_table_bounds striker count path).</summary>
        public System.Action<BilliardBallMotor> OnClothCushionContact;

        /// <summary>obj_cushion segment reflection — scoring uses player-only rules in GM.</summary>
        public System.Action<BilliardBallMotor> OnSegmentCushionContact;

        public System.Action<BilliardBallMotor, BilliardBallMotor> OnBallContact;

        [System.Obsolete("Use OnClothCushionContact for cloth bounds.")]
        public System.Action<BilliardBallMotor> OnCushionContact
        {
            get => OnClothCushionContact;
            set => OnClothCushionContact = value;
        }
    }
}
