
#!/bin/bash

#set -e

source ~/git/GracefulGNU/BashScripts/ssh.agent.sh $3

cd ~/git/
git clone --depth 10 git@github.com:$1/$2.git

