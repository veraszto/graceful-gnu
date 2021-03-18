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
	return "%m%#SameAsExtensionToStatusLine#%n%*)%#SameAsExtensionToStatusLine#%F%*" . 
		\ " / %#SameAsExtensionToStatusLine#%{". s:GetSNR() ."getStamp()}%*%=(%c/%l/%L) byte:%B, %b"
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

"	autocmd mine BufRead *.workspaces iabc 

	autocmd mine BufRead *.yaml set expandtab | set tabstop=2
	
	autocmd mine BufRead * call <SID>SetDict( )
	
	autocmd mine CompleteDonePre * call <SID>InsMenuSelected()

	call <SID>AutoCommandsOverlay( 0 ) 

endfunction

function! <SID>AutoCommandsOverlay( wipe )

	aug my_overlays
		au!
	aug END

	if a:wipe == v:true
		return
	endif

	autocmd my_overlays BufEnter *
		\ call <SID>RefreshingOverlays( 0 )
"	autocmd my_overlays WinEnter *
"		\ call <SID>RefreshingOverlays( 0 )

endfunction

function! <SID>TurnOnOffOverlays( on_off )

	if a:on_off == 0

		let this_tabnr = tabpagenr()

		call <SID>AutoCommandsOverlay( 1 )
		tabdo call popup_clear()
		let s:popup_winids = {}

		execute "normal" . " " . this_tabnr . "gt"

		echo "Overlays are turned OFF"

	else

		call <SID>AutoCommandsOverlay( 0 )
		let s:overlay_allowed_to_show = v:true
		call <SID>RefreshingOverlays( 0 )
		echo "Overlays are turned ON"
	endif

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

	set updatecount=0
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
	set shortmess+=A
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
	$tabnew | $tabnew | tabfirst

endfunction

function! <SID>WriteToFile( content, file )

	try
		return writefile( a:content, a:file )
	catch
		echo "Could not write to file, " . a:file . ", " . v:exception
		return 
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

	let jumps = <SID>ChooseBestPlaceToGetJumps( -1, "Traditional" )

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

function! <SID>ChooseBestPlaceToGetJumps( limit, type )

	return <SID>CollectPertinentJumps( a:limit, a:type )

	let name = <SID>BuildOverlayNameArray( a:type )

	let popup_exists = <SID>PopupExists( name )

	if len( popup_exists ) == 0
		return <SID>CollectPertinentJumps( a:limit, a:type )
	else
		return popup_exists[ 1 ]
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

	let jumps = <SID>ChooseBestPlaceToGetJumps( a:nth, a:filter )
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

"	let built =  "b:" .
"		\ <SID>StrPad( a:jump["bufnr"], " ", 4 ) . 
"		\ matchstr( bufname( a:jump["bufnr"] ), s:tail_file ) .
"		\ getbufvar( a:jump["bufnr"], "jBufs_overlay_amend" )
"	return built

	let bufname = bufname( a:jump["bufnr"] )

	let tailed = matchstr( bufname , s:tail_with_upto_two_dirs )
	
	if len( tailed ) == 0
		let tailed = "(?)" . bufname
	endif

	if isdirectory( bufname )
		let hold = tailed
		let tailed  = "(DIR)" . hold
	endif

	let cwd = getcwd()

	if ( ( cwd . "/" . tailed ) == ( cwd . "/" . bufname ) )
		let hold = "@ " . tailed
		let tailed = hold
	endif


	return  tailed .
		\ getbufvar( a:jump["bufnr"], "jBufs_overlay_amend" )

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

	if ! exists( "s:popup_marks_dir" )
		echo "Please define s:popup_marks_dir, like s:popup_marks_dir=~/.vim/popup_marks"
		return 
	endif

	let to_expand = s:popup_marks_dir . "/" . expand("%:t") . ".vim.shortcut"

	try
		let file = expand( to_expand )
		echo "GetThisFilePopupMark: " . file
		return file 
	catch
		echo "Could not reach file, " . to_expand . ", " . v:exception
	endtry

endfunction

function! <SID>EditMarksFile()

	let file_popup = <SID>GetThisFilePopupMark()
	if file_popup == v:false
		return
	endif
	execute "vi " . file_popup

endfunction

