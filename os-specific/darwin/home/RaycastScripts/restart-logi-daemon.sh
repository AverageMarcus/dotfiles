#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart Logi daemon
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Kills the LogiMgr process to allow a new one to spawn

pkill LogiMgr
