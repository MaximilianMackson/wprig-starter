#!/bin/bash
if [ -e ./node_modules ] && [ -e ./vendor ]
then
    echo "/node_modules and /vendor found; will not run 'npm run rig-init'"
    npm run dev
else
    echo "/node_modules or /vendor not found; running 'npm run rig-init'..."
    # Later, add a line here to clone the WP Rig repo
    npm run rig-init \
    && npm run dev
fi