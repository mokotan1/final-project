using UnityEngine;

namespace CushionChallenge.Core
{
    /// <summary>IEEE754 float32 ops matching GameMaker Runner VM (scr_physics / lengthdir).</summary>
    public static class GameMakerFloat
    {
        public static float F32(float value) => value;

        public static float F32(double value) => (float)value;

        public static float LengthDirX(float length, float directionDeg)
        {
            var rad = F32(directionDeg * (Mathf.PI / 180f));
            var c = F32(Mathf.Cos(rad));
            return F32(c * F32(length));
        }

        public static float LengthDirY(float length, float directionDeg)
        {
            var rad = F32(directionDeg * (Mathf.PI / 180f));
            var s = F32(Mathf.Sin(rad));
            return F32(-s * F32(length));
        }

        public static Vector2 LengthDir(float directionDeg, float length) =>
            new(LengthDirX(length, directionDeg), LengthDirY(length, directionDeg));

        /// <summary>GameMaker point_distance(0, 0, x, y).</summary>
        public static float Distance(float x, float y)
        {
            var xx = F32(x * x);
            var yy = F32(y * y);
            return F32(Mathf.Sqrt(F32(xx + yy)));
        }

        public static void ApplyFriction(ref float vx, ref float vy, float friction, float stopSpeed)
        {
            var magnitude = Distance(vx, vy);
            if (magnitude <= F32(stopSpeed))
            {
                vx = 0f;
                vy = 0f;
                return;
            }

            var next = F32(Mathf.Max(0f, F32(magnitude - friction)));
            var scale = F32(next / magnitude);
            vx = F32(vx * scale);
            vy = F32(vy * scale);
        }

        public static float Abs(float value) => F32(Mathf.Abs(value));
    }
}
