load("blob.star", "blob")

bkt = blob.open("file://")

def sum(iterable, start = 0):
    for x in iterable:
        start += x
    return start

def clock():
    lines = str(bkt.read_all("input.txt")).splitlines()
    # 0 - 6 has 1, 7, no middle
    # 1 - 2
    # 2 - 5 has !1
    # 3 - 5 has 1, 7
    # 4 - 4
    # 5 - 5 has !1
    # 6 - 6 has !1
    # 7 - 3
    # 8 - 7
    # 9 - 6 has 1, 3, 7

    unique = 0

    for line in lines:
        values = line.split(" | ")[1].split()
        for v in values:
            if len(v) != 5 and len(v) != 6:
                unique += 1
    return unique

def strset(a):
    return "".join(sorted(a.elems()))

def strhas(s, subset):
    s = set(s.elems())
    for char in subset.elems():
        if char not in s:
            return False
    return True

def strsub(s, sub):
    subset = set(sub.elems())
    return "".join([x for x in s.elems() if x not in subset])

def clock2():
    lines = str(bkt.read_all("input.txt")).splitlines()

    values = []
    for line in lines:
        parts = line.split(" | ")
        given = sorted([strset(x) for x in parts[0].split()], key = len)
        wants = [strset(x) for x in parts[1].split()]
        #print("given", given)
        #print("wants", wants)

        fives = []
        sixes = []
        have = {}
        for val in given:
            l = len(val)
            if l == 2:
                have["1"] = val
            elif l == 3:
                have["7"] = val
            elif l == 4:
                have["4"] = val
            elif l == 7:
                have["8"] = val  # useless?
            elif l == 5:
                fives.append(val)
            elif l == 6:
                sixes.append(val)
            else:
                fail()

        # find 3
        parts = have["7"]
        for val in fives:
            if strhas(val, parts):
                have["3"] = val

        # find 9
        parts = have["3"]
        for val in sixes:
            if strhas(val, parts):
                have["9"] = val

        # find 5
        parts = strsub(have["4"], have["1"])
        for val in fives:
            if strhas(val, parts):
                have["5"] = val

        # find 0
        parts = have["7"]
        nine = have["9"]
        for val in sixes:
            if val != nine and strhas(val, parts):
                have["0"] = val

        # find 2
        parts = strsub(have["0"], have["4"])
        five = have["5"]
        for val in fives:
            if val != five and strhas(val, parts):
                have["2"] = val

        # find 6
        for val in sixes:
            if val not in set([have["9"], have["0"]]):
                have["6"] = val

        #print("have", have)
        #print("wants", wants)

        lookup = {v: k for (k, v) in have.items()}
        value = "".join([lookup[x] for x in wants])
        print("value", value)
        values.append(int(value))

    return sum(values)

print("part1", clock())
print("part2", clock2())
