#!/usr/bin/python3

########################
# USAGE:
# python3 Parser_Tender_xls.py path_to_the_target_directory
########################

import pandas as pd
import xlrd
import os
import sys

curdir = sys.argv[1]

def xldate_to_date(value):
    date_tuple = reversed(xlrd.xldate_as_tuple(value, datemode=0))
    datetime = [str(i) for i in date_tuple if i != 0]
    return '.'.join(datetime)

def parse_it(filepath):
    filename = os.path.basename(filepath)
    print(filename)

    workbook = xlrd.open_workbook(filepath)
    sheet = workbook.sheet_by_index(0)

    finish_table = []
    results = [filename]
    currazdel = -1
    numbers = list(range(1 ,1000))

    col1 = False
    col2 = False
    col3 = False
    col4 = False
    col5 = False
    col6 = False

    skip_razdel = False
    razdel_total = 0

    for row in range(0 ,sheet.nrows):
        for col in range(0, 11):
            value = sheet.cell_value(row, col)

            # ПОДРЯДЧИК
            if str(value).rstrip() == 'Подрядчик' and col == 0:
                currow = row
                col1 = True
                continue
            if col1 and row == currow and value:
                results.append(value)
                col1 = False

            # СТРОЙКА
            if str(value).rstrip() == 'Стройка' and col == 0:
                currow = row
                col2 = True
                continue
            if col2 and row == currow and value:
                results.append(value)
                col2 = False

            # ДОГОВОР ПОДРЯДА
            if str(value).strip() == 'Договор подряда':
                currow = row
                curcol = col
                col3 = True
                continue
            if col3 and row == currow and col == curcol + 3:
                results.append(value)
            if col3 and row == currow + 1 and col == curcol + 3:
                results.append(xldate_to_date(value))
                col3 = False

            # НОМЕР ДОКУМЕНТА, ДАТА СОСТАВЛЕНИЯ, ОТЧЕТНЫЙ ПЕРИОД С-ПО
            if str(value).strip() == 'Номер документа':
                currow = row
                curcol = col
                col4 = True
                continue
            if col4 and row == currow + 2 and col == curcol and value:
                results.append(int(value))
            if col4 and row == currow + 2 and col == curcol + 1 and value:
                results.append(xldate_to_date(value))
            if col4 and row == currow + 2 and col == curcol + 2 and value:
                results.append(xldate_to_date(value))
            if col4 and row == currow + 2 and col == curcol + 3 and value:
                results.append(xldate_to_date(value))
                col4 = False

            # РАЗДЕЛ
            if str(value).strip().startswith('Раздел:'):
                if currazdel >= 0 and finish_table and razdel_total != 0:
                    finish_table[-1][10] = razdel_total

                razdel_name = value.strip().split(':')[1]
                currazdel += 1
                col5 = True
                continue

            if col5 and col == 0 and value in numbers:
                pp = int(value)
                possition = sheet.cell_value(row, col + 1)
                shifr = sheet.cell_value(row, col + 2)
                workname = sheet.cell_value(row, col + 3)
                measure_unit = sheet.cell_value(row, col + 4)
                amount = sheet.cell_value(row, col + 5)

            if col5 and not value and col == 0:
                checklist = [i for i in range(8) if sheet.cell_value(row, col + i)]
                if not checklist:
                    total_count = sheet.cell_value(row, 10)
                    if total_count:
                        finish_table.append(results + [razdel_name, '', pp, possition, shifr, workname,
                                                       measure_unit, amount, total_count,
                                                       '', '', '', ''] )


            if col5 and isinstance(value, str) and value.strip().startswith('Итого по разделу:'):
                tmp_total = sheet.cell_value(row, 10)
                if tmp_total != 0:
                    razdel_total = sheet.cell_value(row, 10)


            if col5 and isinstance(value, str) and (value.startswith \
                    ('Всего по акту с тендерным снижением стоимости строительства') or \
                    value.startswith('Всего с тендерным снижением стоимости строительства') or \
                    value.startswith('Итого по акту с тендерным снижением')):
                col5 = False
                finish_table[-1][10] = razdel_total

                col6 = True
                finish_table[-1][18] = sheet.cell_value(row, 11)

                if '=' in value:
                    finish_table[-1][19] = value.split('=')[1].rstrip(':,в тч.')
                else:
                    finish_table[-1][19] = value.split()[-1].rstrip(':,в т.ч:')

            if col6 and isinstance(value, str) and (value.strip().startswith(\
                    'Итого с учетом понижающего договорного коэффициента') or\
                    value.strip().startswith('Итого без НДС')):
                col6 = False
                finish_table[-1][20] = sheet.cell_value(row, 11)
                finish_table[-1][21] = value.split('=')[1].rstrip(':):,в тч.')

    data = pd.DataFrame(finish_table, columns=[
        'Имя файла',
        'Подрядчик',
        'Стройка',
        'Договор подряда. Номер',
        'Договор подряда. Дата',
        'Номер документа',
        'Дата составления',
        'Отчетный период. С',
        'Отчетный период. По',
        'Раздел:',
        'Итого по разделу:',
        'п/п',
        'поз. по сме-те',
        'Шифр расценки и коды ресурсов',
        'Наименование работ и затрат',
        'Единица измерения',
        'Кол-во единиц',
        'Итого работ и затрат',
        'Всего по акту с тендерным снижением стоимости строительства:',
        'К тс',
        'Итого с учетом понижающего договорного коэффициента:',
        'К дс'
    ])

    return data

def save_to_xls(df, root, filename):
    filename = filename.replace('.xls', '') + '_SUM.xls'
    df.to_excel(os.path.join(root, 'Summary', filename))

# MAIN
if __name__ == "__main__":
    for root, dirnames, filenames in os.walk(curdir):
        # print(root, filenames)
        break
    if 'Summary' not in dirnames:
        os.mkdir(os.path.join(root, 'Summary'))

    files = [file for file in filenames if file.endswith('.xls')]
    dfs = [parse_it(os.path.join(root, file)) for file in files]
    [save_to_xls(df, root, filename) for df, filename in zip(dfs, files)]

    summary_dfs = pd.concat(dfs)
    save_to_xls(summary_dfs, root, 'Summary_Tenders.xls')

