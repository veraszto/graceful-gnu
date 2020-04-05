function! <SID>BuildTabLine2()
	let l:line = ""
	for i in range(tabpagenr('$'))
		let buf = tabpagewinnr(i + 1)
		let focused = " . "
		if i + 1 == tabpagenr()

			call
				\ settabvar
					\( 
							\ i + 1, "cur_buf_name", 
							\ <SID>LastDir( getcwd() ) . "/" . 
							\ <SID>ExtractExtension( bufname( winbufnr(buf) ) ) 
					\)

			let title = gettabvar(i + 1, "cur_buf_name")
			if len( title ) > 0
				let focused = "%#TabLineSel# " .  ( title ) . " %0*"
			else
				let focused = "%#TabLineSel# . %0*"
			endif
		else
			let other_title = gettabvar( i + 1, "cur_buf_name")
			if len(other_title) > 0
				let focused = " " . other_title . " "
			endif

		endif
		let block = l:line . focused
		let l:line = block
	endfor
	return l:line
endfunction

function! <SID>BoosterNavigation()
	call <SID>WrapperOfStatusLine()
endfunction 

"Jumplist cleaner and status
function! <SID>StatusLineNativeJumpList()
	let list = getjumplist()
	let pos = list[1]
	let length = len(list[0])
	let state = "overflowing"
	if pos < length
		let state = "tectonic"
	endif
	return "[" . pos . "/" . length . ", " . state . "]"
endfunction


function! <SID>ShowType()
	let type = <SID>ExtractExtension(@%) 
	if len(type) > 0
		return "[" .type . "]"
	endif
	return "[CODE]"
endfunction

function! <SID>ExtractExtension(from)
	return 	matchstr(a:from, '\.\(\w\|[-?!]\)\+$', "gi")
endfunction

function! <SID>LastDir( matter )

	return matchstr( a:matter,   '\(/[^/]\+\)\{1}$' ) 

endfunction

function! <SID>WrapperOfStatusLine()

	execute "set statusline=" .
		\ "[%{mode()}]" .
		\ "%{" . <SID>GetSNR() . "ShowType()}%m[%P]" .
		\ "%{" . <SID>GetSNR() . "BuildStatusLine()}" .
		\ "%{b:status_line_assets[0]}" .
		\ "%#TabLineSel#%{b:status_line_assets[1]}%*" .
		\ "%{b:status_line_assets[2]}" .
		\ "%<"

endfunction

function! <SID>BuildStatusLine()
	let left = []
	let right = []
	let current = []
"	let w:surroundings = []
	let side_change = 0
	for w in range(1, winnr("$"))
		let name = bufname(winbufnr(w))
"		let stripped = substitute(name, '^.*/\|\.\w\+$', "", "g")
		let stripped = "   " . matchstr( name, '[^/]\+/\?[[:alnum:]_.-]\+\(\.\?\w\+\)$' ) . "   "
"		if  strlen(stripped) == 0 || matchstr(name, '\(\.\)\@<=\w\+$') != matchstr(bufname("%"), '\(\.\)\@<=\w\+$')
"			continue
"		endif
		if w == winnr()
			let side_change = 1
			call add(current, stripped)
		else
			if side_change == 0
				call add(left, stripped)
			else
				call add(right, stripped)
			endif
		endif
	endfor

	let b:status_line_assets = [join(left, "|"), "|" . join(current, "") . "|", join(right, "|")]

	return ""

endfunction

function! <SID>MakeHTML()
	let tag = matchstr(getline("."), '[[:alnum:]\._-]\+')
	let indent = matchstr(getline("."), '^\(\t\|\s\)\+')
	call setline(".", indent . "<" . tag . ">")
	call append(".", indent . "</" . tag . ">")
endfunction

function! <SID>CropAsYouWill(matter, replace, match)
	return 
		\matchstr
		\(
			\substitute
			\(
				\a:matter,
				\a:replace,
				\"",
				\"gi"
			\),
			\a:match
		\)
endfunction

function! <SID>AutoCommands()

	aug mine
		au!
	aug END
	autocmd mine BufRead * call <SID>BoosterNavigation()
"	autocmd mine BufRead * clearjumps
"	autocmd mine BufEnter * echo expand("%")
	autocmd mine BufEnter * normal zz

	"autocmd  mine BufWrite * 
	"	\tabm0 | execute "normal \<C-W>H" | 
	"	\execute "normal \<C-W>|" | normal zz
	"
endfunction

