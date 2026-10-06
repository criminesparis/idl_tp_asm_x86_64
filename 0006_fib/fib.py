import sys
from math import sqrt

def fib_rec(n):
    """Récursif naïf: exponentiel."""
    return n if n < 2 else fib_rec(n - 1) + fib_rec(n - 2)

def fib_iter(n):
    """Itératif: linéaire."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def fib_binet(n):
    """Formule de Binet, en flottant double: exact jusqu'à n = 70 environ."""
    phi = (1 + sqrt(5)) / 2
    return round(phi ** n / sqrt(5))

n = int(sys.argv[1])
print(fib_rec(n), fib_iter(n), fib_binet(n))
