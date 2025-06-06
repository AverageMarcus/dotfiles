#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart BusyCal Menu
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Kills the BusyCal process

pkill busycal-setapp.alarm
open /Applications/Setapp/BusyCal.app
