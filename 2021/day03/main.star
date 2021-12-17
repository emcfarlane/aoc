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

def part2():
    bkt = blob.open("file://")
    lines = str(bkt.read_all("input.txt")).splitlines()

    n = len(lines)
    size = len(lines[0])

    def mc(zeros, ones):
        return ones >= zeros

    def lc(zeros, ones):
        return ones < zeros

    def apply(lines, filter):
        word = ""
        for i in range(size):
            if len(lines) == 1:
                word += lines[0][i:]
                break

            split = [[], []]  # "0", "1"
            for line in lines:
                split[int(line[i], 2)].append(line)

            if filter(len(split[0]), len(split[1])):
                word += "1"
                lines = split[1]
            else:
                word += "0"
                lines = split[0]

        return word

    oxygen = apply(lines, mc)
    cardon_dioxide = apply(lines, lc)

    oxygen_rate = int(oxygen, 2)
    cardon_dioxide_rate = int(cardon_dioxide, 2)
    print("oxygen", oxygen, oxygen_rate)
    print("carbon", cardon_dioxide, cardon_dioxide_rate)
    return oxygen_rate * cardon_dioxide_rate

print("part1", ans())
print("part2", part2())
