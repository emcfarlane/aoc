load("blob.star", "blob")

bkt = blob.open("file://")

def poly(steps = 10):
    lines = str(bkt.read_all("input.txt")).splitlines()

    template = lines[0]
    mappings = {}

    for line in lines[2:]:
        pair, value = line.split(" -> ")
        mappings[pair] = value

    pairs = {}  # "AB" -> 123
    for i in range(len(template) - 1):
        pair = template[i:i + 2]
        if pair not in pairs:
            pairs[pair] = 0
        pairs[pair] += 1

    #print("pairs", pairs)
    for step in range(steps):
        new = []  # (pair, count)
        for (pair, count) in pairs.items():
            if pair not in mappings:
                continue
            char = mappings[pair]
            pair1 = pair[0] + char
            pair2 = char + pair[1]

            new.append((pair, -count))
            new.append((pair1, count))
            new.append((pair2, count))

        for (pair, count) in new:
            if pair not in pairs:
                pairs[pair] = 0
            pairs[pair] += count

        #print("pairs", pairs)

    counts = {template[-1]: 1}  # Count last element
    for (pair, count) in pairs.items():
        #for char in pair.elems():
        char = pair[0]
        if char not in counts:
            counts[char] = 0
        counts[char] += count

    mce, lce = None, None

    #print("counts", counts)
    for (char, count) in counts.items():
        if mce == None:
            mce, lce = count, count
        lce = min(count, lce)
        mce = max(count, mce)

    print(mce, "-", lce, mce - lce)
    return mce - lce

print("part1", poly())
print("part2", poly(steps = 40))
