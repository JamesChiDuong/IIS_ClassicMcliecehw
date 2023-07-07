// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTranAndRecei.h for the primary calling header

#include "verilated.h"

#include "VTranAndRecei___024root.h"

VL_ATTR_COLD void VTranAndRecei___024root___eval_static(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_static\n"); );
}

VL_ATTR_COLD void VTranAndRecei___024root___eval_initial__TOP(VTranAndRecei___024root* vlSelf);

VL_ATTR_COLD void VTranAndRecei___024root___eval_initial(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_initial\n"); );
    // Body
    VTranAndRecei___024root___eval_initial__TOP(vlSelf);
    vlSelf->__Vm_traceActivity[3U] = 1U;
    vlSelf->__Vm_traceActivity[2U] = 1U;
    vlSelf->__Vm_traceActivity[1U] = 1U;
    vlSelf->__Vm_traceActivity[0U] = 1U;
    vlSelf->__Vtrigrprev__TOP__clk = vlSelf->clk;
    vlSelf->__Vtrigrprev__TOP__TranAndRecei__DOT__reset = 1U;
}

VL_ATTR_COLD void VTranAndRecei___024root___eval_initial__TOP(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_initial__TOP\n"); );
    // Body
    vlSelf->TranAndRecei__DOT__cin = 0U;
    vlSelf->TranAndRecei__DOT__reset = 1U;
    vlSelf->TranAndRecei__DOT__tx_Send = 0U;
    vlSelf->TranAndRecei__DOT__str_index = 0U;
    vlSelf->TranAndRecei__DOT__CHECKOK = 0U;
    vlSelf->TranAndRecei__DOT__counter = 0xfffff00U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0U] = 0x20U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[1U] = 0x4eU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[2U] = 0x55U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[3U] = 0x4dU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[4U] = 0x42U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[5U] = 0x45U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[6U] = 0x52U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[7U] = 0x31U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[8U] = 0x3aU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0xdU] = 0x4eU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0xeU] = 0x55U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0xfU] = 0x4dU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x10U] = 0x42U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x11U] = 0x45U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x12U] = 0x52U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x13U] = 0x32U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x14U] = 0x3aU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x19U] = 0x53U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x1aU] = 0x55U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x1bU] = 0x4dU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x1cU] = 0x3aU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x21U] = 0x43U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x22U] = 0x4fU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x23U] = 0x55U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x24U] = 0x54U;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x25U] = 0x3aU;
    vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x27U] = 0xaU;
}

VL_ATTR_COLD void VTranAndRecei___024root___eval_final(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_final\n"); );
}

VL_ATTR_COLD void VTranAndRecei___024root___eval_triggers__stl(VTranAndRecei___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__stl(VTranAndRecei___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___eval_stl(VTranAndRecei___024root* vlSelf);

VL_ATTR_COLD void VTranAndRecei___024root___eval_settle(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_settle\n"); );
    // Init
    CData/*0:0*/ __VstlContinue;
    // Body
    vlSelf->__VstlIterCount = 0U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        __VstlContinue = 0U;
        VTranAndRecei___024root___eval_triggers__stl(vlSelf);
        if (vlSelf->__VstlTriggered.any()) {
            __VstlContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VstlIterCount))) {
#ifdef VL_DEBUG
                VTranAndRecei___024root___dump_triggers__stl(vlSelf);
#endif
                VL_FATAL_MT("TranAndRecei.v", 2, "", "Settle region did not converge.");
            }
            vlSelf->__VstlIterCount = ((IData)(1U) 
                                       + vlSelf->__VstlIterCount);
            VTranAndRecei___024root___eval_stl(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__stl(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VstlTriggered.at(0U)) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VTranAndRecei___024root___stl_sequent__TOP__0(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___stl_sequent__TOP__0\n"); );
    // Body
    vlSelf->o_uart_tx = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg;
    vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__next 
        = ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))
            ? 0U : (0x3fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))));
    vlSelf->TranAndRecei__DOT__rx_done = 0U;
    vlSelf->TranAndRecei__DOT__tx_done = 0U;
    vlSelf->TranAndRecei__DOT__sum = (0xffU & ((IData)(vlSelf->TranAndRecei__DOT__number1) 
                                               + ((IData)(vlSelf->TranAndRecei__DOT__number2) 
                                                  + (IData)(vlSelf->TranAndRecei__DOT__cin))));
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg;
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg;
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state;
    if ((2U & (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state))) {
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__rx_done = 1U;
                    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state = 0U;
                }
                if ((0xfU != (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg)));
                }
            }
        } else if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
            if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next = 0U;
                if ((7U == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state = 3U;
                }
            } else {
                vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next 
                    = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg)));
            }
        }
        if ((1U & (~ (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state)))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    if ((7U != (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg))) {
                        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next 
                            = (0xfU & ((IData)(1U) 
                                       + (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg)));
                    }
                    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next 
                        = (((IData)(vlSelf->i_uart_rx) 
                            << 7U) | (0x7fU & ((IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg) 
                                               >> 1U)));
                }
            }
        }
    } else if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state))) {
        if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
            if ((7U == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next = 0U;
                vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next = 0U;
                vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state = 2U;
            } else {
                vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next 
                    = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg)));
            }
        }
    } else if ((1U & (~ (IData)(vlSelf->i_uart_rx)))) {
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next = 0U;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state = 1U;
    }
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state;
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg;
    if ((2U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next 
            = (1U & ((IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state) 
                     | (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg)));
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__tx_done = 1U;
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state = 0U;
                }
                if ((0xfU != (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg)));
                }
            }
        } else if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
            if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next = 0U;
                if ((7U == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state = 3U;
                }
            } else {
                vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next 
                    = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg)));
            }
        }
        if ((1U & (~ (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state)))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    if ((7U != (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg))) {
                        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next 
                            = (0xfU & ((IData)(1U) 
                                       + (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg)));
                    }
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next 
                        = (0xffU & ((IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg) 
                                    >> 1U));
                }
            }
        }
    } else {
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next 
            = (1U & (~ (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state)));
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next = 0U;
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next = 0U;
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state = 2U;
                } else {
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg)));
                }
            }
        } else if (vlSelf->TranAndRecei__DOT__tx_Send) {
            vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next = 0U;
            vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state = 1U;
        }
        if ((1U & (~ (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state)))) {
            if (vlSelf->TranAndRecei__DOT__tx_Send) {
                vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next 
                    = vlSelf->TranAndRecei__DOT__tx_data_in;
            }
        }
    }
}

