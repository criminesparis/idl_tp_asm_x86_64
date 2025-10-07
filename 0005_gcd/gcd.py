import sys

def gcd(a, b):
    while a != b:
        if a > b:
            a = a - b
        else:
            b = b - a
    return a

print(gcd(int(sys.argv[1]), int(sys.argv[2])))
