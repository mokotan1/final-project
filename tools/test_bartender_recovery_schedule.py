"""Schedule rules for bartender recovery risk (mirrors GML guards)."""
from __future__ import annotations

STORY_AI_RISK_LEAD = 100_000
STORY_MAX_TURNS = 50


def try_schedule(
    *,
    fifty_round: bool,
    break_pending: bool,
    recovery_used: bool,
    due_pair: int,
    player_score: int,
    player_score_before: int,
    ai_score: int,
    current_round: int,
    rng_offset: int,
) -> int:
    if not fifty_round or break_pending:
        return due_pair
    if recovery_used or due_pair >= 0:
        return due_pair
    if player_score >= player_score_before:
        return due_pair
    if ai_score - player_score < STORY_AI_RISK_LEAD:
        return due_pair
    return min(STORY_MAX_TURNS, current_round + rng_offset)


def test_no_schedule_without_player_loss() -> None:
    due = try_schedule(
        fifty_round=True,
        break_pending=False,
        recovery_used=False,
        due_pair=-1,
        player_score=120_000,
        player_score_before=120_000,
        ai_score=230_000,
        current_round=16,
        rng_offset=3,
    )
    assert due == -1


def test_schedule_after_loss_with_lead() -> None:
    due = try_schedule(
        fifty_round=True,
        break_pending=False,
        recovery_used=False,
        due_pair=-1,
        player_score=0,
        player_score_before=45_000,
        ai_score=160_000,
        current_round=16,
        rng_offset=4,
    )
    assert due == 20


def test_once_per_match() -> None:
    due = try_schedule(
        fifty_round=True,
        break_pending=False,
        recovery_used=True,
        due_pair=-1,
        player_score=0,
        player_score_before=40_000,
        ai_score=150_000,
        current_round=16,
        rng_offset=2,
    )
    assert due == -1


def test_window_clamped_at_match_end() -> None:
    due = try_schedule(
        fifty_round=True,
        break_pending=False,
        recovery_used=False,
        due_pair=-1,
        player_score=0,
        player_score_before=10_000,
        ai_score=200_000,
        current_round=48,
        rng_offset=9,
    )
    assert due == 50


if __name__ == "__main__":
    test_no_schedule_without_player_loss()
    test_schedule_after_loss_with_lead()
    test_once_per_match()
    test_window_clamped_at_match_end()
    print("test_bartender_recovery_schedule: ok")
