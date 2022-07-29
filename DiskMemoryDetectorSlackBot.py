### Control memory usage and send warnings to Slack ###

import subprocess
import os
import time
import sys

##################
URL = sys.argv[1]  # test URL
targetDevice = sys.argv[2]  # '/dev/nvme0n1p4'
warningFreq = 3600
warningExtremeFreq = 1800
detectorFreq = 3600
#################

while True:
    bashCommand = "df -h"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

    usage, dir = [dev for dev in output.decode('utf-8').split('\n') if
                     dev.startswith(targetDevice)][0].split()[4:6]



    if int(usage.rstrip('%')) in range(80,85):
        message = f"Disk space has reached *{usage}*.\nClear some space in {dir}."
        bashCommand = f"curl -X POST -H \"Content-type:application/json\" --data \"{{\'text\':\'{message}\'}}\" {URL}"
        os.system(bashCommand)
        time.sleep(warningFreq)
        continue

    elif int(usage.rstrip('%')) in range(85,96):
        message = f"Disk space has reached *{usage}*.\n*!!! Immediately !!!* clear some space in {dir}."
        bashCommand = f"curl -X POST -H \"Content-type:application/json\" --data \"{{\'text\':\'{message}\'}}\" {URL}"
        os.system(bashCommand)
        time.sleep(warningExtremeFreq)
        continue

    time.sleep(detectorFreq)


