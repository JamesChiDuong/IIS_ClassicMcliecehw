testTop: 
	iverilog Transmitter.v Receiver.v  fullAdder.v baud_rate_generator.v Top.v
testcheck_add:
	python3 check_add.py

testgen_input:
	python3 gen_input.py
run:
	python3 gen_input.py | vvp a.out