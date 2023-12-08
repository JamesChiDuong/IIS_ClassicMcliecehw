'''
 * Function: This file generates the reduction module.
 *
 * Copyright (C) 2018
 * Authors: Wen Wang <wen.wang.ww349@yale.edu>
 *          Ruben Niederhagen <ruben@polycephaly.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
'''

# reduction

import argparse 
import math

parser = argparse.ArgumentParser(description='Generate reduction module: polynomial evaluation part.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-n', '--num', dest='n', type=int, required=True,
          help='number of coeffs')
parser.add_argument('-m', '--gf', dest='m', type=int, required=True, default=13,
          help='finite field (GF(2^m))')
parser.add_argument('-w', '--mem_width', dest='w', type=int, required=True, default=0,
          help='number of multipliers')
args = parser.parse_args()

num = args.n
gf = args.m
w = args.w

mul_pow = int(math.ceil(math.log(w, 2)))  

assert (int(math.pow(2, mul_pow)) == w), "number of multipliers used in reduction should be a power of 2!"

factor = mul_pow-(gf-int(math.ceil(math.log(num, 2)))-1)

num_power = int(math.log(num, 2)) # 128 = 2^7
dep_power = num_power-factor
depth = int(math.pow(2, dep_power))
mem_width = int(math.pow(2, (gf-num_power+factor)))//2

c = []
 
