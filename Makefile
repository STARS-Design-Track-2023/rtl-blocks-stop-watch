
# include binaries and libraries from ece270
export PATH := /home/shay/a/ece270/bin:$(PATH)
export LD_LIBRARY_PATH := /home/shay/a/ece270/lib:$(LD_LIBRARY_PATH)

# binary names
YOSYS=yosys
NEXTPNR=nextpnr-ice40
SHELL=bash

# project vars and filenames
PROJ	= stop_watch
PINMAP 	= pinmap.pcf
#TCLPREF = addwave.gtkw
SRC	= top.sv 
ICE   	= ice40hx8k.sv
UART	= uart/uart.v uart/uart_tx.v uart/uart_rx.v
FILES   = $(ICE) $(SRC) $(UART)
TB      = tb.sv
TRACE	= $(PROJ).vcd
BUILD   = ./build

# fpga specific configuration
DEVICE  = 8k
TIMEDEV = hx8k
FOOTPRINT = ct256

# set default target to cram
all: cram

# this target checks your code and synthesizes it into a netlist
$(BUILD)/$(PROJ).json : $(ICE) $(SRC) $(PINMAP) Makefile
	# lint with Verilator
	verilator --lint-only -Werror-WIDTH -Werror-SELRANGE -Werror-COMBDLY -Werror-LATCH -Werror-MULTIDRIVEN $(SRC)
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	$(YOSYS) -p "read_verilog -sv -noblackbox $(FILES); synth_ice40 -top ice40hx8k -json $(BUILD)/$(PROJ).json"
	
	
# Place and route using nextpnr
$(BUILD)/$(PROJ).asc : $(BUILD)/$(PROJ).json
	$(NEXTPNR) --hx8k --package ct256 --pcf $(PINMAP) --asc $(BUILD)/$(PROJ).asc --json $(BUILD)/$(PROJ).json 2> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2)
# Convert to bitstream using IcePack
$(BUILD)/$(PROJ).bin : $(BUILD)/$(PROJ).asc
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin
	
# synthesize and flash the FPGA
cram: $(BUILD)/$(PROJ).bin
	iceprog -S $(BUILD)/$(PROJ).bin

verify: $(TB) $(SRC)
	@iverilog -g2012  -o sim.vvp $(TB) $(SRC)
	@ vvp -N sim.vvp 1> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2)
	@rm -f sim.vvp

$(PROJ).vcd: $(TB) $(SRC)
	@iverilog -g2012  -o sim.vvp $(TB) $(SRC)
	@ vvp -N sim.vvp 1> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2)
	@rm -f sim.vvp

view_waveforms: $(PROJ).vcd
	gtkwave -a waves_format.gtkw $(PROJ).vcd
	
# remove intermediate build files
clean:
	rm -rf build/ verilog.log $(PROJ).vcd			
	
	
.PHONY: clean cram verify view_waveforms 

