load("blob.star", "blob")

bkt = blob.open("file://")

def sum(iterable, start = 0):
    for x in iterable:
        start += x
    return start

syntax = {
    "(": ")",
    "[": "]",
    "{": "}",
    "<": ">",
}
endings = {v: k for (k, v) in syntax.items()}

def syntax_check():
    lines = str(bkt.read_all("input.txt")).splitlines()

    points = {
        ")": 3,  # points.
        "]": 57,  # points.
        "}": 1197,  # points.
        ">": 25137,  # points.
    }

    illegals = {}  # count
    for line in lines:
        stack = []
        for char in line.elems():
            if char in endings:
                val = stack.pop()
                want = endings[char]
                if val != want:
                    #print("corrupt", line)
                    illegals[char] = illegals.get(char, 0) + 1

            else:
                stack.append(char)

    total = 0
    for (key, count) in illegals.items():
        total += (points[key] * count)
        print("total", key, points[key], count)
    return total

def syntax_fix():
    lines = str(bkt.read_all("input.txt")).splitlines()

    points = {
        ")": 1,  # points.
        "]": 2,  # points.
        "}": 3,  # points.
        ">": 4,  # points.
    }

    scores = []
    for line in lines:
        stack = []
        illegal = False
        for char in line.elems():
            if char in endings:
                val = stack.pop()
                want = endings[char]
                if val != want:
                    illegal = True

            else:
                stack.append(char)
        if illegal:
            continue

        total = 0
        for val in reversed(stack):
            total *= 5
            total += points[syntax[val]]
        scores.append(total)

    scores = sorted(scores)
    return scores[len(scores) // 2]

print("part1", syntax_check())
print("part2", syntax_fix())
