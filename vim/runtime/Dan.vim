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

function! <SID>BuildStatusLine2()
	return "%mbuffer: %#SameAsExtensionToStatusLine#%n%* / %#SameAsExtensionToStatusLine#%t%*" . 
		\ " / %#SameAsExtensionToStatusLine#%{". s:GetSNR() ."getStamp()}%*%=(%c/%l/%L) byte:%B"
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

	aug fedora
		au!
	aug END

	au! BufRead *
	au! filetypedetect BufRead *

	autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

"	autocmd mine BufRead * call <SID>BoosterNavigation()
"	autocmd mine BufRead * clearjumps
"	autocmd mine BufEnter * echo expand("%")
"	autocmd mine BufEnter * normal zz

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
	execute "set statusline=%!" . s:GetSNR() . "BuildStatusLine2()"
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

	let s:base_path = expand("~/") . "/git" 
	call <SID>Sets()	
	call <SID>AutoCommands()
	call <SID>HiLight()
	call <SID>MakeAbbreviations()
	call <SID>MakeMappings()
	call <SID>SetDict()
	echo "StartUp has been called"

endfunction

function! <SID>WriteToFile( content, file )
	try
		return writefile( a:content, a:file )
	catch
		echo "Could not write to file, " . file . ", " . v:exception
		return []
	endtry
endfunction

function! <SID>ReadFromFile( file, create )
	try
		return readfile( a:file )
	catch
		echo "Could not read from file, " . a:file . ", " . v:exception
	endtry

	if a:create == 1
		echo "Creating " . a:file
		call <SID>WriteToFile( [], a:file )
	endif
	return []

endfunction

function! <SID>StrPad( what, with, upto )

	let padded = a:what

	while len( padded ) < a:upto
		let padded .= a:with
	endwhile

	return padded

endfunction

function! <SID>IsMatched( matter )

	for check in s:exclude_from_jbufs

		let matched = match( a:matter, check )
		if matched > - 1 
			return matched
		endif

	endfor

	return -1

endfunction

function! <SID>CollectPertinentJumps( limit )

	let do_not_repeat = [ bufnr() ]
	let jumps = getjumplist()[0]
	let length = len( jumps ) - 1
	let i = length
	let jumps_togo = []

	while i >= 0

		let jump = get( jumps, i )
		let bufnr = jump["bufnr"]
		let bufinfo = getbufinfo( bufnr )[0]

		if
		\(
			\ count( do_not_repeat, bufnr ) > 0 ||
			\ len( bufinfo["name"] ) == 0 ||
			\ <SID>IsMatched( bufinfo["name"] ) > -1
		\)
			let i -= 1
			continue

		endif

		call add( do_not_repeat, bufnr )	
		call add( jumps_togo, jump )

		if len( jumps_togo ) == a:limit
			break
		endif
		
		let i -= 1

	endwhile

	return jumps_togo 

endfunction

function! <SID>PopupJumps( )
	
	try
		nunme jumps
	catch
	endtry

	let jumps = <SID>CollectPertinentJumps( -1 )

	for jump in jumps

		execute "nmenu jumps." . <SID>MakeEscape( <SID>MakeJump( jump ) ) . " " . 
			\ ":try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 

	endfor

	if len( jumps ) > 0
		popup jumps
	else
		echo "No jumps to fill the list popup"
	endif

endfunction

function! <SID>ShortcutToNthPertinentJump( which )

	let jumps = <SID>CollectPertinentJumps( a:which )
	let jump = get( jumps, a:which - 1, {} )
	if jump == {} 
		echo "JBufs did not reach length of " . a:which
		return
	endif
	execute "try | buffer " . jump["bufnr"] . 
				\ " | catch | echo \"Could not buf:\" . v:exception | endtry" 

endfunction

function! <SID>CycleLastTwoExcluded()

	let jumps = getjumplist()[0]
	let length = len( jumps )
	let i = length - 1

	while i >= 0
		let jump = jumps[ i ]
		let bufnr = get( jump, "bufnr")
		let bufname = get( getbufinfo( bufnr )[0], "name" )

		if match( bufname, s:workspaces_pattern ) > -1 && bufnr != bufnr()
			execute "try | buffer " . bufnr . " | catch | echo \"Could not buf:\" . v:exception | endtry" 
			break
		endif

		let i -= 1
	endwhile

endfunction

