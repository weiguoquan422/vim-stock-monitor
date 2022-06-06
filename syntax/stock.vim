hi default Oddlines ctermbg=NONE guibg=NONE
hi default Evenlines ctermbg=grey guibg=#ebdbb2


syn match Oddlines "^.*$" contains=ALL nextgroup=Evenlines skipnl 
syn match Evenlines "^.*$" contains=ALL nextgroup=Oddlines skipnl 
