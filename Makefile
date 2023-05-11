all: rtl bench test

.PHONY: rtl
## {{{
rtl:
	cd rtl ; $(MAKE) --no-print-directory

.PHONY: bench
## {{{
bench: rtl
	cd bench/verilog ; $(MAKE) --no-print-directory
	cd bench/cpp     ; $(MAKE) --no-print-directory

.PHONY: test
## {{{
test: bench
	bench/cpp/Data_Receiver
	# bench/cpp/Data_Transmitter 
## }}}

.PHONY: clean
## {{{
clean:
	cd rtl ; $(MAKE) --no-print-directory clean
	cd bench/verilog ; $(MAKE) --no-print-directory clean
	cd bench/cpp     ; $(MAKE) --no-print-directory clean
## }}}