function! <SID>MakeJump( jump )

	let built = "jbuf: " . 
		\ <SID>StrPad( a:jump["bufnr"], " ", 3 ) . 
		\ matchstr( bufname( a:jump["bufnr"] ), s:tail_file )
	return built

endfunction

function! <SID>PopupBuffers()

	let buffers = getbufinfo()

	try
		nunme buffers
	catch
	endtry
	let counter = 0
	for buffer in buffers
		if len( get( buffer, "name") ) == 0 ||
			\ get( buffer, "listed" ) == 0

			continue
		endif
		execute "nmenu buffers." . <SID>MakeEscape( <SID>BuildBufferPopupItem( buffer ) ) . 
			\ " :buffer" . get(buffer, "bufnr")  . "<CR>"
		let counter += 1
	endfor
	if counter > 0
		popup buffers
	else
		echo "No eligible buffers to fill the list popup"
	endif

endfunction

function! <SID>BuildBufferPopupItem( buffer )

	let label = "buf: " . 
		\ <SID>StrPad( get(a:buffer, "bufnr"), " ", 3 ) . 
		\ matchstr( get(a:buffer, "name"), s:tail_file )

	return label

endfunction

function! <SID>GetThisFilePopupMark()
	let file = expand("~/.vim/" . $USER . "_popup_marks/shortcuts/") . expand("%:t") . ".vim.shortcut"
	echo "GetThisFilePopupMark: " . file
	return file 
endfunction

function! <SID>EditMarksFile()
	execute "vi " . <SID>GetThisFilePopupMark()
endfunction

func! <SID>PopupMarksShow()

	if !exists("b:marks")

		let b:marks = 
			\ <SID>ReadFromFile
			\ ( 
				\ <SID>GetThisFilePopupMark(), 
				\ v:true 
			\ )

	endif

	if len( b:marks ) == 0
		echo "Marks' empty"
		return
	endif

	try
		nunme mightynimble
	catch
	endtry
	
	let jump = v:false	
	let there_is_a_menu = v:false		
	let counter = 0

	for each_label in b:marks

		let search_for = get( b:marks, counter + 1 )

		let len_each_label = len( trim( each_label ) )
		let len_search_for = len( trim( search_for ) )
"		echo each_label . "(" . len_each_label  . "): " . search_for . "(" . len_search_for . ")"

		if jump == v:true ||
				\ len_each_label == 0 || 
				\ len_search_for == 0 

			let counter += 1
			let jump = v:false
			continue

		endif
		
		let jump = v:true

		let to_execute = "nmenu mightynimble." . 
			\ <SID>MakeEscape( <SID>StrPad( each_label, " ", 50 ) . search_for ) .
			\ " :call <SID>PopupChosen(" . ( counter + 1 ) . ")<CR>"

		execute to_execute
		let counter += 1
		let there_is_a_menu = v:true		
	endfor

	if there_is_a_menu == v:true
		popup mightynimble
	else
		echo "Not showing this empty content -> " . b:marks->join("//")
	endif

endfunction

"\PopupChosen
func! <SID>PopupChosen( index )
			
	let item = b:marks[a:index]
	echo item
	call <SID>MakeSearchNoEscape( item, "sw" )
	let removed = remove(b:marks, a:index - 1, a:index ) 

	let len_removed = len( removed )

	for a in range( len_removed )
		call insert( b:marks, removed[ len_removed - 1 - a ] )
	endfor

	normal zz

	call <SID>WriteToFile( b:marks, <SID>GetThisFilePopupMark() )
	
endfunction



function! <SID>LocalCDAtThisLine()

	let to_lcd = getline(".")
	execute "lcd " . to_lcd
	echo "Current lcd is now " . to_lcd

endfunction

function! <SID>LocalCDAtFirstRoof()

	let to_lcd = <SID>GetRoofDir()
	execute "lcd " . to_lcd
	echo "Current lcd is now " . to_lcd

endfunction

function! <SID>GetRoofDir()

	let line_base = search('^\(\s\|\t\)*\cwe\s*are\s*here\s*:', "bnW")
	if line_base == 0
		let dir = getcwd()
		echo "The \"We are here:\" to set base dir was not found, using: " . dir
	else
		let dir = getline( line_base + 1 )
	endif

	return dir

endfunction