func! <SID>PopupMarksShow()

	if !exists("b:marks")

		let popup_file = <SID>GetThisFilePopupMark()

		if popup_file == v:false
			return
		endif

		let b:marks = 
			\ <SID>ReadFromFile
			\ ( 
				\ popup_file, 
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

	let popup_file = <SID>GetThisFilePopupMark()

	if popup_file == v:false
		return
	endif

	call <SID>WriteToFile( b:marks, popup_file )
	
endfunction



function! <SID>LocalCDAtThisFile()

	let to_lcd = expand("%:h")
	execute "lcd " . to_lcd
	echo "Current lcd is now " . to_lcd

endfunction

function! <SID>LocalCDAtFirstRoof()

	let to_lcd = <SID>GetRoofDir()

	if to_lcd < 0
		return
	endif

	execute "lcd " . to_lcd
	echo "Current lcd is now " . to_lcd

endfunction

function! <SID>GetRoofDir()

	let current_dir = getcwd()
	let line_base = search( s:we_are_here, "bnW")
	if line_base == 0
		let dir = current_dir 
		echo "The '" . s:we_are_here . "' to set base dir was not found, using: " . dir
	else
		let dir = trim( getline( line_base + 1 ) )
	endif

	let expanded = expand( dir )
	if isdirectory(  expanded )
		return expanded . "/"
	endif

	redraw | echo dir . " is not a directory, please checkout your [we are here] referenced dir"
	
	return -1

endfunction

function! <SID>GoAfterAWorkSpace()

	let counter = winnr("$")

	while counter > 0
		
		let buf_name = bufname( winbufnr( counter ) )
		if match( buf_name, s:workspaces_pattern ) > -1
			execute counter . "wincmd w"
			return
		endif
		let counter -= 1

	endwhile

	split
	wincmd J
	call <SID>ShortcutToNthPertinentJump(1, "Workspaces")

"	echo "An active workspace buffer is currently no present at this tab"

endfunction

function! <SID>SpacebarActionAtWorkspaces( )

	if match( buffer_name(), s:workspaces_pattern ) < 0
		call <SID>GoAfterAWorkSpace()
		return
	endif

	let line_number = line(".")
	let this_line_content_raw = getline( line_number )
	let this_line_content = trim( this_line_content_raw )

	if ( len( this_line_content ) <= 0 )
		echo "Line empty"
		return
	endif

	let line_above = getline( line_number - 1 )
	let msg = line_above

	let build_func_name = matchstr( line_above, '\(\[\)\@<=.\+\(\]\)\@=' )

	if len( build_func_name ) <= 0
		call <SID>SpaceBarAction( line_number, this_line_content_raw )
		return
	endif

	let func_name = 
			\ expand("<SID>") . "SpaceBarAction_" . 
			\ substitute( tolower(build_func_name), '\s', "", "g")

	if ! exists( "*" . func_name )
		echo "There is not an action regarding " . build_func_name
		return
	endif

	let Func = function(func_name)

	call Func( line_number, this_line_content ) 

endfunction

function! <SID>SpaceBarAction_maketree( line_number, line )

	let toTree = "tree " . a:line . " " . <SID>GetRoofDir()
	let tree = systemlist( toTree )
	call remove( tree, 0 )
	call remove( tree, len( tree ) - 1 )
"	if len( tree ) > 900
"		echo "The tree returned is huge, please refine better using the make tree parameters or scoping [we are here]"
"		return
"	endif
	let append = append( line(".") + 1, tree )
	if append > 0
		echo "Please make room of at least two lines after the [make tree] parameters"
	endif
	
endfunction

function! <SID>SpaceBarAction_search( line_number, line )

	let this_line = a:line
	let roof = expand( <SID>GetRoofDir() )

	if roof < 0
		return
	endif

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


function! <SID>SpecialBu( this_bu )

	let built = a:this_bu

	if len( trim( built ) ) == 0
		echo "Could not SpecialBu an empty file: " . built
		return
	endif


	let 
		\ [
				\ pattern_prefix,
				\ pattern_bufvar_suffix,
				\ pattern_bufvar_suffix_with_error,
				\ filtered_built
		\ ] =
		\ <SID>MatchedAndAllRemoved
		\	( 
				\ built, 
				\ [
						\ s:cmd_buf_pattern,
						\ s:add_as_bufvar,
						\ s:add_as_bufvar_missing_bar
				\ ] 
		\	)

	let built = filtered_built

	if len( pattern_bufvar_suffix_with_error ) > 0
		echo "Please, the hash must be escaped(\\) and adjacent to curly open({), like:" .
			\ "\nfilename.abc__\\#{a:1,b:2, \"hello\": \"Hi!\"}" 
		return
	endif

	let space = match( built, '[[:space:]]' )
	if space > -1
		echo "Cannot args " . built . ", there is a [[:space:]]"
		return
	endif

	if isdirectory( built )
		echo built . " is a directory, please select a file"
		return
	endif

	echon "argadd this: " . built 

	argglobal

	if argc() > 0
		argd *
	endif
	execute "argadd " . escape( built, '#%' )
	let first_file = argv()[0]
	wa
	let to_execute = "buffer " . pattern_prefix . first_file 
	try
		execute to_execute 
	catch
		echo "Could not " .  to_execute . ", because: " . v:exception . 
				\ ", so trying to just buffer the asked file " . first_file
	endtry

	call <SID>LoadBufferVars( bufnr(),  pattern_bufvar_suffix )

	arglocal

endfunction

function! <SID>MatchedAndAllRemoved( matter, cycle )

	let gather = []
	let hold_matter = a:matter

	for a in a:cycle
		
		call add( gather, matchstr( a:matter, a ) )
		let filtered = substitute( hold_matter, a, "", "" )
		let hold_matter = filtered

	endfor

	call add( gather, filtered )

	return gather

endfunction

function! <SID>SpaceBarAction_wearehere( line_number, line )

	call <SID>LocalCDAtFirstRoof()

endfunction

function! <SID>SpaceBarAction( line_number, line )

	let this_line = a:line
	let dir = <SID>GetRoofDir()

	if dir < 0
		return
	endif

	let tree_prefix = matchstr( this_line, s:tree_special_chars )
	let len_tree_prefix = strchars( tree_prefix )
	if len_tree_prefix > 0
		call <SID>BuFromGNUTree( a:line_number, a:line, len_tree_prefix, dir )
		return
	endif
	let built = dir . trim( this_line )
	return <SID>SpecialBu( built )

endfunction

function! <SID>BuFromGNUTree( line_number, line, len_tree_prefix, roof_dir )

	let this_level = a:len_tree_prefix
	let counter = 0
	let dirs = []
	while 1

		let going_up = getline( a:line_number - counter)
		let len_level = strchars( matchstr( going_up, s:tree_special_chars ) )
		if len_level <= 0
			echo "Reached tree top"
			break
		endif
"		echo len_level . "|" . this_level . ", " . going_up
		if len_level >= this_level
			let counter += 1
			continue
		else
"			echo len_level
			let this_level = len_level
			let add_dir = substitute( going_up, s:tree_special_chars, "", "gi")
			call add( dirs, add_dir )
		endif

		let counter += 1

	endwhile

	let target_file = substitute( a:line, s:tree_special_chars, "", "gi" )

	let len_dirs = len( dirs )

	if len_dirs == 0
		call <SID>SpecialBu( a:roof_dir .  target_file )
		return
	endif	
	
	let counter = len_dirs - 1

	let wrap = [ a:roof_dir ]

	while counter >= 0
		call add( wrap, get( dirs, counter ))
		let counter -= 1
	endwhile

	call add( wrap, target_file )

	let joined_target = join( wrap, "/" )

	if filereadable( joined_target )
		execute "vi " . joined_target 
	else
		echo joined_target . " not readable"
	endif

endfunction


function! <SID>WriteBasicStructure()

	call append
	\ (
		\ line("."),
		\ [
	 		\ "[we are here]",
			\ expand("~/"),
			\ "",
			\ "[search]",
			\ "-i \"\"",
			\ "",
			\ "[make tree]",
			\ "-x -I node_modules --filelimit 10", "", ""
		\ ]
	\ )

endfunction


function! <SID>LoadBufferVars( bufnr, string_dict )

	if len( a:string_dict ) <= 0
		return
	endif

	let cropped = substitute( a:string_dict, '^...', "", "" )

	try
"		execute "let dict = " . escape( cropped, '"' )
		execute "let dict = " . cropped
	catch
		echo "Could not parse: " . cropped . ", because: " . v:exception .
			\ "\nUsage: filename.abc__\\#{a:1, b:2, \"jBufs_overlay_amend\":\"(Hello)\"}"
		return
	endtry

	for a in keys( dict )
		call setbufvar( a:bufnr, a, dict[ a ] )
	endfor

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

	call <SID>TurnOnOffOverlays( 0 )

	let already_stamped = []
	let non_stamped = []

	for a in range( 1, winnr("$") )

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
					call <SID>SpecialBu( c )
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
			call <SID>SpecialBu( c )
		endfor

		call remove( files_to_buffer, a_key_group )

		call <SID>StampThisTypeToStatusLine()

	endfor
	
	let keys_files_to_buffer = keys( files_to_buffer ) 

	for b in keys_files_to_buffer
		let files = files_to_buffer[ b ]
		split
		for c in files
			call <SID>SpecialBu( c )
		endfor
		call <SID>StampThisTypeToStatusLine()
	endfor

"No need as winheight is set to 999 and winminheight to 0
"	wincmd _

	call <SID>TurnOnOffOverlays( 1 )

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

		if roof < 0
			return {}
		endif

		let content_line_number = open + 1
		let content_line_content = getline( content_line_number )

		while 1

			if
				\ match( content_line_content, '^}' ) >= 0 ||
				\ content_line_number > last_line
				break
			endif

			let [ a, b, filtered ] = 
					\ <SID>MatchedAndAllRemoved
					\ (
							\ content_line_content,
							\ [
									\ s:add_as_bufvar,
									\ s:cmd_buf_pattern
							\ ]
					\ )

			let ext = <SID>ExtractExtension( filtered )

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


function! <SID>CycleTwoLetters( letters )

	let joined_letters = join( a:letters, "")

"	if joined_letters =~ '^\l\{2}'
"		let add_to_joined = joined_letters . "_" . bufnr()
"		let joined_letters = add_to_joined
"	endif

	if ! exists("s:counter_cycle_bufs_" . joined_letters )
		let s:counter_cycle_bufs_{joined_letters} = 0
	endif

	let s:counter_cycle_bufs_{joined_letters} += 1
	let index = s:counter_cycle_bufs_{joined_letters} % len( a:letters )

	let letter = a:letters[ index ]
	
	let pos = getpos( "'" . letter )

	if <SID>MarksAutoCyclingErasing( index, joined_letters, a:letters ) == 1
		return
	endif

	if pos[1] > 0

		if bufnr() != pos[ 0 ] &&
				\ pos[ 0 ] != 0
			try
				wa
				execute "bu " . pos[ 0 ]
			catch
				echo "Could not reach: '" . letter . ", because: " . v:exception
			endtry
		else
			echo "At mark: " . letter
		endif
		normal m'
"		call setpos( ".", pos ) | execute "normal z\<enter>"
		call setpos( ".", pos ) | normal zz
	else
		echo "Marking letter \"" . letter . "\" here: " . getline(".")
		execute "mark " . letter
	endif

	if index >= 36
		unlet s:counter_cycle_bufs_{joined_letters}
	endif

	let s:last_two_letters_cycle = a:letters	

endfunction

function! <SID>MarksAutoCyclingErasing( index, joined_letters, letters )

	if v:count == 0
		return v:false
	endif

	let save_index = a:index 
	let s:counter_cycle_bufs_{a:joined_letters} -= 1
	let prev_index = s:counter_cycle_bufs_{a:joined_letters} % len( a:letters )

	if v:count > 2

		echo "Erasing all"
		for a in s:elligible_auto_global_marks_letters
			execute "delm " . a
			echo "Erased " . a
		endfor
		return 1

	endif

	execute "delmark " . a:letters[ prev_index ]
	echo a:letters[ prev_index ] . " has just been deleted"

	if v:count > 1
		execute "delmark " . a:letters[ save_index ]
		echo a:letters[ save_index ] . " has just been deleted"			
	endif
	return 1


endfunction

function! <SID>WrapperCycleThroughLetters( start, amount )

	let select = []
	for a in range( a:start, a:start + a:amount - 1 )
		call add( select, s:elligible_auto_global_marks_letters[ a ] )
	endfor
	call <SID>CycleTwoLetters( select )

endfunction

function! <SID>RemoveLastTwoLettersCycle()

	if ! exists("s:last_two_letters_cycle")
		echo "There are not marks to remove"
		return
	endif

	let letters = join( s:last_two_letters_cycle, " ")

	echo "Removing " .  letters

	execute "delm " . letters
 
endfunction

function! <SID>MarkNext()

	let counter = 0
	let length = len( s:elligible_auto_cycle_local_marks_letters )
	while 1

		let try_this = s:elligible_auto_cycle_local_marks_letters[ counter % length ]
		let pos = getpos("'" . try_this )
		if pos[1] == 0
			execute "mark " . try_this
			redraw | echo "Marked " . try_this
			break
		endif
		if counter >= length
			echo "All marks are set!"
			break
		endif
		let counter += 1

	endwhile
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


	map <C-S-Left>	:previous<CR>
	map <C-S-Right>	:next<CR>
	inoremap jh 	<Esc>:call <SID>PopupMarksShow()<CR>a

"	Shortcuts

	map ;a :ab<CR>
	map ;bl :ls<CR>
	map ;bu :bu 
	map ;ch :changes<CR>
	map ;cj :clearjumps<CR>
	map ;cp :call <SID>CopyRegisterToFileAndClipboard()<CR>
	map ;< <C-W>H<C-W>\|
	map ;ea :call <SID>RefreshAll()<CR>
	map ;em :call <SID>EditMarksFile()<CR>

	map <S-Left> :call <SID>PopupMarksShow()<CR>
	map <S-Right> :call <SID>PopupBuffers()<CR>
	map <S-Down> :call <SID>PopupJumps()<CR>
"	map <C-S-Down> :call <SID>PopupWorkspaces()<CR>

	map <C-S-Down> <Cmd>call <SID>LocalMarksAutoJumping( 13487, "down" )<CR>
	map <C-S-Up> <Cmd>call <SID>LocalMarksAutoJumping( 9750, "up"  )<CR>


"	for a in range(1, 9)		
"
"		execute "map j" . a . " " . 
"			\ ":call <SID>ShortcutToNthPertinentJump( " . a . ", \"Traditional\" )<CR>"
"		execute "map w" . a . " " . 
"			\ ":call <SID>ShortcutToNthPertinentJump( " . a . ", \"Workspaces\" )<CR>"
"		execute "inoremap j" . a . " " . 
"			\ "<Esc>:call <SID>ShortcutToNthPertinentJump( " . a . ", \"Traditional\" )<CR>"
"		execute "inoremap w" . a . " " . 
"			\ "<Esc>:call <SID>ShortcutToNthPertinentJump( " . a . ", \"Workspaces\" )<CR>"
"
"	endfor

	let types = [ "\"Traditional\"", "\"Workspaces\"" ]

	let keys = 
		\ [
			\ "<S-Home>", "<S-End>", "<S-PageUp>", "<S-PageDown>",
			\ "<C-S-Home>", "<C-S-End>", "<C-S-PageUp>", "<C-S-PageDown>" 
		\ ]


	for a in range(1, 4)
		execute "map " . keys[ a - 1 ] . 
			\ " :call <SID>ShortcutToNthPertinentJump( " . a . ", " . types[ 0 ] . ")<CR>"

		let a_plus_three = a + 3

		execute "map " . keys[ a_plus_three ] . 
			\ " :call <SID>ShortcutToNthPertinentJump( " . ( a_plus_three + 1 ). ", " . types[ 0 ] . ")<CR>"
	endfor

	map <C-S-kDel> :call <SID>ViInitialWorkspace()<CR>
	nmap <Del> :call <SID>ShortcutToNthPertinentJump(1, "Workspaces")<CR>
	map <S-kDel> :call <SID>ShortcutToNthPertinentJump(2, "Workspaces")<CR>

	map <C-Home> <Cmd>call <SID>WrapperCycleThroughLetters( 0, 2 )<CR>
	map <C-End> <Cmd>call <SID>WrapperCycleThroughLetters( 2, 2 )<CR>
	map <C-kDel> <Cmd>call <SID>WrapperCycleThroughLetters( 4, 2 )<CR>
"	noremap <Tab> <Cmd>call <SID>CycleTwoLetters( [ "C", "O" ] )<CR>

	map ;J :call <SID>SharpSplits("J")<CR>
	map ;K :call <SID>SharpSplits("K")<CR>

	map B :bu<Space>
	map E :e<CR>
	map V EG

	map P :set paste! <Bar> 
			\ if &paste == 0 <Bar> echo "Paste mode is OFF" 
			\ <Bar> else <Bar> echo "Paste mode is ON" <Bar> endif <CR>

	map <F3> <Cmd>call <SID>MarkNext()<CR>
	map <F4> <Cmd>call <SID>WriteBasicStructure()<CR>
	map <F5> <Cmd>echo search( '\(<\\|>\\|=\)\{7}' )<CR>

"	=======

	map <Space> :call <SID>SpacebarActionAtWorkspaces()<CR>
	map ;hi :call <SID>HiLight()<CR>
	map ;hn :new<CR><C-W>_
	map ;ju :jumps<CR>
	map ;hs :split<CR><C-W>_
	map ;ks :keepjumps /
	map ;lc :lcd 
	map ;lf :call <SID>LocalCDAtThisFile()<CR>
	map ;u :call <SID>LocalCDAtFirstRoof()<CR>
	map ;pw :pwd<CR>
	map ;pb :call <SID>PasteFromBridge()<CR>
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
	map ;O0 :call <SID>TurnOnOffOverlays( 0 )<CR>
	map ;O1 :call <SID>TurnOnOffOverlays( 1 )<CR>
	map ;OO :call <SID>ShowPopups()<CR>
	noremap <expr> ;i ":vi " . getcwd() . "/"
	noremap <expr> ;I ":vi " . expand("%")

	map <F2> <Cmd>call <SID>WrapperHideAndShowPopups()<CR>

	echo "Maps done!"


endfunction

function! <SID>PasteFromBridge()

	execute "read " . s:bridge_file

endfunction

function! <SID>WrapperHideAndShowPopups()

	let s:overlay_allowed_to_show = ! s:overlay_allowed_to_show

	if s:overlay_allowed_to_show == 0
		for a in s:types_of_overlays
			call <SID>HideAndShowPopups( ["mustnotmatch"], a )
		endfor
	else
		for a in s:types_of_overlays
			call <SID>HideAndShowPopups( <SID>BuildOverlayNameArray( a ), a )
		endfor
	endif

endfunction

function! <SID>ViInitialWorkspace()
	try
		execute "vi" . " " . s:initial_workspace
	catch
		echo "Could not jump to initial workspace, " .
			\ "maybe you need to save first, vim says: " . v:exception
	endtry
endfunction

function! <SID>SetDict( )

	let potential_dicts = expand
			\ ( s:base_path . "/vim/vim_dictionary/*", 1, 1)

	let selected = []
	let this_type = matchstr( expand("<afile>"), s:file_extension )

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

	colorscheme default

	highlight clear

"	call <SID>ClearHighlights( highlights )
"	highlight Special ctermfg=98
"	highlight PreProc ctermfg=98
"	highlight Comment ctermfg=244

	
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

	iab ht <Esc>:call <SID>MakeHTML()<CR>i

endfunction

function! <SID>CopyRegisterToFileAndClipboard( )

	let tmp = @" 
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

function! <SID>BuildOverlayTabName()

	if exists("t:overlay_id")
		return t:overlay_id
	endif

	let t:overlay_id = "tab" . ( rand() * rand() )

	return t:overlay_id

endfunction

function!<SID>ShowPopups()

	
	for a in keys( s:popup_winids )
		echo a
		for b in keys( s:popup_winids[ a ] )
			echo b
			echo s:popup_winids[ a ][ b ][ 0 ]
		endfor
	endfor

endfunction!

function! <SID>PopupCreate( what, config, name )
	"
	let popup = popup_create( a:what[ 0 ], a:config )
	let s:popup_winids[ <SID>BuildOverlayTabName() ][ join( a:name, "" ) ] = [ popup, a:what[ 1 ] ]

endfunction

function! <SID>GetWinnrFromOverlayKey( key )

	return matchstr( a:key, '\d\+$')

endfunction

function! <SID>HideAndShowPopups( name, this_type )

	if s:popup_winids == {}
		
		echo "Overlays are turned off for the type:" . a:this_type . ", " .
			\ "turn them on using the normal command [  ;O1  ]," .
			\ "semicolon, letter O uppercased and number one"
		return

	endif

	let tabname = <SID>BuildOverlayTabName()
	let str_name = join( a:name, "" )


	for key in keys( s:popup_winids[ tabname ] )
		
		if match( key, a:this_type ) < 0
			continue
		endif

		if str_name == key && s:overlay_allowed_to_show == v:true
			call popup_show( s:popup_winids[ tabname ][ key ][ 0 ] )
		else
			call popup_hide( s:popup_winids[ tabname ][ key ][ 0 ] )
		endif

	endfor

endfunction

function! <SID>PopupExists( name )
	
	let tabname = <SID>BuildOverlayTabName()
	let str_name = join( a:name, "" )

	if has_key( s:popup_winids, tabname )
		
		if has_key( s:popup_winids[ tabname ], str_name  )
			return s:popup_winids[ tabname ][ str_name ]
		endif

	else
		let s:popup_winids[ tabname ] = {}
	endif

	return []

endfunction


function! <SID>AddAtCwd( jumps )

	let current = matchstr( bufname(), s:tail_with_upto_two_dirs )

	call extend
	\ ( 
			\ a:jumps[0], 
			\ [ "", current , matchstr( getcwd(), s:tail_with_upto_two_dirs ) ]
	\ )

endfunction


function! <SID>RefreshingOverlays( type )

"	echo "Type:" . a:type
"	echo s:popup_winids

	let types = s:types_of_overlays

	if ! exists("types[" . a:type . "]")
		return
	endif
	
	let this_type = types[ a:type ]

	let name = <SID>BuildOverlayNameArray( this_type )

	let popup_exists = <SID>PopupExists( name )

	let len_popup = len( popup_exists )

	let jumps = <SID>BuildJBufs( this_type )

	call <SID>AddAtCwd( jumps )

	if  len_popup == 0

		call <SID>PopupConfigThenCreate( jumps, name, a:type )

	else

		call <SID>UpdateOverlay( popup_exists, jumps, this_type )

	endif

	call <SID>HideAndShowPopups( name, this_type )

	let increase = a:type + 1
	call <SID>RefreshingOverlays( increase )

	if ( increase + 1 ) == len( types )

		let s:last_win_tab = [ winnr(), tabpagenr() ]

	endif

endfunction

function! <SID>BuildOverlayNameArray( type )

	return [ "jbuf", ".", a:type, ".", winnr() ]

endfunction

function! <SID>PopupConfigThenCreate( content, name, type )

	let line = 2
	let highlight = "Extension"
	let title = "jBufs"
	if a:type > 0
		let line += 19
		let highlight = "FileNamePrefix"
		let title = "jBufs Workspaces"
	endif

	let highlight = "MyActivities"

	call <SID>PopupCreate
	\ ( 
		\ a:content, 
		\ #{
			\ pos: "topright",
			\ scrollbar: 0,
			\ title: title,
			\ line: line,
			\ col: 999,
			\ highlight: highlight,
			\ thumbhighlight: "Visual",
			\ borderhighlight: ["MyLightGray"],
			\ border: [1, 1, 1, 1],
			\ padding: [2, 3, 2, 3],
			\ maxheight: 13,
			\ minheight: 13
		\ },
		\ a:name 
	\ )

endfunction

function! <SID>BuildJBufs( type )

	if s:last_win_tab[ 0 ] == winnr() &&
		\ s:last_win_tab[ 1 ] == tabpagenr()

		let jumps = <SID>CollectPertinentJumps( -1, a:type )
	else

		let jumps = <SID>ChooseBestPlaceToGetJumps( -1, a:type )

	endif

	return <SID>JBufsViewAndRaw( jumps, a:type )

endfunction

function! <SID>JBufsViewAndRaw( jumps, type )

	let jumps_improved = []

	let counter = 1
	for jump in a:jumps
		call add( jumps_improved, <SID>JBufsView{a:type}( counter, jump ) )
		if counter >= 8
			break
		endif
		let counter += 1
	endfor

	let bufname = bufname()
	
"	if bufname =~ '^/'
"		let current = matchstr( bufname, s:tail_with_upto_two_dirs )
"	else
"		let current = "@ " . bufname
"	endif
"

	return [ jumps_improved, a:jumps ]

endfunction

function! <SID>JBufsViewWorkspaces( counter, jump )

	return a:counter . "  " . <SID>MakeJump( a:jump )

endfunction

function! <SID>JBufsViewTraditional( counter, jump )

"	let key = s:traditional_keybinds[ ( a:counter - 1 ) % s:len_traditional_keybinds ]
"	let prefix = a:counter . "/" . key
"	let padded = <SID>StrPad( prefix, " ", 10 )

	let divisor = ""
	if a:counter == 5
		let divisor = "- "
	endif

	return  divisor .  <SID>MakeJump( a:jump )

endfunction

function! <SID>UpdateOverlay( which, content, type )
	
	call popup_settext
			\ ( 
				\ a:which[ 0 ], a:content[ 0 ]
			\ )

	let str_name = join( <SID>BuildOverlayNameArray( a:type ), "" )
	let tabname = <SID>BuildOverlayTabName()

	let a:which[ 1 ] = a:content[ 1 ]

endfunction

function! <SID>LocalMarksAutoJumping( iteration_count, go )

	if a:iteration_count >= 5000
		let copy_iteration_count = len( s:elligible_auto_cycle_local_marks_letters )
	else
		let copy_iteration_count = a:iteration_count
	endif


	if ! exists("b:local_marks_auto_jumping")
		let b:local_marks_auto_jumping = 0
	endif

	if a:iteration_count <= 0
		echo "No local marks found!"
		return
	endif

	let iteration_count_partner = copy_iteration_count - 1

	if a:go =~ '^up$'
		let b:local_marks_auto_jumping += 1
	else
		let b:local_marks_auto_jumping -= 1
	endif

	let letter = 
		\ s:elligible_auto_cycle_local_marks_letters
		\[ 
			\ b:local_marks_auto_jumping % len( s:elligible_auto_cycle_local_marks_letters ) 
		\]

	normal m'
	let mark_pos = getpos( "'" . letter )

	if mark_pos[ 1 ] > 0
		call setpos( ".", mark_pos )
		redraw
		echo "At mark: " . letter . ") " . getline( mark_pos[ 1 ] ) 
		normal zz
		return
	endif

"	echo iteration_count_partner

	call <SID>LocalMarksAutoJumping( iteration_count_partner, a:go )

endfunction


let s:popup_marks_dir = "~/git/MyStuff/vim/popup.shortcuts"
let s:base_path = expand("~") . "/git/GracefulGNU/" 
let s:bridge_file = "/tmp/bridge"
let s:tail_file = '[._[:alnum:]-]\+$'
let s:tail_with_upto_two_dirs = '\([^/]\+/\)\{,2}[^/]\+$'
let s:file_extension = '\.[^./\\]\+$'
let s:workspaces_pattern = '\.workspaces$'
" The order of the array contents below matters
let s:exclude_from_jbufs = [ s:workspaces_pattern, '\.shortcut$' ]
let s:initial_workspace = "~/git/MyStuff/vim/workspaces/all.workspaces"
let s:max_file_search = 36
let s:we_are_here = '^\[\(we.are.here\|base\)\]'
let s:search_by_basic_regex = '^\[search\]'
let s:traditional_keybinds = [ "Home", "End", "pgUp", "pgDown" ]
let s:len_traditional_keybinds = len( s:traditional_keybinds )
let s:elligible_auto_global_marks_letters = [ "L", "V", "R", "W", "D", "G" ]
let s:elligible_auto_cycle_local_marks_letters = 
	\ ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m"]

let s:tree_special_chars = '^\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\|[[:space:]]\)\+'
let s:tree_len_each_level = 4

let s:add_as_bufvar = '__\\#{.\+$'
let s:add_as_bufvar_missing_bar = '\(\\\)\@<!#.*{.\+$'
let s:cmd_buf_pattern = '\(\s\|\t\)*+\(/\|\d\).\{-}\s\+'

"let s:types_of_overlays = [ "Traditional", "Workspaces" ]
let s:types_of_overlays = [ "Traditional" ]

let s:overlay_allowed_to_show = v:true

echo "Dan.vim has just been loaded"

if exists("s:this_has_been_loaded") == v:false
	let s:this_has_been_loaded = v:true
	let s:popup_winids = {}
	let s:last_win_tab = [0, 0]
	echo "As its the first time for this instance, then we call StartUp"
	call <SID>StartUp()
	call <SID>SayHello(["Hello are you good?", "What are you up to today?", "Great!"])
"	call <SID>SayHello("Hello!")
endif



