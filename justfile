default:
    @just --list

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl), bar sign_old.scad: its syntax error is the point
fmt:
    git ls-files -z '*.scad' ':!:fixes/zosenerdambrug_sign_reddit/sign_old.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' ':!:fixes/zosenerdambrug_sign_reddit/sign_old.scad' | xargs -0 -r -n1 topiary format --check
