let g:Danvim_current_being_sourced = expand("<SID>")

let s:base_vars = 
\ {
	\ "popup_marks_dir": $MY_STUFF . "/vim/popup.shortcuts",
	\ "base_path": expand("~") . "/git/GracefulGNU/",
	\ "bridge_file": "/tmp/bridge",
	\ "clipboard_commands": [ "wl-copy", "wl-paste" ],
	\ "initial_workspace": $MY_STUFF . "/vim/workspaces/all.workspaces",
	\ "loaders_dir": $MY_STUFF . "/vim/loaders/trending",
	\ "basic_structure_initial_dir": expand("~/git"),
	\ "last": v:null
\ }

function! <SID>BaseVars()
	
	return s:base_vars

endfunction

