load("blob.star", "blob")

bkt = blob.open("file://")

def sum(iterable, start = 0):
    for x in iterable:
        start += x
    return start

def load_rows():
    lines = str(bkt.read_all("input.txt")).splitlines()
    rows = []
    for line in lines:
        rows.append([int(x) for x in line.elems()])
    return rows

rows = load_rows()

def get(point):
    i, j = point
    if i < 0 or j < 0 or i >= len(rows) or j >= len(rows[0]):
        return None
    return rows[i][j]

def low_points():
    def check(point1, point2):
        adjacent = get(point2)
        if adjacent == None:
            return True
        current = get(point1)
        return current < adjacent

    def is_low_point(point1):
        i, j = point1
        for point2 in [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]:
            if not check(point1, point2):
                return False
        return True

    points = []
    for i in range(len(rows)):
        for j in range(len(rows[0])):
            if is_low_point((i, j)):
                points.append((i, j))
    return points

def adjacent(point):
    i, j = point
    return [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]

def smoke_basin():
    cache = {}  # (x, y)
    points = low_points()

    def flows_down(point):
        val = get(point)
        if val == 9 or val == None:
            return False
        return True

    groups = []
    for point in points:
        if point in cache:
            continue
        cache[point] = True

        # search, must be finite
        group = [point]
        points = adjacent(point)
        for i in range(1000):
            if i == 999:
                fail("max steps reached")

            if len(points) == 0:
                break

            point = points.pop()
            if point in cache:
                continue

            cache[point] = True
            if flows_down(point):
                group.append(point)
                points.extend(adjacent(point))

        groups.append(group)

    groups = sorted(groups, key = len)
    return groups

print("part1", sum([get(point) + 1 for point in low_points()]))

groups = smoke_basin()

def calc(groups):
    if len(groups) > 3:
        groups = groups[-3:]
    print("groups", [len(group) for group in groups])
    total = 1
    for group in groups:
        total = total * len(group)
    return total

print("part2", calc(groups))
