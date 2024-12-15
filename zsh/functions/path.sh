#!/usr/bin/env bash
# echo out the path with a new line for each entry
echo -e ${PATH//:/\\n}
