load("blob.star", "blob")

bkt = blob.open("file://")

def linear(n):
    return n

def triangular(n):
    return n * (n + 1) // 2

def sum(iterable, start = 0):
    for x in iterable:
        start += x
    return x

def crabs(cost = linear):
    data = str(bkt.read_all("input.txt")).strip()
    nums = [int(x) for x in data.split(",")]
    nums = sorted(nums)

    #mean = int(sum(nums) / len(nums) + 0.5)
    #print("mean", mean, "->", sum(nums) / len(nums))
    #length = len(nums)
    #mid = length // 2
    #if length % 2 == 0:
    #    median = (nums[mid - 1] + nums[mid]) // 2
    #else:
    #    median = nums[mid]

    distances = [x for x in range(min(nums), max(nums))]
    fuels = [0 for x in range(len(distances))]
    for num in nums:
        for i in range(len(fuels)):
            fuels[i] += cost(abs(num - distances[i]))

    #print(fuels)
    return min(fuels)

print("part1", crabs())
print("part2", crabs(cost = triangular))
