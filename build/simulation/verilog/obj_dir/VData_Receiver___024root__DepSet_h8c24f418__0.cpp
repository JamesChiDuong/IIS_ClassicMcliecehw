// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VData_Receiver.h for the primary calling header

#include "verilated.h"

#include "VData_Receiver___024root.h"

VL_INLINE_OPT void VData_Receiver___024root___ico_sequent__TOP__0(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___ico_sequent__TOP__0\n"); );
    // Body
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next 
        = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg;
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next 
        = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg;
    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state 
        = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state;
    if ((2U & (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state))) {
        if ((1U & (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU != (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg)));
                }
                if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state = 0U;
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
        if ((1U & (~ (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state)))) {
            if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next 
                        = (((IData)(vlSelf->i_uart_rx) 
                            << 7U) | (0x7fU & ((IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg) 
                                               >> 1U)));
                }
            }
        }
    } else if ((1U & (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state))) {
        if ((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))) {
            if ((7U == (IData)(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg))) {
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
}

void VData_Receiver___024root___eval_ico(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_ico\n"); );
    // Body
    if (vlSelf->__VicoTriggered.at(0U)) {
        VData_Receiver___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void VData_Receiver___024root___eval_act(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_act\n"); );
}

VL_INLINE_OPT void VData_Receiver___024root___nba_sequent__TOP__0(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___nba_sequent__TOP__0\n"); );
    // Body
    vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_reg 
        = ((IData)(vlSelf->Data_Receiver__DOT__reset) 
           | (IData)(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_next));
    if (vlSelf->Data_Receiver__DOT__reset) {
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg = 0U;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg = 0U;
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg = 0U;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg = 0U;
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg = 0U;
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state = 0U;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg = 0U;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state = 0U;
        vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter = 0U;
    } else {
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg 
            = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg 
            = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next;
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg 
            = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg 
            = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next;
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg 
            = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next;
        vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state 
            = vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg 
            = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next;
        vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state 
            = vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state;
        vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter 
            = vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__next;
    }
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

VL_INLINE_OPT void VData_Receiver___024root___nba_sequent__TOP__1(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___nba_sequent__TOP__1\n"); );
    // Body
    vlSelf->Data_Receiver__DOT__reset = 0U;
}

void VData_Receiver___024root___eval_nba(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_nba\n"); );
    // Body
    if (vlSelf->__VnbaTriggered.at(1U)) {
        VData_Receiver___024root___nba_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VData_Receiver___024root___nba_sequent__TOP__1(vlSelf);
    }
}

void VData_Receiver___024root___eval_triggers__ico(VData_Receiver___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__ico(VData_Receiver___024root* vlSelf);
#endif  // VL_DEBUG
void VData_Receiver___024root___eval_triggers__act(VData_Receiver___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__act(VData_Receiver___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__nba(VData_Receiver___024root* vlSelf);
#endif  // VL_DEBUG

void VData_Receiver___024root___eval(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval\n"); );
    // Init
    CData/*0:0*/ __VicoContinue;
    VlTriggerVec<2> __VpreTriggered;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    vlSelf->__VicoIterCount = 0U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        __VicoContinue = 0U;
        VData_Receiver___024root___eval_triggers__ico(vlSelf);
        if (vlSelf->__VicoTriggered.any()) {
            __VicoContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VicoIterCount))) {
#ifdef VL_DEBUG
                VData_Receiver___024root___dump_triggers__ico(vlSelf);
#endif
                VL_FATAL_MT("Data_Receiver.v", 2, "", "Input combinational region did not converge.");
            }
            vlSelf->__VicoIterCount = ((IData)(1U) 
                                       + vlSelf->__VicoIterCount);
            VData_Receiver___024root___eval_ico(vlSelf);
        }
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        __VnbaContinue = 0U;
        vlSelf->__VnbaTriggered.clear();
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            vlSelf->__VactContinue = 0U;
            VData_Receiver___024root___eval_triggers__act(vlSelf);
            if (vlSelf->__VactTriggered.any()) {
                vlSelf->__VactContinue = 1U;
                if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                    VData_Receiver___024root___dump_triggers__act(vlSelf);
#endif
                    VL_FATAL_MT("Data_Receiver.v", 2, "", "Active region did not converge.");
                }
                vlSelf->__VactIterCount = ((IData)(1U) 
                                           + vlSelf->__VactIterCount);
                __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
                vlSelf->__VnbaTriggered.set(vlSelf->__VactTriggered);
                VData_Receiver___024root___eval_act(vlSelf);
            }
        }
        if (vlSelf->__VnbaTriggered.any()) {
            __VnbaContinue = 1U;
            if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
                VData_Receiver___024root___dump_triggers__nba(vlSelf);
#endif
                VL_FATAL_MT("Data_Receiver.v", 2, "", "NBA region did not converge.");
            }
            __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
            VData_Receiver___024root___eval_nba(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
void VData_Receiver___024root___eval_debug_assertions(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->i_uart_rx & 0xfeU))) {
        Verilated::overWidthError("i_uart_rx");}
}
#endif  // VL_DEBUG
