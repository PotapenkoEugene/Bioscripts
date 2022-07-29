### Control memory usage and send warnings to Slack ###

import subprocess
import os
import time
import datetime
import sys


##################
URL = sys.argv[1]  # test URL
targetDevice = sys.argv[2]  # '/dev/nvme0n1p4'
warningFreq = 3600
warningRange = range(80, 85)
warningExtremeFreq = 1800
warningExtremeRange = range(85, 90)
detectorFreq = 3600
nightTime = list(range(11)) + list(range(20, 25)) # from 20 to 10 hour is NIGHT
#################

while True:
    # Skip notifications if night
    curhour = int(datetime.datetime.now().strftime("%H"))
    if curhour in nightTime:
        time.sleep(detectorFreq)
        continue

    # Check disk load
    bashCommand = "df -h"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

    usage, dir = [dev for dev in output.decode('utf-8').split('\n') if
                  dev.startswith(targetDevice)][0].split()[4:6]

    # Send warning or extreme warning if we near to the memory limit
    if int(usage.rstrip('%')) in warningRange:
        message = f"Disk space has reached *{usage}*.\nClear some space in {dir}."
        bashCommand = f"curl -X POST -H \"Content-type:application/json\" --data \"{{\'text\':\'{message}\'}}\" {URL}"
        os.system(bashCommand)
        time.sleep(warningFreq)
        continue

    elif int(usage.rstrip('%')) in warningExtremeRange:
        message = f"Disk space has reached *{usage}*.\n*!!! Immediately !!!* clear some space in {dir}."
        bashCommand = f"curl -X POST -H \"Content-type:application/json\" --data \"{{\'text\':\'{message}\'}}\" {URL}"
        os.system(bashCommand)
        time.sleep(warningExtremeFreq)
        continue

    time.sleep(detectorFreq)
