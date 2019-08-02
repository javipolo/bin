#!/usr/bin/env python

import subprocess

cmd = ['xscreensaver-command', '-watch']
exec_cmd = 'xscreensaver-exec.sh'
blanked = False

proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
try:
    while True:
        line = proc.stdout.readline().rstrip()
        if line:
            action = line.split(' ')[0]
            if not blanked and (action == 'BLANK') or (action == 'LOCK'):
                subprocess.Popen([ exec_cmd, 'lock'])
                blanked = True
            elif action == 'UNBLANK':
                subprocess.Popen([ exec_cmd, 'unlock'])
                blanked = False
        else:
            break
except KeyboardInterrupt:
    pass
