
# py3 << EOF
import easyquotation
import vim

quotation = easyquotation.use('qq')

stock_config_list = [
        'sh000001','shangzhengzs',
        '159813',  'bandaoti-etf',
        '512660',  'jungong-etf',
        '159752',  'xinNY-etf',
        '159767',  'dianchi-etf',
        '513050',  'ZGU-etf',
        '600305',  'hengScuye',
        ]
cur_stock = stock_config_list[0]
cur_s_name = stock_config_list[1]
res_stocks = quotation.stocks(cur_stock)

if cur_stock == 'sh000001':
    cur_pri = res_stocks['000001']['now']
else:
    cur_pri = res_stocks[cur_stock]['now']

# EOF