function! <SID>AddBufferAtThisLine( )

	let this_line = getline(".")
	
	let dir = <SID>GetRoofDir()

	let built = trim( dir . this_line )

	if len( trim( this_line ) ) == 0
		echo "Cannot args " . built 
		return
	endif

	let pattern = '\(\s\|\t\)*+\(/\|\d\).\{-}\s\+'
	let pattern_prefix = matchstr( built, pattern )	
	let remove_pattern_prefix = substitute( built, pattern, "", "")
	let built = remove_pattern_prefix

	let space = match( built, '[[:space:]]' )
	if space > -1
		echo "Cannot args " . built . ", there is a [[:space:]]"
		return
	endif

	echon "argadd this: " . built 

	argglobal
	if argc() > 0
		argd *
	endif
	execute "argadd " . built
	let first_file = argv()[0]
	let to_execute = "buffer " . pattern_prefix . first_file 
	"echo to_execute
	try
		execute to_execute 
	catch
		echo "Could not " .  to_execute . ", because: " . v:exception . 
				\ ", so trying to just buffer the asked file " . first_file
	endtry
	arglocal

endfunction


function! <SID>MakeSearchNoEscape( matter, search_flags )

	call search( a:matter, a:search_flags )
	
endfunction

function! <SID>StampThisTypeToStatusLine()
	let w:stamp_name = <SID>ShowType()
endfunction

function! <SID>getStamp()
	if exists("w:stamp_name")
		return w:stamp_name
	endif
	return ""
endfunction

"\MakeEscape
func! <SID>MakeEscape(matter)

	return escape
		\(
			\a:matter, 
			\'\" .'
		\)

endfunction

function! <SID>AfterRuntimeAndDo( what )
	
	let l:this_file = expand("%:t") 
	echo "Calling " . a:what . ", with already runtimed Dan.vim expected"
	"This below would give an error, the one that cannot redefine a function while it is being called
	let l:Function = function( "<SID>" . a:what )	
	call l:Function()

endfunction

"\MakeMappings
function! <SID>MakeMappings() "\Sample of a mark

"	Avoid clearing other mappings beyond this function
"	echo "Maps will be cleared now"
"	mapclear
"	imapclear
	mapclear <buffer>
	imapclear <buffer>
	
"	Avoiding insert/replace toggle
	inoremap <Insert> <Esc>a

"	Easing autocomplete
	imap jj <C-X><C-N>
	imap jn <C-X><C-N>
	imap jk <C-X><C-K>
	imap jv <C-X><C-V>
	imap jf <C-X><C-F>

"   Window Navigation
	map <C-Up> <C-W>k<C-W>_
	map <C-Down> <C-W>j<C-W>_
	map <C-Left> <C-W>h<C-W><Bar>
	map <C-Right> <C-W>l<C-W><Bar>
	imap <C-Up> <Esc><C-W>k<C-W>_i
	imap <C-Down> <Esc><C-W>j<C-W>_i
	imap <C-Left> <Esc><C-W>h<C-W><Bar>i
	imap <C-Right> <Esc><C-W>l<C-W><Bar>i
	
"	imap <S-C-Left> <Esc><C-W>hi
"	imap <S-C-Right> <C-W>li


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
	map ;;g :runtime Dan.vim <Bar> :call <SID>AfterRuntimeAndDo( "StartUp" )<CR>
	map ;ma :runtime Dan.vim <Bar> :call <SID>AfterRuntimeAndDo( "MakeAbbreviations" )<CR>
	map ;mm :runtime Dan.vim <Bar> :call <SID>AfterRuntimeAndDo( "MakeMappings" )<CR>
	map ;mt :runtime Dan.vim <Bar> :call <SID>AfterRuntimeAndDo( "Sets" )<CR>
	map ;mh :runtime Dan.vim <Bar> :call <SID>AfterRuntimeAndDo( "HiLight" )<CR>
	map ;mc :runtime Dan.vim <Bar> :call <SID>AfterRuntimeAndDo( "AutoCommands" )<CR>

"	map ;ms :call <SID>SaveMark()<CR>

"	Easy save
	imap 	<S-Up> <Esc>:wa<CR>
	map 	<S-Up> :wa<CR>

"	ChangeList
	map { g;
	map } g,
	

