#!/usr/bin/env bash

# This file will grab the current state of the system. The system will change over time and this will store snapshots that inform the next interation of dotfiles.

# this will grab all apps loaded from the App Store
find /Applications -path '*Contents/_MASReceipt/receipt' -maxdepth 4 -print |\sed 's#.app/Contents/_MASReceipt/receipt#.app#g; s#/Applications/##'
