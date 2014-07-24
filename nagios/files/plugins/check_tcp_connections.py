#!/usr/bin/python

## ./check_connection_counts.py --established=80:100 --time_wait=30:40 --close_wait=40:50
## --established=warning,critical
##

import os, sys

def removeChar(l,c):
    n = []
    for i in l:
        if i != c:
            n.append(i)
    return n

def check(args):
    E,T,C = 0,0,0
    if 'ESTABLISHED' in args:
        E = args['ESTABLISHED']
    if 'TIME_WAIT' in args:
        T = args['TIME_WAIT']
    if 'CLOSE_WAIT' in args:
        C = args['CLOSE_WAIT']

    E_ACTUAL = 0
    T_ACTUAL = 0
    C_ACTUAL = 0

    try:
        data = os.popen("netstat -nat | awk '{print $6}' | sort | uniq -c | sort -n").read().strip().split("\n")
        for i in data:
            x = removeChar(i.split(' '),'')
            try:
                if x[1] == "ESTABLISHED":
                    E_ACTUAL = int(x[0])
                elif x[1] == "TIME_WAIT":
                    T_ACTUAL = int(x[0])
                elif x[1] == "CLOSE_WAIT":
                    C_ACTUAL = int(x[0])
            except:
                pass
    except:
        pass

    ### GENERATE MSG
    MSG_CRITICAL = ""
    MSG_WARNING = ""
    if E != 0:
        if E[1] <= E_ACTUAL:
            MSG_CRITICAL = "ESTABLISHED connections is at %s (limit: %s) - %s" % (str(E_ACTUAL),str(E[1]),MSG_CRITICAL)
        elif E[0] <= E_ACTUAL:
            MSG_WARNING = "ESTABLISHED connections is at %s (limit: %s) - %s" % (str(E_ACTUAL),str(E[0]),MSG_WARNING)
    if T != 0:
        if T[1] <= T_ACTUAL:
            MSG_CRITICAL = "TIME_WAIT connections is at %s (limit: %s) - %s" % (str(T_ACTUAL),str(T[1]),MSG_CRITICAL)
        elif T[0] <= T_ACTUAL:
            MSG_WARNING = "TIME_WAIT connections is at %s (limit: %s) - %s" % (str(T_ACTUAL),str(T[0]),MSG_WARNING)
    if C != 0:
        if C[1] <= C_ACTUAL:
            MSG_CRITICAL = "CLOSE_WAIT connections is at %s (limit: %s) - %s" % (str(C_ACTUAL),str(C[1]),MSG_CRITICAL)
        elif C[0] <= C_ACTUAL:
            MSG_WARNING = "CLOSE_WAIT connections is at %s (limit: %s) - %s" % (str(C_ACTUAL),str(C[0]),MSG_WARNING)
    if len(MSG_CRITICAL[:-2]) != 0:
        print "CRITICAL - %s | established=%s time_wait=%s close_wait=%s" % (str(MSG_CRITICAL[:-2]), str(E_ACTUAL), str(T_ACTUAL), str(C_ACTUAL))
        sys.exit(2)
    elif len(MSG_WARNING[:-2]) != 0:
        print "WARNING - %s | established=%s time_wait=%s close_wait=%s" % (str(MSG_WARNING[:-2]), str(E_ACTUAL), str(T_ACTUAL), str(C_ACTUAL))
        sys.exit(1)
    else:
        print "OK - ESTABLISHED: %s, TIME_WAIT: %s, CLOSE_WAIT: %s | established=%s time_wait=%s close_wait=%s" % (str(E_ACTUAL), str(T_ACTUAL), str(C_ACTUAL), str(E_ACTUAL), str(T_ACTUAL), str(C_ACTUAL))
        sys.exit(0)

###
### GRAB ARGUMENTS FROM COMMAND LINE
###
try:
    wanted = ['--ESTABLISHED','--TIME_WAIT','--CLOSE_WAIT']
    args = {}
    for i in sys.argv[1:]:
        if i.upper().split("=")[0] in wanted:
            k = i.split("=")[0][2:].upper()
            v = []
            t = i.upper().split("=")[1].split(":")
            for ii in t:
                v.append(int(ii))
            if len(v) == 2:
                args[k] = v
    ## DO CHECK ON ARGUMENTS
    check(args)

except Exception, e:
    print "FAILED:", e
    pass
    sys.exit(3)
