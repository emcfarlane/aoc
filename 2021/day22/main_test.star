load("main.star", "sub3D")

def test_sub3D(t):
    p1 = ((1, 3), (1, 3), (1, 3))  # cube
    p2 = ((2, 4), (2, 4), (2, 4))  # small cube
    want = [
        ((1, 1), (1, 3), (1, 3)),
        ((2, 3), (1, 1), (1, 3)),
        ((2, 3), (2, 3), (1, 1)),
    ]
    got = sub3D(p1, p2)
    if got != want:
        fail("want\n", want, "\ngot\n", got)

    p2 = ((2, 2), (2, 2), (2, 2))
    want = [
        ((1, 1), (1, 3), (1, 3)),
        ((3, 3), (1, 3), (1, 3)),
        ((2, 2), (1, 1), (1, 3)),
        ((2, 2), (3, 3), (1, 3)),
        ((2, 2), (2, 2), (1, 1)),
        ((2, 2), (2, 2), (3, 3)),
    ]
    got = sub3D(p1, p2)
    if got != want:
        fail("want\n", want, "\ngot\n", got)

    # subtract all
    p2 = ((1, 3), (1, 3), (1, 3))
    want = []
    got = sub3D(p1, p2)
    if got != want:
        fail("want\n", want, "\ngot\n", got)

    # z-index
    p2 = ((1, 3), (1, 3), (1, 1))
    want = [
        ((1, 3), (1, 3), (2, 3)),
    ]
    got = sub3D(p1, p2)
    if got != want:
        fail("want\n", want, "\ngot\n", got)

    p1 = ((23, 74), (22, 77), (29, 80))
    p2 = ((28, 58), (27, 78), (27, 50))
    got = sub3D(p1, p2)
    want = [
        ((23, 27), (22, 77), (29, 80)),
        ((59, 74), (22, 77), (29, 80)),
        ((28, 58), (22, 26), (29, 80)),
        ((28, 58), (27, 77), (51, 80)),
    ]
    if got != want:
        fail("want\n", want, "\ngot\n", got)

    p1 = ((-3, -1), (-1, 2), (-3, -1))
    p2 = ((-1, -1), (-2, 1), (-2, 1))
    got = sub3D(p1, p2)

    want = [
        ((-3, -2), (-1, 2), (-3, -1)),
        ((-1, -1), (2, 2), (-3, -1)),
        ((-1, -1), (-1, 1), (-3, -3)),
    ]

    if got != want:
        fail("want\n", want, "\ngot\n", got)
