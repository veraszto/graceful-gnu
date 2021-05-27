
function! <SID>MakeMappings()


	
"	Avoiding insert/replace toggle
	inoremap <Insert> <Esc>a

"	Easing autocomplete
	imap jj <C-X><C-N>
	imap jn <C-X><C-N>
	imap jk <C-X><C-K>
	imap jv <C-X><C-V>

	call <SID>iMapShortcut( "jf", 'LocalCDAtFirstRoof()', "<C-X><C-F>" )


"   Window Navigation
	call <SID>MapShortcut( "<C-Up>", 'MoveTo("up")' )
	call <SID>MapShortcut( "<C-Down>", 'MoveTo("down")' )

	map <C-Left> <C-W>h
	map <C-Right> <C-W>l

	call <SID>iMapShortcut( "<C-Up>", 'MoveTo("up")' )
	call <SID>iMapShortcut( "<C-Down>", 'MoveTo("down")' )

	imap <C-Left> <Esc><C-W>hi
	imap <C-Right> <Esc><C-W>li

	"Alternate buffer navigation
	map <S-Tab> :up <Bar> :e#<CR>

	"Buffer navigation
	map <Bar> :bprevious<CR>
	map Z :bnext<CR>


	"Commenting and uncommenting
	map ;c1 <Cmd>s/^/\/\//<CR>
	map ;c2 <Cmd>s/^/\/*/<CR><Cmd>s/$/*\//<CR>
	map ;c3 <Cmd>s/\(\w\\|<\)\@=/<!--/<CR>:s/$/-->/<CR>
	map ;c0 <Cmd>s/\(:\)\@<!\(\/\/\)\\|\/\*\\|\*\/\\|^\s*"\+\\|^\s*#\+\\|<!--\\|-->//g<CR>


"	Instant reloads
	call <SID>MapShortcutButFirstRuntimeDanVim( ";rs", "StartUp()" )
	call <SID>MapShortcutButFirstRuntimeDanVim( ";rm", "MakeMappings()" )


"	Easy save
	imap 	<S-Up> <Cmd>:wa<CR>
	map 	<S-Up> <Cmd>wa<CR>

"	ChangeList
	map { g;
	map } g,


	map <C-S-Left>	:previous<CR>
	map <C-S-Right>	:next<CR>

"	Shortcuts

	map ;ab :ab<CR>
	map ;bl :ls<CR>
	map ;bu :bu<Space>
	map ;ch :changes<CR>
	map ;cj :clearjumps<CR>

	call <SID>MapShortcut( ";ea", 'RefreshAll()' )
	call <SID>MapShortcut( ";em", 'EditMarksFile()' )

	call <SID>MapShortcut( "<S-Left>", "PopupMarksShow()" )
	call <SID>MapShortcut( "<S-Right>", "PopupBuffers()" )
	call <SID>MapShortcut( "<S-Down>", "PopupJumps()" )

	call <SID>MapShortcut( "<C-S-Down>", 'LocalMarksAutoJumping( 13487, "down" )' )
	call <SID>MapShortcut( "<C-S-Up>", 'LocalMarksAutoJumping( 9750, "up" )' )


	let types = [ "Traditional", "Workspaces" ]

	let keys = 
		\ [
			\ "<S-Home>", "<S-End>", "<S-PageUp>", "<S-PageDown>",
			\ "<C-S-Home>", "<C-S-End>", "<C-S-PageUp>", "<C-S-PageDown>" 
		\ ]


	for a in range(1, 4)

		call <SID>MapShortcut( keys[ a - 1 ], 'ShortcutToNthPertinentJump( "' . a . '", "' . types[ 0 ] . '")' )

		let a_plus_three = a + 3

		call <SID>MapShortcut( keys[ a_plus_three ], 'ShortcutToNthPertinentJump( "' . ( a_plus_three + 1 ) . '", "' . types[ 0 ] . '")' )

	endfor

	call <SID>MapShortcut( "<C-S-kDel>", "ViInitialWorkspace()" )
	call <SID>MapShortcut( "<Del>", 'ShortcutToNthPertinentJump(1, "Workspaces")' )
	call <SID>MapShortcut( "<S-kDel>", 'ShortcutToNthPertinentJump(2, "Workspaces")' )

	call <SID>MapShortcut( ";J", 'SharpSplits("J")' )
	call <SID>MapShortcut( ";K", 'SharpSplits("K")' )

	map B :bu<Space>
	map E :e<CR>
	map V EG

	map P :set paste! <Bar> 
			\ if &paste == 0 <Bar> echo "Paste mode is OFF" 
			\ <Bar> else <Bar> echo "Paste mode is ON" <Bar> endif <CR>


	call <SID>MapShortcut( "<F1>", 'CopyRegisterToFileAndClipboard()' )
	call <SID>MapShortcut( "[1;2P", 'PasteFromClipboard( v:false )' )
	call <SID>MapShortcut( "[1;6P", 'PasteFromClipboard( 1 )' )
	call <SID>MapShortcut( "<F2>", 'WrapperHideAndShowPopups()' )
	call <SID>MapShortcut( "<F3>", 'MarkNext()' )
	call <SID>MapShortcut( "<F4>", 'WriteBasicStructure()' )

	map <F5> <Cmd>echo "Searching for >>>>>, <<<<<<, \|\|\|\|\|\|" <Bar> call search( '\(<\\|>\\|=\)\{6,}' )<CR>
	
	call <SID>MapShortcut( "<F6>", 'LoadLoader( )' )
	map <silent> <S-F6> :try \| %bd \| catch \| echo "Tryied to unload all buffers, has it been enough?" \| endtry<CR>
	call <SID>MapShortcut( "<F7>", 'SaveLoader( )' )
	call <SID>MapShortcut( "<S-F7>", 'SaveBuffersOfThisTab( )' )

"	=======

	call <SID>MapShortcut( "<Space>", 'SpacebarActionAtWorkspaces()' )
	call <SID>MapShortcut( ";hi", 'HiLight()' )
	map ;hn :new<CR>
	map ;ju :jumps<CR>
	map ;hs :split<CR>
	map ;ks :keepjumps /
	map ;lc :lcd 


	call <SID>MapShortcut( ";lf", "LocalCDAtThisFile()" )
	call <SID>MapShortcut( ";u", "LocalCDAtFirstRoof()" )
	map ;pw :pwd<CR>
	call <SID>MapShortcut( ";pt", "GetThisFilePopupMark()" )
	map ;q :quit<CR>
	map ;r :reg<CR>
	map ;sm :marks<CR>
	call <SID>MapShortcut( ";std", "StampThisTypeToStatusLine()" )
	map ;stc :try <Bar> unlet w:stamp_name <Bar> catch <Bar> echo "Already unstamped" <Bar> endtry<CR>
	"Remember todo Tab moves back and forth
	map ;, :tabm0<CR>
	call <SID>MapShortcut( ";t", "ViInitialWorkspace()", "<Cmd>tabnew", "clearjumps" )
	map ;vn :vertical new<CR>
	map ;vs :vertical split<CR>
	call <SID>MapShortcut( ";so", "SourceCurrent_ifVim()" )
	call <SID>MapShortcut( ";sc", "ShowMeColors()" )
	call <SID>MapShortcut( ";o", "OpenWorkspace()" )
	call <SID>MapShortcut( ";O0", "TurnOnOffOverlays( 0 )" )
	call <SID>MapShortcut( ";O1", "TurnOnOffOverlays( 1 )" )
	call <SID>MapShortcut( ";OO", "ShowPopups()" )
	noremap <expr> ;i ":vi " . getcwd() . "/"
	noremap <expr> ;I ":vi " . expand("%")

	echo "Maps done!"


endfunction

function! <SID>MapShortcutButFirstRuntimeDanVim( sequence, action )

	call <SID>MapShortcut( a:sequence, a:action, "<Cmd>runtime Dan.vim" )

endfunction

let s:map = "map"
let s:inoremap = "inoremap"

function! <SID>MapShortcut( sequence, action, ... )

	call <SID>MapShortcutCore( s:map, a:sequence, a:action, a:000, [] )

endfunction

function! <SID>iMapShortcut( sequence, action, ... )

	call <SID>MapShortcutCore( s:inoremap, a:sequence, a:action, [], a:000 )

endfunction

function! <SID>MapShortcutCore( map, sequence, action, prepend_cmds, append_cmds )

	let make = 
	\ [
		\ a:map,
		\ a:sequence
	\ ]

	let counter = 0

	let cmd = "<Cmd>"

	let len_prepends = len( a:prepend_cmds )
	let len_appends = len( a:append_cmds )

	while counter < len_prepends
		
		call extend( make, [ a:prepend_cmds[ counter ] . " <Bar>" ] )
		let counter += 1

	endwhile

	if counter > 0
		let cmd = ""
	endif
	
	let counter = 0


	call extend( make, [ cmd . "call", g:Danvim_SID . a:action . "<CR>" ] )
	
	while counter < len_appends
		
		call extend( make, [ a:append_cmds[ counter ] ] )
		let counter += 1

	endwhile

	let map_this = join( make, " ")
	let remove_spaces_from_appended = substitute( map_this, '\(<CR>\)\@<=\s', "", "g" )
"	echo map_this
	execute remove_spaces_from_appended

endfunction


call <SID>MakeMappings()

