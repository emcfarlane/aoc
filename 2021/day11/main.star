load("blob.star", "blob")

bkt = blob.open("file://")

def octopus(steps = 100):
    lines = str(bkt.read_all("input.txt")).splitlines()
    rows = []
    for line in lines:
        rows.append([int(x) for x in line.elems()])

    def outofbounds(point):
        i, j = point
        return i < 0 or j < 0 or i >= len(rows) or j >= len(rows[0])

    def inc(point):
        i, j = point
        rows[i][j] += 1
        return rows[i][j]

    def get(point):
        i, j = point
        return rows[i][j]

    def adjacent(point):
        i, j = point
        points = [
            (i + 1, j),
            (i - 1, j),
            (i, j + 1),
            (i, j - 1),
            (i + 1, j + 1),
            (i - 1, j + 1),
            (i + 1, j - 1),
            (i - 1, j - 1),
        ]
        return [point for point in points if not outofbounds(point)]

    flashes = 0
    for step in range(steps):
        flashes_step = 0
        for i in range(len(rows)):
            for j in range(len(rows[0])):
                points = [(i, j)]
                for tick in range(1000):
                    if tick >= 999:
                        fail("max ticks")

                    if len(points) == 0:
                        break

                    point = points.pop()
                    if inc(point) == 10:
                        flashes_step += 1
                        points.extend(adjacent(point))

        flashes += flashes_step
        if flashes_step == 100:
            print("sync step", step, flashes_step)
            return step

        for i in range(len(rows)):
            for j in range(len(rows[0])):
                if rows[i][j] >= 10:
                    rows[i][j] = 0
    return flashes

print("octopus", octopus())
print("octopus", octopus(steps = 500) + 1)
