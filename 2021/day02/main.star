load("blob.star", "blob")

def sum(iterable, start = 0):
    for n in iterable:
        start += n
    return start

def ans():
    bkt = blob.open("file://")
    lines = str(bkt.read_all("input.txt")).splitlines()

    horizontal = 0
    depth = 0
    for line in lines:
        parts = line.split(" ")
        dir = parts[0]
        mov = int(parts[1])
        if dir == "forward":
            horizontal += mov
        if dir == "up":
            depth += mov * -1
        if dir == "down":
            depth += mov

    return horizontal * depth

def aim():
    bkt = blob.open("file://")
    input = str(bkt.read_all("input.txt"))
    lines = input.splitlines()

    horizontal = 0
    depth = 0
    aim = 0
    for line in lines:
        parts = line.split(" ")
        dir = parts[0]
        mov = int(parts[1])
        if dir == "forward":
            horizontal += mov
            depth += aim * mov
        if dir == "up":
            aim += mov * -1
        if dir == "down":
            aim += mov

    return horizontal * depth

print("part1", ans())
print("part2", aim())
