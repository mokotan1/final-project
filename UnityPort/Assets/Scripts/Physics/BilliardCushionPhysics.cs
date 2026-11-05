using UnityEngine;

namespace CushionChallenge.Physics
{
    public static class BilliardCushionPhysics
    {
        /// <summary>scr_physics physics_resolve_cushion_collision velocity flip.</summary>
        public static Vector2 ApplyReflection(Vector2 velocity, TableCushionOrientation orientation, float restitution)
        {
            if (orientation == TableCushionOrientation.Horizontal)
                return new Vector2(velocity.x, -velocity.y * restitution);
            return new Vector2(-velocity.x * restitution, velocity.y);
        }
    }
}