"\Sets
function! <SID>Sets()
	set autoindent
	set smartindent
	set title
	set tabstop=4
	set shiftwidth=4
	set scrolloff=5
	set noloadplugins
	set nohlsearch
	set number
	set noshowmode
	set nocompatible
	set noincsearch
	set autoread
	set showcmd
	set showtabline=2
	set laststatus=2
	set wmh=0
	set wmw=0
	execute "set tabline=%!" . s:GetSNR() . "BuildTabLine2()"
"	set tabline=%!<SID>BuildTabLine2()
	set backspace=2
	set wrap
	set comments=""
	"Add minus sign
	set iskeyword+=-
"	set mouse=""
"	set ttymouse=""
	filetype indent off
	filetype plugin off
	syntax on
endfunction

function! s:GetSNR()
	let snr = matchstr( expand("<sfile>"), '.SNR.\d\+')
"	echo snr
	return snr . "_"
endfunction

function! <SID>StartUp()

	call <SID>SetDict()
	call <SID>Sets()	
	call <SID>AutoCommands()
	call <SID>HiLight()
	call <SID>MakeAbbreviations()
	call <SID>MakeMappings()
	echo "StartUp has been called"

endfunction

"\PopupTargetFile
func! <SID>PopupTargetFile()
	let path = <SID>PopupMakeDirectory()
	let this_file = expand("%:t")
	let sha = sha256( this_file )
	return 
		\[ 
			\this_file, 
			\sha, 
			\path . this_file . ".vim.shortcut" 
		\]

endfunction

func! <SID>PopupMakeDirectory()

	let path = expand("~/.vim/" . $USER . "_popup_marks/shortcuts/")
	if len( finddir( path ) ) > 0
			return path
	endif
	let path_one_level_up = matchstr( path, '.\+\(/.\+/\)\@=')
	call mkdir( path_one_level_up, "p" )
	return path

endfunction

func! <SID>PopupReadFile()

	if exists("b:popup_is_dirty") &&
		\b:popup_is_dirty == v:false
		return b:marks
	endif
	let file = <SID>PopupTargetFile()
	try
		let marks = readfile(file[2])
		let b:marks = marks
		let b:popup_is_dirty = v:false
		return marks
	catch
		echo "Popup: could not read file " . file[2]
	endtry
	return []

endfunction

func! <SID>PopupShow()

	let list = <SID>PopupReadFile()
	if len(list) == 0
		echo "Marks' stack is empty, so is it the designated file"
		return
	endif
	try
		nunme mightynimble
	catch
	endtry

	let counter = 0
	for a in b:marks

		let to_execute = "nmenu mightynimble." 
			\. <SID>MakeEscape(a) . 
			\" :call <SID>PopupChosen(" . counter . ")<CR>"

		execute to_execute
		let counter += 1

	endfor
	popup mightynimble
endfunction

"\PopupChosen
func! <SID>PopupChosen(index)
			
	let item = b:marks[a:index]
	execute "call <SID>MakeSearch('" . item . "')"
	call remove(b:marks, a:index)
	call insert(b:marks, item)
	normal zz
	
endfunction

func! <SID>PopupAdd()

	let b:popup_is_dirty = v:true
	let file = <SID>PopupTargetFile()
	try
		call writefile( b:marks, file[2] )
	catch
		echo "Popup: could not write to file " . file[2] . ", " . v:exception
	endtry

endfunction

function! <SID>MarksNavigationCheckContainer()

	if ! exists("b:marks")
		let b:marks = []
	endif
	if ! exists("b:current_mark")
		let b:current_mark = 0
	endif

endfunction

function! <SID>SaveMark()

	call <SID>MarksNavigationCheckContainer()	

	let line = getline(".")
	let counter = 0
	let length = len(b:marks)	
	let tell = "This line has been saved: "
	while exists("s:acceptable_to_mark[" . counter . "]")
		let match = matchstr(line, s:acceptable_to_mark[counter])
		if len(match) > 0
			call insert(b:marks, match)
			call <SID>PopupAdd()
			let tell .= match
			break
		endif
		let counter += 1
	endw
	if len(b:marks) == length
		echo "This line " . line . " was asserted not to be desirable"
		return
	endif
	echo tell

endfunction

