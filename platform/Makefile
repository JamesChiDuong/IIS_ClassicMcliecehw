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
	cd rtl 	   ; make -f rtl.mk clean
	cd verilog ; make -f verilog.mk clean
	cd cpp     ; make -f cpp.mk clean