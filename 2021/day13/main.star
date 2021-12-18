load("blob.star", "blob")

bkt = blob.open("file://")

def origami(steps = 20):
    lines = str(bkt.read_all("input.txt")).splitlines()
    rows = []

    def hit(x, y):
        if y >= len(rows):
            for i in range(y + 1 - len(rows)):
                rows.append([])
        row = rows[y]
        if x >= len(row):
            for i in range(x + 1 - len(row)):
                row.append(0)
        row[x] = 1
        return row[x]

    def foldy(val, rows):
        for y in range(val, len(rows)):
            row = rows[y]
            new_y = val - (y - val)
            for x in range(len(row)):
                if row[x] == 1:
                    hit(x, new_y)
        if len(rows) > val:
            rows = rows[:val]
        return rows

    def foldx(val, rows):
        for y in range(len(rows)):
            row = rows[y]
            for x in range(val, len(row)):
                if row[x] == 1:
                    new_x = val - (x - val)
                    hit(new_x, y)
            if len(row) > val:
                row = row[:val]
                rows[y] = row
        return rows

    is_instructions = False
    instructions = []
    for line in lines:
        if len(line) == 0:
            is_instructions = True
            continue

        if is_instructions:
            axis, arg = line[len("fold along "):].split("=")
            instructions.append((axis, int(arg)))
        else:
            x, y = line.split(",")
            hit(int(x), int(y))

    #print("---")
    #for row in rows:
    #    print("".join([str(x) for x in row]))
    #print("---")

    for i in range(steps):
        if i >= len(instructions):
            break

        axis, val = instructions[i]
        if axis == "y":
            rows = foldy(val, rows)
        else:
            rows = foldx(val, rows)

    mapping = [" ", "#"]

    print("---")
    for row in rows:
        print("".join([mapping[x] for x in row]), len(row))
    print("---")

    def sum(rows, start = 0):
        for row in rows:
            for x in row:
                start += x
        return start

    return sum(rows)

print("part1", origami())
