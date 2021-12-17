load("blob.star", "blob")

def hydrothermal():
    bkt = blob.open("file://")
    lines = str(bkt.read_all("input.txt")).splitlines()

    rows = []

    def hit(x, y):
        if x >= len(rows):
            for i in range(x + 1 - len(rows)):
                rows.append([])
        row = rows[x]
        if y >= len(row):
            for i in range(y + 1 - len(row)):
                row.append(0)
        row[y] += 1
        return row[y]

    def stride(a, b):
        stride = 1
        if a > b:
            stride = -1
        return [x for x in range(a, b + stride, stride)]

    count = 0
    for line in lines:
        parts = line.split(" -> ")
        start = parts[0].split(",")
        end = parts[1].split(",")
        x1, y1 = int(start[0]), int(start[1])
        x2, y2 = int(end[0]), int(end[1])

        if x1 == x2:
            for y in range(min(y1, y2), max(y1, y2) + 1):
                if hit(x1, y) == 2:
                    count += 1
        elif y1 == y2:
            for x in range(min(x1, x2), max(x1, x2) + 1):
                if hit(x, y1) == 2:
                    count += 1
        else:
            xs = stride(x1, x2)
            ys = stride(y1, y2)
            for i in range(len(xs)):
                if hit(xs[i], ys[i]) == 2:
                    count += 1

    return count

print("part2", hydrothermal())  # Part1: 6666
