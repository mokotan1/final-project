import copy
import unittest
from compare_gm_unity_physics_trace import compare_traces


def trace():
    def ball(x):
        return dict(role="Foul", x=x, y=0, vx=0, vy=0, lock=0)
    return dict(direction=312, power=15, frames=[dict(step=0, balls=[ball(10), ball(20)])], outcome=dict(cushions=0, hit_target=False, foul=False, score=0))


class DuplicateRoleComparisonTests(unittest.TestCase):
    def test_first_foul_ball_movement_is_detected(self):
        gm = trace()
        unity = copy.deepcopy(gm)
        unity['frames'][0]['balls'][0]['x'] += 1
        self.assertTrue(compare_traces(gm, unity))

    def test_missing_first_foul_ball_is_detected(self):
        gm = trace()
        unity = copy.deepcopy(gm)
        unity['frames'][0]['balls'].pop(0)
        self.assertTrue(compare_traces(gm, unity))

    def test_identical_duplicate_roles_match(self):
        gm = trace()
        self.assertEqual([], compare_traces(gm, copy.deepcopy(gm)))


if __name__ == '__main__':
    unittest.main()
