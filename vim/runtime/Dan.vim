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

	return 	trim( matchstr(a:from, s:file_extension ) )

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

"	au! BufRead *
"	au! filetypedetect BufRead *

	autocmd mine BufReadPost * normal g'"zz

	autocmd mine BufRead *.yaml set expandtab | set tabstop=2
	
	autocmd mine BufRead * call <SID>SetDict( expand("<afile>") )
	
	autocmd mine CompleteDonePre * call <SID>InsMenuSelected()

endfunction

function! <SID>StudyAu( event )

	if ! exists("b:menu")
		let b:menu = []
	endif

	call add( b:menu, a:event )

endfunction


function! <SID>InsMenuSelected()

" 	Turn on verbose to help, set verbose=9

	if complete_info()["mode"] =~ "^dictionary$"  
		set iskeyword&
		set iskeyword+=-
	endif

endfunction


"\Sets
function! <SID>Sets()
	set autoindent	
	set smartindent
	set title
	set tabstop=4	
	set shiftwidth=0 "So takes the value of 'ts'
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
	set winheight=999
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

	call <SID>Sets()	
	call <SID>AutoCommands()
	call <SID>HiLight()
	call <SID>MakeAbbreviations()
	call <SID>MakeMappings()
"	call <SID>SetDict()
	echo "StartUp has been called"

endfunction

function! <SID>WriteToFile( content, file )

	if a:file == v:false
		return
	endif

	try
		return writefile( a:content, a:file )
	catch
		echo "Could not write to file, " . a:file . ", " . v:exception
		return 
	endtry
endfunction

function! <SID>ReadFromFile( file, create )

	if a:file == v:false
		return []
	endif

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

function! <SID>IsMatchedWithStamp( matter )

	if ! exists("w:stamp_name")
		return 1
	endif

	if w:stamp_name != <SID>ExtractExtension( a:matter )
		return -1
	endif

	return 0

endfunction

function! <SID>IsMatchedWithExcludeFromTraditionalJBufs( matter )

	let matches = [ 0, -1 ]
	let counter = 0

	for check in s:exclude_from_jbufs

		let matched = match( a:matter, check )
		if matched > - 1 
			let	matches[ 0 ] = 1
			let	matches[ 1 ] = counter
			break
		endif

		let counter += 1

	endfor

	retur matches

endfunction


function! <SID>TraditionalPertinentJumps( bufinfo )

	return <SID>IsMatchedWithExcludeFromTraditionalJBufs( a:bufinfo["name"] )[ 0 ] > 0 ||
				\ <SID>IsMatchedWithStamp( a:bufinfo["name"] ) < 0

endfunction

function! <SID>WorkspacesPertinentJumps( bufinfo )

	return ! ( <SID>IsMatchedWithExcludeFromTraditionalJBufs( a:bufinfo["name"] )[ 1 ] == 0 )

endfunction

