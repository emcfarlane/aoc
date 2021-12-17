load("blob.star", "blob")

def lanternfish(days = 80):
    bkt = blob.open("file://")
    data = str(bkt.read_all("input.txt")).strip()
    lives = [int(x) for x in data.split(",")]

    pool = [0 for _ in range(9)]
    for life in lives:
        pool[life] += 1

    for day in range(days):
        count = pool.pop(0)
        pool.append(count)
        pool[6] += count

    def sum(iterable, start = 0):
        for x in iterable:
            start += x
        return start

    return sum(pool)

print("part1", lanternfish())
print("part2", lanternfish(days = 256))
