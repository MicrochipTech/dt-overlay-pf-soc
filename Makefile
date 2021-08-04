CC?=$(CROSS_COMPILE)gcc
DTC_OPTIONS?=-@
DTC_OPTIONS += -Wno-unit_address_vs_reg -Wno-graph_child_address
KERNEL_DIR?=../linux
KERNEL_BUILD_DIR?=$(KERNEL_DIR)
DTC?=$(KERNEL_BUILD_DIR)/scripts/dtc/dtc

# workaround to make mkimage use the same dtc as we do
PATH:=$(shell dirname $(DTC)):$(PATH)

ICICLE_KIT_ES_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard icicle_kit_es/*.dtso))

%.pre.dtso: %.dtso
	$(CC) -E -nostdinc -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/riscv/boot/dts -x assembler-with-cpp -undef -o $@ $^

%.dtbo: %.pre.dtso
	$(DTC) $(DTC_OPTIONS) -I dts -O dtb -o $@ $^

%.itb: %.its %_dtbos
	mkimage -D "-i$(KERNEL_BUILD_DIR)/arch/riscv/boot -i$(KERNEL_BUILD_DIR)/arch/riscv/boot/dts -p 1000 $(DTC_OPTIONS)" -f $< $@

icicle_kit_es_dtbos: $(ICICLE_KIT_ES_DTBO_OBJECTS)

.PHONY: clean
clean:
	rm -f icicle_kit*/*.dtbo *.itb
