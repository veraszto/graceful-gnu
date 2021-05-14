

function! <SID>MyHiLights()
endfunction


function! <SID>MyMakeAbbreviations()


	"Special
	iab cla class="hello"<Esc>bve
	iab stt setTimeout<CR>(<CR><Tab>function( ev )<CR>{<CR>}, <CR>);<Home><Del>
	iab linkrel <link rel="icon" type="image/png" href="images/common/link_rel_icon.png?2" />

	iab sout System.out.println("")<Left><Left>

	iab <expr> bufName matchstr( expand("%:t"), '.\{-}\(\.\)\@=' )

	iab htmlbasic <!doctype html>
		\ <CR><html><CR><head><CR></head><CR><body><CR></body><CR></html>

	iab mdep <dependency><CR><Tab>
			\<groupId></groupId><CR><artifactId></artifactId><CR>
			\<version></version><CR><BS></dependency>

	iab holdT var holdThis = this;
	"CODE
	iab ac appendChild();<Left><Left>
	iab ae addEventListener<CR>(<CR><Tab>"",<CR>);<kHome><Del><Up><kEnd><CR>
	iab ahe alert("Hello");
	iab ahi alert("Hi");
	iab bcla getElementsByClassName("")<Left><Left>
	iab bid document.getElementById("")<Left><Left>
	iab btag getElementsByTagName("")<Left><Left>
	iab cl console.log( ev );<Esc>Feve
	iab dc document.createElement("")<Left><Left>
	iab fev function ( ev )<CR>{<CR>}<Up><End><CR>
	iab fi for ( var i = 0 ; i < list.length ; i++ )<CR>{<CR>}<Up><Up><kHome><Esc>flw
	iab fiin for ( var i in list )<CR>{<CR>}<Up><Up><kHome><Esc>flw
	iab frv for ( var rv = 0 ; rv < list.length ; rv++ )<CR>{<CR>}<Up><Up><kHome><Esc>flw
	iab frvin for ( var rv in list )<CR>{<CR>}<Up><Up><kHome><Esc>flw
	iab fu function func(   )<CR>{<CR>}<Up><Up>ffve
	iab gbc getElementsByClassName("")<Left><Left>
	iab gbi document.getElementById("")<Left><Left>
	iab gbt getElementsByTagName("")<Left><Left>
	iab inn innerHTML
	iab rc removeChild()<Left>
	iab rel removeEventListener();
	iab rf return false;
	iab rt return true;
	"CSS

	iab csskeyframes @keyframes SlowAndSteadyWinsTheRace<CR>{<CR>from<CR>{<CR>}<CR>to<CR>{<CR>}<CR>}<Esc>8kfSve
	iab ad animation-duration:1000ms;
	iab ade animation-delay:1000ms;
	iab afm animation-fill-mode:forwards;
	iab aic animation-iteration-count:infinite;<Left>
	iab ait align-items:stretch;<Left>
	iab ana animation-name:hakunamatata;<Esc>bve
	iab atf animation-timing-function:linear;<Left>
	iab bblr border-bottom-left-radius:.5em;
	iab bbrr border-bottom-right-radius:.5em;
	iab bc background-color:red;<Left>
	iab bck background:;<Left>
	iab bem border:.5em solid Crimson;
	iab bi background-image:url('');<Esc>3<Left>i
	iab bora border-radius:.5em;<Left>
	iab borb border-bottom:1px solid Crimson;<Left>
	iab bort border-top:1px solid Crimson;<Left>
	iab bott bottom:0;<Left>
	iab bow border-width:1em;<Left>
	iab boxsh box-shadow:none;
	iab boxsi box-sizing:border-box;<Left>
	iab bp background-position:left top;<Left>
	iab bpx border:1px solid Crimson;
	iab bcl border-color:red;
	iab bre background-repeat:no-repeat;<Left>
	iab bs background-size:;<Left>
	iab btlr border-top-left-radius:.5em;
	iab btrr border-top-right-radius:.5em;
	iab cll clear:left;
	iab clr clear:right;
	iab cow color:white;
	iab csr cursor:pointer;
	iab ctt content:"";<Left><Left>
	iab dbl display:block;
	iab dfl display:flex;
	iab dgr display:grid;
	iab dib display:inline-block;
	iab din display:inline;
	iab dn display:none;
	iab fb flex-basis:100%;

	iab ob <Esc>o{<CR>}<Esc><Up>o

	iab fc <End>:first-child
	iab lc <End>:last-child
	iab nc <kEnd>:nth-child(2)<Left>
	iab noty <kEnd>:nth-of-type(1)<Left>
	iab nt <kEnd>:nth-child(2)<Left>

	iab cssvar var(--)<Left>
	iab fd flex-direction:row;<Left>
	iab ff font-family:'Hello';<Left><Left>
	iab ffsrc src:url('Hello');<Left><Left><Left>
	iab filb filter:blur(0);<Esc>hha
	iab fl float:left;
	iab fn float:none;
	iab fop fill-opacity:0.5;<Esc>hhh
	iab fr float:right;
	iab fs font-size:small;
	iab fst font-style:normal;
	iab fw font-weight:normal;
	iab flw flex-wrap:wrap;
	iab ght right:0;
	iab he height:2em;<Left>
	iab hp height:100%;
	iab jc justify-content:center;<Left>
	iab le left:0;<Left>
	iab lh line-height:1;<Left>
	iab mg margin:1em;<Left>
	iab mb margin-bottom:1em;<Left>
	iab mc /*****Section******/<Esc>3bfSve
	iab ml margin-left:1em;<Left>
	iab mr margin-right:1em;<Left>
	iab mt margin-top:1em;<Left>
	iab oa overflow:auto;<Left>
	iab oh overflow:hidden;<Left>
	iab opty opacity:0;
	iab osc overflow:scroll;<Left>
	iab oun outline:none;
	iab pb padding-bottom:1em;<Left>
	iab pd padding:1em;<Left>
	iab pl padding-left:1em;<Left>
	iab poa position:absolute;
	iab pof position:fixed;
	iab pore position:relative;
	iab pr padding-right:1em;<Left>
	iab pt padding-top:1em;<Left>
	iab strk stroke:Crimson;
	iab strlp stroke-linecap:butt;
	iab strw stroke-width:10;<Left>
	iab strarr stroke-dasharray:100;<Left>
	iab stroff stroke-dashoffset:100;<Left>
	iab ta text-align:center;<Left>
	iab td transition-duration:;<Left>
	iab top0 top:0;<Left>
	iab tp transition-property:;<Left>
	iab tro transform-origin:center;<Left>
	iab tr transform:;<Left>
	iab tt text-transform:uppercase;<Left>
	iab vad var(--hello)<Left>
	iab va vertical-align:;<Left>
	iab wi width:2em;
	iab wp width:100%;<Left><Left>
	iab ws white-space:nowrap;<Left>
	iab zi z-index:1;<Left>


	iab cc 
		\/***********************************
		\CloseSection
		\***********************************/
		\<Esc>3bfCve

	iab ccc /**SmallComment**/<Esc>bbve
		

endfunction

function! <SID>InjectToMac()
	au! * <buffer>
	au BufWritePost <buffer> call <SID>ThisToMac()
"	map <silent> ;ss :silent call <SID>ThisToMac()<CR>

endfunction

function! <SID>ThisToMac()
	let this_name = expand("%")
	if ! exists("b:swift_injection_path")
		echo "Swift injection path not set!"
		return
	endif
	execute "!scp " . expand("%") . " " . b:swift_injection_path
endfunction

function! <SID>MyMaps()

	map ;;y :echo "runtime Supplementary.vim and call MyStartUp" <Bar> runtime Supplementary.vim<CR>

endfunction

function! <SID>MyStartUp()

	call <SID>MyHiLights()
	call <SID>MyMakeAbbreviations()
	call <SID>MyMaps()
	echo "MyStartUp has been called"

endfunction

call <SID>MyStartUp()

echo "DanSupplementary has been loaded"

"if exists("s:this_has_been_loaded") == v:false
"
"	let s:this_has_been_loaded = v:true
"	echo "As its the first time for this instance or it has been asked to do so, " .
"			\ "then we call MyStartUp"
"
"	call <SID>MyStartUp()
"
"endif









