#! /bin/bash

ruff --quiet check $@
# --quiet - do not show message "All checks passed!"

(exit 0) # replace exit code by 0