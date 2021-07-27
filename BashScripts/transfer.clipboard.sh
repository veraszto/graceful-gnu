

#!/bin/bash
ssh -i "$MY_GIT_KEY" "$MY_SECOND_HAND_COMPUTER_SSH" "wl-copy '$(wl-paste)' &> /dev/null"