for i in range(num//2):
  c.append('0')
  c.append('1')
 
for i in range(num_power-1):
  period = int(math.pow(2, i+2))
  for j in range(num//period):
    for k in range(period):
      if(k < period//2):
        c[k+j*period] += '0'
      else:
        c[k+j*period] += '1'
 
int_c = []
for i in range(num):
    int_c.append(int(c[i], 2))

print("""
// reduction part in additive FFT module

module reduction (
  input  wire         clk,
  input  wire         start,
  input  wire [{0}:0] coeff_in,
  input  wire         rd_en,
  input  wire [{1}:0] rd_addr,
  output wire [{2}:0] mem_coeff_A_dout_0,
  output wire [{2}:0] mem_coeff_B_dout_0,
  output wire         done
);
""".format(num*gf-1, dep_power-1, mem_width*gf-1))

print("""//rearrange the coefficients based on reversal list

wire [{0}:0] coeff_re;
""".format(gf*num-1))

for i in range(num):
  print("assign coeff_re[{0}:{1}] = coeff_in[{2}:{3}];".format(gf*i+gf-1, gf*i, int_c[i]*gf+gf-1, int_c[i]*gf))
  
print("""
// initialize mem_coeff_A and mem_coeff_B

reg [{0}:0] init_counter = {2}'b0;
reg [{0}:0] init_counter_reg = {2}'b0;

always @(posedge clk)
  begin
    init_counter <= start ? init_counter + 1 :
                    (init_counter > 0) ? init_counter + 1 :
                    init_counter;
                    
    init_counter_reg <= init_counter;
  end
  
wire init_running;
reg init_running_reg = 1'b0;
reg init_running_reg_buffer = 1'b0;

reg rearrange_done = 1'b0;

assign init_running = start | (init_counter >= 1 && init_counter <= {1});

wire init_done;
assign init_done = (init_counter == {1});

always @(posedge clk)
  begin
    init_running_reg <= init_running;
    init_running_reg_buffer <= init_running_reg;
    
    rearrange_done <= (init_counter == {3}) ? 1'b1 : 1'b0;
  end
""".format(dep_power-2, int(depth/2)-1, dep_power-1, int(depth/2)-1))


print("""// generate coeff mem initialization contents
 
reg [{0}:0] coeff_reg = {1}'b0;

always @(posedge clk)
  begin
    coeff_reg <= start ? coeff_re : (coeff_reg >> {2});
   end  
""".format(gf*num-1, gf*num, int(math.pow(2, factor+1))*gf))

for i in range(int(math.pow(2, factor+1))):
  print("reg [{0}:0] coeff_lowest_{1} = {2}'b0;".format(gf-1, i, gf))

print("")
  
for i in range(int(math.pow(2, factor+1))):
  print("reg [{0}:0] coeff_lowest_{1}_buffer = {2}'b0;".format(gf-1, i, gf))
  
print("""
always @(posedge clk)
  begin""")

for i in range(int(math.pow(2, factor+1))):
  print("    coeff_lowest_{0} <= coeff_reg[{1}:{2}];".format(i, gf*(i+1)-1, i*gf))

print("")

for i in range(int(math.pow(2, factor+1))):
  print("    coeff_lowest_{0}_buffer <= coeff_lowest_{0};".format(i, gf*(i+1)-1, i*gf))
print("  end")

print("")

print("""// evaluation counter for each round

reg [{0}:0] eva_counter = {1}'b0;
reg [{2}:0] round_counter = {3}'b0;

reg round_done = 1'b0;
wire done_buffer;
 
assign done_buffer = (round_done && (round_counter == {5}));
 
always @(posedge clk)
  begin
    eva_counter <= done_buffer ? {1}'b0 :
                   (rearrange_done | round_done) ? eva_counter + 1 :
                   (eva_counter >= 1) ? eva_counter + 1 :
                   eva_counter;
    
    round_done <= start ? 1'b0 :
                  (eva_counter == {4}) ? 1'b1 :
                  1'b0;
                  
    round_counter <= start ? {3}'b0 :
                     (rearrange_done | round_done) ? round_counter + 1 :
                     round_counter;
  end

""".format(dep_power-1, dep_power, int(math.ceil(math.log(num_power, 2))), int(math.ceil(math.log(num_power, 2)))+1, depth-1, num_power))

print("// evaluation counter for each round")
print("")

for i in range(num_power): 
  print("wire round_{0}_running_reg;".format(i))
  for j in range(1, 7):
    print("reg round_{0}_running_reg_{1} = 1'b0;".format(i, j))
  print("")

for i in range(num_power):
  print("assign round_{0}_running_reg = (round_counter == {1});".format(i, i+1))
  
print("""
always @(posedge clk)
  begin""")

for i in range(num_power):
  print("    round_{0}_running_reg_1 <= round_{0}_running_reg;".format(i, 1))
  for j in range(2, 7):
    print("    round_{0}_running_reg_{1} <= round_{0}_running_reg_{2};".format(i, j, j-1))
  print("")
print("  end")

print("")

print("// interface for mem_coeff")

print("")

print("reg [{0}:0] mem_coeff_rd_address_0_first_factor_round = {2}'b0;".format(dep_power-1, i, dep_power))

for i in range(factor+1, num_power):
  print("reg [{0}:0] mem_coeff_rd_address_0_round_{1} = {2}'b0;".format(dep_power-1, i, dep_power))
 
print("""
always @(posedge clk)
  begin""")

print("    mem_coeff_rd_address_0_first_factor_round <= eva_counter;".format(i))
  
for i in range(factor+1, num_power-1):
  print("    mem_coeff_rd_address_0_round_{0} <= ((eva_counter >> {1}) << {1}) + ((eva_counter >> 1) % {2});".format(i, i+1-factor, int(math.pow(2, i-factor))))
print("    mem_coeff_rd_address_0_round_{0} <= ((eva_counter >> 1) % {1});".format(num_power-1, depth//2))
print("  end")
print("")

print("reg [{0}:0] mem_coeff_rd_address_1_first_factor_round = {2}'b0;".format(dep_power-1, i, dep_power))

for i in range(factor+1, num_power):
  print("reg [{0}:0] mem_coeff_rd_address_1_round_{1} = {2}'b0;".format(dep_power-1, i, dep_power))

print("""
always @(posedge clk)
  begin""")
print("    mem_coeff_rd_address_1_first_factor_round <= eva_counter + 1;".format(i))
for i in range(factor+1, num_power-1):
  print("    mem_coeff_rd_address_1_round_{0} <= ((eva_counter >> {1}) << {1}) + ((eva_counter >> 1) % {2}) + {2};".format(i, i+1-factor, int(math.pow(2, i-factor))))
print("    mem_coeff_rd_address_1_round_{0} <= ((eva_counter >> 1) % {1}) + {1};".format(num_power-1, depth//2))
print("end")

print("""
reg [{0}:0] mem_coeff_rd_address_0 = {1}'b0;
reg [{0}:0] mem_coeff_rd_address_1 = {1}'b0;""".format(dep_power-1, dep_power))

for i in range(2):
  print("wire [{0}:0] mem_coeff_rd_address_{1}_buffer_4;".format(dep_power-1, i, dep_power))

print("""
reg [{0}:0] mem_coeff_wr_address_0 = {1}'b0;
reg [{0}:0] mem_coeff_wr_address_1 = {1}'b0;
 
reg [{0}:0] mem_coeff_address_0 = {1}'b0;
reg [{0}:0] mem_coeff_address_1 = {1}'b0;""".format(dep_power-1, dep_power))

for i in range(1, 6):
  print("reg odd_signal_buffer_{0} = 1'b0;".format(i))
print("")

round_factor_str = "("
for i in range(factor+1):
  if (i == 0):
    round_factor_str += "round_{0}_running_reg".format(i)
  else:
    round_factor_str += " | round_{0}_running_reg".format(i)
round_factor_str += ")"

print("""
always @(posedge clk)
  begin
    mem_coeff_rd_address_0 <= {0} ? mem_coeff_rd_address_0_first_factor_round :""".format(round_factor_str))
 
for i in range(factor+1, num_power):
  print("                              round_{0}_running_reg ? mem_coeff_rd_address_0_round_{0} :".format(i))
print("                              {0}'b0;".format(dep_power))
print("")
print("    mem_coeff_rd_address_1 <= {0} ? mem_coeff_rd_address_1_first_factor_round :".format(round_factor_str))
for i in range(factor+1, num_power):
  print("                              round_{0}_running_reg ? mem_coeff_rd_address_1_round_{0} :".format(i))
print("                              {0}'b0;".format(dep_power))

print("""
    // delay between write and read: 5 cycles
    mem_coeff_wr_address_0 <= init_running_reg ? (init_counter_reg << 1) : mem_coeff_rd_address_0_buffer_4; 
    mem_coeff_wr_address_1 <= init_running_reg ? ((init_counter_reg << 1) + 1) : mem_coeff_rd_address_1_buffer_4; 
    
    mem_coeff_address_0 <= (init_running_reg_buffer | odd_signal_buffer_5) ? mem_coeff_wr_address_0 : mem_coeff_rd_address_0;
    mem_coeff_address_1 <= (init_running_reg_buffer | odd_signal_buffer_5) ? mem_coeff_wr_address_1 : mem_coeff_rd_address_1;
""".format(num_power-1, num_power))

print("  end")

 
print("""
wire [{0}:0] mem_coeff_A_address_0;
wire [{0}:0] mem_coeff_A_address_1;

reg [{0}:0] mem_coeff_B_address_0_buffer = {1}'b0;
reg [{0}:0] mem_coeff_B_address_1_buffer = {1}'b0;

wire [{0}:0] mem_coeff_B_address_0;
wire [{0}:0] mem_coeff_B_address_1;

always @(posedge clk)
  begin
    mem_coeff_B_address_0_buffer <= mem_coeff_address_0;
    mem_coeff_B_address_1_buffer <= mem_coeff_address_1;
  end

assign mem_coeff_A_address_0 = mem_coeff_address_0;
assign mem_coeff_A_address_1 = mem_coeff_address_1;

assign mem_coeff_B_address_0 = mem_coeff_B_address_0_buffer;
assign mem_coeff_B_address_1 = mem_coeff_B_address_1_buffer;""".format(dep_power-1, dep_power))

print("""
wire [{0}:0] mem_coeff_A_dout_1;

wire [{0}:0] mem_coeff_B_dout_1;

reg [{0}:0] mem_coeff_A_dout_0_reg = {1}'b0;
reg [{0}:0] mem_coeff_A_dout_0_reg_buffer_1 = {1}'b0;
reg [{0}:0] mem_coeff_A_dout_0_reg_buffer_2 = {1}'b0;

reg [{0}:0] mem_coeff_A_dout_1_reg = {1}'b0;
reg [{0}:0] mem_coeff_A_dout_1_reg_buffer_1 = {1}'b0;
reg [{0}:0] mem_coeff_A_dout_1_reg_buffer_2 = {1}'b0;

reg [{0}:0] mem_coeff_B_dout_0_reg = {1}'b0;
reg [{0}:0] mem_coeff_B_dout_0_reg_buffer_1 = {1}'b0;
reg [{0}:0] mem_coeff_B_dout_0_reg_buffer_2 = {1}'b0;

reg [{0}:0] mem_coeff_B_dout_1_reg = {1}'b0;
reg [{0}:0] mem_coeff_B_dout_1_reg_buffer_1 = {1}'b0;
reg [{0}:0] mem_coeff_B_dout_1_reg_buffer_2 = {1}'b0;

always @(posedge clk)
  begin
    mem_coeff_A_dout_0_reg <= mem_coeff_A_dout_0;
    mem_coeff_A_dout_0_reg_buffer_1 <= mem_coeff_A_dout_0_reg;
    mem_coeff_A_dout_0_reg_buffer_2 <= mem_coeff_A_dout_0_reg_buffer_1;

    mem_coeff_A_dout_1_reg <= mem_coeff_A_dout_1;
    mem_coeff_A_dout_1_reg_buffer_1 <= mem_coeff_A_dout_1_reg;
    mem_coeff_A_dout_1_reg_buffer_2 <= mem_coeff_A_dout_1_reg_buffer_1;

    mem_coeff_B_dout_0_reg <= mem_coeff_B_dout_0;
    mem_coeff_B_dout_0_reg_buffer_1 <= mem_coeff_B_dout_0_reg;
    mem_coeff_B_dout_0_reg_buffer_2 <= mem_coeff_B_dout_0_reg_buffer_1;

    mem_coeff_B_dout_1_reg <= mem_coeff_B_dout_1;
    mem_coeff_B_dout_1_reg_buffer_1 <= mem_coeff_B_dout_1_reg;
    mem_coeff_B_dout_1_reg_buffer_2 <= mem_coeff_B_dout_1_reg_buffer_1;	 
  end""".format(mem_width*gf-1, mem_width*gf))

print("""
reg mem_coeff_wr_en = 1'b0;

reg odd_signal = 1'b0;""")

 
print("""
always @(posedge clk)
  begin
    odd_signal <= (eva_counter % 2 == 1);
""") 

for i in range(1, 6):
  if (i == 1):
    print("    odd_signal_buffer_{0} <= odd_signal;".format(i))
  else:
    print("    odd_signal_buffer_{0} <= odd_signal_buffer_{1};".format(i, i-1))

print("""    
    mem_coeff_wr_en <= init_running_reg_buffer | odd_signal_buffer_5;
  end

wire mem_coeff_A_wr_en;
reg mem_coeff_B_wr_en = 1'b0;

assign mem_coeff_A_wr_en = mem_coeff_wr_en;

always @(posedge clk)
  begin
    mem_coeff_B_wr_en <= mem_coeff_wr_en;
  end""")

print("""
wire [{0}:0] vec_c;
reg [{0}:0] vec_c_reg = {1}'b0;
""".format(mem_width*gf-1, mem_width*gf))

print("// first \"factor\" rounds are special, others follows the patterns")

print("""
reg [{0}:0] mem_coeff_A_din_0 = {1}'b0;
reg [{0}:0] mem_coeff_A_din_1 = {1}'b0;

wire [{0}:0] mem_coeff_A_din_0_buffer;
wire [{0}:0] mem_coeff_A_din_1_buffer;

reg [{0}:0] mem_coeff_A_din_0_buffer_reg = {1}'b0;

// starting from round #"factor", the pattern gets regular
assign mem_coeff_A_din_0_buffer = vec_c_reg ^ mem_coeff_A_dout_0_reg_buffer_1;
assign mem_coeff_A_din_1_buffer = mem_coeff_A_din_0_buffer_reg ^ mem_coeff_A_dout_1_reg_buffer_2;
""".format(mem_width*gf-1, mem_width*gf))

if (factor != 0):
  print("// the first \"factor\" rounds are special")

  for i in range(factor): 
    for j in range(2):
      print("wire [{1}:0] mem_coeff_A_din_0_round_{0}_buffer_{2};".format(i, mem_width*gf-1, j))
    print("reg [{1}:0] mem_coeff_A_din_0_round_{0}_buffer_0_reg = {2}'b0;".format(i, mem_width*gf-1, mem_width*gf))
    print("")

  print("""
  always @(posedge clk)
    begin""")

  for i in range(factor):
    print("    mem_coeff_A_din_0_round_{0}_buffer_0_reg <= mem_coeff_A_din_0_round_{0}_buffer_0;".format(i))
  print("  end")

  print("")

  # check this part again

  for i in range(factor): # each round
    for j in range(int(math.pow(2, factor-i-1))): # within one round, number of identical patterns, for example, in round one, 01, 23, 45,... forms patterns
      for k in range(int(math.pow(2, i))): # within one pattern, different elements, for example, in pattern 01, there are 2 elements
        print("""assign mem_coeff_A_din_0_round_{0}_buffer_0[{1}:{2}] = (vec_c_reg[{3}:{4}] ^ mem_coeff_A_dout_0_reg_buffer_1[{1}:{2}]);
  assign mem_coeff_A_din_0_round_{0}_buffer_1[{3}:{4}] = (mem_coeff_A_din_0_round_{0}_buffer_0_reg[{1}:{2}] ^ mem_coeff_A_dout_0_reg_buffer_2[{3}:{4}]);""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))))
      print("")

  for i in range(factor):
    print("wire [{0}:0] mem_coeff_A_din_0_round_{1};".format(gf*mem_width-1, i))

  print("")

  for i in range(factor):
    for j in range(int(math.pow(2, factor-i-1))):
      for k in range(int(math.pow(2, i))):
        print("""assign mem_coeff_A_din_0_round_{0}[{1}:{2}] = mem_coeff_A_din_0_round_{0}_buffer_0_reg[{1}:{2}];
  assign mem_coeff_A_din_0_round_{0}[{3}:{4}] = mem_coeff_A_din_0_round_{0}_buffer_1[{3}:{4}];""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))))
    print("")

  # data_1

  for i in range(factor):
    for j in range(2):
      print("wire [{1}:0] mem_coeff_A_din_1_round_{0}_buffer_{2};".format(i, gf*mem_width-1, j))
    print("reg [{1}:0] mem_coeff_A_din_1_round_{0}_buffer_0_reg = {2}'b0;".format(i, mem_width*gf-1, mem_width*gf))
    print("") 

  print("""
  always @(posedge clk)
    begin""")

  for i in range(factor):
    print("    mem_coeff_A_din_1_round_{0}_buffer_0_reg <= mem_coeff_A_din_1_round_{0}_buffer_0;".format(i))
  print("  end")

  print("")

  # check this part again

  for i in range(factor):
    for j in range(int(math.pow(2, factor-i-1))):
      for k in range(int(math.pow(2, i))):
        print("""assign mem_coeff_A_din_1_round_{0}_buffer_0[{1}:{2}] = vec_c_reg[{5}:{6}] ^ mem_coeff_A_dout_1_reg_buffer_1[{1}:{2}];
  assign mem_coeff_A_din_1_round_{0}_buffer_1[{3}:{4}] = mem_coeff_A_din_1_round_{0}_buffer_0_reg[{1}:{2}] ^ mem_coeff_A_dout_1_reg_buffer_2[{3}:{4}];""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))))
      print("")

  for i in range(factor):
    print("wire [{0}:0] mem_coeff_A_din_1_round_{1};".format(gf*mem_width-1, i))

  print("")

  for i in range(factor):
    for j in range(int(math.pow(2, factor-i-1))):
      for k in range(int(math.pow(2, i))):
        print("""assign mem_coeff_A_din_1_round_{0}[{1}:{2}] = mem_coeff_A_din_1_round_{0}_buffer_0_reg[{1}:{2}];
  assign mem_coeff_A_din_1_round_{0}[{3}:{4}] = mem_coeff_A_din_1_round_{0}_buffer_1[{3}:{4}];""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))))
    print("")
   
    
din_0_str = ""
for i in range(factor):
  if (i == 0):
    din_0_str += "round_{0}_running_reg_5 ? mem_coeff_A_din_0_round_{0} :\n ".format(i)
  else:
    din_0_str += "                            round_{0}_running_reg_5 ? mem_coeff_A_din_0_round_{0} :\n ".format(i)
    
din_1_str = ""
for i in range(factor):
  if (i == 0):
    din_1_str += "round_{0}_running_reg_5 ? mem_coeff_A_din_1_round_{0} :\n ".format(i)
  else:
    din_1_str += "                            round_{0}_running_reg_5 ? mem_coeff_A_din_1_round_{0} :\n ".format(i)
    
      
print("""
always @(posedge clk)
  begin
    // mem_coeff initialization
    if(init_running_reg_buffer)
      begin""")
for i in range(int(math.pow(2, factor))):
  for j in range(mem_width//int(math.pow(2, factor))):
     print("""        mem_coeff_A_din_0[{0}:{1}] <= coeff_lowest_{2};""".format((i*mem_width//int(math.pow(2, factor))+j+1)*gf-1, (i*mem_width//int(math.pow(2, factor))+j)*gf, i, i+int(math.pow(2, factor))))

print("")

for i in range(int(math.pow(2, factor))):
  for j in range(mem_width//int(math.pow(2, factor))):
     print("""        mem_coeff_A_din_1[{0}:{1}] <= coeff_lowest_{3};""".format((i*mem_width//int(math.pow(2, factor))+j+1)*gf-1, (i*mem_width//int(math.pow(2, factor))+j)*gf, i, i+int(math.pow(2, factor))))
print("""      end
    else
      begin
        mem_coeff_A_din_0_buffer_reg <= mem_coeff_A_din_0_buffer;""")

if (factor == 0):
  print("        mem_coeff_A_din_0 <= mem_coeff_A_din_0_buffer_reg;")
else:
  print("        mem_coeff_A_din_0 <= {0}                            mem_coeff_A_din_0_buffer_reg;".format(din_0_str))

if (factor == 0):
  print("        mem_coeff_A_din_1 <= mem_coeff_A_din_1_buffer;")
else:
  print("        mem_coeff_A_din_1 <= {0}                            mem_coeff_A_din_1_buffer;".format(din_1_str))

print("      end")
print("  end")
 
print("""
reg [{0}:0] mem_coeff_B_din_0 = {1}'b0;
reg [{0}:0] mem_coeff_B_din_1 = {1}'b0;

wire [{0}:0] mem_coeff_B_din_0_buffer;
wire [{0}:0] mem_coeff_B_din_1_buffer;

reg [{0}:0] mem_coeff_B_din_0_buffer_reg = {1}'b0;

// starting from round #"factor", the pattern gets regular
assign mem_coeff_B_din_0_buffer = vec_c_reg ^ mem_coeff_B_dout_0_reg_buffer_1;
assign mem_coeff_B_din_1_buffer = mem_coeff_B_din_0_buffer_reg ^ mem_coeff_B_dout_1_reg_buffer_2;
""".format(mem_width*gf-1, mem_width*gf))

if (factor != 0):

  print("// the first \"factor\" rounds are special")

  for i in range(factor): 
    for j in range(2):
      print("wire [{1}:0] mem_coeff_B_din_0_round_{0}_buffer_{2};".format(i, mem_width*gf-1, j))
    print("reg [{1}:0] mem_coeff_B_din_0_round_{0}_buffer_0_reg = {2}'b0;".format(i, mem_width*gf-1, mem_width*gf))
    print("")

  print("""
  always @(posedge clk)
    begin""")

  for i in range(factor):
    print("    mem_coeff_B_din_0_round_{0}_buffer_0_reg <= mem_coeff_B_din_0_round_{0}_buffer_0;".format(i))
  print("  end")

  print("")

  # check this part again

  for i in range(factor): # each round
    for j in range(int(math.pow(2, factor-i-1))): # within one round, number of identical patterns, for example, in round one, 01, 23, 45,... forms patterns
      for k in range(int(math.pow(2, i))): # within one pattern, different elements, for example, in pattern 01, there are 2 elements
        print("""assign mem_coeff_B_din_0_round_{0}_buffer_0[{1}:{2}] = (vec_c_reg[{3}:{4}] ^ mem_coeff_B_dout_0_reg_buffer_1[{1}:{2}]);
  assign mem_coeff_B_din_0_round_{0}_buffer_1[{3}:{4}] = (mem_coeff_B_din_0_round_{0}_buffer_0_reg[{1}:{2}] ^ mem_coeff_B_dout_0_reg_buffer_2[{3}:{4}]);""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))))
      print("")

  for i in range(factor):
    print("wire [{0}:0] mem_coeff_B_din_0_round_{1};".format(gf*mem_width-1, i))

  print("")

  for i in range(factor):
    for j in range(int(math.pow(2, factor-i-1))):
      for k in range(int(math.pow(2, i))):
        print("""assign mem_coeff_B_din_0_round_{0}[{1}:{2}] = mem_coeff_B_din_0_round_{0}_buffer_0_reg[{1}:{2}];
  assign mem_coeff_B_din_0_round_{0}[{3}:{4}] = mem_coeff_B_din_0_round_{0}_buffer_1[{3}:{4}];""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))))
    print("")

  # data_1

  for i in range(factor):
    for j in range(2):
      print("wire [{1}:0] mem_coeff_B_din_1_round_{0}_buffer_{2};".format(i, gf*mem_width-1, j))
    print("reg [{1}:0] mem_coeff_B_din_1_round_{0}_buffer_0_reg = {2}'b0;".format(i, mem_width*gf-1, mem_width*gf))
    print("") 



  print("""
  always @(posedge clk)
    begin""")

  for i in range(factor):
    print("    mem_coeff_B_din_1_round_{0}_buffer_0_reg <= mem_coeff_B_din_1_round_{0}_buffer_0;".format(i))
  print("  end")

  print("")



  for i in range(factor):
    for j in range(int(math.pow(2, factor-i-1))):
      for k in range(int(math.pow(2, i))):
        print("""assign mem_coeff_B_din_1_round_{0}_buffer_0[{1}:{2}] = vec_c_reg[{5}:{6}] ^ mem_coeff_B_dout_1_reg_buffer_1[{1}:{2}];
  assign mem_coeff_B_din_1_round_{0}_buffer_1[{3}:{4}] = mem_coeff_B_din_1_round_{0}_buffer_0_reg[{1}:{2}] ^ mem_coeff_B_dout_1_reg_buffer_2[{3}:{4}];""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))))
      print("")

  for i in range(factor):
    print("wire [{0}:0] mem_coeff_B_din_1_round_{1};".format(gf*mem_width-1, i))

  print("")

  for i in range(factor):
    for j in range(int(math.pow(2, factor-i-1))):
      for k in range(int(math.pow(2, i))):
        print("""assign mem_coeff_B_din_1_round_{0}[{1}:{2}] = mem_coeff_B_din_1_round_{0}_buffer_0_reg[{1}:{2}];
  assign mem_coeff_B_din_1_round_{0}[{3}:{4}] = mem_coeff_B_din_1_round_{0}_buffer_1[{3}:{4}];""".format(i, gf*(k+1+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1))))*mem_width//int(math.pow(2, factor)), gf*(k+1+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))-1, gf*(k+j*(int(math.pow(2, i+1)))+int(math.pow(2, i)))*mem_width//int(math.pow(2, factor))))
    print("")

    
din_0_str = ""
for i in range(factor):
  if (i == 0):
    din_0_str += "round_{0}_running_reg_6 ? mem_coeff_B_din_0_round_{0} :\n ".format(i)
  else:
    din_0_str += "                            round_{0}_running_reg_6 ? mem_coeff_B_din_0_round_{0} :\n ".format(i)
    
din_1_str = ""
for i in range(factor):
  if (i == 0):
    din_1_str += "round_{0}_running_reg_6 ? mem_coeff_B_din_1_round_{0} :\n ".format(i)
  else:
    din_1_str += "                            round_{0}_running_reg_6 ? mem_coeff_B_din_1_round_{0} :\n ".format(i)
    
      
print("""
reg init_running_reg_buffer_B = 1'b0;

always @(posedge clk)
  begin
    init_running_reg_buffer_B <= init_running_reg_buffer;
    
    // mem_coeff initialization
    if(init_running_reg_buffer_B)
      begin""")
for i in range(int(math.pow(2, factor))):
  for j in range(mem_width//int(math.pow(2, factor))):
     print("""        mem_coeff_B_din_0[{0}:{1}] <= coeff_lowest_{2}_buffer;""".format((i*mem_width//int(math.pow(2, factor))+j+1)*gf-1, (i*mem_width//int(math.pow(2, factor))+j)*gf, i, i+int(math.pow(2, factor))))

print("")

for i in range(int(math.pow(2, factor))):
  for j in range(mem_width//int(math.pow(2, factor))):
     print("""        mem_coeff_B_din_1[{0}:{1}] <= coeff_lowest_{3}_buffer;""".format((i*mem_width//int(math.pow(2, factor))+j+1)*gf-1, (i*mem_width//int(math.pow(2, factor))+j)*gf, i, i+int(math.pow(2, factor))))
print("""      end
    else
      begin
        mem_coeff_B_din_0_buffer_reg <= mem_coeff_B_din_0_buffer;""")

if (factor == 0):
  print("        mem_coeff_B_din_0 <= mem_coeff_B_din_0_buffer_reg;")
else:
  print("        mem_coeff_B_din_0 <= {0}                            mem_coeff_B_din_0_buffer_reg;".format(din_0_str))

if (factor == 0):
  print("        mem_coeff_B_din_1 <= mem_coeff_B_din_1_buffer;")
else:
  print("        mem_coeff_B_din_1 <= {0}                            mem_coeff_B_din_1_buffer;".format(din_1_str))
print("      end")
print("  end") 
 
print("""
wire [{0}:0] mem_consts_dout;""".format(2*gf*mem_width-1))

round_str = ""
for i in range(factor):
  if (i == 0):
    round_str += "round_{0}_running".format(i)
  else:
    round_str += " | round_{0}_running".format(i)
    
vec_a_str_A = []
for i in range(factor): # rounds
  vec_a_str_A.append("")
  for j in range(int(math.pow(2, factor-1-i))):
    for k in range(int(math.pow(2, i))):
      vec_a_str_A[i] += ("mem_coeff_A_dout_0[{0}:{1}], ".format(gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-k*mem_width//int(math.pow(2, factor)))-1, gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-(k+1)*mem_width//int(math.pow(2, factor)))))
    for k in range(int(math.pow(2, i))):
      if(k == (int(math.pow(2, i))-1) and (j == (int(math.pow(2, factor-1-i))-1))):
        vec_a_str_A[i] += ("mem_coeff_A_dout_1[{0}:{1}]".format(gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-k*mem_width//int(math.pow(2, factor)))-1, gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-(k+1)*mem_width//int(math.pow(2, factor)))))
      else:
        vec_a_str_A[i] += ("mem_coeff_A_dout_1[{0}:{1}], ".format(gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-k*mem_width//int(math.pow(2, factor)))-1, gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-(k+1)*mem_width//int(math.pow(2, factor)))))
  vec_a_str_A[i] = "{" + vec_a_str_A[i]
  vec_a_str_A[i] += "}"

vec_a_str_B = []
for i in range(factor): # rounds
  vec_a_str_B.append("")
  for j in range(int(math.pow(2, factor-1-i))):
    for k in range(int(math.pow(2, i))):
      vec_a_str_B[i] += ("mem_coeff_B_dout_0[{0}:{1}], ".format(gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-k*mem_width//int(math.pow(2, factor)))-1, gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-(k+1)*mem_width//int(math.pow(2, factor)))))
    for k in range(int(math.pow(2, i))):
      if(k == (int(math.pow(2, i))-1) and (j == (int(math.pow(2, factor-1-i))-1))):
        vec_a_str_B[i] += ("mem_coeff_B_dout_1[{0}:{1}]".format(gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-k*mem_width//int(math.pow(2, factor)))-1, gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-(k+1)*mem_width//int(math.pow(2, factor)))))
      else:
        vec_a_str_B[i] += ("mem_coeff_B_dout_1[{0}:{1}], ".format(gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-k*mem_width//int(math.pow(2, factor)))-1, gf*(mem_width-j*mem_width//int(math.pow(2, factor-i-1))-(k+1)*mem_width//int(math.pow(2, factor)))))
  vec_a_str_B[i] = "{" + vec_a_str_B[i]
  vec_a_str_B[i] += "}"
         
      
print("""
// interface for vec_mul module
// time mux the vector multiplier

reg [{0}:0] vec_a = {1}'b0;
 
always @(posedge clk)
  begin""".format(mem_width*gf-1, mem_width*gf))

if (factor == 0):
  print("""    vec_a <= odd_signal_buffer_2 ? mem_coeff_A_dout_1 : 
             mem_coeff_B_dout_1;""")
else:
  for i in range(factor):
    if (i == 0):
      print("""    vec_a <= (odd_signal_buffer_2 && round_{0}_running_reg_3) ? {1} :
               round_{0}_running_reg_3 ? {2} :""".format(i, vec_a_str_A[i], vec_a_str_B[i]))
    else:
      print("""             (odd_signal_buffer_2 && round_{0}_running_reg_3) ? {1} :
               round_{0}_running_reg_3 ? {2} :""".format(i, vec_a_str_A[i], vec_a_str_B[i])) 
  print("""             odd_signal_buffer_2 ? mem_coeff_A_dout_1 : 
               mem_coeff_B_dout_1;""")
print("  end")

print("""
reg [{0}:0] vec_b = {1}'b0;
reg [{0}:0] mem_consts_B_reg = {1}'b0;

always @(posedge clk)
  begin
    mem_consts_B_reg <= mem_consts_dout[{2}:{3}];  
    
    vec_b <= odd_signal_buffer_2 ? mem_consts_dout[{0}:0] : mem_consts_B_reg;
    
    vec_c_reg <= vec_c;
  end
""".format(mem_width*gf-1, mem_width*gf, 2*mem_width*gf-1, mem_width*gf))

consts_str = ""
for i in range(factor+1):
  if(i == 0):
    consts_str += "round_{0}_running_reg ? {1}'b0 :".format(i, int(math.ceil(math.log((math.pow(2, gf-factor)+factor-1), 2))))
  else:                                                                        
    consts_str += "\n                                   round_{0}_running_reg ? {1} :".format(i, i)                                                                        

                                                                        
                                                                        
print("""
// interface for mem_consts

wire mem_consts_rd_en;
assign mem_consts_rd_en = 1'b1;

reg [{0}:0] mem_consts_rdaddress_buffer = {1}'b0;
reg [{0}:0] mem_consts_rdaddress = {1}'b0;

always @(posedge clk)
  begin
    mem_consts_rdaddress_buffer <= {2}""".format(int(math.ceil(math.log(depth+factor-1, 2)))-1, int(math.ceil(math.log(depth+factor-1, 2))), consts_str))
                                                                        
# FIXME here.
                                                                        
for i in range(factor+1, num_power):
  if (i == (num_power-1)):
    print("                                   round_{0}_running_reg ? {1} + (eva_counter >> 1) :".format(i, int(math.pow(2, i-factor))+factor-1))
  else:
    print("                                   round_{0}_running_reg ? {2} + ((eva_counter % {1}) >> 1) :".format(i, int(math.pow(2, i-factor+1)), int(math.pow(2, i-factor))+factor-1))
print("""                                   0;

    mem_consts_rdaddress <= mem_consts_rdaddress_buffer;
  end
""".format(int(math.ceil(int(math.log((math.pow(2, gf-factor)+factor-1), 2))))-1, int(math.ceil(int(math.log((math.pow(2, gf-factor)+factor-1), 2))))))

 

 
print("// delay modules")  
for i in range(2):
  print("""
delay #(.WIDTH({0}), .DELAY(4)) delay_inst_rd_addr_{1} (
  .clk(clk),
  .din(mem_coeff_rd_address_{1}),
  .dout(mem_coeff_rd_address_{1}_buffer_4)
);""".format(dep_power, i))
  
print("""
delay #(.WIDTH(1), .DELAY(8)) delay_inst_done (
  .clk(clk),
  .din(done_buffer),
  .dout(done)
);
""")

print("""// vec_mul module

vec_mul_reduction vec_mul_reduction_inst (
  .clk(clk),
  .vec_a(vec_a),
  .vec_b(vec_b),
  .vec_c(vec_c)
);

// two dual-port mem modules for storing evaluation data

mem_dual #(.WIDTH({0}), .DEPTH({1})) mem_coeff_A (
  .clock (clk),
  .data_0 (mem_coeff_A_din_0),
  .data_1 (mem_coeff_A_din_1),
  .address_0 (rd_en ? rd_addr : mem_coeff_A_address_0),
  .address_1 (mem_coeff_A_address_1),
  .wren_0 (mem_coeff_A_wr_en),
  .wren_1 (mem_coeff_A_wr_en),
  .q_0 (mem_coeff_A_dout_0),
  .q_1 (mem_coeff_A_dout_1)
);
 
mem_dual #(.WIDTH({0}), .DEPTH({1})) mem_coeff_B (
  .clock (clk),
  .data_0 (mem_coeff_B_din_0),
  .data_1 (mem_coeff_B_din_1),
  .address_0 (rd_en ? rd_addr : mem_coeff_B_address_0),
  .address_1 (mem_coeff_B_address_1),
  .wren_0 (mem_coeff_B_wr_en),
  .wren_1 (mem_coeff_B_wr_en),
  .q_0 (mem_coeff_B_dout_0),
  .q_1 (mem_coeff_B_dout_1)
);
 
// one single-port mem module for string constants data

mem #(.WIDTH({3}), .DEPTH({4})) mem_consts (
  .clock (clk),
  .data (0),
  .rdaddress (mem_consts_rdaddress),
  .rden (mem_consts_rd_en),
  .wraddress (0),
  .wren (0),
  .q (mem_consts_dout)
);

`ifdef VERILATOR
   defparam mem_consts.FILE = `FILE_MEM_CONSTS;
`else
   defparam mem_consts.FILE = "`FILE_MEM_CONSTS";
`endif

endmodule

""".format(mem_width*gf, depth, mem_width, 2*mem_width*gf, depth+factor-1))

