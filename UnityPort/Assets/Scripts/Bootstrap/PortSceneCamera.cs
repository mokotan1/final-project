using CushionChallenge.Core;
using UnityEngine;

namespace CushionChallenge.Bootstrap
{
    public static class PortSceneCamera
    {
        public static Camera EnsureMainCamera()
        {
            var cam = Camera.main;
            if (cam == null)
            {
                var camGo = new GameObject("Main Camera");
                cam = camGo.AddComponent<Camera>();
                camGo.tag = "MainCamera";
                camGo.AddComponent<AudioListener>();
            }

            cam.orthographic = true;
            cam.orthographicSize = GameConstants.TargetHeight * 0.5f;
            cam.transform.position = new Vector3(GameConstants.TargetWidth * 0.5f, GameConstants.TargetHeight * 0.5f, -10f);
            cam.backgroundColor = Color.black;
            return cam;
        }

        public static void ApplyToExisting(Camera cam)
        {
            if (cam == null)
                return;
            cam.orthographic = true;
            cam.orthographicSize = GameConstants.TargetHeight * 0.5f;
            cam.transform.position = new Vector3(GameConstants.TargetWidth * 0.5f, GameConstants.TargetHeight * 0.5f, -10f);
            cam.backgroundColor = Color.black;
        }
    }
}