"	Fast moving
"	map <S-Down> 	:<C-U>call <SID>CommitToMark()<CR>
"	map <S-Left>	:call <SID>SlideThroughMarks("left")<CR>
"	map <S-Right>	:call <SID>SlideThroughMarks("right")<CR>

	map <C-S-Left>	:previous<CR>
	map <C-S-Right>	:next<CR>
	inoremap jh 	<Esc>:call <SID>PopupMarksShow()<CR>a

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
	map ;em :call <SID>EditMarksFile()<CR>
	map <S-Left> :call <SID>PopupMarksShow()<CR>
	map <S-Right> :call <SID>PopupBuffers()<CR>
	map <S-Down> :call <SID>PopupJumps()<CR>
	map <S-Home> :call <SID>ShortcutToNthPertinentJump( 1 )<CR>
	map <S-End> :call <SID>ShortcutToNthPertinentJump( 2 )<CR>
	map [ :call <SID>ViInitialWorkspace()<CR>
	map ] :call <SID>CycleLastTwoExcluded()<CR>
	map B :bu<Space>
	map E :e<CR>
	map V EG
	map <Space> :call <SID>AddBufferAtThisLine()<CR>
	map ;hi :call <SID>HiLight()<CR>
	map ;hn :new<CR><C-W>_
	map ;ju :jumps<CR>
	map ;hs :split<CR><C-W>_
	map ;ks :keepjumps /
	map ;l :lcd 
	map ;u :call <SID>LocalCDAtFirstRoof()<CR>
	map ;pw :pwd<CR>
	map ;pt :call <SID>GetThisFilePopupMark()<CR>
	map ;q :quit<CR><C-W>_
	map ;r :reg<CR>
	map ;sm :marks<CR>
	map ;std :call <SID>StampThisTypeToStatusLine()<CR>
	map ;stc :try <Bar> unlet w:stamp_name <Bar> catch <Bar> echo "Already unstamped" <Bar> endtry<CR>
	map ;, :tabm0<CR>
	map ;t :tabnew<CR>
	map ;vn :vertical new<CR><C-W>\|
	map ;vs :vertical split<CR><C-W>\|
	map ;so :call <SID>SourceCurrent_ifVim()<CR>
	map ;sc :call <SID>ShowMeColors()<CR>
	noremap <expr> ;i ":vi " . getcwd() . "/"
	noremap <expr> ;I ":vi " . expand("%")

	echo "Maps done!"

endfunction

function! <SID>ViInitialWorkspace()
	try
		execute "vi" . " " . s:initial_workspace
	catch
		echo "Could not jump to initial workspace, " .
			\ "maybe you need to save first, vim says: " . v:exception
	endtry
endfunction

function! <SID>SetDict()
	let set_dict = 
		\"set dictionary=" . 
		\join(expand(s:base_path . "/GracefulGNU/" . "vim/vim_dictionary/*", 0, 1), ",")
	execute set_dict
endfunction

function! <SID>SourceCurrent_ifVim()
	let l:extension = <SID>ExtractExtension( expand("%") )
	if  l:extension == ".vim"
		let l:this_file = expand( "%" )
		try
			echo "Sourcing " . l:this_file
			execute "source " . l:this_file
		catch
			echo "Could not source, remember that this function" .
					\ " cannot source Dan.vim, " .
					\ "as it will try to redefine an executing function ok? v:exception => " . 
					\ v:exception
		endtry
	else
		echo "Is this a vim script? it is stated as " . l:extension
	endif
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
	
	let purple = 55
	let status_line_background = 237
	let choose_separator_color = 237
	let date_color = 99

	let highlights =
	\[
		\ [ "StatusLine", status_line_background, 213, "NONE" ],
		\ [ "StatusLineNC", status_line_background, 40, "NONE" ],
		\ [ "VertSplit", 16, 16, "NONE" ],
		\ [ "Visual", purple, 207, "NONE" ],
		\ [ "TabLineSel", 235, 189, "NONE" ],
		\ [ "TabLineFill", 240, 189, "NONE" ]
	\]

	colorscheme default

	highlight clear

