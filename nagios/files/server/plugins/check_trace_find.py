#!/usr/bin/python
## Mark.Nelson@akqa.com
## Finds a host in a traceroute and exits with status 1 OK or 2 Warning.
##./trace_check.py -host <ip> -find <ip>

# Import Modules
import argparse
import subprocess
import sys  

# Set command line arugments
parser = argparse.ArgumentParser (description='Checks for an IP address in a traceroute')
parser.add_argument('-host', help='Host to trace to.', required=True)
parser.add_argument('-find', help='Node to find in trace.', required=True)
args = parser.parse_args()

# Run the traeroute and search the output 
output = subprocess.Popen(['traceroute', '-w 1' , args.host],stderr=subprocess.STDOUT,stdout=subprocess.PIPE).communicate ()[0]
result = output.find(args.find)

#set the exit code
if result >= 0: 
    print 'OK' 
    sys.exit (0)
else:
    print 'WARNING'
    sys.exit(1)

