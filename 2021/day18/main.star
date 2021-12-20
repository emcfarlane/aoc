load("blob.star", "blob")
load("math.star", "math")

bkt = blob.open("file://")

# 3*left + 2*right
def magnitude(row, steps = 1000):
    for step in range(steps):
        if step >= steps - 1:
            fail("max steps")

        n = len(row)
        for i in range(0, n - 1):
            l, r = row[i], row[i + 1]
            (vl, dl), (vr, dr) = l, r
            if dl == dr:
                l = (3 * vl + 2 * vr, dl - 1)
                row = row[:i] + [l] + row[i + 2:]
                break

        if len(row) == 1:
            break
    return row[0][0]

def parse_row(line):
    depth = 0
    row = []
    for e in line.elems():
        if e == "[":
            depth += 1
        elif e == "]":
            depth -= 1
        elif e == ",":
            pass
        else:
            value = int(e)
            row.append((value, depth))
    return row

def test_magnitude():
    tests = [
        ("[[1,2],[[3,4],5]]", 143),
        ("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", 1384),
        ("[[[[1,1],[2,2]],[3,3]],[4,4]]", 445),
        ("[[[[3,0],[5,3]],[4,4]],[5,5]]", 791),
        ("[[[[5,0],[7,4]],[5,5]],[6,6]]", 1137),
        ("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]", 3488),
        ("[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]", 4140),
    ]

    for test in tests:
        line, want = test
        row = parse_row(line)
        got = magnitude(row)
        if want != got:
            fail("want", want, "got", got)

#test_magnitude()

def reduce(row, steps = 1000):
    for step in range(steps):
        #print("-------")
        #print("row", row)
        if step >= steps - 1:
            fail("max step reached")

        n = len(row)
        for i in range(n):
            (v, d) = row[i]
            if d == 5:
                (v2, d2) = row[i + 1]
                #print("    exploding", i, [v, v2])

                l = i - 1
                if l >= 0:
                    (vl, dl) = row[l]
                    row[l] = (vl + v, dl)
                r = i + 2
                if r < n:
                    (vr, dr) = row[r]
                    row[r] = (vr + v2, dr)

                row = row[:i] + [(0, d - 1)] + row[i + 2:]  # pop pair
                break

        if n != len(row):
            continue

        for i in range(n):
            (v, d) = row[i]
            if v > 9:  # split
                split = v / 2
                v1, v2 = int(split), int(split + 0.5)

                #print("    splitting", i, (v, d), "->", v1, v2, "@", d + 1)
                row = row[:i] + [(v1, d + 1), (v2, d + 1)] + row[i + 1:]
                break
        if n == len(row):
            break
    return row

def test_reduce():
    tests = [
        ## (the 9 has no regular number to its left, so it is not added to any regular number).
        #("[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"),
        ## (the 2 has no regular number to its right, and so it is not added to any regular number).
        #("[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"),
        #("[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"),
        ## (the pair [3,2] is unaffected because the pair [7,3] is further to the left; [3,2] would explode on the next action).
        #("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"),
        #("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"),
        ("[[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]],[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]]", "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]"),
    ]

    for test in tests:
        t1, t2 = test
        r1, r2 = reduce(parse_row(t1)), reduce(parse_row(t2))
        if r1 != r2:
            fail("want\n", r2, "got\n", r1)

test_reduce()

def add(x, y, steps = 1000):
    return reduce(
        [(value, depth + 1) for (value, depth) in x + y],
        steps,
    )

def run(input, steps = 1000):
    lines = str(bkt.read_all(input)).splitlines()

    rows = []
    for line in lines:
        row = reduce(parse_row(line))
        rows.append(row)
        print("row", row)

    total = rows[0]
    for row in rows[1:]:
        total = add(total, row, steps)
        print("->", total)

    print("total", total, len(total))
    print("magnitude", magnitude(total, steps))

    # largest
    max_mag = 0
    for i in range(len(rows)):
        for j in range(len(rows)):
            if i == j:
                continue
            part = add(rows[i], rows[j])
            max_mag = max(max_mag, magnitude(part, steps))
    print("max magnitude", max_mag)

run("input.txt")
