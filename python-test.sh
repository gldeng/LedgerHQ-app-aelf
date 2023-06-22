#!/usr/bin/env bash
device_label=${1:-"nanos"} # "nanos", "nanox", "nanosp"
app_name=${2:-"aelf"} # "aelf", "ethereum"

if [[ $app_name == "aelf" ]]; then
    [ -f bin/app.elf ] && mv bin/app.elf bin/aelf_${device_label}.elf
    mkdir -p tests/elfs
    cp bin/*.elf tests/elfs
else
    [ -f bin_eth/app.elf ] && mv bin_eth/app.elf bin_eth/aelf_${device_label}.elf
    mkdir -p tests/elfs
    cp bin_eth/*.elf tests/elfs
fi

echo "Running tests for ${app_name} on ${device_label}"

pytest -s tests/python/ -v --tb=short --device ${device_label} -p no:warnings