

if exists("b:current_syntax")
	finish
endif


" Highlight definitions are at Dan.vim
syn match SubItemHelpers /^\t.\+/ contains=WarningMsg
syn match WarningMsg /\/\/.*/ contained
syn match WarningMsg /\/\/.*/
syn match MyDone /^\tDone/ 
syn match MyDone /^\tDoing/ 
syn match MyDone /^\t\cchanged.my.mind/ 
syn match MyStarted /^\tStarted/ 
syn match MyContinue /^\tContinue/ 
syn match MyContinued /^\tContinued/ 
syn match Question /Hello.how.are.you?/ 
syn match MyActivities /^>\s\w.*/
syn match CompanyActivities /^>>\s\w.*/
syn match BeAware /^\*\s\?\w.*/
syn match DiaryDivisor /*\{100}/
syn match DiaryDivisorDate /\s\(\d\{2}\s\w\{3}\s\d\+\s\|\w\{3}\s\d\{1,2}\s\)/ 
syn match CallingAttention /^\t\+\([![:space:]]\|\u\)\+\t\+/
"syn match TabLineFill /\w\{3}\s\d\{2}.\+/ contains=ModeMsg
"syn match EndOfBuffer /^.*$/ 

let b:current_syntax = "diary"
