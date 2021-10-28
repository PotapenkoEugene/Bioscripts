# from tkinter import Tk
# import translators as ts
from googletrans import Translator
# from translate import Translator
import platform, os
# import datetime
import time
import pyperclip
import random


def push(title, message):
    """ Function recognize system and re-direct stdout to popup window"""
    exptime = 10000 * len(message.split())
    plt = platform.system()
    if plt == "Darwin":
        command = '''
        osascript -e 'display notification "{message}" with title "{title}"'
        '''
    elif plt == "Linux":
        command = f'''
        notify-send \"{title}\" \"--hint int:transient:1\" \"--expire-time={exptime}\" \"{message}\" 
        '''
    # elif plt == "Windows":
    #     win10toast.ToastNotifier().show_toast(title, message)
    #     return
    else:
        return #?
    os.system(command)


#
#
# def use_clipboard(paste_text=None):
#     import tkinter  # For Python 2, replace with "import Tkinter as tkinter".
#     tk = tkinter.Tk()
#     tk.withdraw()
#     if type(paste_text) == str:  # Set clipboard text.
#         tk.clipboard_clear()
#         tk.clipboard_append(paste_text)
#     try:
#         clipboard_text = tk.clipboard_get()
#     except tkinter.TclError:
#         clipboard_text = ''
#     tk.update()  # Stops a few errors (clipboard text unchanged, command line program unresponsive, window not destroyed).
#     tk.destroy()
#     return clipboard_text


# path_english_dict = '/home/gene/Orthonectida/English/English.tsv'
translator = Translator(service_urls=['translate.googleapis.com'])
lastclip = None
# endTime = datetime.datetime.now() + datetime.timedelta(minutes=15)
while True:
    # if datetime.datetime.now() >= endTime:
    #     break

    clip = pyperclip.paste()

    if clip != lastclip:
        # new or old word:
        # if clip:
        #     new_word = True
        #     with open(path_english_dict) as f:
        #         for line in f:
        #             dict_word = line.split('\t')[0]
        #             if clip == dict_word:
        #                 new_word = False
        #                 break
        # translatedText = ts.google(clip,
                                   # if_use_cn_host=True,
                                   # to_language='ru')
        translatedText = translator.translate(clip, dest='ru')
        # push('English_dict', f'{clip} - {translatedText}')
        message = translatedText.text.upper()
        iconpath = '/home/gene/Tools/MY_SCRIPTS/data/icons/tyan' + str(random.randrange(0,3)) + '.png'
        # command = f'zenity --info --timeout=5 --title=\"English dictionary\" --text \"{message}\" &'
        command = f'notify-send -t 1000 -i {iconpath} -u low \"English dictionary\" \"{message}\"'
        os.system(command)
        # save to dict if new
        # if new_word:
        #     with open(path_english_dict, 'a') as w:
        #         w.write(clip + '\t' + translatedText + '\n')
        # print("None")
        # print(clip)
        lastclip = clip

    time.sleep(1)
# push('English_dict', 'Good Bye')
