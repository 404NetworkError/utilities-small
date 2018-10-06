#!/usr/bin/python
import socket
import sys

if len(sys.argv) != 3:
    print "Usage: vrfy.py <user list filename> <target ip address>"
    sys.exit(0)

with open(sys.argv[1]) as u:
    users = u.readlines()

ip = sys.argv[2]
results = []

try:
    #Create a Socket
    s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #Connection Timeout 
    s.settimeout(60)
    #Connect to the Server
    connect=s.connect((str(ip),25))
    #Receive the banner
    banner=s.recv(1024)
    print banner
    #VRFY a user
    for user in users:
        s.send('VRFY ' + user + '\r\n')
        results.append(s.recv(1024))
    print "Results for IP: {0}".format(ip)
    for result in results:
        print result
    print "-----------------------------------\n"
    #Close the Socket
    s.close()
except:
        print "Failed to connect with {0}".format(ip)