function! <SID>SlideThroughMarks(direction)
	
	call <SID>MarksNavigationCheckContainer()	
	if 
		\ a:direction =~? '^right$' &&
		\ b:current_mark < (len(b:marks) - 1)
			let b:current_mark += 1
	elseif
		\ a:direction =~? '^left$' &&
		\ b:current_mark > 0 

			let b:current_mark -= 1
	endif
	let fixed_width = 28
	for i in range(-1, 1)

		let index = b:current_mark + i

		let pure_content = get(b:marks, index, -1)

		let content = 
			\matchstr(pure_content, '[[:alnum:]_.]\+')

		if pure_content == -1
			let content = "<EmptySlot>"
		endif

		let remainder = (fixed_width - strlen(content)) / 2

		let padded_content = 
			\repeat(" ", remainder) .
			\index . ")" . content . 
			\repeat(" ", remainder)
		
		if index < 0
			let unaccessible = "Unaccessible"
			let remainder = (fixed_width - strlen(unaccessible)) / 2
			let padded_content = 
				\repeat(" ", remainder) .
				\"-)" . unaccessible . 
				\repeat(" ", remainder)
		endif
		
		if i == 0
			echohl PmenuSel
		elseif index > 0 && pure_content >= 0
			echohl None
		else
			echohl EndOfBuffer
		endif

		echon padded_content
		echohl None

	endfor

endfunction

"\Commit to mark
function! <SID>CommitToMark() 

	call <SID>MarksNavigationCheckContainer()	

	if v:count1 == 1 && v:count == 0
		let say = "Going through arrows navigating"
	else
		let b:current_mark = v:count
		let say = "Going through input v:count and v:count1, whose are " . v:count . " and " . v:count1
	endif

	let matter = get(b:marks, b:current_mark, -1)

	if matter == -1
		echo "Out of bounds mark"
		return
	endif

	let s = <SID>MakeSearch( matter )

	normal j
	if s != 0
		execute "normal z\<Enter>\<End>"
		let say .= " reaching " . matter
	else
		let say .= ", however, " . matter . " has not been found"
	endif
	echo say

endfunction

"\MakeSearch
function! <SID>MakeSearch(matter)
	let s = search
	\(
		\<SID>MakeEscape(a:matter), 
		\"s"
	\)
	return s
endfunction

"\MakeEscape
func! <SID>MakeEscape(matter)

	return escape
		\(
			\a:matter, 
			\'\"$ .'
		\)

endfunction

"\MakeMappings
function! <SID>MakeMappings() "\Sample of a mark

	mapclear
	imapclear
	mapclear <buffer>
	imapclear <buffer>
	echo "Maps cleared"
	
"	Avoiding insert/replace toggle
	inoremap <Insert> <Esc>a

"	Easing autocomplete
	imap jj <C-X><C-N>
	imap jk <C-X><C-K>

"   Window Navigation
	map <C-UP> <C-W>k<C-W>_
	map <C-DOWN> <C-W>j<C-W>_
	map <C-LEFT> <C-W>h<C-W><Bar>
	map <C-RIGHT> <C-W>l<C-W><Bar>
	map <S-C-LEFT> <C-W>h
	map <S-C-RIGHT> <C-W>l
	imap <C-UP> <Esc><C-W>k<C-W>_i
	imap <C-DOWN> <Esc><C-W>j<C-W>_i
	imap <C-LEFT> <Esc><C-W>h<C-W><Bar>i
	imap <C-RIGHT> <Esc><C-W>l<C-W><Bar>i
	imap <S-C-LEFT> <Esc><C-W>hi
	imap <S-C-RIGHT> <C-W>li


"	Buffer Navigation
	map <S-Tab> :up <Bar> :e#<CR>

	map <Bar> :bprevious<CR>
	map Z :bnext<CR>


