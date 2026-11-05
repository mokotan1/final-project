using System.Collections.Generic;
using System.Linq;
using CushionChallenge.Core;
using CushionChallenge.Bootstrap;
using CushionChallenge.Physics;
using CushionChallenge.Rules;
using CushionChallenge.Story;
using CushionChallenge.UI;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CushionChallenge.Gameplay
{
    public class GameRoomController : MonoBehaviour
    {
        [SerializeField] Sprite tableSprite;
        [SerializeField] Sprite playerBallSprite;
        [SerializeField] Sprite targetBallSprite;
        [SerializeField] Sprite foulBallSprite;

        public GameModeKind Mode { get; private set; } = GameModeKind.Endless;
        EndlessRulesEngine _rules = new();
        StoryVersusSession _story = new();
        readonly List<BilliardBallView> _foulBalls = new();
        BilliardBallView _playerBall;
        BilliardBallView _aiBall;
        BilliardBallView _targetBall;
        CueAimController _cue;
        StoryDialoguePanel _dialogue;
        GameHudPanel _hud;
        StoryShopPanel _shop;
        MatchResultPanel _result;
        EndlessRewardChoicePanel _rewardChoice;
        int _cushionsThisShot;
        bool _storyMode;
        bool _shotInProgress;
        bool _endShotHandled;
        bool _aiTurnScheduled;
        float _aiTurnDelay;
        bool _resultShown;
        readonly Dictionary<int, int> _ruleContactLocks = new();
        readonly List<Sprite> _runtimeSprites = new();
        Material _gameplayMaterial;

        const int RuleContactLockFrames = 30;

        public static GameRoomController Instance { get; private set; }

        BilliardBallView Striker =>
            _storyMode && _story.CurrentTurn == StoryTurnSide.Ai ? _aiBall : _playerBall;

        public static void Launch(GameModeKind mode)
        {
            SessionRequest.PendingMode = mode;
            SceneFlow.LoadGamePlay(mode);
        }

        void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }

            Instance = this;
            PortSceneCamera.EnsureMainCamera();
            PortUiRuntime.EnsureEventSystem();
            Mode = SessionRequest.PendingMode;
            _storyMode = Mode == GameModeKind.StoryFiftyRound;
            if (!_storyMode)
            {
                _rules.Mode = Mode;
                _rules.ResetRun();
            }

            LoadSpritesFromResources();
            BuildRoom();
            if (_storyMode)
            {
                _story.IntroMatch = SessionRequest.StoryIntroMatch;
                _story.BeginFiftyRoundMatch();
                var breaker = _story.RollBreakBreaker();
                _story.AssignBreakBreaker(breaker);
                _story.PlayerScoreAtTurnStart = 0;
                ShowStoryLine("Bartender", breaker == StoryTurnSide.Player ? "OPN-01" : "OPN-02");
                if (breaker == StoryTurnSide.Ai)
                    ScheduleAiTurn();
            }

            _hud = GameHudPanel.Create(transform);
            _shop = StoryShopPanel.Create(transform);
            _shop.gameObject.SetActive(_storyMode);
            _result = MatchResultPanel.Create(transform, ReturnToMenu);
            _rewardChoice = EndlessRewardChoicePanel.Create(transform);
            _rewardChoice.OnPick = item =>
            {
                if (_rules.TryChooseReward(item))
                    RefreshHud();
            };
            _rewardChoice.gameObject.SetActive(false);
            RefreshHud();
        }

        void ReturnToMenu() => SceneFlow.LoadMainMenu();

        void LoadSpritesFromResources()
        {
            _gameplayMaterial = Resources.Load<Material>("GameArt/GameplayUnlit");
            if (tableSprite == null) tableSprite = LoadSprite("GameArt/Table/spr_table");
            if (playerBallSprite == null) playerBallSprite = LoadSprite("GameArt/Balls/spr_ball_player");
            if (targetBallSprite == null) targetBallSprite = LoadSprite("GameArt/Balls/spr_ball_target");
            if (foulBallSprite == null) foulBallSprite = LoadSprite("GameArt/Balls/spr_ball_foul");
        }

        Sprite LoadSprite(string path)
        {
            var sprites = Resources.LoadAll<Sprite>(path);
            if (sprites.Length == 0) return null;
            var source = sprites[0];
            var pivot = new Vector2(source.pivot.x / source.rect.width, source.pivot.y / source.rect.height);
            var sprite = Sprite.Create(source.texture, source.rect, pivot, 1f);
            _runtimeSprites.Add(sprite);
            return sprite;
        }

        void OnDestroy()
        {
            foreach (var sprite in _runtimeSprites)
                if (sprite != null) Destroy(sprite);
            if (Instance == this) Instance = null;
        }

        void BuildRoom()
        {
            var cam = Camera.main;
            if (cam != null)
                PortSceneCamera.ApplyToExisting(cam);

            var tableGo = transform.Find("Table");
            if (tableGo != null && tableGo.TryGetComponent<SpriteRenderer>(out var existingTable))
            {
                if (existingTable.sprite == null && tableSprite != null)
                    existingTable.sprite = tableSprite;
            }
            else if (tableSprite != null)
            {
                tableGo = new GameObject("Table").transform;
                tableGo.SetParent(transform, false);
                var sr = tableGo.gameObject.AddComponent<SpriteRenderer>();
                sr.sprite = tableSprite;
                tableGo.position = new Vector3(GameConstants.TableOriginX, GameConstants.TableOriginY, 0f);
            }

            if (tableGo != null && tableSprite != null)
            {
                var renderer = tableGo.GetComponent<SpriteRenderer>();
                if (renderer != null && _gameplayMaterial != null) renderer.sharedMaterial = _gameplayMaterial;
                // rm_game Table background uses a top-left origin at (160, 90).
                tableGo.position = GameMakerDisplay.ToDisplay(new Vector3(
                    GameConstants.TableOriginX + tableSprite.rect.width * 0.5f,
                    GameConstants.TableOriginY + tableSprite.rect.height * 0.5f, 0f));
            }

            TableCushionLayout.EnsureCushions(transform);

            _playerBall = SpawnBall("PlayerBall", playerBallSprite, BallRole.Player, new Vector2(380, 350));
            _aiBall = SpawnBall("AiBall", playerBallSprite, BallRole.AiStriker, new Vector2(900, 350));
            _targetBall = SpawnBall("TargetBall", targetBallSprite, BallRole.Target, new Vector2(640, 260));
            _foulBalls.Add(SpawnBall("FoulBallA", foulBallSprite, BallRole.Foul, new Vector2(520, 480)));
            _foulBalls.Add(SpawnBall("FoulBallB", foulBallSprite, BallRole.Foul, new Vector2(760, 480)));
            SyncStoryFoulCount();

            foreach (var view in new[] { _playerBall, _aiBall, _targetBall })
            {
                view.Motor.OnCushionContact += motor =>
                {
                    if (motor.gameObject != Striker.gameObject)
                        return;
                    if (_storyMode)
                    {
                        if (!_story.ShotActive || _story.ShotScored || _story.ShotPenalized)
                            return;
                    }
                    else if (!_rules.ShotActive || _rules.ShotScored || _rules.ShotPenalized)
                        return;

                    _cushionsThisShot++;
                    if (_storyMode)
                        _story.OnCushionHit(_cushionsThisShot);
                };
            }

            foreach (var view in FindObjectsByType<BilliardBallView>(FindObjectsSortMode.None))
                view.Motor.OnBallContact += OnBallContact;

            var cueTransform = transform.Find("Cue");
            if (cueTransform != null)
                _cue = cueTransform.GetComponent<CueAimController>() ?? cueTransform.gameObject.AddComponent<CueAimController>();
            else
            {
                var cueGo = new GameObject("Cue");
                cueGo.transform.SetParent(transform, false);
                _cue = cueGo.AddComponent<CueAimController>();
            }
            _cue.Bind(_playerBall);

            var dialogueTransform = transform.Find("StoryDialogue");
            if (dialogueTransform != null)
                _dialogue = dialogueTransform.GetComponent<StoryDialoguePanel>() ?? dialogueTransform.gameObject.AddComponent<StoryDialoguePanel>();
            else
            {
                var dialogueGo = new GameObject("StoryDialogue");
                dialogueGo.transform.SetParent(transform, false);
                _dialogue = dialogueGo.AddComponent<StoryDialoguePanel>();
            }
        }

        BilliardBallView SpawnBall(string name, Sprite sprite, BallRole role, Vector2 pos)
        {
            var existing = transform.Find(name);
            GameObject go;
            if (existing != null)
            {
                go = existing.gameObject;
                go.transform.position = pos;
            }
            else
            {
                go = new GameObject(name);
                go.transform.SetParent(transform, false);
                go.transform.position = pos;
            }
            var sr = go.GetComponent<SpriteRenderer>() ?? go.AddComponent<SpriteRenderer>();
            sr.sprite = sprite;
            if (_gameplayMaterial != null) sr.sharedMaterial = _gameplayMaterial;
            sr.sortingOrder = 1;
            (go.GetComponent<GameMakerBallVisual>() ?? go.AddComponent<GameMakerBallVisual>()).Configure(sr);
            var motor = go.GetComponent<BilliardBallMotor>() ?? go.AddComponent<BilliardBallMotor>();
            var view = go.GetComponent<BilliardBallView>() ?? go.AddComponent<BilliardBallView>();
            view.Role = role;
            var rb = go.GetComponent<Rigidbody2D>();
            if (rb == null)
                rb = go.AddComponent<Rigidbody2D>();
            rb.bodyType = RigidbodyType2D.Kinematic;
            return view;
        }

        void SyncStoryFoulCount()
        {
            if (!_storyMode)
                return;
            _story.FoulBallCountOnTable = _foulBalls.Count(b => b.gameObject.activeSelf);
        }

        void OnBallContact(BilliardBallMotor self, BilliardBallMotor other)
        {
            var selfView = self.GetComponent<BilliardBallView>();
            var otherView = other.GetComponent<BilliardBallView>();
            if (selfView == null || otherView == null)
                return;

            TryApplyBallRules(selfView, otherView);
            TryApplyBallRules(otherView, selfView);
        }

        void TryApplyBallRules(BilliardBallView strikerSide, BilliardBallView otherBall)
        {
            if (Striker == null || strikerSide != Striker)
                return;
            if (!BeginRuleContact(otherBall))
                return;

            if (_storyMode)
            {
                if (!_story.ShotActive)
                    return;
                _story.OnCushionHit(_cushionsThisShot);
                if (otherBall.Role == BallRole.Target)
                    _story.OnTargetHit();
                else if (otherBall.Role == BallRole.Foul)
                    _story.OnFoulHit();
                RefreshHud();
                return;
            }

            if (!_rules.ShotActive)
                return;

            if (otherBall.Role == BallRole.Target)
                _rules.OnTargetHit(_cushionsThisShot);
            else if (otherBall.Role == BallRole.Foul)
                _rules.OnFoulHit(_rules.RiskShotActive);
        }

        bool BeginRuleContact(BilliardBallView other)
        {
            var key = other.GetInstanceID();
            if (_ruleContactLocks.TryGetValue(key, out var frames) && frames > 0)
                return false;
            _ruleContactLocks[key] = RuleContactLockFrames;
            return true;
        }

        void TickRuleContactLocks()
        {
            if (_ruleContactLocks.Count == 0)
                return;
            var keys = new List<int>(_ruleContactLocks.Keys);
            foreach (var key in keys)
            {
                _ruleContactLocks[key]--;
                if (_ruleContactLocks[key] <= 0)
                    _ruleContactLocks.Remove(key);
            }
        }

        void Update()
        {
            TickRuleContactLocks();
            if (_storyMode)
                _story.Tick(Time.deltaTime);
            else
                _rules.Tick(Time.deltaTime);

            UpdateDialogueDisplay();
            TrySpawnPendingFouls();
            ShowResultIfReady();
            HandleShopInput();
            HandleEndlessPlaceMode();
            HandleStoryPlaceMode();
            HandleEndlessItemKeys();
            HandleEndlessRewardChoice();
            if (!_storyMode && GameModeRules.ItemsEnabled(Mode))
                _rules.TryOpenRewardChoice(AllBallsStopped());

            if (_storyMode && !_story.MatchOver && _story.CurrentTurn == StoryTurnSide.Ai)
                TryScheduleAiTurn();
            else if (!_storyMode || _story.CurrentTurn == StoryTurnSide.Player)
                _cue.Bind(_playerBall);
            else
                _cue.Bind(_aiBall);

            if (_cue != null && _cue.WantsShoot && CanAcceptInput())
            {
                var strikerSide = _storyMode
                    ? (_story.CurrentTurn == StoryTurnSide.Ai ? StoryTurnSide.Ai : StoryTurnSide.Player)
                    : StoryTurnSide.Player;
                if (_storyMode)
                {
                    if (!_story.TryBeginShot(strikerSide))
                        return;
                    _cushionsThisShot = 0;
                    _shotInProgress = true;
                    _endShotHandled = false;
                }
                else if (_rules.TryBeginShot())
                {
                    _cushionsThisShot = 0;
                    _shotInProgress = true;
                    _endShotHandled = false;
                }
                else
                    return;

                if (strikerSide == StoryTurnSide.Ai)
                    return;
                _cue.ExecuteShot();
            }

            if (_aiTurnScheduled)
            {
                _aiTurnDelay -= Time.deltaTime;
                if (_aiTurnDelay <= 0f)
                {
                    _aiTurnScheduled = false;
                    ExecuteAiTurn();
                }
            }

            var moving = !AllBallsStopped();
            if (moving)
                _endShotHandled = false;
            else if (_shotInProgress && !_endShotHandled)
            {
                EndShotIfNeeded();
                _endShotHandled = true;
                _shotInProgress = false;
                RestoreStoryFouls();
                RefreshHud();
                if (_storyMode && !_story.MatchOver && _story.CurrentTurn == StoryTurnSide.Ai)
                    ScheduleAiTurn();
            }

            RefreshHud();
        }

        void UpdateDialogueDisplay()
        {
            if (_dialogue == null)
                return;
            if (_storyMode && _story.Dialogue.TryGetDisplay(out var speaker, out var text))
                _dialogue.Show(speaker, text);
            else if (!_storyMode || !_story.Dialogue.HasVisibleDialogue)
                _dialogue.Hide();
        }

        void ShowResultIfReady()
        {
            if (_resultShown)
                return;
            if (_storyMode)
            {
                if (!_story.MatchOver || _story.Dialogue.HasVisibleDialogue)
                    return;
                _result.ShowStory(_story);
                _resultShown = true;
                return;
            }

            if (!_rules.ResultReady)
                return;
            _result.ShowEndless(_rules);
            _resultShown = true;
        }

        void HandleShopInput()
        {
            if (!_storyMode || !_story.IsHumanTurn())
                return;
            var kb = Keyboard.current;
            if (kb == null)
                return;
            if (kb.digit1Key.wasPressedThisFrame)
                TryStoryPurchase(GameItemKind.Move);
            if (kb.digit2Key.wasPressedThisFrame)
                TryStoryPurchase(GameItemKind.RiskShot);
            if (kb.digit3Key.wasPressedThisFrame)
                TryStoryPurchase(GameItemKind.RemoveFoul);
            if (kb.spaceKey.wasPressedThisFrame)
                _story.Dialogue.Skip();
        }

        void TryStoryPurchase(GameItemKind item)
        {
            if (!_story.TryPurchaseItem(item, true))
                return;
            if (_story.RequestFoulRemoval)
                HideAllFouls();
            RefreshHud();
        }

        void HideAllFouls()
        {
            foreach (var foul in _foulBalls)
            {
                if (!foul.gameObject.activeSelf)
                    continue;
                _story.NoteRemovedFoul(foul.transform.position);
                foul.gameObject.SetActive(false);
            }

            _story.RequestFoulRemoval = false;
            SyncStoryFoulCount();
        }

        void RestoreStoryFouls()
        {
            if (!_storyMode || _story.RemovedFoulPositions.Count == 0)
                return;
            foreach (var pos in _story.RemovedFoulPositions)
            {
                foreach (var foul in _foulBalls)
                {
                    if (foul.gameObject.activeSelf)
                        continue;
                    if (Vector2.Distance(foul.transform.position, pos) < 1f)
                        foul.gameObject.SetActive(true);
                }
            }

            _story.RestoreRemovedFouls();
            SyncStoryFoulCount();
        }

        void HandleEndlessRewardChoice()
        {
            if (_storyMode || _rewardChoice == null)
                return;
            if (_rules.RewardChoiceOpen)
            {
                _rewardChoice.gameObject.SetActive(true);
                _rewardChoice.Show();
            }
            else
            {
                _rewardChoice.Hide();
                _rewardChoice.gameObject.SetActive(false);
            }

            if (!_rules.RewardChoiceOpen)
                return;
            var kb = Keyboard.current;
            if (kb == null)
                return;
            if (kb.digit1Key.wasPressedThisFrame)
                _rules.TryChooseReward(GameItemKind.Move);
            if (kb.digit2Key.wasPressedThisFrame)
                _rules.TryChooseReward(GameItemKind.RiskShot);
            if (kb.digit3Key.wasPressedThisFrame)
                _rules.TryChooseReward(GameItemKind.RemoveFoul);
        }

        void HandleStoryPlaceMode()
        {
            if (!_storyMode || !_story.PlaceMode)
                return;
            TryPlaceBall(_playerBall, pos =>
            {
                _playerBall.transform.position = pos;
                _playerBall.Motor.Stop();
                _story.TryFinishPlaceMode();
            });
        }

        void HandleEndlessPlaceMode()
        {
            if (_storyMode || !_rules.PlaceMode)
                return;
            TryPlaceBall(_playerBall, pos =>
            {
                _playerBall.transform.position = pos;
                _playerBall.Motor.Stop();
                _rules.TryFinishPlaceMode(pos, true);
            });
        }

        void TryPlaceBall(BilliardBallView ball, System.Action<Vector2> apply)
        {
            var mouse = Mouse.current;
            if (mouse == null || !mouse.leftButton.wasPressedThisFrame)
                return;
            var cam = Camera.main;
            if (cam == null)
                return;
            var world = cam.ScreenToWorldPoint(mouse.position.ReadValue());
            var pos = (Vector2)GameMakerDisplay.ToRoom(world);
            var views = FindObjectsByType<BilliardBallView>(FindObjectsSortMode.None);
            if (!BallPlacementUtility.IsPositionClear(pos, GameConstants.BallRadius, ball, views))
                return;
            apply(pos);
        }

        void HandleEndlessItemKeys()
        {
            if (_storyMode || _rules.GameOver || _rules.ShotActive || _rules.RewardChoiceOpen)
                return;
            var kb = Keyboard.current;
            if (kb == null)
                return;
            if (kb.digit1Key.wasPressedThisFrame && _rules.TryUseInventoryItem(GameItemKind.Move))
                RefreshHud();
            if (kb.digit2Key.wasPressedThisFrame && _rules.TryUseInventoryItem(GameItemKind.RiskShot))
                RefreshHud();
            if (kb.digit3Key.wasPressedThisFrame && TryUseEndlessRemoveFoul())
                RefreshHud();
        }

        bool TryUseEndlessRemoveFoul()
        {
            if (!_rules.TryUseInventoryItem(GameItemKind.RemoveFoul))
                return false;
            foreach (var foul in _foulBalls)
            {
                if (!foul.gameObject.activeSelf)
                    continue;
                foul.gameObject.SetActive(false);
                _rules.Items.FoulCount = Mathf.Max(0, _rules.Items.FoulCount - 1);
                return true;
            }

            return true;
        }

        void TrySpawnPendingFouls()
        {
            if (_storyMode || _rules.Items.PendingFoulSpawns <= 0 || !AllBallsStopped())
                return;
            var cap = GameModeRules.FoulCap(Mode);
            while (_rules.Items.PendingFoulSpawns > 0 && _foulBalls.Count(f => f.gameObject.activeSelf) < cap)
            {
                var pos = new Vector2(UnityEngine.Random.Range(520f, 760f), UnityEngine.Random.Range(420f, 500f));
                var foul = SpawnBall($"FoulBall_{_foulBalls.Count}", foulBallSprite, BallRole.Foul, pos);
                _foulBalls.Add(foul);
                foul.Motor.OnBallContact += OnBallContact;
                _rules.Items.PendingFoulSpawns--;
                _rules.Items.FoulCount++;
            }
        }

        void TryScheduleAiTurn()
        {
            if (_shotInProgress || !AllBallsStopped() || _aiTurnScheduled)
                return;
            ScheduleAiTurn();
        }

        void ScheduleAiTurn()
        {
            _aiTurnScheduled = true;
            _aiTurnDelay = StoryConstants.AiTurnDelaySeconds;
        }

        void ExecuteAiTurn()
        {
            if (_story.MatchOver || _story.CurrentTurn != StoryTurnSide.Ai || !AllBallsStopped())
                return;

            _cushionsThisShot = 0;
            if (!_story.TryBeginShot(StoryTurnSide.Ai))
                return;
            _shotInProgress = true;
            _endShotHandled = false;

            if (_story.BreakPending)
            {
                var targetPos = _targetBall.transform.position;
                var aiPos = _aiBall.transform.position;
                var baseDir = (Vector2)(targetPos - aiPos);
                var side = UnityEngine.Random.value < 0.5f ? -1f : 1f;
                var dir = Rotate(baseDir.normalized, side * UnityEngine.Random.Range(5f, 6f));
                var power = UnityEngine.Random.Range(26f, 30f);
                _aiBall.Motor.Shoot(dir, power);
                PortAudio.PlaySfx("snd_shot");
                return;
            }

            TryRelocateAiIfPending();
            var layout = LiveLayoutSnapshot();
            var aiPos2 = (Vector2)_aiBall.transform.position;
            var plan = StoryAiTurnPlanner.PlanAiTurn(_story, layout, aiPos2);
            if (plan.PassTurn)
            {
                _story.AbortActiveShot();
                _story.PassTurnNoShot();
                _shotInProgress = false;
                RefreshHud();
                return;
            }

            if (!plan.Shoot)
            {
                _story.AbortActiveShot();
                _story.PassTurnNoShot();
                _shotInProgress = false;
                return;
            }

            var shotDir = AngleToVector(plan.DirectionDeg);
            _aiBall.Motor.Shoot(shotDir, plan.Power);
            PortAudio.PlaySfx("snd_shot");
        }

        void TryRelocateAiIfPending()
        {
            if (!_story.ConsumePendingAiRelocate())
                return;
            var views = FindObjectsByType<BilliardBallView>(FindObjectsSortMode.None);
            for (var i = 0; i < 40; i++)
            {
                var pos = new Vector2(
                    UnityEngine.Random.Range(GameConstants.TableLeft + 32f, GameConstants.TableRight - 32f),
                    UnityEngine.Random.Range(GameConstants.TableTop + 32f, GameConstants.TableBottom - 32f));
                if (!BallPlacementUtility.IsPositionClear(pos, GameConstants.BallRadius, _aiBall, views))
                    continue;
                _aiBall.transform.position = pos;
                _aiBall.Motor.Stop();
                return;
            }
        }
        static Vector2 AngleToVector(float deg) => GameConstants.LengthDir(deg, 1f);

        static Vector2 Rotate(Vector2 v, float degrees)
        {
            var rad = degrees * Mathf.Deg2Rad;
            var c = Mathf.Cos(rad);
            var s = Mathf.Sin(rad);
            return new Vector2(v.x * c - v.y * s, v.x * s + v.y * c);
        }

        List<StoryAiSimulator.SimBall> LiveLayoutSnapshot()
        {
            var list = new List<StoryAiSimulator.SimBall>();
            foreach (var view in FindObjectsByType<BilliardBallView>(FindObjectsSortMode.None))
            {
                if (!view.gameObject.activeSelf)
                    continue;
                var pos = view.transform.position;
                list.Add(new StoryAiSimulator.SimBall
                {
                    Role = view.Role,
                    X = pos.x,
                    Y = pos.y,
                    R = GameConstants.BallRadius
                });
            }

            return list;
        }

        bool CanAcceptInput()
        {
            if (_resultShown)
                return false;
            if (_storyMode)
            {
                if (_story.PlaceMode || _story.InputLocked())
                    return false;
                return !_story.MatchOver && _story.CurrentTurn == StoryTurnSide.Player && !_aiTurnScheduled
                       && !_story.ShotActive && AllBallsStopped();
            }

            if (_rules.PlaceMode || _rules.RewardChoiceOpen || _rules.Items.PendingRewardChoice)
                return false;

            return !_rules.GameOver && !_rules.ShotActive && AllBallsStopped();
        }

        bool AllBallsStopped() =>
            FindObjectsByType<BilliardBallMotor>(FindObjectsSortMode.None).All(b => !b.IsMoving);

        void EndShotIfNeeded()
        {
            if (_storyMode)
            {
                _story.EndShot();
                if (_story.MatchOver && StoryDialogueDatabase.TryGet(_story.ResultDialogue.Id, out var resultEntry))
                    _story.Dialogue.ShowMain(_story.ResultDialogue.Id, resultEntry.speaker, resultEntry.line, 8f);
                RefreshHud();
                return;
            }

            if (_rules.ShotActive)
                _rules.EndShot();
        }

        void RefreshHud()
        {
            if (_hud == null)
                return;
            if (_storyMode)
            {
                _hud.RefreshStory(_story);
                _shop?.Refresh(_story);
            }
            else
                _hud.RefreshEndless(Mode, _rules);
        }

        void ShowStoryLine(string fallbackSpeaker, string id)
        {
            if (_dialogue == null)
                return;
            if (StoryDialogueDatabase.TryGet(id, out var entry))
            {
                if (_storyMode && id.StartsWith("RESULT"))
                    _story.Dialogue.ShowMain(id, entry.speaker, entry.line, 8f);
                else
                    _story.Dialogue.ShowMain(id, entry.speaker, entry.line, 4f);
            }
        }
    }

    public static class SessionRequest
    {
        public static GameModeKind PendingMode = GameModeKind.Endless;
        public static bool StoryIntroMatch;
    }
}
