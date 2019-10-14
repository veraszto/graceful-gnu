function! BuildTabLine2()
	let l:line = ""
	for i in range(tabpagenr('$'))
		let buf = tabpagewinnr(i + 1)
		let focused = " . "
		if i + 1 == tabpagenr()
			call settabvar(i + 1, "cur_buf_name", ExtractExtension( bufname( winbufnr(buf) ) )  )
			let title = gettabvar(i + 1, "cur_buf_name")
			if len(title) > 0
				let focused = "%#Conceal# " .  (title) . " %0*"
			else
				let focused = "%#Conceal# . %0*"
			endif
		else
			let other_title = gettabvar(i + 1, "cur_buf_name")
			if len(other_title) > 0
				let focused = " " . other_title . " "
			endif

		endif
		let block = l:line . focused
		let l:line = block
	endfor
	return l:line
endfunction

function! BoosterNavigation()
	call WrapperOfStatusLine()
endfunction 

"Jumplist cleaner and status
function! StatusLineNativeJumpList()
	let list = getjumplist()
	let pos = list[1]
	let length = len(list[0])
	let state = "overflowing"
	if pos < length
		let state = "tectonic"
	endif
	return "[" . pos . "/" . length . ", " . state . "]"
endfunction


function! ShowType()
	let type = ExtractExtension(@%) 
	if len(type) > 0
		return "[" .type . "]"
	endif
	return "[CODE]"
endfunction

function! ExtractExtension(from)
	return 	matchstr(a:from, '\.\(\w\|[-?!]\)\+$', "gi")
endfunction


function! WrapperOfStatusLine()
	
	setlocal statusline=
		\[%{mode()}]
		\%{ShowType()}%m[%P]%{BuildStatusLine()}
		\%{b:status_line_assets[0]}
		\%#FocusedMenu#%{b:status_line_assets[1]}%*
		\%{b:status_line_assets[2]}
"		\%{StatusLineNativeJumpList()} "getjumlist may not be available

endfunction

function! BuildStatusLine()
	let left = []
	let right = []
	let current = []
"	let w:surroundings = []
	let side_change = 0
	for w in range(1, winnr("$"))
		let name = bufname(winbufnr(w))
		let stripped = substitute(name, '^.*/\|\.\w\+$', "", "g")
"		if  strlen(stripped) == 0 || matchstr(name, '\(\.\)\@<=\w\+$') != matchstr(bufname("%"), '\(\.\)\@<=\w\+$')
"			continue
"		endif
		if w == winnr()
			let side_change = 1
			call add(current, "[" . stripped . "]")
		else
			if side_change == 0
				call add(left, stripped)
			else
				call add(right, stripped)
			endif
		endif
	endfor

	let b:status_line_assets = [join(left, "|"), join(current, ""), join(right, "|")]

	return ""

endfunction

function! MakeHTML()
	let tag = matchstr(getline("."), '[a-z0-9]\+')
	let indent = matchstr(getline("."), '^\(\t\|\s\)\+')
	call setline(".", indent . "<" . tag . ">")
	call append(".", indent . "</" . tag . ">")
endfunction

function! CropAsYouWill(matter, replace, match)
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

function! AutoCommands()

	aug mine
		au!
	aug END
	autocmd  mine BufEnter * exe "call BoosterNavigation()"

	"autocmd  mine BufWrite * 
	"	\tabm0 | execute "normal \<C-W>H" | 
	"	\execute "normal \<C-W>|" | normal zz
	"
	autocmd! buildlabels

endfunction

"\Sets
function! Sets()
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
	set noincsearch
	set autoread
	set showcmd
	set showtabline=2
	set laststatus=2
	set wmh=0
	set wmw=0
	set tabline=%!BuildTabLine2()
	set backspace=2
	set wrap
	set comments=""
	filetype indent off
endfunction

function! StartUp()

	call SetDict()
	call Sets()	
	call AutoCommands()
	call HiLight()
	call MakeAbbreviations()
	call MakeMappings()
	echo "StartUp has been called"

endfunction

"\PopupTargetFile
func! PopupTargetFile()
	let path = PopupMakeDirectory()
	let this_file = expand("%:p")
	let sha = sha256(this_file)
	return [this_file, sha, path . sha]
