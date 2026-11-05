using UnityEngine;

namespace CushionChallenge.Physics
{
    /// <summary>rm_game / rm_story_ai_verify obj_cushion instances (spr_cushion 64×32, origin center).</summary>
    public static class TableCushionLayout
    {
        const float CushionSpriteWidth = 64f;
        const float CushionSpriteHeight = 32f;
        const float RailScaleX = 13.4375f;
        const float SideScaleX = 6.5625f;

        public static void EnsureCushions(Transform parent)
        {
            if (parent == null)
                return;

            var existing = parent.GetComponentsInChildren<TableCushionSegment>(true);
            if (existing.Length >= 4)
                return;

            foreach (var seg in existing)
            {
                if (seg != null)
                    Object.Destroy(seg.gameObject);
            }

            CreateSegment(parent, "CushionTop", TableCushionOrientation.Horizontal,
                new Vector2(640f, 140f), RailScaleX, 1f);
            CreateSegment(parent, "CushionBottom", TableCushionOrientation.Horizontal,
                new Vector2(640f, 560f), RailScaleX, 1f);
            CreateSegment(parent, "CushionLeft", TableCushionOrientation.Vertical,
                new Vector2(210f, 350f), SideScaleX, 1f);
            CreateSegment(parent, "CushionRight", TableCushionOrientation.Vertical,
                new Vector2(1070f, 350f), SideScaleX, 1f);
        }

        static void CreateSegment(
            Transform parent,
            string name,
            TableCushionOrientation orientation,
            Vector2 center,
            float scaleX,
            float scaleY)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent, false);
            go.transform.position = new Vector3(center.x, center.y, 0f);

            var width = CushionSpriteWidth * scaleX;
            var height = CushionSpriteHeight * scaleY;
            if (orientation == TableCushionOrientation.Vertical)
                (width, height) = (height, width);

            var seg = go.AddComponent<TableCushionSegment>();
            seg.Orientation = orientation;
            seg.WorldBounds = new Rect(center.x - width * 0.5f, center.y - height * 0.5f, width, height);
        }
    }
}
