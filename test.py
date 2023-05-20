

f = open("server.properties", "r")
data = f.read()
f.close()

lines = data.split("\n")
finished = []

for line in lines:
    split = line.split("=")
    left = split[0]
    left = left.upper()
    left = left.replace("-", "_")
    left = left.replace(".", "_")
    left = "MC_" + left
    try:
        finished.append(left + "=" + split[1])
    except:
        finished.append(left + "=")
        print(left)

f = open("server_properties.env", "w")
for line in finished:
    f.write(line)
    f.write("\n")

f.flush()
f.close()