using UnityEngine;
using UnityEngine.UI;

namespace CushionChallenge.UI
{
    public static class GameUiFonts
    {
        static Font _body;
        static Font _bold;

        public static Font Body
        {
            get
            {
                if (_body == null)
                    _body = Resources.Load<Font>("Fonts/Galmuri11")
                              ?? Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
                return _body;
            }
        }

        public static Font Bold
        {
            get
            {
                if (_bold == null)
                    _bold = Resources.Load<Font>("Fonts/Galmuri11-Bold") ?? Body;
                return _bold;
            }
        }

        public static void Apply(Text text, bool bold = false)
        {
            text.font = bold ? Bold : Body;
        }
    }
}
