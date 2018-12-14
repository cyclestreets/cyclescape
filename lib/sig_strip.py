#!/usr/bin/env python3

import sys
import talon
from talon import quotations

talon.init()

reply = quotations.extract_from_html(sys.argv[1])
print(reply)
