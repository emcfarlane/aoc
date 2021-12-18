load("blob.star", "blob")

bkt = blob.open("file://")

def caves_search(max_steps = 1000000, part2 = False):
    lines = str(bkt.read_all("input.txt")).splitlines()

    routes = {}  # A -> set(B,...)

    def add_route(a, b):
        if a in routes:
            l = routes[a]
            if b not in l:
                l.append(b)
        else:
            routes[a] = [b]

    for line in lines:
        a, b = line.split("-")
        add_route(a, b)
        add_route(b, a)

    ends = []
    paths = [["start"]]
    for steps in range(max_steps):
        if steps >= max_steps - 1:
            fail("max steps")

        if len(paths) == 0:
            break

        path = paths.pop()
        a = path[-1]
        for b in routes[a]:
            if b.islower() and b in path:
                if not part2 or b == "start":
                    continue
                lowers = [x for x in path if x.islower()]
                if len(set(lowers)) < len(lowers):
                    continue

            newpath = path + [b]
            if b == "end":
                ends.append(newpath)
            else:
                paths.append(newpath)

    #for end in ends:
    #    print(",".join(end))
    return ends

print("part1", len(caves_search()))
print("part2", len(caves_search(part2 = True)))