endfunction

func! PopupMakeDirectory()

	let path = expand("~/.vim/" . $USER . "_popup_marks/")

	if exists("b:has_already_created_popup_directory") &&
		\b:has_already_created_popup_directory == v:true
			return path
	endif
	call mkdir(path, "p")
	let b:has_already_created_popup_directory = v:true
	return path

endfunction

func! PopupReadFile()

	if exists("b:popup_is_dirty") &&
		\b:popup_is_dirty == v:false
		return b:marks
	endif
	let file = PopupTargetFile()
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

func! PopupShow()

	let list = PopupReadFile()
	if len(list) == 0
		echo "BMarks is empty, so is it the designated file"
		return
	endif
	try
		nunme mightynimble
	catch
	endtry

	let counter = 0
	for a in b:marks

		let to_execute = "nmenu mightynimble." 
			\. MakeEscape(a) . 
			\" :call PopupChosen(" . counter . ")<CR>"

		execute to_execute
		let counter += 1

	endfor
	popup mightynimble
endfunction

"\PopupChosen
func! PopupChosen(index)
			
	let item = b:marks[a:index]
	execute "call MakeSearch('" . item . "')"
	call remove(b:marks, a:index)
	call insert(b:marks, item)
	normal zz
	
endfunction

func! PopupAdd(what)

	let b:popup_is_dirty = v:true
	let file = PopupTargetFile()
	try
		if len(findfile(file[2])) == 0
			call writefile([a:what, file[0], file[1]], file[2])
		else
			call writefile(b:marks, file[2])
		endif
	catch
		echo "Popup: could not write to file " . file[2] . ", " . v:exception
	endtry

endfunction

function! MarksNavigationCheckContainer()

	if ! exists("b:marks")
		let b:marks = []
		let b:current_mark = 0
	endif

endfunction

function! SaveMark()

	call MarksNavigationCheckContainer()	

	let line = getline(".")
	let counter = 0
	let length = len(b:marks)	
	let tell = "This line has been saved: "
	while exists("s:acceptable_to_mark[" . counter . "]")
		let match = matchstr(line, s:acceptable_to_mark[counter])
		if len(match) > 0
			call add(b:marks, match)
			call PopupAdd(match)
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

function! SlideThroughMarks(direction)
	
	call MarksNavigationCheckContainer()	
	if 
		\ a:direction =~? '^right$' &&
		\ b:current_mark < (len(b:marks) - 1)
			let b:current_mark += 1
	elseif
		\ a:direction =~? '^left$' &&
		\ b:current_mark > 0 

			let b:current_mark -= 1
	endif
	let a:fixed_width = 28
	for i in range(-1, 1)

		let index = b:current_mark + i

		let pure_content = get(b:marks, index, -1)

		let content = 
			\matchstr(pure_content, '[[:alnum:]_.]\+')

		if pure_content == -1
			let content = "<EmptySlot>"
		endif

		let remainder = (a:fixed_width - strlen(content)) / 2

		let a:padded_content = 
			\repeat(" ", remainder) .
			\index . ")" . content . 
			\repeat(" ", remainder)
		
		if index < 0
			let unaccessible = "Unaccessible"
			let remainder = (a:fixed_width - strlen(unaccessible)) / 2
			let a:padded_content = 
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

		echon a:padded_content
		echohl None

	endfor

endfunction

"\Commit to mark
function! CommitToMark() 

	call MarksNavigationCheckContainer()	

	if v:count1 == 1 && v:count == 0
		let say = "Going through arrows navigating"
	else
		let b:current_mark = v:count
		let say = "Going through input v:count and v:count1, whose are " . v:count . " and " . v:count1
	endif

	let a:matter = get(b:marks, b:current_mark, -1)

	if a:matter == -1
		echo "Out of bounds mark"
		return
	endif

	let s = MakeSearch(a:matter)

	normal j
	if s != 0
		execute "normal z\<Enter>\<End>"
		let say .= " reaching " . a:matter
	else
		let say .= ", however, " . a:matter . " has not been found"
	endif
	echo say

endfunction

