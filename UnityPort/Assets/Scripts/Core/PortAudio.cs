using UnityEngine;

namespace CushionChallenge.Core
{
    public static class PortAudio
    {
        static AudioSource _source;

        static AudioSource Source
        {
            get
            {
                if (_source != null)
                    return _source;
                var go = new GameObject("PortAudio");
                if (Application.isPlaying)
                    Object.DontDestroyOnLoad(go);
                _source = go.AddComponent<AudioSource>();
                _source.playOnAwake = false;
                return _source;
            }
        }

        static float VolumeScale => PortSaveStore.AudioVolumePercent / 100f;

        public static void PlaySfx(string resourceName, float scale = 1f)
        {
            var clip = Resources.Load<AudioClip>("Audio/" + resourceName);
            if (clip == null)
                return;
            Source.PlayOneShot(clip, scale * VolumeScale);
        }
    }
}
