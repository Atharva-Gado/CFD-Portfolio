import math

# Schäfer–Turek 2D cylinder benchmark geometry
cx = 0.20
cy = 0.20
r = 0.05
z0 = -0.005
z1 =  0.005
n = 128

def vertex(x, y, z):
    return f"      vertex {x:.8f} {y:.8f} {z:.8f}\n"

with open("constant/triSurface/cylinder.stl", "w") as f:
    f.write("solid cylinder\n")

    for i in range(n):
        t1 = 2.0 * math.pi * i / n
        t2 = 2.0 * math.pi * (i + 1) / n

        x1 = cx + r * math.cos(t1)
        y1 = cy + r * math.sin(t1)
        x2 = cx + r * math.cos(t2)
        y2 = cy + r * math.sin(t2)

        # side triangle 1
        f.write("  facet normal 0 0 0\n")
        f.write("    outer loop\n")
        f.write(vertex(x1, y1, z0))
        f.write(vertex(x2, y2, z0))
        f.write(vertex(x2, y2, z1))
        f.write("    endloop\n")
        f.write("  endfacet\n")

        # side triangle 2
        f.write("  facet normal 0 0 0\n")
        f.write("    outer loop\n")
        f.write(vertex(x1, y1, z0))
        f.write(vertex(x2, y2, z1))
        f.write(vertex(x1, y1, z1))
        f.write("    endloop\n")
        f.write("  endfacet\n")

    f.write("endsolid cylinder\n")
