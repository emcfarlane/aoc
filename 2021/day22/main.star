load("blob.star", "blob")
load("math.star", "math")

bkt = blob.open("file://")

def intersects(r1, r2):
    (s1, e1) = r1
    (s2, e2) = r2
    return s1 <= e2 and e1 >= s2

def intersects3D(r1, r2):
    (x1, y1, z1) = r1
    (x2, y2, z2) = r2
    return intersects(x1, x2) and intersects(y1, y2) and intersects(z1, z2)

def sub(r1, r2):
    (s1, e1) = r1
    (s2, e2) = r2
    endpoints = sorted((s1, s2, e1, e2))
    result = []
    if endpoints[0] == s1 and endpoints[1] != s1:
        result.append((endpoints[0], endpoints[1] - 1))
    if endpoints[3] == e1 and endpoints[2] != e1:
        result.append((endpoints[2] + 1, endpoints[3]))

    #print("\tsub", r1, "-", r2, result, endpoints)
    return result

def sub3D(r1, r2):
    #print("sub3D", r1, "-", r2)
    (x1, y1, z1) = r1
    (x2, y2, z2) = r2
    results = []
    xs = sub(x1, x2)
    ys = sub(y1, y2)
    zs = sub(z1, z2)
    #print("xs:", xs)
    #print("ys:", ys)
    #print("zs:", zs)

    xsub = x1
    for x in xs:
        results.append((x, y1, z1))
        xsub = sub(xsub, x)[0]

    ysub = y1
    for y in ys:
        results.append((xsub, y, z1))
        ysub = sub(ysub, y)[0]

    for z in zs:
        results.append((xsub, ysub, z))

    #print("\tresult:", results)
    return results

def area(r):
    (xs, xe), (ys, ye), (zs, ze) = r
    return (xe - xs + 1) * (ye - ys + 1) * (ze - zs + 1)

# Reactor Reboot
def run(input, size = 100, steps = 1000):
    lines = str(bkt.read_all(input)).splitlines()

    ins = []
    for line in lines:
        (cmd, volume) = line.split(" ")  # TODO: regex...
        region = []
        for part in volume.split(","):
            (a, b) = part[2:].split("..")
            if int(a) > int(b):
                fail("order", a, b)

            #parts.append((
            #    max(int(a) + size // 2, 0),
            #    min(int(b) + size // 2 + 1, size),
            #))
            region.append((int(a), int(b)))
        ins.append((int(cmd == "on"), tuple(region)))

    regions = []
    for (cmd, r1) in ins:
        print(cmd, r1)

        new_region = []
        if cmd == 0:  # off
            for r2 in regions:
                if intersects3D(r1, r2):
                    rsplit = sub3D(r2, r1)
                    new_region.extend(rsplit)
                else:
                    new_region.append(r2)

        else:  # on
            rs = [r1]
            for r2 in regions:
                new_rs = []
                for r in rs:
                    if intersects3D(r, r2):
                        rsplit = sub3D(r, r2)
                        new_rs.extend(rsplit)
                    else:
                        new_rs.append(r)
                rs = new_rs
            new_region = regions + rs

        before = len(regions)
        regions = new_region

    total = 0
    for r in regions:
        total += area(r)
    print("total", total)

    #cuboid = []
    #for i in range(size):
    #    row = []
    #    for j in range(size):
    #        row.append([0 for _ in range(size)])
    #    cuboid.append(row)
    #for (cmd, ((x1, x2), (y1, y2), (z1, z2))) in ins:
    #    print(cmd, ((x1, x2), (y1, y2), (z1, z2)))
    #    for i in range(x1, x2):
    #        for j in range(y1, y2):
    #            for k in range(z1, z2):
    #                cuboid[i][j][k] = cmd
    #total = 0
    #for i in range(len(cuboid)):
    #    for j in range(len(cuboid[0])):
    #        for k in range(len(cuboid[0][0])):
    #            total += cuboid[i][j][k]
    #print("total", total)

def main():
    run("input.txt")

main()  # TODO: run main func as entrypoint
