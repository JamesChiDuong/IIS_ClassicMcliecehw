all: rtl bench

.PHONY: rtl
## {{{
rtl:
	cd rtl ; make -f rtl.mk

.PHONY: bench
## {{{
bench: rtl
	cd verilog ; make -f verilog.mk
	cd cpp     ; make -f cpp.mk

clean:
	cd rtl 			 ; $(MAKE) --no-print-directory clean
	cd bench/verilog ; $(MAKE) --no-print-directory clean
	cd bench/cpp     ; $(MAKE) --no-print-directory clean