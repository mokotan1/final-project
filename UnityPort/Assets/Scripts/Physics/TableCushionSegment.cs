using UnityEngine;

namespace CushionChallenge.Physics
{
    public enum TableCushionOrientation
    {
        Horizontal,
        Vertical
    }

    /// <summary>GameMaker obj_cushion instance — collision mask and axis reflection only (scr_physics physics_resolve_cushion_collision).</summary>
    public class TableCushionSegment : MonoBehaviour
    {
        public TableCushionOrientation Orientation;
        public Rect WorldBounds;

        public static bool CircleOverlaps(Vector2 center, float radius, Rect bounds)
        {
            var closestX = Mathf.Clamp(center.x, bounds.xMin, bounds.xMax);
            var closestY = Mathf.Clamp(center.y, bounds.yMin, bounds.yMax);
            var dx = center.x - closestX;
            var dy = center.y - closestY;
            return dx * dx + dy * dy <= radius * radius;
        }
    }
}
