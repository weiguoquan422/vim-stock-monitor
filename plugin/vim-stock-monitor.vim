
"set window options
function! s:set_stock_win()
    " Options for a non-file/control buffer.
    setlocal bufhidden=hide
    "setlocal buftype=nofile
    setlocal noswapfile

    " Options for controlling buffer/window appearance.
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nobuflisted
    setlocal nofoldenable
    setlocal nolist
    setlocal nospell
    setlocal nowrap

    "set linenumber
    setlocal nonumber
    if v:version >= 703
        setlocal norelativenumber
    endif
    iabc <buffer>
    setlocal filetype=stock_monitor
endfunction


" Function: s:ExistsForTab()
" Returns 1 if a stock win exists in the current tab
function! s:ExistsForTab()
    if !exists('t:Stock_monitor_BufName')
        return
    end

    "check b:stock_monitor is still there and hasn't been e.g. :bdeleted
    return !empty(getbufvar(bufnr(t:Stock_monitor_BufName), ''))
endfunction


function! s:creat_stock_win()
    let l:splitLocation = 'botright '
    let l:splitSize = 53

    if !s:ExistsForTab()
        let t:Stock_monitor_BufName = '~/stock.tmp'
        silent! execute l:splitLocation . 'vertical ' . l:splitSize . ' new'
        silent! execute 'edit ' . t:Stock_monitor_BufName
        silent! execute 'vertical resize '. l:splitSize
    else
        "if stock_monitor is bdeleted, dont need edit Stock_monitor_BufName again, but buffer Stock_monitor_BufName
        silent! execute l:splitLocation . 'vertical ' . l:splitSize . ' split'
        silent! execute 'buffer ' . t:Stock_monitor_BufName
        silent! execute 'vertical resize '. l:splitSize
    endif

    setlocal winfixwidth

    call s:set_stock_win()

    if has('patch-7.4.1925')
        clearjumps
    endif
    "execute 'win_gotoid('.l:stock_buf_id.')'
    call win_gotoid(g:cur_win_id)

endfunction


function! s:refresh_win()
    if s:ExistsForTab()
        silent! execute 'edit ' . '~/stock.tmp'
        silent! execute 'vertical resize '. l:splitSize
    endif

    setlocal winfixwidth
    call s:set_stock_win()

    if has('patch-7.4.1925')
        clearjumps
    endif

endfunction


function! s:OnEvent(job_id, data, event) dict
    if a:event == 'stdout'
    elseif a:event == 'stderr'
    else
        if bufwinnr('stock.tmp') > 0
            "autoread file when vim does an action, like a command in ex :!
            set autoread | autocmd CursorHold * checktime
        endif
    endif
endfunction

let s:callbacks = {
\ 'on_stdout': function('s:OnEvent'),
\ 'on_stderr': function('s:OnEvent'),
\ 'on_exit': function('s:OnEvent')
\ }

function! s:asyn_get_stock()
    "let job1 = jobstart(['bash', '-c', 'for i in {1..10}; do echo hello $i!; sleep 1; done'], extend({'shell': 'shell 2'}, s:callbacks))
    let job1 = jobstart(['python3','/home/10292438@zte.intra/.local/share/nvim/plugged/vim-stock-monitor/plugin/stock_obtain.py'],s:callbacks)
endfunction



"main
function! g:Stock_monitor_main()
    if bufwinnr('stock.tmp') > 0
        let l:stock_buf_id = bufnr('stock.tmp')
        silent! execute 'bdelete '.l:stock_buf_id
    else
        "store current win_id
        let g:cur_win_id = win_getid()
        "gene stock window
        call s:creat_stock_win()
        "get price by python, write in stock.tmp
        call s:asyn_get_stock()
    endif
endfunction

