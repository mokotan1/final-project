using CushionChallenge.Core;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CushionChallenge.Gameplay
{
    public class CueAimController : MonoBehaviour
    {
        BilliardBallView _player;
        Camera _cam;
        float _charge;
        const float MaxPower = 18f;

        public bool WantsShoot { get; private set; }

        public bool TryGetPowerNormalized(out float normalized)
        {
            normalized = MaxPower <= 0f ? 0f : Mathf.Clamp01(_charge / MaxPower);
            return _player != null;
        }

        public void Bind(BilliardBallView player)
        {
            _player = player;
            _cam = Camera.main;
        }

        void Update()
        {
            WantsShoot = false;
            if (_player == null || _cam == null)
                return;

            var mouse = Mouse.current;
            if (mouse == null)
                return;

            var world = _cam.ScreenToWorldPoint(mouse.position.ReadValue());
            var dir = (Vector2)GameMakerDisplay.ToRoom(world) - (Vector2)_player.transform.position;

            if (mouse.leftButton.wasPressedThisFrame)
                _charge = 0f;
            if (mouse.leftButton.isPressed)
                _charge = Mathf.Min(MaxPower, _charge + MaxPower * Time.deltaTime);
            if (mouse.leftButton.wasReleasedThisFrame && _charge > 0.5f)
                WantsShoot = true;

            var start = GameMakerDisplay.ToDisplay(_player.transform.position);
            var end = GameMakerDisplay.ToDisplay(_player.transform.position + (Vector3)dir.normalized * (_charge * 8f));
            Debug.DrawLine(start, end, Color.cyan);
        }

        public void ExecuteShot()
        {
            if (_player?.Motor == null)
                return;
            var mouse = Mouse.current;
            if (mouse == null)
                return;
            var world = _cam.ScreenToWorldPoint(mouse.position.ReadValue());
            var dir = (Vector2)GameMakerDisplay.ToRoom(world) - (Vector2)_player.transform.position;
            ExecuteShot(dir, _charge);
        }

        public void ExecuteShot(Vector2 direction, float power)
        {
            if (_player?.Motor == null)
                return;
            _player.Motor.Shoot(direction, power);
            _charge = 0f;
            PortAudio.PlaySfx("snd_shot");
        }
    }
}
