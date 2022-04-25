default:
	cairo-compile schnorr2.cairo --output test_compiled.json

run: default
	cairo-run --program=test_compiled.json --print_output --print_info --relocate_prints --layout=small