"	Commenting and uncommenting
	map cc :s/^/\/\//<CR>
	map ccc :s/^/\/*/<CR>:s/$/*\//<CR>
	map cccc :s/\(\w\\|<\)\@=/<!--/<CR>:s/$/-->/<CR>
"	map cd :s/\/\*\\|\/\/\\|\*\/\\|<!--\\|-->\\|^\(\s\\|\t\)*#//g<CR>
	map cd :execute ':s/\/\*\\|\*\/\\|<!--\\|-->\\|^\(\s\\|\t\)*\/\///g'<CR>


"	Instant reloads
	map ;; :call <SID>StartUp()<CR>
	map ;ma :call <SID>MakeAbbreviations()<CR>
	map ;mm :call <SID>MakeMappings()<CR>
	map ;ms :call <SID>SaveMark()<CR>


"	Easy save
	imap 	<S-Up> <Esc>:wa<CR>
	map 	<S-Up> :wa<CR>


"	Fast moving
	map <S-Down> 	:<C-U>call <SID>CommitToMark()<CR>
	map <S-Left>	:call <SID>SlideThroughMarks("left")<CR>
	map <S-Right>	:call <SID>SlideThroughMarks("right")<CR>
	inoremap jh 	<Esc>:call <SID>PopupShow()<CR>a
"	imap <S-Down> 	
	
"	map <C-S-Down> 	
	map <C-S-Up> 	
"	imap <C-S-Down> 
"	imap <C-S-Up> 	


"	Shortcuts
	map ;a :ab<CR>
	map ;bl :ls<CR>
	map ;bu :bu 
	map ;ch :changes<CR>
	map ;cj :clearjumps<CR>
	map ;cp :call <SID>CopyRegisterToFileAndClipboard("t")<CR>
	map ;< <C-W>H<C-W>\|
	map ;ea :call <SID>RefreshAll()<CR>
	map F :call <SID>PopupShow()<CR>
	map L :buffers<CR>
	map B :bu<Space>
	map E :e<CR>
	map V EG
	map ;hi :call <SID>HiLight()<CR>
	map ;hn :new<CR><C-W>_ 
	map ;ju :jumps<CR>
	map ;hs :split<CR><C-W>_ 
	map ;ks :keepjumps /
	map ;l :lcd 
	map ;p :pwd<CR>
	map ;q :quit<CR>
	map ;r :reg<CR>
	map ;sm :marks<CR>
	map ;, :tabm0<CR>
	map ;t :tabnew<CR>
	map ;vn :vertical new<CR><C-W>\| 
	map ;vs :vertical split<CR><C-W>\| 
"	map <PageUp> <C-I>
"	map <PageDown> <C-O>
"	imap <PageUp> <Esc><C-I>i
"	imap <PageDown> <Esc><C-O>i
	noremap <expr> ;i ":vi " . getcwd() . "/"
	noremap <expr> ;I ":vi " . expand("%")
	echo "Maps done!"

endfunction

function! <SID>RefreshAll()
	tabdo
		\ windo 
			\ echo buffer_name("%") |
			\ try |
				\ :e |
			\ catch |
				\ echohl Visual |
				\ echo v:exception |
				\ echohl None |
			\ endtry |
			\ vertical resize
endfunction

function! <SID>HiLight()	

	"Some colors customizations here
	
	let assemble_83 = [ 8, 3 ]
	let assemble_53 = [ 5, 3 ]

	let purple = 55

	let highlights =
	\[
		\ [ "StatusLine", 189, 240, "reverse" ],
		\ [ "StatusLineNC", 240, 159, "NONE" ],
		\ [ "VertSplit", 16, 16, "NONE" ],
		\ [ "Pmenu", 24, 214, "NONE" ],
		\ [ "PmenuSel", "red", 24, "NONE" ],
		\ [ "Visual", purple, 16, "reverse" ],
		\ [ "TabLineSel", 235, 189, "NONE" ],
		\ [ "TabLineFill", 240, 189, "NONE" ]
	\]

	colorscheme default

	highlight clear
"	call <SID>ClearHighlights( highlights )
	highlight Special ctermfg=98
	highlight PreProc ctermfg=98
	highlight Comment ctermfg=244

	for a in highlights
		call <SID>MakeHighlight( get(a, 0), get(a, 1), get(a, 2), get( a, 3 ) )	
	endfor

endfunction

function! <SID>MakeHighlight( highlight, ctermbg, ctermfg, cterm )
	execute "highlight " . a:highlight . " ctermbg=" . a:ctermbg . " ctermfg=" . a:ctermfg . " cterm=" . a:cterm
endfunction

function! <SID>ClearHighlights( list )

	for a in a:list
		execute "highlight clear " . get( a , 0 )
	endfor

endfunction

function! <SID>SetDict()
	"Some dicitionaries targeting here
endfunction

function! <SID>MakeAbbreviations()
	"Some iabs here
	iab ht <Esc>:call <SID>MakeHTML()<CR>A
endfunction

function! <SID>CopyRegisterToFileAndClipboard(register)

	execute "let tmp = @" . a:register
	let escaped = shellescape(tmp, 1)
	silent execute "!echo " . escaped  . " | dd of=" . s:bridge_file
"	silent execute "!echo " . escaped  . " | xclip -selection clipboard"
	execute "!echo " . escaped  . " | wl-copy"
	redraw!

endfunction

" Acceptable to mark
let s:acceptable_to_mark = 
\[
	\'\(\(\s\|\t\)*\)\@<=\\\([-[:alnum:]_.,?!]\+[[:space:]]\{,2}\)\{1,}'
\]

let s:bridge_file = "/tmp/bridge"

echo "Dan.vim has just been loaded"

if exists("s:this_has_been_loaded") == v:false
	let s:this_has_been_loaded = v:true
	echo "As its the first time for this instance, then we call StartUp"
	call <SID>StartUp()
endif





	
	
	
