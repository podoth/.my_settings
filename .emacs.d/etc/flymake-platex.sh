#!/bin/bash
mkdir -p .flymake 1>/dev/null 2>&1
platex -output-directory=.flymake -aux-directory=.flymake -file-line-error -interaction=nonstopmode $1|egrep ".+:.+:.+"
exit 0