"\MakeSearch
function! MakeSearch(matter)
	let s = search
	\(
		\MakeEscape(a:matter), 
		\"sce"
	\)
	return s
endfunction

"\MakeEscape
func! MakeEscape(matter)

	return escape
		\(
			\a:matter, 
			\'\"$ .'
		\)

endfunction

"\MakeMappings
function! MakeMappings() "\Sample of a mark

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


"	Quick access to alternate file
	map <S-Tab> :up <Bar> :e #<CR>
	imap <S-Tab> <Esc>:up <Bar> :e #<CR>


"	Commenting and uncommenting
	map cc :s/^/\/\//<CR>
	map ccc :s/^/\/*/<CR>:s/$/*\//<CR>
	map cccc :s/\(\w\\|<\)\@=/<!--/<CR>:s/$/-->/<CR>
"	map cd :s/\/\*\\|\/\/\\|\*\/\\|<!--\\|-->\\|^\(\s\\|\t\)*#//g<CR>
	map cd :execute ':s/\/\*\\|\*\/\\|<!--\\|-->\\|^\(\s\\|\t\)*\/\///g'<CR>


"	Instant reloads
	map ;; :call StartUp()<CR>
	map ;ma :call MakeAbbreviations()<CR>
	map ;mm :call MakeMappings()<CR>
	map m :call SaveMark()<CR>


"	Easy save
	imap 	<S-Up> <Esc>:wa<CR>
	map 	<S-Up> :wa<CR>


"	Fast moving
	map <S-Down> 	:<C-U>call CommitToMark()<CR>
	map <S-Left>	:call SlideThroughMarks("left")<CR>
	map <S-Right>	:call SlideThroughMarks("right")<CR>
	inoremap jh 	<Esc>:call PopupShow()<CR>a
"	imap <S-Down> 	
	
"	map <C-S-Down> 	
"	map <C-S-Up> 	
"	imap <C-S-Down> 
"	imap <C-S-Up> 	


"	Shortcuts
	map ;a :ab<CR>
	map ;bl :ls<CR>
	map ;bu :bu 
	map ;ch :changes<CR>
	map ;cj :clearjumps<CR>
	map ;cp :call CopyRegisterToFileAndClipboard("t")<CR>
	map ;< <C-W>H<C-W>\|
	map ;ea :call RefreshAll()<CR>
	map F :call PopupShow()<CR>
	map ;hi :call HiLight()<CR>
	map ;hn :new<CR><C-W>_ 
	map ;hs :split<CR><C-W>_ 
	map ;j :call PopupShow()<CR>
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
	noremap <expr> ;i ":vi " . getcwd() . "/"
	noremap <expr> ;I ":vi " . expand("%")
	echo "Maps done!"

endfunction

function! RefreshAll()
	tabdo
		\ windo 
			\ echo buffer_name("%") |
			\ try |
				\ :e |
			\ catch |
				\ echohl Visual |
				\ echo v:exception |
				\ echohl None|
			\ endtry
endfunction

function! HiLight()	

	"Some colors customizations here
	hi clear StatusLine
	hi clear StatusLineNC
	hi clear VertSplit
	hi clear Conceal
	hi StatusLine ctermbg=0 ctermfg=10
	hi StatusLineNC ctermbg=0 ctermfg=2 
	hi VertSplit ctermbg=0 ctermfg=0

endfunction

function! SetDict()
	"Some dicitionaries targeting here
endfunction

function! MakeAbbreviations()
	"Some iabs here
endfunction

function! CopyRegisterToFileAndClipboard(register)

	execute "let tmp = @" . a:register
	let escaped = shellescape(tmp, 1)
	silent execute "!echo " . escaped  . " | dd of=" . s:bridge_file
	silent execute "!echo " . escaped  . " | xclip -selection clipboard"
	redraw!

endfunction

" Acceptable to mark
let s:acceptable_to_mark = 
\[
	\'\(\(\s\|\t\)*\)\@<=\\\([-[:alnum:]_.,?!]\+[[:space:]]\{,2}\)\{1,}'
\]

let s:bridge_file = "/tmp/bridge"

echo "Dan.vim has just been loaded, branch Overriding Marks"





	
	
	
