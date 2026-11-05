using CushionChallenge.Core;
using CushionChallenge.Physics;
using UnityEngine;

namespace CushionChallenge.Gameplay
{
    public enum BallRole
    {
        Player,
        Target,
        Foul,
        AiStriker
    }

    public class BilliardBallView : MonoBehaviour
    {
        public BallRole Role;
        BilliardBallMotor _motor;

        public BilliardBallMotor Motor => _motor != null ? _motor : (_motor = GetComponent<BilliardBallMotor>());

        void Awake()
        {
            _motor = GetComponent<BilliardBallMotor>();
        }
    }
}
