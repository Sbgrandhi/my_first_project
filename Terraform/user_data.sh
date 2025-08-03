#!/bin/bash
sudo apt update -y
sudo apt install -y python3 python3-pip
pip3 install flask

cat <<EOF > /home/ubuntu/app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Flask App in Auto Scaling Group!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

nohup python3 /home/ubuntu/app.py &
