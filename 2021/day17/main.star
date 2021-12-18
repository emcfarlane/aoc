load("blob.star", "blob")
load("math.star", "math")

bkt = blob.open("file://")

# Goes up and down to same point then moves in one step from zero to min.
# triangular number
def triangular(n):
    return n * (n + 1) // 2

def triangular_inv(m):
    return math.sqrt(2 * m + 0.25) - 0.5

def run(input, steps = 8):
    lines = str(bkt.read_all(input)).splitlines()

    xs, ys = lines[0][len("target area: "):].split(", ")
    x1, x2 = [int(x) for x in xs[len("x="):].split("..")]
    y1, y2 = [int(y) for y in ys[len("y="):].split("..")]

    min_x = min(x1, x2)
    max_x = max(x1, x2)
    min_y = min(y1, y2)
    max_y = max(y1, y2)
    print("max_height", triangular(min_y))

    def inbounds(x, y):
        return x >= min_x and x <= max_x and y >= min_y and y <= max_y

    velocities = []
    tried = 0
    for y in range(min_y, -min_y):
        for x in range(int(triangular_inv(min_x)), max_x + 1):
            #print("(", x, y, ")")
            vx, vy = x, y
            px, py = 0, 0
            for step in range(2 * abs(min_y) + 1):
                #print("[", px, py, "]")

                px += vx
                py += vy
                if vx > 0:
                    vx -= 1
                vy -= 1

                if inbounds(px, py):
                    velocities.append((x, y))
                    break
            tried += 1

    print("tried", tried)
    print("velocities", len(velocities))

run("input.txt")
