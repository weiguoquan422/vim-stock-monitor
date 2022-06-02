import easyquotation
import shutil
import sys

class py_get_price_demo:
    def __init__(self):
        quotation = easyquotation.use('qq')
        
        vim_stock_monitor_path = ' '.join(sys.argv[1:])
        stock_back_path = vim_stock_monitor_path + 'stock_back.tmp'
        stock_path = vim_stock_monitor_path + 'stock.tmp'
        #config list read
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

        stockFile = open(stock_back_path, 'w')
        stockFile.write('name         cur_pri  high_pri low_pri  r/f%   rate  \n') #print header

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
            stockFile.write(r_str)
            stockFile.write('\n')

        stockFile.close()
        shutil.copy(stock_back_path, stock_path)



#main
py_get_price_demo()
