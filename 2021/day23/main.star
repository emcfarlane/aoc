load("blob.star", "blob")
load("math.star", "math")

bkt = blob.open("file://")

amphipods = {
    "A": 1,
    "B": 10,
    "C": 100,
    "D": 1000,
}

# Amphipod
def run(input, depth = 4):
    lines = str(bkt.read_all(input)).splitlines()

    # ..x.x.x.x..
    #   . . . .
    #   . . . .
    #   . . . .
    #   . . . .

    hall = [None for _ in range(11)]
    base = [lines[j][i] for i in range(3, 11, 2) for j in range(2, 2 + depth)]
    want = [c for c in ["A", "B", "C", "D"] for i in range(depth)]

    entrances = set([x for x in range(2, 10, 2)])

    def is_win(base):
        return base == want

    def valid_hall_idxs(hall, idx):
        pos = []
        past_current = False
        for i in range(len(hall)):
            past_current = past_current or i == idx
            if i in entrances:
                continue

            a = hall[i]
            if a == None:
                pos.append(i)
            else:
                if past_current:
                    break
                pos.clear()
        return pos

    def is_hall_clear(hall, start, end):
        dir = 1 if end > start else -1
        start += dir  # move off start

        for i in range(start, end, dir):
            if hall[i] != None:
                return False
        return True

    def abs(v):
        if v < 0:
            return -1 * v
        return v

    def gen(hall, base):
        states = []

        hall_idxs = {}
        for i in range(len(hall)):
            a = hall[i]
            if a == None:
                continue
            if a not in hall_idxs:
                hall_idxs[a] = [i]
            else:
                hall_idxs[a].append(i)

        for i in range(4):
            part = base[i * depth:i * depth + depth]

            for j in range(len(part)):
                l = i * depth + j
                a = base[l]
                c = want[l]
                idx = i * 2 + 2

                must_move = False
                for b in part[j + 1:]:
                    must_move = must_move or b != c

                if a == c and not must_move:
                    continue  # all set

                if a != None and (must_move or a != c):
                    # Move from base to hall
                    idxs = valid_hall_idxs(hall, idx)
                    for k in idxs:
                        states.append((
                            hall[:k] + [a] + hall[k + 1:],
                            base[:l] + [None] + base[l + 1:],
                            (1 + j + abs(idx - k)) * amphipods[a],
                        ))

                if a == None and (not must_move) and c in hall_idxs:
                    # Move from hall to base
                    for k in hall_idxs[c]:
                        if not is_hall_clear(hall, k, idx):
                            continue

                        states.append((
                            hall[:k] + [None] + hall[k + 1:],
                            base[:l] + [c] + base[l + 1:],
                            (1 + j + abs(idx - k)) * amphipods[c],
                        ))

                if a != None:
                    break

        return states

    seen = {}

    def search(hall, base):  # -> cost
        #print("search", hall, base)
        key = (tuple(hall), tuple(base))
        if key in seen:
            return seen[key]
        if is_win(base):
            return 0

        min_cost = None
        new_states = sorted(gen(hall, base), lambda state: state[2])

        for (hall, base, cost) in new_states:
            new_cost = search(hall, base)
            if new_cost == None:
                continue
            new_cost += cost
            if min_cost == None or new_cost < min_cost:
                min_cost = new_cost

        seen[key] = min_cost
        return min_cost

    min_cost = search(hall, base)
    print("min_cost", min_cost)

def main():
    run("input.txt", depth = 4)
