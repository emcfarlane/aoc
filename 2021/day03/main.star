load("blob.star", "blob")

def ans():
    bkt = blob.open("file://")
    lines = str(bkt.read_all("input.txt")).splitlines()

    n = len(lines)
    size = len(lines[0])
    run = [0 for _ in range(size)]
    for line in lines:
        for i in range(size):
            if line[i] == "1":
                run[i] += 1
            else:
                run[i] -= 1

    gamma = ""
    epsilon = ""
    for x in run:
        if x > 0:
            gamma += "1"
            epsilon += "0"
        else:
            gamma += "0"
            epsilon += "1"

    gamma_rate = int(gamma, 2)
    epsilon_rate = int(epsilon, 2)
    return gamma_rate * epsilon_rate

print("part1", ans())