function! <SID>CollectPertinentJumps( limit, what_is_pertinent )

	let do_not_repeat = [ bufnr() ]
	let jumps = getjumplist()[0]
	let length = len( jumps ) - 1
	let i = length
	let jumps_togo = []

	while i >= 0

		let jump = get( jumps, i )
		let bufnr = jump["bufnr"]
		let buf = getbufinfo( bufnr )
		
		if len( buf ) == 0
			let i -= 1
			continue			
		endif

		let bufinfo = buf[0]

		if
		\(
				\ count( do_not_repeat, bufnr ) > 0 ||
				\ bufnr == 0 || 
				\ len( bufinfo["name"] ) == 0 ||
				\ <SID>{a:what_is_pertinent}PertinentJumps( bufinfo ) == v:true
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

	let jumps = <SID>CollectPertinentJumps( -1, "Traditional" )

	for jump in jumps

		execute "nmenu jumps." . <SID>MakeEscape( <SID>MakeJump( jump ) ) . " " . 
			\ ":wa <Bar> try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 

	endfor

	if len( jumps ) > 0
		popup jumps
	else
		echo "No jumps to fill the list popup"
	endif

endfunction

function! <SID>PopupWorkspaces( )
	
	try
		nunme workspaces
	catch
	endtry

	let jumps = <SID>CollectPertinentJumps( -1, "Workspaces" )

	for jump in jumps

		execute "nmenu workspaces." . <SID>MakeEscape( <SID>MakeJump( jump ) ) . " " . 
			\ ":wa <Bar> try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 

	endfor

	if len( jumps ) > 0
		popup workspaces
	else
		echo "No workspaces to fill popup"
	endif

endfunction

function! <SID>ShortcutToNthPertinentJump( nth, filter )

	let jumps = <SID>CollectPertinentJumps( a:nth, a:filter )
	let jump = get( jumps, a:nth - 1, {} )
	if jump == {} 
		echo "JBufs did not reach length of " . a:nth
		return
	endif

	execute "try | wa | buffer " . jump["bufnr"] . 
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
			\ " :wa <Bar> buffer" . get(buffer, "bufnr")  . "<CR>"
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

	try
		let file = expand( s:popup_marks_dir ) . expand("%:t") . ".vim.shortcut"
		echo "GetThisFilePopupMark: " . file
		return file 
	catch
		echo "Could not reach file, " . v:exception
	endtry

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
				\ v:false 
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

	let current_dir = getcwd() . "/"
	let line_base = search( s:we_are_here, "bnW")
	if line_base == 0
		let dir = current_dir 
		echo "The '" . s:we_are_here . "' to set base dir was not found, using: " . dir
	else
		let dir = getline( line_base + 1 )
	endif

	if match( dir, '/$' ) < 0
		echo dir . " does not seem to be a valid dir, remember to finish with a \"/\" ok?"
				\ "By now current dir(". current_dir .") is being used"
		return current_dir 
	endif

	return trim( dir ) 

endfunction

function! <SID>SearchOrAddBufferAtThisLine( )
	
	let should_search = match
	\ ( 
		\ getline( line(".") - 1 ),
		\ s:search_by_basic_regex 
	\ )

	if should_search < 0
		call <SID>AddBufferAtThisLine( )
	else
		call <SID>ItsASearch(  )
	endif

endfunction

function! <SID>ItsASearch( )

	let this_line = getline(".")
	let roof = expand( <SID>GetRoofDir() )
	let build_find = 
			\ "find " 
			\ . roof . 
			\ " | grep " . this_line

	echo build_find

	let files = systemlist( build_find ) 
	let b:search_result = []
	for a in files
		call add( b:search_result, substitute( a, roof, "", "" ) )
	endfor


	if len( files ) > s:max_file_search
		echo "Result for " . this_line . 
				\ " has gone through the limit of " . s:max_file_search .
				\ " please tune your search better"
		return
	endif

	call <SID>BuildSearchMenu( this_line, roof )
	

endfunction

function! <SID>BuildSearchMenu( is_searching, where )
	
	try
		nunme searchfilesmenu 
	catch
	endtry

	for search_file in b:search_result

		let prefix = "(N)"
		let has_already_been_stamped = search( search_file, "wn")
		if has_already_been_stamped > 0
			let prefix = "(A:" . has_already_been_stamped . ")"
		endif

		let to_execute = 
			\ "nmenu <silent> searchfilesmenu." . <SID>MakeEscape( prefix . search_file ) . " " . 
			\ ":try <Bar> call <SID>SearchFileAction(\"" . search_file . "\", \"" . prefix . "\") <Bar> " .
			\ "catch <Bar> echo \"Could not stamp file\" . v:exception <Bar> endtry<CR>"

		execute to_execute

	endfor

	if len( b:search_result ) > 0
		popup searchfilesmenu
	else
		echo "The search to " . a:is_searching . " in the folder: " . a:where . ","
				\ "did not return any elligible files"
	endif

endfunction

function! <SID>SearchFileAction( filename_to_stamp, prefix )

	if match( a:prefix, '.a:\c') > -1
		let line = matchstr( a:prefix, '\d\+')
		execute "normal gg" . ( line - 1 ) . "jzz"
	else
		let @" = a:filename_to_stamp . "\n"
		echo a:filename_to_stamp . " has copied to @\", just p in normal mode to paste"
"		call setline(".", a:filename_to_stamp)
	endif

endfunction


function! <SID>AddBufferAtThisLine( )

	let this_line = trim( getline(".") )
	
	let dir = <SID>GetRoofDir()

	let built = dir . this_line

	if len( trim( this_line ) ) == 0
		echo "Cannot args an empty line with the roof " . dir
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
	wa
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

	let w:stamp_name = <SID>ExtractExtension( @% )

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

function! <SID>OpenWorkspace()

	let files_to_buffer = <SID>WorkspacesFilesToBuffer()

	if files_to_buffer == {}
		return
	endif
	

	let already_stamped = []
	let non_stamped = []

	for a in range( 1, winnr("$") )

		let this_window_cur_buffer = getbufinfo( winbufnr( a ) )[ 0 ]
		if this_window_cur_buffer[ "changed" ] == 1

			echo "Please save buf " . this_window_cur_buffer["bufnr"] . ", " .
					\ matchstr( this_window_cur_buffer[ "name" ], s:tail_file ) . 
					\ ", before trying to open " .
					\ " the \n{ \n\tembraced files \n}"
			return
		endif

		let stamp = getwinvar( a, "stamp_name", -1)
		if  stamp > -1
			call add( already_stamped, [ a, win_getid( a ), stamp ] )
		else
			call add( non_stamped, [ a, win_getid( a ) ] )
		endif
	endfor


	for a in already_stamped

		let keys_files_to_buffer = keys( files_to_buffer ) 

		for b in keys_files_to_buffer 

			let files = files_to_buffer[ b ]
			if b == a[ 2 ]
				call win_gotoid( a[ 1 ] )
				for c in files
					execute "vi " . c
				endfor
				call remove( files_to_buffer, b )
				break
			endif

		endfor

	endfor
	

	for a in non_stamped

		let files_groups = keys( files_to_buffer )

		if len( files_groups ) == 0
			break
		endif

		let a_key_group = files_groups[ 0 ]

		let files = files_to_buffer[ a_key_group ]
		call win_gotoid( a[ 1 ] )
		for c in files
			execute "vi " . c
		endfor

		call remove( files_to_buffer, a_key_group )

		call <SID>StampThisTypeToStatusLine()

	endfor
	
	let keys_files_to_buffer = keys( files_to_buffer ) 

	for b in keys_files_to_buffer
		let files = files_to_buffer[ b ]
		split
		for c in files
			execute "vi " . c
		endfor
		call <SID>StampThisTypeToStatusLine()
	endfor

"No need as winheight is set to 999 and winminheight to 0
"	wincmd _

endfunction

function! <SID>WorkspacesFilesToBuffer()

	let this_file = expand("%")
	let is_workspace = match( this_file, s:workspaces_pattern ) 
	if is_workspace < 0
		echo "We are not in a workspace file " . s:workspaces_pattern
			return {}
	endif

	let this_line = line(".")
	let files = {}
	call cursor(1, 1)
	let last_line = line("$")
	let curly_groups_found = 0

	while 1

		let open = search( '^{', "W" )

		if open == 0
			echo "Opened " . curly_groups_found . " curly groups of files"
			break
		endif

		let curly_groups_found += 1
		
		let roof = <SID>GetRoofDir()

		let content_line_number = open + 1
		let content_line_content = getline( content_line_number )

		while 1

			if
				\ match( content_line_content, '^}' ) >= 0 ||
				\ content_line_number > last_line
				break
			endif

			let ext = <SID>ExtractExtension( content_line_content )

			if len( ext ) == 0
				let ext = ".ext.less"
			endif

			if 
				\ match( ext, s:workspaces_pattern ) > -1 ||
				\ len( trim( content_line_content  )  ) == 0

					let content_line_number += 1
					let content_line_content = getline( content_line_number )
					continue
			endif

			if ! exists( "files[ ext ]" )
				let files[ ext ] = []
			endif

			call add( files[ ext ], roof . trim( content_line_content ) )
			
			let content_line_number += 1
			let content_line_content = getline( content_line_number )


		endwhile
	endwhile

	return files

endfunction

function! <SID>MoveTo( direction )

	let this_win = winnr()
	let last_win = winnr("$")


	if ( a:direction =~ "^up$" )
		if this_win > 1
			wincmd k
		else
			wincmd b
		endif
	else
		if this_win < last_win
			wincmd j
		else
			wincmd t
		endif
	endif

" As winheight is 999, the option below is not necessary
"	wincmd _

endfunction

function! <SID>AfterRuntimeAndDo( what )
	
	let l:this_file = expand("%:t") 
	echo "Calling " . a:what . ", with already runtimed Dan.vim expected"
	"This below would give an error, the one that cannot redefine a function while it is being called
	let l:Function = function( "<SID>" . a:what )	
	call l:Function()

endfunction

function! s:AFunction()
	echo "Hello"
endfunction

function! <SID>SharpSplits( JK )

	split
	execute "wincmd " . a:JK
	call <SID>ShortcutToNthPertinentJump( 1, "Workspaces" )

endfunction

"\MakeMappings
function! <SID>MakeMappings() "\Sample of a mark

"	Avoid clearing other mappings beyond this function
"	echo "Maps will be cleared now"
"	mapclear
"	imapclear
	mapclear <buffer>
	imapclear <buffer>

"	map ;L :call <SID>Afunction()<CR>
	
"	Avoiding insert/replace toggle
	inoremap <Insert> <Esc>a

"	Easing autocomplete
	imap jj <C-X><C-N>
	imap jn <C-X><C-N>
"	iskeyword is put back at AutoCommand
	imap jp <Esc>:set iskeyword=21-125<CR>a<C-X><C-K>
	imap jk <C-X><C-K>
	imap jv <C-X><C-V>
	imap jf <Esc>:call <SID>LocalCDAtFirstRoof()<CR>a<C-X><C-F>

"   Window Navigation
	map <silent> <C-Up> :call <SID>MoveTo("up")<CR>
	map <silent> <C-Down> :call <SID>MoveTo("down")<CR>
	map <C-Left> <C-W>h
	map <C-Right> <C-W>l
	imap <silent> <C-Up> <Esc>:call <SID>MoveTo("up")<CR>a
	imap <silent> <C-Down> <Esc>:call <SID>MoveTo("down")<CR>a
	imap <C-Left> <Esc><C-W>hi
	imap <C-Right> <Esc><C-W>li

"	Buffer Navigation
	map <S-Tab> :up <Bar> :e#<CR>

	map <Bar> :bprevious<CR>
	map Z :bnext<CR>
	map <Del> :echo "Please use \"x\" or \"X\" instead of <Del\>"<CR>


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
	map <C-S-Down> :call <SID>PopupWorkspaces()<CR>

	map <S-Home> :call <SID>ShortcutToNthPertinentJump( 1, "Traditional" )<CR>
	map <S-End> :call <SID>ShortcutToNthPertinentJump( 2, "Traditional" )<CR>
	map <S-PageUp> :call <SID>ShortcutToNthPertinentJump( 3, "Traditional" )<CR>
	map <S-PageDown> :call <SID>ShortcutToNthPertinentJump( 4, "Traditional" )<CR>

	map <C-S-Home> :call <SID>ShortcutToNthPertinentJump( 1, "Workspaces" )<CR>
	map <C-S-End> :call <SID>ShortcutToNthPertinentJump( 2, "Workspaces" )<CR>
	map <C-S-PageUp> :call <SID>ShortcutToNthPertinentJump( 3, "Workspaces" )<CR>
	map <C-S-PageDown> :call <SID>ShortcutToNthPertinentJump( 4, "Workspaces" )<CR>

	map <C-S-kDel> :call <SID>ViInitialWorkspace()<CR>

"	map ] :call <SID>CycleLastTwoExcluded()<CR>
	
	map ;J :call <SID>SharpSplits("J")<CR>
	map ;K :call <SID>SharpSplits("K")<CR>

	map B :bu<Space>
	map E :e<CR>
	map V EG

	map P :set paste! <Bar> 
			\ if &paste == 0 <Bar> echo "Paste mode is OFF" 
			\ <Bar> else <Bar> echo "Paste mode is ON" <Bar> endif <CR>

	map <Space> :call <SID>SearchOrAddBufferAtThisLine()<CR>
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
	map ;t :tabnew \| clearjumps \| call <SID>ViInitialWorkspace()<CR>
	map ;vn :vertical new<CR><C-W>\|
	map ;vs :vertical split<CR><C-W>\|
	map ;so :call <SID>SourceCurrent_ifVim()<CR>
	map ;sc :call <SID>ShowMeColors()<CR>
	map ;o :call <SID>OpenWorkspace()<CR>
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

function! <SID>SetDict( file )

	let potential_dicts = expand
			\ ( s:base_path . "/vim/vim_dictionary/*", 1, 1)

	let selected = []
	let this_type = matchstr( a:file, s:file_extension )

	if len( this_type ) == 0
"		echo "len(this_type) empty"
		return
	endif

	for a in potential_dicts
		let type = matchstr( a, s:tail_file )		
		if match( type, this_type ) >= 0
			call add( selected, a )
		endif
	endfor

"	echo selected

	execute "setlocal dictionary=" . join( selected, "," )

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
	execute "highlight CallingAttention ctermbg=" . choose_separator_color . " ctermfg=197"
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
"	highligh WeAreHere ctermfg=63
	highligh WeAreHere ctermfg=39
	highligh link SearchFromInside WeAreHere
	highligh Regex ctermfg=196
	highligh RegexWithIn ctermfg=141
	highligh Any ctermfg=57
	highligh Dirs ctermfg=111
	highligh FileNamePrefix ctermfg=201

"	highligh link WorkspacesMetaData FileNamePrefix
"	highligh link WorkspacesMetaDataEnclosure Any 
"	highligh link WorkspacesMetaDataContainer FileNamePrefix
"	highligh link WorkspacesCurlyBraces Extension

	highligh WorkspacesMetaDataEnclosure ctermfg=45
	highligh WorkspacesMetaDataContainer ctermfg=81 
	highligh WorkspacesMetaData ctermfg=84
	highligh WorkspacesCurlyBraces ctermfg=45

"	highlight! link Comment Extension

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


let s:base_path = expand("~") . "/git/GracefulGNU/" 
let s:bridge_file = "/tmp/bridge"
let s:tail_file = '[._[:alnum:]-]\+$'
let s:file_extension = '\.[^./\\]\+$'
let s:workspaces_pattern = '\.workspaces$'
" The order of the array contents below matters
let s:exclude_from_jbufs = [ s:workspaces_pattern, '\.shortcut$' ]
let s:initial_workspace = "~/git/MyStuff/vim/workspaces/all.workspaces"
let s:max_file_search = 36
let s:we_are_here = '^\[\(we.are.here\|base\)\]'
let s:search_by_basic_regex = '^\[search\]'

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











