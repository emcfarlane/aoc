load("blob.star", "blob")
load("math.star", "math")

bkt = blob.open("file://")

# Dirac Die
def run(input, max_score = 21, steps = 100000):
    lines = str(bkt.read_all(input)).splitlines()

    p1 = int(lines[0].split(": ")[1]) - 1
    p2 = int(lines[1].split(": ")[1]) - 1

    rolls = []
    for i in range(3):
        for j in range(3):
            for k in range(3):
                rolls.append((i + 1, j + 1, k + 1))

    cache = {}  # (p1, p2, s1, s2) -> (s1, s2)
    stack = [[(p1, p2, 0, 0)]]

    for step in range(steps):
        #print("stack", stack)
        if step >= steps - 1:
            fail("max step", step)
        if len(stack) == 0:
            break

        frame = stack[-1]
        if len(frame) == 0:
            stack.pop()
            continue

        key = frame[-1]
        (p1, p2, s1, s2) = key
        if s2 >= max_score:
            cache[key] = (0, 1)
            frame.pop()
            continue

        okay = True
        totals1, totals2 = 0, 0
        for (r1, r2, r3) in rolls:
            new_p = (p1 + r1 + r2 + r3) % 10
            new_s = s1 + new_p + 1
            subkey = (p2, new_p, s2, new_s)
            if subkey in cache:
                (wins2, wins1) = cache[subkey]  # switch turns
                totals1 += wins1
                totals2 += wins2
            else:
                frame.append(subkey)
                okay = False
                break

        if not okay:
            continue

        # Made it through rolls
        cache[key] = (totals1, totals2)
        frame.pop()

    print("cache", cache[(p1, p2, 0, 0)], len(cache))

def simple(input, max_score = 1000, steps = 1000):
    lines = str(bkt.read_all(input)).splitlines()

    positions = [
        int(lines[0].split(": ")[1]) - 1,
        int(lines[1].split(": ")[1]) - 1,
    ]
    scores = [0, 0]

    def ddice(turn):
        return (turn % 100) + 1

    roll = 0
    turn = 0
    for step in range(steps):
        if step >= steps - 1:
            fail("max step", step)

        for i in range(2):
            val = 0
            for d in range(1, 4):
                val += (roll % 100) + 1
                roll += 1

            positions[i] += val
            scores[i] += (positions[i] % 10) + 1
            if scores[i] >= max_score:
                break
        if max(scores) >= max_score:
            break

    print("ans", roll * min(scores))

run("input.txt")
