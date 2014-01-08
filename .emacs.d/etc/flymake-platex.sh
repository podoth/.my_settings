#!/bin/bash
platex -file-line-error -interaction=nonstopmode $1|egrep ".+:.+:.+"
exit 0
