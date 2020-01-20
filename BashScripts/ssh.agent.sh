

#!/bin/bash

ssh_agent=$(pgrep ssh-agent | head -n 1)
ssh_agent_name="$HOME/ssh.agent"

#-z works well free of quotes but with content free from IFS
create="ssh-agent -s -a $ssh_agent_name"
test -z $ssh_agent && \
	eval $($create) || \
	{
		export SSH_AUTH_SOCK=~/ssh.agent				
		export SSH_AGENT_PID=$ssh_agent
		echo "SSH agent already detected"
		echo "$SSH_AUTH_SOCK, $SSH_AGENT_PID";
	}

#on X display server one can use xclip instead of wl-paste

echo -e "$(wl-paste)" > $1
chmod 700 $1

exec="ssh-add $1"
echo $exec
$exec
exec="ssh-add -L"
echo $exec
$exec


