if !exists("g:vim_stock_monitor_install_dir")
    let g:vim_stock_monitor_install_dir = '/home/' . $USER . '/.local/share/nvim/plugged/vim-stock-monitor/'
endif

if !exists("g:vim_stock_monitor_tmp_file_dir")
    let g:vim_stock_monitor_tmp_file_dir = '/home/' . $USER . '/'
endif

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
    setlocal filetype=stock
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
        let t:Stock_monitor_BufName = g:vim_stock_monitor_tmp_file_dir . 'monitor.stock'
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
    call win_gotoid(g:get_stock_cur_win_id)

endfunction


function! s:OnEvent(job_id, data, event) dict
    if a:event == 'stdout'
    elseif a:event == 'stderr'
    else
        if bufwinnr('monitor.stock') > 0
        endif
    endif
endfunction

let s:get_stock_callbacks = {
\ 'on_stdout': function('s:OnEvent'),
\ 'on_stderr': function('s:OnEvent'),
\ 'on_exit': function('s:OnEvent')
\ }


function! s:set_autoread_and_trigger()
    "autoread file when vim does an action, like a command in ex :!
    silent! set autoread
    "autoread trigger:cursor isn't moved for 2s(default is 4s, set updatetime=2000 in .vimrc, then now is 2s)
    "https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim
    silent! autocmd CursorHold,CursorHoldI,FocusGained,BufEnter * 
                \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
    "if monitor.stock autoreload, will echo 'monitor.stock xxxL, xxxC' message, use
    "echo empty to clear the message
    silent! autocmd FileChangedShellPost * echo ""
endfunction


function! s:unset_autoread_and_trigger()
    "autoread file when vim does an action, like a command in ex :!
    silent! set noautoread
    "autoread trigger:cursor isn't moved for 2s(default is 4s, set updatetime=2000 in .vimrc, then now is 2s)
    "https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim
    silent! autocmd! CursorHold,CursorHoldI,FocusGained,BufEnter * 
                \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
    silent! autocmd! FileChangedShellPost * echo ""
endfunction


function! s:asyn_get_stock()
    let job1 = jobstart(['python3', g:vim_stock_monitor_install_dir . 'plugin/stock_obtain.py', g:vim_stock_monitor_tmp_file_dir],s:get_stock_callbacks)
endfunction


function! s:repeat_get_stock_once(timer_id)
    silent! let job2 = jobstart(['python3', g:vim_stock_monitor_install_dir . 'plugin/stock_obtain.py', g:vim_stock_monitor_tmp_file_dir],s:get_stock_callbacks)
endfunction


"repeat_get_stock by timer
"this while..endwhile is executed instantaneously, it gene a set of timer to
"tell which times the repeat_get_stock_once function is started
if !exists("g:REPEAT_GET_STOCK_INTERVAL")
    let g:REPEAT_GET_STOCK_INTERVAL = 10
endif
if !exists("g:REPEAT_GET_STOCK_TIMES")
    let g:REPEAT_GET_STOCK_TIMES = 900
endif
function! s:repeat_get_stock()
    silent! let g:get_stock_timer_id = timer_start(g:REPEAT_GET_STOCK_INTERVAL*1000, function('s:repeat_get_stock_once'),{'repeat': g:REPEAT_GET_STOCK_TIMES})
endfunction



"main
function! g:Stock_monitor_main()
    if bufwinnr('monitor.stock') > 0
        "get buf id
        let l:stock_buf_id = bufnr('monitor.stock')
        "close stock win buf
        silent! execute 'bdelete '.l:stock_buf_id
        "stop timer
        silent! call timer_stop(g:get_stock_timer_id)
        "unset_autoread_and_trigger
        "silent! call s:unset_autoread_and_trigger()
    else
        silent! call s:set_autoread_and_trigger()
        "store current win_id
        let g:get_stock_cur_win_id = win_getid()
        "gene stock window
        silent! call s:creat_stock_win()
        "get price by python, write in monitor.stock, first time for init
        call s:asyn_get_stock()
        "repeat get stock
        silent! call s:repeat_get_stock()
    endif
endfunction

