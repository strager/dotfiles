#!/usr/bin/env python2.7

from __future__ import print_function

import sys

def func(a, b, c):
    if a > 1:
        if b > 1:
            if c > 1:
                return (a * a + b * b + c * c) * (a * a + b * b + c * c)
    return None

if __name__ == '__main__':
    print('error: see test_format.vim', file=sys.stderr)
    exit(1)
