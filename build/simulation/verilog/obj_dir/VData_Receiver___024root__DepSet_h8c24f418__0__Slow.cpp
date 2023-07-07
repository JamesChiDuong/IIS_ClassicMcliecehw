// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VData_Receiver.h for the primary calling header

#include "verilated.h"

#include "VData_Receiver___024root.h"

VL_ATTR_COLD void VData_Receiver___024root___eval_static(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_static\n"); );
}

VL_ATTR_COLD void VData_Receiver___024root___eval_initial__TOP(VData_Receiver___024root* vlSelf);

VL_ATTR_COLD void VData_Receiver___024root___eval_initial(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_initial\n"); );
    // Body
    VData_Receiver___024root___eval_initial__TOP(vlSelf);
    vlSelf->__Vtrigrprev__TOP__clk = vlSelf->clk;
    vlSelf->__Vtrigrprev__TOP__Data_Receiver__DOT__reset = 1U;
}

VL_ATTR_COLD void VData_Receiver___024root___eval_initial__TOP(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_initial__TOP\n"); );
    // Body
    vlSelf->Data_Receiver__DOT__reset = 1U;
}

VL_ATTR_COLD void VData_Receiver___024root___eval_final(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_final\n"); );
}

VL_ATTR_COLD void VData_Receiver___024root___eval_triggers__stl(VData_Receiver___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__stl(VData_Receiver___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___eval_stl(VData_Receiver___024root* vlSelf);

VL_ATTR_COLD void VData_Receiver___024root___eval_settle(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_settle\n"); );
    // Init
    CData/*0:0*/ __VstlContinue;
    // Body
    vlSelf->__VstlIterCount = 0U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        __VstlContinue = 0U;
        VData_Receiver___024root___eval_triggers__stl(vlSelf);
        if (vlSelf->__VstlTriggered.any()) {
            __VstlContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VstlIterCount))) {
#ifdef VL_DEBUG
                VData_Receiver___024root___dump_triggers__stl(vlSelf);
#endif
                VL_FATAL_MT("Data_Receiver.v", 2, "", "Settle region did not converge.");
            }
            vlSelf->__VstlIterCount = ((IData)(1U) 
                                       + vlSelf->__VstlIterCount);
            VData_Receiver___024root___eval_stl(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__stl(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VstlTriggered.at(0U)) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VData_Receiver___024root___stl_sequent__TOP__0(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___stl_sequent__TOP__0\n"); );
    // Body
    vlSelf->o_uart_tx = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_reg;
    vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__next 
        = ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))
            ? 0U : (0x3fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))));
    vlSelf->Data_Receiver__DOT__tx_done = 0U;
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next 
        = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg;
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next 
        = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg;
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next 
        = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg;
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next 
        = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg;
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state 
        = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state;
    vlSelf->Data_Receiver__DOT__rx_done = 0U;
    if ((2U & (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state))) {
        if ((1U & (~ (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state)))) {
            if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    if ((7U != (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg))) {
                        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next 
                            = (0xfU & ((IData)(1U) 
                                       + (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg)));
                    }
                    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next 
                        = (((IData)(vlSelf->i_uart_rx) 
                            << 7U) | (0x7fU & ((IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg) 
                                               >> 1U)));
                }
            }
        }
        if ((1U & (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU != (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg)));
                }
                if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state = 0U;
                    vlSelf->Data_Receiver__DOT__rx_done = 1U;
                }
            }
        } else if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
            if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next = 0U;
                if ((7U == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state = 3U;
                }
            } else {
                vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next 
                    = (0x1fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg)));
            }
        }
    } else if ((1U & (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state))) {
        if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
            if ((7U == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next = 0U;
                vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next = 0U;
                vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state = 2U;
            } else {
                vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next 
                    = (0x1fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg)));
            }
        }
    } else if ((1U & (~ (IData)(vlSelf->i_uart_rx)))) {
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next = 0U;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state = 1U;
    }
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next 
        = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg;
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state 
        = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state;
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next 
        = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg;
    if ((2U & (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state))) {
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_next 
            = (1U & ((IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state) 
                     | (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg)));
        if ((1U & (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__tx_done = 1U;
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state = 0U;
                }
                if ((0xfU != (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg)));
                }
            }
        } else if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
            if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next = 0U;
                if ((7U == (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state = 3U;
                }
            } else {
                vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next 
                    = (0x1fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg)));
            }
        }
        if ((1U & (~ (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state)))) {
            if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    if ((7U != (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg))) {
                        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next 
                            = (0xfU & ((IData)(1U) 
                                       + (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg)));
                    }
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next 
                        = (0xffU & ((IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg) 
                                    >> 1U));
                }
            }
        }
    } else {
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_next 
            = (1U & (~ (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state)));
        if ((1U & (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next = 0U;
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next = 0U;
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state = 2U;
                } else {
                    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg)));
                }
            }
        } else if (vlSelf->Data_Receiver__DOT__rx_done) {
            vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next = 0U;
            vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state = 1U;
        }
        if ((1U & (~ (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state)))) {
            if (vlSelf->Data_Receiver__DOT__rx_done) {
                vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next 
                    = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg;
            }
        }
    }
}

VL_ATTR_COLD void VData_Receiver___024root___eval_stl(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_stl\n"); );
    // Body
    if (vlSelf->__VstlTriggered.at(0U)) {
        VData_Receiver___024root___stl_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
        vlSelf->__Vm_traceActivity[0U] = 1U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__ico(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VicoTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VicoTriggered.at(0U)) {
        VL_DBG_MSGF("         'ico' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__act(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VactTriggered.at(0U)) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk)\n");
    }
    if (vlSelf->__VactTriggered.at(1U)) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(posedge Data_Receiver.reset or posedge clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__nba(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
    if (vlSelf->__VnbaTriggered.at(1U)) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(posedge Data_Receiver.reset or posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VData_Receiver___024root___ctor_var_reset(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->i_uart_rx = VL_RAND_RESET_I(1);
    vlSelf->o_uart_tx = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__data_buffer = VL_RAND_RESET_I(8);
    vlSelf->Data_Receiver__DOT__tx_fifo_out = VL_RAND_RESET_I(8);
    vlSelf->Data_Receiver__DOT__rx_done = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__tx_done = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__tx_empty = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__tx_fifo_not_empty = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__rx_empty = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__rx_full = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__tx_full = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter = VL_RAND_RESET_I(6);
    vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__next = VL_RAND_RESET_I(6);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state = VL_RAND_RESET_I(2);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state = VL_RAND_RESET_I(2);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg = VL_RAND_RESET_I(5);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next = VL_RAND_RESET_I(5);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg = VL_RAND_RESET_I(4);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next = VL_RAND_RESET_I(4);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg = VL_RAND_RESET_I(8);
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next = VL_RAND_RESET_I(8);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state = VL_RAND_RESET_I(2);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state = VL_RAND_RESET_I(2);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg = VL_RAND_RESET_I(5);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next = VL_RAND_RESET_I(5);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg = VL_RAND_RESET_I(4);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next = VL_RAND_RESET_I(4);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg = VL_RAND_RESET_I(8);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next = VL_RAND_RESET_I(8);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_reg = VL_RAND_RESET_I(1);
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_next = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigrprev__TOP__clk = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigrprev__TOP__Data_Receiver__DOT__reset = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
