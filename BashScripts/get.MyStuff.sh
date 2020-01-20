
#!/bin/bash

source ~/git/GracefulGNU/BashScripts/ssh.agent.sh $1

cd ~/git/
git clone --depth 10 git@github.com:$1:$2.git

