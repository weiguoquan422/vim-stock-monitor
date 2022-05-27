
"set window options
function! s:set_stock_win()
    " Options for a non-file/control buffer.
    setlocal bufhidden=hide
    setlocal buftype=nofile
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
        let t:Stock_monitor_BufName = 'stock.tmp'
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

endfunction


function! s:py_get_price()
py3 << EOF
import easyquotation
import vim

class py_get_price_demo:
    def __init__(self):
        quotation = easyquotation.use('qq')
        
        stock_config_list = [
                'sh000001','ShangZhengZS',
                '159813',  'BanDaoTi-E'  ,
                '512660',  'JunGong-E'   ,
                '159752',  'XinNengY-E'  ,
                '159767',  'DianChi-E'   ,
                '512170',  'YiLiao-E'    ,
                '159825',  'NongYe-E'    ,
                '515220',  'MeiTan-E'    ,
                '159611',  'DianLi-E'    ,
                '513050',  'ZhongGai-E'  ,
                '513100',  'NaiZhi-E'    ,
                '159732',  'XiaoFeiDZ-E' ,
                '518880',  'HuangJin-E'  ,
                '512200',  'FangDiC-E'   ,
                '515790',  'GuangFu-E'   ,
                '512690',  'Jiu-E'       ,
                '159842',  'QuanShang-E' ,
                '159766',  'LvYou-E'     ,
                '516950',  'JiJian-E'    ,
                '159740',  'HK-KeJi-E'   ,
                '513060',  'HK-YiL-E'    ,
                '600305',  'HengSCuYe'   ,
                '600559',  'LaoBaiGan'   ,
                ]
        #stock_config_list = ['sh000001','shangzhengzs','000001',  'zhongguopa','600519',  'guizhoumt']
        len_config_lsit = len(stock_config_list)

        i = 0
        while i < len_config_lsit:
            cur_stock_idx = stock_config_list[i]
            i = i + 1
            cur_s_name = stock_config_list[i]
            i = i + 1
            res_stocks = quotation.stocks(cur_stock_idx)
            
            #sh000001 is specical
            if cur_stock_idx == 'sh000001':
                name_tmp = res_stocks['000001']['name']
                cur_pri  = res_stocks['000001']['now']
                high_pri = res_stocks['000001']['high']
                low_pri  = res_stocks['000001']['low']
                raise_f  = res_stocks['000001']['涨跌(%)']
                rate     = res_stocks['000001']['量比']
            else:
                name_tmp = res_stocks[cur_stock_idx]['name']
                cur_pri  = res_stocks[cur_stock_idx]['now']
                high_pri = res_stocks[cur_stock_idx]['high']
                low_pri  = res_stocks[cur_stock_idx]['low']
                raise_f  = res_stocks[cur_stock_idx]['涨跌(%)']
                rate     = res_stocks[cur_stock_idx]['量比']
            if cur_s_name == '':
                cur_s_name = name_tmp

            cur_s_name = cur_s_name.ljust(12)
            #float to str
            cur_pri    = str(cur_pri )
            high_pri   = str(high_pri)
            low_pri    = str(low_pri )
            raise_f    = str(raise_f )
            rate       = str(rate    )
            #left align
            cur_pri    = cur_pri.ljust(8)
            high_pri   = high_pri.ljust(8)
            low_pri    = low_pri.ljust(8)
            raise_f    = raise_f.ljust(6)
            rate       = rate.ljust(6)
            #join and print
            r_str = ' '.join([cur_s_name, cur_pri, high_pri, low_pri, raise_f, rate])
            vim.current.buffer.append(r_str)

py_get_price_demo()

EOF
endfunction



"main
function! g:Stock_monitor_main()
    if bufwinnr('stock.tmp') > 0
        let l:stock_buf_id = bufnr('stock.tmp')
        silent! execute 'bdelete '.l:stock_buf_id
    else
        "gene stock window
        call s:creat_stock_win()
        "print first line
        call setline(1, 'name         cur_pri  high_pri low_pri  r/f%   rate  ')
        "get price by python
        call s:py_get_price()
    endif
endfunction

