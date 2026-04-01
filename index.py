import socket

target = input("Enter IP: ")
port = int(input("Enter port: "))

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
result = s.connect_ex((target, port))

if result == 0:
    print("Port open")
else:
    print("Port closed")
