"""
command history will be added to historyPath (scriptname.history)
"""
import atexit
import os
import readline
import rlcompleter
import sys

historyPath = sys.argv[0]+".history"

def save_history(historyPath=historyPath):
    import readline
    readline.write_history_file(historyPath)

if os.path.exists(historyPath):
    readline.read_history_file(historyPath)

atexit.register(save_history)
