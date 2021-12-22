load("blob.star", "blob")
load("math.star", "math")

bkt = blob.open("file://")

def run(input, steps = 2):
    lines = str(bkt.read_all(input)).splitlines()

    algo = [int(c == "#") for c in lines[0].elems()]

    img = []
    for line in lines[2:]:
        img.append([int(c == "#") for c in line.elems()])

    for i in range(steps):
        c = i & algo[0]
        h, w = len(img), len(img[0])
        pad_img = []
        for i in range(2):
            pad_img.append([c for _ in range(w + 4)])
        for row in img:
            pad_img.append([c, c] + row + [c, c])
        for i in range(2):
            pad_img.append([c for _ in range(w + 4)])
        img = pad_img

        first = None
        last = None

        new_img = []
        for y in range(1, len(img) - 1):
            new_row = []
            for x in range(1, len(img[0]) - 1):
                res = 0
                bits = img[y - 1][x - 1:x + 2]
                bits += img[y][x - 1:x + 2]
                bits += img[y + 1][x - 1:x + 2]
                for bit in bits:
                    res = (res << 1) | bit

                new_row.append(algo[res])
            new_img.append(new_row)

        img = new_img

    pprint(img)
    print("len(img) =", len(img), "x", len(img[0]))

    total = 0
    for row in img:
        for px in row:
            total += px
    print("count", total)

def pprint(img):
    print("")
    m = [".", "#"]
    for row in img:
        print("".join([m[x] for x in row]))

run("input.txt", steps = 50)
