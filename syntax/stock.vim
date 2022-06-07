hi default Oddlines ctermbg=NONE guibg=NONE
hi default Evenlines ctermbg=grey guibg=#ebdbb2
hi default Plus guifg=#fb4934
hi default Minus guifg=#b8bb26


syn match Oddlines "^.*$" contains=ALL nextgroup=Evenlines skipnl 
syn match Evenlines "^.*$" contains=ALL nextgroup=Oddlines skipnl 
syn match Plus "+\ze\d" contains=ALL nextgroup=Plus_num skipnl 
syn match Minus "-\ze\d" contains=ALL nextgroup=Minus_num skipnl 
