
let g:cur_buf_id = ""
"gen window
function! s:creat_stock_win()
    silent! execute 'botright vertical 53 new'
    silent! execute 'edit ~/stock.tmp'
    silent! execute 'vertical resize 53'
    setlocal winfixwidth
    call s:set_stock_win()
    "get cur_win_id and save
    let g:cur_win_id = winnr()
    "get cur_buf_id and save
    let g:cur_buf_id = bufnr("")
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
        
        stock_config_list = [
                'sh000001','ShangZhengZS',
                '159813',  'BanDaoTi-etf',
                '512660',  'JunGong-etf' ,
                '159752',  'XinNengY-etf',
                '159767',  'DianChi-etf' ,
                '512170',  'YiLiao-etf'  ,
                '513050',  'ZhongGai-etf',
                '513100',  'NaiZhi-etf'  ,
                '159732',  'XiaoFDZ-etf' ,
                '159611',  'DianLi-etf'  ,
                '518880',  'HuangJin-etf',
                '512200',  'FangDiC-etf' ,
                '515790',  'GuangFu-etf' ,
                '512690',  'Jiu-etf'     ,
                '159842',  'QuanShan-etf',
                '159825',  'NongYe-etf'  ,
                '159766',  'LvYou-etf'   ,
                '515220',  'MeiTang-etf' ,
                '516950',  'JiJian-etf'  ,
                '159740',  'HK-KeJi-etf' ,
                '513060',  'HK-YiL-etf'  ,
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
        silent! execute 'bdelete '.g:cur_buf_id
    else
        "gene stock window
        call s:creat_stock_win()
        "print first line
        call setline(1, 'name         cur_pri  high_pri low_pri  r/f%   rate  ')
        "get price by python
        call s:py_get_price()
    endif
endfunction