"	call <SID>ClearHighlights( highlights )
"	highlight Special ctermfg=98
"	highlight PreProc ctermfg=98
"	highlight Comment ctermfg=244

	
	execute "highlight DiaryDivisorDate ctermbg=" . choose_separator_color . " ctermfg=" . date_color
	execute "highlight DiaryDivisor ctermbg=" . choose_separator_color . " ctermfg=" . choose_separator_color
	highlight MyActivities ctermfg=177
	highlight CompanyActivities ctermfg=165
	highlight BeAware ctermfg=219
	highlight SubItemHelpers ctermfg=202
	highlight MyDone ctermfg=46
	highlight MyStarted ctermfg=75
	highlight MyContinue ctermfg=75
	highlight MyContinued ctermfg=87
	
	highligh MyCategory ctermfg=201 ctermbg=234
	highligh MySubCategory ctermfg=198 ctermbg=234
	highligh MySeparator ctermfg=234 ctermbg=234
	highligh Bars ctermfg=99 
	highligh Extension ctermfg=198 
	execute "highligh SameAsExtensionToStatusLine ctermfg=198 ctermbg=" . status_line_background
	highligh WeAreHere ctermfg=63
	highligh Any ctermfg=57
	highligh Dirs ctermfg=111
	highligh FileNamePrefix ctermfg=201

	call <SID>MakeMarksPopupHiLight()
"	highlight default Pmenu 
"	highlight default PmenuSel

	for a in highlights
		call <SID>MakeHighlight( get(a, 0), get(a, 1), get(a, 2), get( a, 3 ) )	
	endfor


endfunction

function! <SID>MakeMarksPopupHiLight()
	highlight Pmenu ctermbg=24 ctermfg=214
	highlight PmenuSel ctermbg=red ctermfg=24
endfunction

function! <SID>MakeBuffersPopupHiLight()
	highlight Pmenu ctermbg=8 ctermfg=213
	highlight PmenuSel ctermbg=black ctermfg=213
endfunction

function! <SID>MakeHighlight( highlight, ctermbg, ctermfg, cterm )
	execute "highlight " . a:highlight . " ctermbg=" . a:ctermbg . " ctermfg=" . a:ctermfg . " cterm=" . a:cterm
endfunction

function! <SID>ClearHighlights( list )

	for a in a:list
		execute "highlight clear " . get( a , 0 )
	endfor

endfunction

function! <SID>ShowMeColors()

	let counter = 0xFF 

	for a in range( counter ) 

		let inverse = counter - a
		execute "highlight MyHighlight" .
					\ " ctermfg=" . ( "white" ) . 
					\ " ctermbg=" . a

		echohl MyHighlight
		echo "ctermbg:" . a . ",  Hello how are you?"
		echohl None
	endfor

endfunction

function! <SID>MakeAbbreviations()
	"Some iabs here
	iabc
	iabc <buffer>
	iab ht <Esc>:call <SID>MakeHTML()<CR>i
endfunction

function! <SID>CopyRegisterToFileAndClipboard(register)

	execute "let tmp = @" . a:register
	let escaped = shellescape(tmp, 1)
	silent execute "!echo " . escaped  . " | dd of=" . s:bridge_file
"	silent execute "!echo " . escaped  . " | xclip -selection clipboard"
	execute "!echo " . escaped  . " | wl-copy"
	redraw!

endfunction

function! <SID>SayHello( msg )

	call popup_create
		\(
			\ a:msg,
			\ #{
				\ time: 15000,
				\ line:6,
				\ highlight: "Extension",
				\ padding: [ 2, 2, 1, 2 ],
				\ border: [ 0, 0, 1, 0],
				\ borderchars: ["_", "", "_", ""]
			\ }
		\)

endfunction

function! PopupCreate()
	"
endfunction


let s:bridge_file = "/tmp/bridge"
let s:tail_file = '[._[:alnum:]-]\+$'
let s:workspaces_pattern = '\.workspaces$'
let s:exclude_from_jbufs = [ s:workspaces_pattern, '\.shortcuts' ]
let s:initial_workspace = "~/git/MyStuff/vim/workspaces/all.workspaces"

echo "Dan.vim has just been loaded"

if exists("s:this_has_been_loaded") == v:false
	let s:this_has_been_loaded = v:true
	echo "As its the first time for this instance, then we call StartUp"
	call <SID>StartUp()
	call <SID>SayHello(["Hello are you good?", "What are you up to today?", "Great!"])
"	call <SID>SayHello("Hello!")
endif


"Parked code from here below on, that have not been used lately, superseeded
"********************************************************************************************************************************************

" Acceptable to mark
let s:acceptable_to_mark = 
\[
	\'\(\(\s\|\t\)*\)\@<=\\\([-[:alnum:]_.,?!]\+[[:space:]]\{,2}\)\{1,}'
\]

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

"function! <SID>BoosterNavigation()
"	call <SID>WrapperOfStatusLine()
"endfunction 

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











