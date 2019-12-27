# GracefulGNU

## Compact description

These are to customize and enhance pretty ability throughout my GNU/Linux daily usage,
a part from some trivial customizations, there are the [SharpFocus](Bashcripts/SharpFocus) and [Dan.vim](vim/runtime/Dan.vim).

## SharpFocus

This was being used by me when i had the idea of not using alt+tab in order to move and focus accross terminals, browsers among workspaces,
as it was not being straightforward as needed while using GNOME.

I mapped Ctrl+[0-9] in gsettings to call [keybindings.sh](BashScripts/SharpFocus/keybindings.sh) passing as a parameter the number/symbol which Ctrl was pressed with.

This number argument is a array index which points to a wmctrl window id, triggering in one turn the desired focus sharply.

This array was previously built with the help of [launcher.sh](BashScripts/SharpFocus/launcher.sh) and [boost_browsers.sh](BashScripts/SharpFocus/boost_browsers.sh).

This works well, but then i became aware of the existence of Sway/Wayland, so i replaced SharpFocus with it and found out that
what i was trying to do was to logically organize my workspace, which Sway is further doing with excellence.


## Dan.vim

This is a vim script which i have been writting to tackle file editing/access to the best.

It is intended to open buffers vertically in the same window whose type/extension are the same. Navigating with Ctrl+(Left|Right) arrows.

Navigation with a custom popup(normal F) and though arrows using Shift+(Left|Right) arrows and down arrow to confirm while in normal mode.

;ms in normal mode in a satisfied(search for acceptable_mark in Dan.vim, it is something like this //\ToMark) string to mark it into the popup.


##### Thank you.

