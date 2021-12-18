load("blob.star", "blob")

bkt = blob.open("file://")

def chilton(steps = 10000, part2 = False):
    lines = str(bkt.read_all("input.txt")).splitlines()
    rows = []
    for line in lines:
        rows.append([int(x) for x in line.elems()])

    # START
    if part2:
        def wrap(x):
            return (x - 1) % 9 + 1

        large_grid = []
        for i in range(5):
            for row in rows:
                new_row = []
                for j in range(5):
                    new_row.extend([wrap(x + i + j) for x in row])
                large_grid.append(new_row)

        #print("large_grid")
        #for row in large_grid:
        #    print("".join([str(x) for x in row]))
        #print("----------")
        rows = large_grid

    def outofbounds(point):
        i, j = point
        return i < 0 or j < 0 or i >= len(rows) or j >= len(rows[0])

    def adjacent(point):
        i, j = point
        points = [
            (i + 1, j),
            (i - 1, j),
            (i, j + 1),
            (i, j - 1),
        ]
        return [point for point in points if not outofbounds(point)]

    def get(point):
        i, j = point
        return rows[i][j]

    start_point = (0, 0)
    end_point = (len(rows) - 1, len(rows[0]) - 1)
    been = {start_point: True}
    paths = [(start_point, 0)]  # current asdf
    for step in range(steps):
        #print("paths", paths)
        if step >= steps:
            fail("max steps reached")

        if len(paths) == 0:
            fail("failed to find end")

        current_point, current_value = paths.pop()
        if current_point == end_point:
            print("point", current_point, current_value)
            return current_value

        for point in adjacent(current_point):
            value = current_value + get(point)
            if point not in been:
                paths.append((point, value))
            been[point] = True

        paths = sorted(paths, lambda v: v[1], reverse = True)
    fail("not found")

print("part1", chilton())
print("part2", chilton(steps = 1000000, part2 = True))
