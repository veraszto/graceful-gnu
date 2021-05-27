let g:Danvim_current_being_sourced = expand("<SID>")



"Some colors customizations here
function! <SID>HighLight()

	colorscheme default
	highlight clear

	let purple = 55
	let status_line_background = 237
	let choose_separator_color = 237 
	let date_color = 21

	let highlights =
	\[
		\ [ "StatusLine", status_line_background, 213, "NONE" ],
		\ [ "StatusLineNC", status_line_background, 40, "NONE" ],
		\ [ "VertSplit", 16, 16, "NONE" ],
		\ [ "Visual", purple, 207, "NONE" ],
		\ [ "TabLineSel", 235, 189, "NONE" ],
		\ [ "TabLineFill", 240, 189, "NONE" ]
	\]


	execute "highlight DiaryDivisorDate ctermbg=197 ctermfg=" . date_color
	execute "highlight DiaryDivisor ctermbg=" . choose_separator_color . " ctermfg=" . choose_separator_color
	execute "highlight CallingAttention ctermbg=" . choose_separator_color . " ctermfg=197"

	highlight MyLightGray ctermfg=242
	highlight MyLightGrayForText ctermfg=246
	highlight MyActivities ctermfg=177
	highlight CompanyActivities ctermfg=165
	highlight BeAware ctermfg=219
	highlight link SubItemHelpers MyDone
	highlight TreeSticks ctermfg=241
	highlight MyDone ctermfg=46
	highlight MyStarted ctermfg=75
	highlight MyContinue ctermfg=75
	highlight MyContinued ctermfg=87
	
	highligh MyCategory ctermfg=201 ctermbg=234
	highligh MySubCategory ctermfg=198 ctermbg=234
	highligh MySeparator ctermfg=234 ctermbg=234
	highligh Bars ctermfg=99 
	highligh Extension ctermfg=198 
	execute "highligh SameAsExtensionToStatusLine ctermfg=250 ctermbg=" . status_line_background
	highligh WeAreHere cterm=underline,bold ctermfg=46
	highligh link SearchFromInside WeAreHere
	highligh Regex ctermfg=196
	highligh RegexWithIn ctermfg=141
	highligh Any ctermfg=57
	highligh Dirs ctermfg=111
	highligh FileNamePrefix ctermfg=201
	
	highligh DirsSaliented cterm=underline ctermfg=111
	highligh BarsSaliented cterm=underline ctermfg=99 

	highligh WorkspacesMetaDataEnclosure ctermfg=45
	highligh WorkspacesMetaDataContainer ctermfg=81
	highligh WorkspacesMetaData ctermfg=84 
	highligh WorkspacesCurlyBraces ctermfg=45


	call <SID>MakeMarksPopupHiLight()

	for a in highlights

		call <SID>MakeHighlight( get(a, 0), get(a, 1), get(a, 2), get( a, 3 ) )	

	endfor

endfunction

function! <SID>MakeMarksPopupHiLight( )

	highlight Pmenu ctermbg=24 ctermfg=214
	highlight PmenuSel ctermbg=red ctermfg=24

endfunction

function! <SID>MakeBuffersPopupHiLight( )

	highlight Pmenu ctermbg=8 ctermfg=213
	highlight PmenuSel ctermbg=black ctermfg=213

endfunction

function! <SID>MakeHighlight( highlight, ctermbg, ctermfg, cterm )

	execute "highlight " . a:highlight . " ctermbg=" . a:ctermbg . " ctermfg=" . a:ctermfg . " cterm=" . a:cterm

endfunction


call <SID>HighLight()




