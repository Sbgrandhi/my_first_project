#!/bin/bash
# This script is executed on the instance at launch time.
sudo yum update -y
sudo yum install -y python3
sudo yum install -y git
# Install pip for Python 3
pip install --upgrade pip
# Install Flask
pip install Flask
cat <<EOF > /home/ec2-user/app.py
from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello():
    return "Hello, World!"
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF
nohup python3 /home/ec2-user/app.py &