load("blob.star", "blob")

def sum(iterable, start = 0):
    for n in iterable:
        start += n
    return start

def count(window_size = 1):
    bkt = blob.open("file://")
    input = str(bkt.read_all("input.txt"))

    i = 0
    inc = 0
    previous = 0
    window = [0 for _ in range(window_size)]
    for line in input.splitlines():
        window[i % window_size] = int(line)
        current = 0
        if i >= 3:
            current = sum(window)
            if current > previous:
                inc += 1

        previous = current
        i += 1

    return inc

print("part1", count())
print("part2", count(3))
