load("blob.star", "blob")
load("math.star", "math")

bkt = blob.open("file://")

def distance(p1, p2):
    (x1, y1, z1), (x2, y2, z2) = p1, p2
    return "%f" % (math.sqrt(
        math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) + math.pow(z2 - z1, 2),
    ))

def taxicab_distance(p1, p2):
    (x1, y1, z1), (x2, y2, z2) = p1, p2
    return math.abs(x2 - x1) + math.abs(y2 - y1) + math.abs(z2 - z1)

def close_enough(dset1, dset2, matching = -1):
    if matching < 0:
        matching = min(len(dset1), len(dset2))
    return len(dset1 & dset2) >= matching

def run(input, steps = 1000):
    lines = str(bkt.read_all(input)).splitlines()

    prefix = "--- scanner "
    suffix = " ---"

    scanners = {}
    scanner = None
    for line in lines:
        if line.startswith(prefix):
            val = line[len(prefix):-len(suffix)]
            scanner = int("" + line[len(prefix):-len(suffix)])
            continue
        if scanner == None or len(line) == 0:
            continue
        if scanner not in scanners:
            scanners[scanner] = []

        x, y, z = line.split(",")
        scanners[scanner].append((int(x), int(y), int(z)))

    #print(scanners)

    pointsets = {}  # scanner -> point -> set of point distances
    for (scanner, points) in scanners.items():
        for i in range(len(points)):
            p1 = points[i]
            distances = []
            for j in range(len(points)):
                if i == j:
                    continue
                p2 = points[j]
                distances.append(distance(p1, p2))

            if scanner not in pointsets:
                pointsets[scanner] = {}
            val = set(distances)
            pointsets[scanner][p1] = val

    mappings = {}  # (scanner, point): [(scanner, point),...]
    for (scanner1, dsets1) in pointsets.items():
        pointmatches = {}
        for (p1, dset1) in dsets1.items():
            matches = []
            for (scanner2, dsets2) in pointsets.items():
                if scanner2 == scanner1:
                    continue

                for (p2, dset2) in dsets2.items():
                    #if scanner == 4:
                    #    print(p1, "&", p2, "=", dset1 & dset2)

                    if close_enough(dset1, dset2, 2):
                        #mappings[scanner2][p2] = (scanner1, p1)
                        #total -= 1
                        matches.append((scanner2, p2))

            #mappings[(scanner1, p1)] = matches
            pointmatches[p1] = matches
        mappings[scanner1] = pointmatches

    total = 0
    seen = {}
    for (s1, pointmatches) in mappings.items():
        print("-- scanner", s1, "---")
        for (p1, pairs) in pointmatches.items():
            print(" ", p1, "->", pairs)
            if p1 not in seen:
                total += 1
            seen[p1] = True
            for (_, p2) in pairs:
                seen[p2] = True
        print("")
    print("total", total)

    # Resolve all points
    ## TODO: math.

run("test.txt")

# 486 > ans
