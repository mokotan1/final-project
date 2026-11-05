using System.Collections.Generic;
using UnityEngine;

namespace CushionChallenge.Physics
{
    /// <summary>Drives GM-order live physics once per FixedUpdate for all BilliardBallMotor instances.</summary>
    [DefaultExecutionOrder(-100)]
    public class BilliardPhysicsWorld : MonoBehaviour
    {
        static BilliardPhysicsWorld _active;
        TableCushionSegment[] _segments = System.Array.Empty<TableCushionSegment>();

        public static BilliardPhysicsWorld Ensure(Transform cushionRoot = null)
        {
            if (_active != null)
                return _active;

            var go = new GameObject(nameof(BilliardPhysicsWorld));
            _active = go.AddComponent<BilliardPhysicsWorld>();
            if (cushionRoot != null)
                _active.BindCushions(cushionRoot);
            return _active;
        }

        public void BindCushions(Transform root)
        {
            _segments = root != null
                ? root.GetComponentsInChildren<TableCushionSegment>(true)
                : System.Array.Empty<TableCushionSegment>();
        }

        void OnDestroy()
        {
            if (_active == this)
                _active = null;
        }

        void FixedUpdate()
        {
            var balls = FindObjectsByType<BilliardBallMotor>(FindObjectsSortMode.None);
            if (balls.Length == 0)
                return;

            if (_segments.Length == 0)
            {
                foreach (var ball in balls)
                {
                    var parent = ball.transform.parent;
                    if (parent != null)
                    {
                        BindCushions(parent);
                        break;
                    }
                }
            }

            BilliardLivePhysics.StepWorld(balls, _segments);
        }
    }

}
