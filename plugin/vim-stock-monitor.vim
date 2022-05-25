
"gen window
function! s:creat_stock_win()
    silent! execute 'botright vertical 53 new'
    silent! execute 'edit ~/.stock.tmp'
    silent! execute 'vertical resize 53'
    setlocal winfixwidth
    call s:set_stock_win()
endfunction

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
endfunction


function! s:py_get_price()
py3 << EOF
import easyquotation
import vim

class py_get_price_demo:
    def __init__(self):
        quotation = easyquotation.use('qq')
        
        stock_config_list = ['sh000001','shangzhengzs','000001',  'zhongguopa','600519',  'guizhoumt']
        len_config_lsit = len(stock_config_list)

        i = 0
        while i < len_config_lsit:
            cur_stock_idx = stock_config_list[i]
            i = i + 1
            cur_s_name = stock_config_list[i]
            i = i + 1
            res_stocks = quotation.stocks(cur_stock_idx)
            
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
            cur_pri    = str(cur_pri )
            high_pri   = str(high_pri)
            low_pri    = str(low_pri )
            raise_f    = str(raise_f )
            rate       = str(rate    )
            cur_pri    = cur_pri.ljust(8)
            high_pri   = high_pri.ljust(8)
            low_pri    = low_pri.ljust(8)
            raise_f    = raise_f.ljust(6)
            rate       = rate.ljust(6)
            r_str = ' '.join([cur_s_name, cur_pri, high_pri, low_pri, raise_f, rate])
            vim.current.buffer.append(r_str)

py_get_price_demo()

EOF
endfunction



"main
function! g:Stock_monitor_main()
    call s:creat_stock_win()
    call setline(1, 'name         cur_pri  high_pri low_pri  r/f%   rate  ')
    call s:py_get_price()
endfunction