VL_ATTR_COLD void VTranAndRecei___024root___eval_stl(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_stl\n"); );
    // Body
    if (vlSelf->__VstlTriggered.at(0U)) {
        VTranAndRecei___024root___stl_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[3U] = 1U;
        vlSelf->__Vm_traceActivity[2U] = 1U;
        vlSelf->__Vm_traceActivity[1U] = 1U;
        vlSelf->__Vm_traceActivity[0U] = 1U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__ico(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___dump_triggers__ico\n"); );
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
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__act(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VactTriggered.at(0U)) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk)\n");
    }
    if (vlSelf->__VactTriggered.at(1U)) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(posedge TranAndRecei.reset or posedge clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__nba(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
    if (vlSelf->__VnbaTriggered.at(1U)) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(posedge TranAndRecei.reset or posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VTranAndRecei___024root___ctor_var_reset(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->i_uart_rx = VL_RAND_RESET_I(1);
    vlSelf->o_uart_tx = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__rx_index = VL_RAND_RESET_I(3);
    vlSelf->TranAndRecei__DOT__tx_index = VL_RAND_RESET_I(11);
    vlSelf->TranAndRecei__DOT__str_index = VL_RAND_RESET_I(2);
    for (int __Vi0 = 0; __Vi0 < 6; ++__Vi0) {
        vlSelf->TranAndRecei__DOT__rx_Data_Buffer[__Vi0] = VL_RAND_RESET_I(8);
    }
    for (int __Vi0 = 0; __Vi0 < 41; ++__Vi0) {
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[__Vi0] = VL_RAND_RESET_I(8);
    }
    vlSelf->TranAndRecei__DOT__tx_data_in = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__number1 = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__number2 = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__sum = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__cin = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__reset = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__tx_Send = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__tx_done = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__rx_done = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__counter = VL_RAND_RESET_I(28);
    vlSelf->TranAndRecei__DOT__CHECKOK = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__current_state = VL_RAND_RESET_I(3);
    vlSelf->TranAndRecei__DOT__next_state = VL_RAND_RESET_I(3);
    vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter = VL_RAND_RESET_I(6);
    vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__next = VL_RAND_RESET_I(6);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state = VL_RAND_RESET_I(2);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state = VL_RAND_RESET_I(2);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg = VL_RAND_RESET_I(5);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next = VL_RAND_RESET_I(5);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg = VL_RAND_RESET_I(4);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next = VL_RAND_RESET_I(4);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state = VL_RAND_RESET_I(2);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state = VL_RAND_RESET_I(2);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg = VL_RAND_RESET_I(5);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next = VL_RAND_RESET_I(5);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg = VL_RAND_RESET_I(4);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next = VL_RAND_RESET_I(4);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next = VL_RAND_RESET_I(8);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg = VL_RAND_RESET_I(1);
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigrprev__TOP__clk = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigrprev__TOP__TranAndRecei__DOT__reset = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
