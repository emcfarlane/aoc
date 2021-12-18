load("blob.star", "blob")

bkt = blob.open("file://")

binary_mapping = [
    "0000",
    "0001",
    "0010",
    "0011",
    "0100",
    "0101",
    "0110",
    "0111",
    "1000",
    "1001",
    "1010",
    "1011",
    "1100",
    "1101",
    "1110",
    "1111",
]

def run(input):
    lines = str(bkt.read_all(input)).splitlines()
    for line in lines:
        print("line", line)
        binary = "".join([binary_mapping[int(x, 16)] for x in line.elems()])

        version_sum, op_sum = packet_decoder(binary)
        print("binary_length", len(binary))
        print("part1", version_sum)
        print("part2", op_sum)

def packet_decoder(binary):
    packets = []  # (version, type, data)
    pos = 0

    def read(pos, n):
        return binary[pos:pos + n]

    for i in range(len(binary)):  # a while loop
        if pos >= len(binary):
            break

        version = read(pos, 3)
        if len(version) < 3:
            break
        pos += 3

        type = read(pos, 3)
        if len(type) < 3:
            break
        pos += 3

        data = ""
        if int(type, 2) == 4:
            part = read(pos, 5)
            pos += 5
            data += part

            for i in range(pos, len(binary)):
                if part[0] == "0":
                    break
                part = read(pos, 5)
                pos += 5
                data += part

        else:
            ltid = read(pos, 1)
            pos += 1
            data += ltid

            if ltid == "1":
                part = read(pos, 11)
                pos += 11
                data += part
            else:
                part = read(pos, 15)
                pos += 15
                data += part

        packets.append((version, type, data))

    #print("packets", packets)
    version_sum = 0
    for packet in packets:
        version_sum += int(packet[0], 2)

    mem = []  # (value, length)
    for i in reversed(range(len(packets))):
        #print("mem", mem)
        version, type, data = packets[i]

        #print(packets[i])
        op = int(type, 2)
        length = len(version) + len(type) + len(data)

        #print("op", op)
        if op >= 0 and op <= 3:  # sum
            ltid, want = data[0], int(data[1:], 2)
            got = 0

            count = 0
            vals = []
            for (val, l) in reversed(mem):
                if ltid == "1":
                    got += 1  # by count
                else:
                    got += l  # by length

                vals.append(val)
                count += 1
                length += l
                if got == want:
                    break
                if got > want:
                    fail("invalid count", got, want)

            new_val = 0
            if op == 0:  # sum
                for val in vals:
                    new_val += val
            elif op == 1:  # product
                new_val = 1
                for val in vals:
                    new_val *= val
            elif op == 2:  # minimum
                new_val = min(vals)
            elif op == 3:  # maximum
                new_val = max(vals)
            mem = mem[:-count] + [(new_val, length)]

        elif op == 4:  # value
            n = 5
            val_str = "".join(
                [data[i + 1:i + n] for i in range(0, len(data), n)],
            )
            mem.append((int(val_str, 2), length))

        elif op >= 5 and op <= 7:
            val1, len1 = mem[-1]
            val2, len2 = mem[-2]
            length += len1 + len2
            val = 0
            if op == 5:  # greater than
                val = int(val1 > val2)
            elif op == 6:  # less than
                val = int(val1 < val2)
            elif op == 7:  # equal to
                val = int(val1 == val2)
            mem = mem[:-2] + [(val, length)]

        else:
            fail("unknown", op)

    print("mem", mem)
    return (version_sum, mem[0][0])

run("input.txt")
