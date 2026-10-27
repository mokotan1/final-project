"""Pure-Python mirrors of story 50-round score helpers for regression checks."""

STORY_SCORE_MAX = 999_999_999
STORY_MAX_TURNS = 50


def story_score_add(current: int, points: int) -> int:
    cur = max(0, min(STORY_SCORE_MAX, int(current)))
    pts = max(0, min(STORY_SCORE_MAX, int(points)))
    if pts >= STORY_SCORE_MAX - cur:
        return STORY_SCORE_MAX
    return cur + pts


def story_risk_points_for_cushions(cushions: int) -> int:
    c = max(0, int(cushions))
    if c >= 7:
        return STORY_SCORE_MAX
    return 100 * (10 ** c)


def story_normal_points_for_cushions(cushions: int) -> int:
    c = max(0, int(cushions))
    if c <= 0:
        return 100
    remaining = STORY_SCORE_MAX
    points = 100
    for _ in range(c):
        if points >= remaining:
            return STORY_SCORE_MAX
        if points > remaining // 2:
            return STORY_SCORE_MAX
        points *= 2
    return min(points, STORY_SCORE_MAX)


def test_score_saturation() -> None:
    assert story_risk_points_for_cushions(0) == 100
    assert story_risk_points_for_cushions(1) == 1_000
    assert story_risk_points_for_cushions(2) == 10_000
    assert story_risk_points_for_cushions(6) == 100_000_000
    assert story_risk_points_for_cushions(7) == STORY_SCORE_MAX
    assert story_score_add(STORY_SCORE_MAX - 1, 1) == STORY_SCORE_MAX
    assert story_score_add(STORY_SCORE_MAX, 1) == STORY_SCORE_MAX
    assert story_score_add(STORY_SCORE_MAX - 1, 2) == STORY_SCORE_MAX


if __name__ == "__main__":
    test_score_saturation()
    print("story_fifty_round_logic: ok")
