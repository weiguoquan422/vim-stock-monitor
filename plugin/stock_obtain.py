import easyquotation
import shutil
import sys
from config_list import stock_config_list

class py_get_price_demo:
    def __init__(self):
        quotation = easyquotation.use('qq')
        
        vim_stock_monitor_path = ' '.join(sys.argv[1:])
        stock_back_path = vim_stock_monitor_path + 'stock_back.tmp'
        stock_path = vim_stock_monitor_path + 'monitor.stock'
        len_config_lsit = len(stock_config_list)

        stockFile = open(stock_back_path, 'w')
        stockFile.write('name         r/f%   rate   cur_pri  high_pri low_pri  \n') #print header

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
            if raise_f > 0:
                raise_f    = "+" + str(raise_f )
            else:
                raise_f    = str(raise_f )
            rate       = str(rate    )
            #left align
            cur_pri    = cur_pri.ljust(8)
            high_pri   = high_pri.ljust(8)
            low_pri    = low_pri.ljust(8)
            raise_f    = raise_f.ljust(6)
            rate       = rate.ljust(6)
            #join and print
            r_str = ' '.join([cur_s_name, raise_f, rate, cur_pri, high_pri, low_pri])
            stockFile.write(r_str)
            stockFile.write('\n')

        stockFile.close()
        shutil.copy(stock_back_path, stock_path)



#main
py_get_price_demo()
