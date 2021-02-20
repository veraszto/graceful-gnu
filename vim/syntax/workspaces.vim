

if exists("b:current_syntax")
	finish
endif


" Highlight definitions are at Dan.vim

syn region WorkspacesMetaDataContainer start=/^\[.\+\]/ end=/^.*$/ keepend contains=WorkspacesMetaDataEnclosure,Dirs,Bars
syn match WorkspacesMetaDataEnclosure /^\[.\+\].*/ contained contains=WorkspacesMetadata
syn match WorkspacesMetaData /[^\[\]]\+/ contained 
syn match WorkspacesCurlyBraces /^\s*\({\|}\)\s*$/


syn match Dirs /.\{-}\//me=e-1 contains=TreeSticks
syn match TreeSticks /\%u2500\|\%u2502\|\%u251C\|\%u2514/

syn match FileNamePrefix /[[:alnum:]-_]\{-}\.\([^/]\+$\)\@=/ contains=Extension
syn match Extension /\.[^./]\{-}$/ contained
syn match Bars /\//

let b:current_syntax = "workspaces"
