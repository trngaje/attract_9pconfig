#!/bin/bash

corename=`basename $2`

### Kill Command
#sudo killall xboxdrv > /dev/null 2>&1
#sudo killall evdevd > /dev/null 2>&1
killxboxdrv.sh

