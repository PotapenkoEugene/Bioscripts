### Control memory usage and send warnings to Slack ###

import subprocess
import os
import time
import datetime
import sys


####### Args ##########
# 1 URL
# 2 target device, example: /dev/nvme0n1p4
# 3 warning Frequency - 3600
# 4 warning Range start
# 5 warning Range end
# 6 - warning Extreme Frequency - 1800
# 7 - warning Extreme Range start
# 8 - warning Extreme Range end
# 9 - detector frequency - 3600
#######################

URL = sys.argv[1]
targetDevice = sys.argv[2]
warningFreq = int(sys.argv[3])
warningRange = range(int(sys.argv[4]), int(sys.argv[5]))
warningExtremeFreq = int(sys.argv[6])
warningExtremeRange = range(int(sys.argv[7]), int(sys.argv[8]))
detectorFreq = int(sys.argv[9])
nightTime = list(range(11)) + list(range(20, 25))  # from 20 to 10 hour is NIGHT
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
        bashCommand = f"curl -k -X POST -H \"Content-type:application/json\" --data \"{{\'text\':\'{message}\'}}\" {URL}"
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
