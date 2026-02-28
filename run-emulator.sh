#!/bin/bash

qemu-system-x86_64 -accel tcg -smp 8 -m 4G -M q35 -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd -drive if=pflash,format=raw,file=OVMF_VARS.fd -drive file=bootable.img,format=raw
