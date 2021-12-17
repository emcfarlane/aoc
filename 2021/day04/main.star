load("blob.star", "blob")

def bingo():
    bkt = blob.open("file://")
    lines = str(bkt.read_all("input.txt")).splitlines()

    numbers = [int(x) for x in lines[0].split(",")]
    print(numbers)

    boards = []  # [[[0,...],...]]

    lookup = {}  # num -> [(board, row, pos),...]

    size = 5
    n = (len(lines) - 1) // (size + 1)
    for i in range(n):
        rows = []
        for j in range(size):
            line = lines[i * 6 + 2 + j]
            nums = [int(x) for x in line.split()]
            rows.append(nums)
            for k in range(size):
                v = nums[k]
                val = (i, j, k)
                if v in lookup:
                    lookup[v].append(val)
                else:
                    lookup[v] = [val]
        boards.append(rows)

    def sum(row, start = 0):
        for x in row:
            start += x
        return start

    def sum_col(rows, col, start = 0):
        for row in rows:
            start += row[col]
        return start

    def sum_board(rows, start = 0):
        for row in rows:
            start += sum(row)
        return start

    cache = []
    for board in boards:
        cache.append([[0 for _ in range(5)], [0 for _ in range(5)], 0])

    winners = []
    has_won = {}
    for v in numbers:
        print("search", v, lookup[v])
        for val in lookup[v]:
            i, j, k = val[0], val[1], val[2]
            rows = boards[i]
            c = cache[i]
            c[0][j] += 1
            c[1][k] += 1
            c[2] -= v

            if (c[0][j] >= size or c[1][k] >= size) and i not in has_won:
                print("got board", val, c, sum_board(rows), v)

                #return (sum_board(rows) + cache[i][2]) * v
                total = (sum_board(rows) + cache[i][2]) * v
                winners.append(total)
                has_won[i] = True
        print("------")

    return winners

winners = bingo()
print("part1", winners[0])
print("winners", winners)
print("part2", winners[len(winners) - 1])
