using CushionChallenge.Core;
using UnityEngine;

namespace CushionChallenge.Gameplay
{
    /// <summary>Converts rm_game's downward-positive room coordinates at the display boundary.</summary>
    public static class GameMakerDisplay
    {
        public static Vector3 ToDisplay(Vector3 roomPosition) =>
            new Vector3(roomPosition.x, GameConstants.TargetHeight - roomPosition.y, roomPosition.z);

        // Reflection is its own inverse; screen input returns Unity world coordinates.
        public static Vector3 ToRoom(Vector3 displayPosition) => ToDisplay(displayPosition);
    }

    /// <summary>Keeps the rendered sprite separate from the GM-coordinate physics transform.</summary>
    public sealed class GameMakerBallVisual : MonoBehaviour
    {
        Transform _visual;

        public void Configure(SpriteRenderer source)
        {
            var child = transform.Find("GmVisual");
            if (child == null)
            {
                var go = new GameObject("GmVisual");
                child = go.transform;
                child.SetParent(transform, false);
            }

            if (!child.TryGetComponent(out SpriteRenderer renderer))
                renderer = child.gameObject.AddComponent<SpriteRenderer>();
            renderer.sprite = source.sprite;
            renderer.sharedMaterial = source.sharedMaterial;
            renderer.sortingLayerID = source.sortingLayerID;
            renderer.sortingOrder = source.sortingOrder;
            renderer.color = source.color;
            source.enabled = false;
            _visual = child;
            Sync();
        }

        void LateUpdate() => Sync();

        void Sync()
        {
            if (_visual != null)
                _visual.position = GameMakerDisplay.ToDisplay(transform.position);
        }
    }
}
