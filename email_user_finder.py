#!/usr/bin/python
import socket
import sys

if len(sys.argv) != 3:
    print "Usage: vrfy.py <user list filename> <target ip address>"
    sys.exit(0)

def setupConnection():
    #Create a Socket
    s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #Connection Timeout 
    s.settimeout(60)
    #Connect to the Server
    connect=s.connect((str(ip),25))
    #Receive the banner
    banner=s.recv(1024)
    print banner
    return s

with open(sys.argv[1]) as u:
    users = u.readlines()

ip = sys.argv[2]
results = []
total_user_tries = len(users)
print total_user_tries


try:
    reset = 1
    #VRFY a user
    s = setupConnection()
    for user in users:
        if reset % 12 == 0:
            s.close()
            s = setupConnection()
            reset = 1
            print "Trying {}....".format(user)
            s.send('VRFY ' + user + '\r\n')
            results.append(s.recv(1024))
        else:
            print "Trying {}....".format(user)
            s.send('VRFY ' + user + '\r\n')
            results.append(s.recv(1024))
            reset += 1
    print "Results for IP: {0}".format(ip)
    for result in results:
        print result
    print "-----------------------------------\n"
    #Close the Socket
    s.close()
except:
        print "Failed to connect with {0}".format(ip)
