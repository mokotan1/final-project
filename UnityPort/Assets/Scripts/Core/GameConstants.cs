using UnityEngine;

namespace CushionChallenge.Core
{
    /// <summary>Matches GameMaker rm_game table placement and playable cloth bounds.</summary>
    public static class GameConstants
    {
        public const int TargetWidth = 1280;
        public const int TargetHeight = 720;
        public const float TargetFps = 60f;

        public const float TableOriginX = 160f;
        public const float TableOriginY = 90f;
        public const float TableLeft = 210f;
        public const float TableTop = 140f;
        public const float TableRight = 1070f;
        public const float TableBottom = 560f;

        public const float BallRadius = 16f;
        public const float BallFriction = 0.045f;
        public const float BallStopSpeed = 0.08f;
        public const float BallRestitution = 0.96f;

        public static Rect TablePlayableRect => new(TableLeft, TableTop, TableRight - TableLeft, TableBottom - TableTop);

        public static bool PlayableContains(Vector2 pos) =>
            pos.x >= TableLeft + BallRadius && pos.x <= TableRight - BallRadius
            && pos.y >= TableTop + BallRadius && pos.y <= TableBottom - BallRadius;

        /// <summary>GameMaker lengthdir_x / lengthdir_y (y-down room space, float32).</summary>
        public static Vector2 LengthDir(float directionDeg, float length) =>
            GameMakerFloat.LengthDir(directionDeg, length);
    }
}
