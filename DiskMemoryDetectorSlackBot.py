### Control memory usage and send warnings to Slack ###

import subprocess
import os
import time

##################
targetDevice = '/dev/nvme0n1p4'
URL = "https://hooks.slack.com/services/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"

##################

while True:
    bashCommand = "df -h"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

    usage, dir = [dev for dev in output.decode('utf-8').split('\n') if
                     dev.startswith(targetDevice)][0].split()[4:6]

    bashCommand = f"curl -X POST -H \"Content-type:application/json\" --data \"{{\'text\':\'{message}\'}}\" {URL}"

    if int(usage.rstrip('%')) in range(80-85):
        message = f"Disk space has reached {usage}. Clear some space in {dir}."
        os.system(bashCommand)

    elif int(usage.rstrip('%')) in range(85-90):
        message = f"Disk space has reached {usage}. Clear some space in {dir}."
        os.system(bashCommand)
        time.sleep(1800)

    time.sleep(3600)


