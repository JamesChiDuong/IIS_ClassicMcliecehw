// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTranAndRecei.h for the primary calling header

#include "verilated.h"

#include "VTranAndRecei___024root.h"

VL_INLINE_OPT void VTranAndRecei___024root___ico_sequent__TOP__0(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___ico_sequent__TOP__0\n"); );
    // Body
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state;
    if ((2U & (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state))) {
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU != (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg)));
                }
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state = 0U;
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
}

void VTranAndRecei___024root___eval_ico(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_ico\n"); );
    // Body
    if (vlSelf->__VicoTriggered.at(0U)) {
        VTranAndRecei___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void VTranAndRecei___024root___eval_act(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_act\n"); );
}

VL_INLINE_OPT void VTranAndRecei___024root___nba_sequent__TOP__0(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___nba_sequent__TOP__0\n"); );
    // Init
    CData/*7:0*/ TranAndRecei__DOT____Vlvbound_hc237d6f7__0;
    TranAndRecei__DOT____Vlvbound_hc237d6f7__0 = 0;
    CData/*2:0*/ __Vdly__TranAndRecei__DOT__rx_next_state;
    __Vdly__TranAndRecei__DOT__rx_next_state = 0;
    CData/*3:0*/ __Vdly__TranAndRecei__DOT__rx_index;
    __Vdly__TranAndRecei__DOT__rx_index = 0;
    CData/*3:0*/ __Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0;
    __Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0;
    __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0;
    CData/*0:0*/ __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0;
    __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0;
    CData/*7:0*/ __Vdly__TranAndRecei__DOT__number1;
    __Vdly__TranAndRecei__DOT__number1 = 0;
    CData/*7:0*/ __Vdly__TranAndRecei__DOT__number2;
    __Vdly__TranAndRecei__DOT__number2 = 0;
    CData/*0:0*/ __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v3;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v3 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4 = 0;
    CData/*0:0*/ __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v4;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v4 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6 = 0;
    CData/*0:0*/ __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v6;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v6 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v7;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v7 = 0;
    CData/*2:0*/ __Vdly__TranAndRecei__DOT__tx_next_state;
    __Vdly__TranAndRecei__DOT__tx_next_state = 0;
    SData/*10:0*/ __Vdly__TranAndRecei__DOT__tx_index;
    __Vdly__TranAndRecei__DOT__tx_index = 0;
    // Body
    __Vdly__TranAndRecei__DOT__tx_index = vlSelf->TranAndRecei__DOT__tx_index;
    __Vdly__TranAndRecei__DOT__number2 = vlSelf->TranAndRecei__DOT__number2;
    __Vdly__TranAndRecei__DOT__number1 = vlSelf->TranAndRecei__DOT__number1;
    __Vdly__TranAndRecei__DOT__rx_index = vlSelf->TranAndRecei__DOT__rx_index;
    __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0U;
    __Vdly__TranAndRecei__DOT__tx_next_state = vlSelf->TranAndRecei__DOT__tx_next_state;
    __Vdly__TranAndRecei__DOT__rx_next_state = vlSelf->TranAndRecei__DOT__rx_next_state;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0 = 0U;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v4 = 0U;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v6 = 0U;
    if (((IData)(vlSelf->TranAndRecei__DOT__tx_done) 
         & (8U > (IData)(vlSelf->TranAndRecei__DOT__tx_index)))) {
        __Vdly__TranAndRecei__DOT__tx_index = (0x7ffU 
                                               & ((IData)(1U) 
                                                  + (IData)(vlSelf->TranAndRecei__DOT__tx_index)));
    } else if ((8U <= (IData)(vlSelf->TranAndRecei__DOT__tx_index))) {
        __Vdly__TranAndRecei__DOT__tx_index = 0U;
    }
    if ((4U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
        if ((2U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
            if ((1U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
                __Vdly__TranAndRecei__DOT__number2 
                    = vlSelf->TranAndRecei__DOT__number2;
                __Vdly__TranAndRecei__DOT__number1 
                    = vlSelf->TranAndRecei__DOT__number1;
                if (vlSelf->TranAndRecei__DOT__rx_done) {
                    __Vdly__TranAndRecei__DOT__rx_next_state = 0U;
                }
            } else {
                __Vdly__TranAndRecei__DOT__number1 = 0U;
                __Vdly__TranAndRecei__DOT__number1 = 0U;
                __Vdly__TranAndRecei__DOT__rx_next_state = 0U;
            }
        } else {
            __Vdly__TranAndRecei__DOT__number1 = 0U;
            __Vdly__TranAndRecei__DOT__number1 = 0U;
            __Vdly__TranAndRecei__DOT__rx_next_state = 0U;
        }
    } else if ((2U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
        if ((1U & (~ (IData)(vlSelf->TranAndRecei__DOT__rx_current_state)))) {
            __Vdly__TranAndRecei__DOT__number2 = (0xffU 
                                                  & ((((IData)(0x64U) 
                                                       * 
                                                       (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                        [4U] 
                                                        - (IData)(0x30U))) 
                                                      + 
                                                      ((IData)(0xaU) 
                                                       * 
                                                       (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                        [5U] 
                                                        - (IData)(0x30U)))) 
                                                     + 
                                                     (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                      [6U] 
                                                      - (IData)(0x30U))));
            __Vdly__TranAndRecei__DOT__number1 = vlSelf->TranAndRecei__DOT__number1;
        }
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
            __Vdly__TranAndRecei__DOT__rx_next_state = 7U;
        } else if (((0xaU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg)) 
                    & (IData)(vlSelf->TranAndRecei__DOT__rx_done))) {
            __Vdly__TranAndRecei__DOT__rx_next_state = 3U;
        }
    } else if ((1U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
        __Vdly__TranAndRecei__DOT__number2 = 0U;
        __Vdly__TranAndRecei__DOT__number1 = (0xffU 
                                              & ((((IData)(0x64U) 
                                                   * 
                                                   (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                    [0U] 
                                                    - (IData)(0x30U))) 
                                                  + 
                                                  ((IData)(0xaU) 
                                                   * 
                                                   (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                    [1U] 
                                                    - (IData)(0x30U)))) 
                                                 + 
                                                 (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                  [2U] 
                                                  - (IData)(0x30U))));
        if (((0x2dU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg)) 
             & (IData)(vlSelf->TranAndRecei__DOT__rx_done))) {
            __Vdly__TranAndRecei__DOT__rx_next_state = 2U;
        }
    } else {
        __Vdly__TranAndRecei__DOT__number2 = vlSelf->TranAndRecei__DOT__number2;
        __Vdly__TranAndRecei__DOT__number1 = (0xffU 
                                              & (IData)(vlSelf->TranAndRecei__DOT__number1));
        if (((0x2dU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg)) 
             & (IData)(vlSelf->TranAndRecei__DOT__rx_done))) {
            __Vdly__TranAndRecei__DOT__rx_next_state = 1U;
        }
    }
    if ((((0U == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg)) 
          & (IData)(vlSelf->TranAndRecei__DOT__rx_done)) 
         | (0xbU < (IData)(vlSelf->TranAndRecei__DOT__rx_index)))) {
        __Vdly__TranAndRecei__DOT__rx_index = 0U;
    } else if ((1U & (IData)(vlSelf->TranAndRecei__DOT__rx_done))) {
        __Vdly__TranAndRecei__DOT__rx_index = (0xfU 
                                               & ((IData)(1U) 
                                                  + (IData)(vlSelf->TranAndRecei__DOT__rx_index)));
    }
    TranAndRecei__DOT____Vlvbound_hc237d6f7__0 = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg;
    if ((0xbU >= (IData)(vlSelf->TranAndRecei__DOT__rx_index))) {
        __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0 
            = TranAndRecei__DOT____Vlvbound_hc237d6f7__0;
        __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0 = 1U;
        __Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0 
            = vlSelf->TranAndRecei__DOT__rx_index;
    }
    if ((0U == (IData)(vlSelf->TranAndRecei__DOT__tx_current_state))) {
        if ((7U == (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
            __Vdly__TranAndRecei__DOT__tx_next_state = 4U;
        }
    } else if ((4U == (IData)(vlSelf->TranAndRecei__DOT__tx_current_state))) {
        if ((6U < (IData)(vlSelf->TranAndRecei__DOT__tx_index))) {
            __Vdly__TranAndRecei__DOT__tx_next_state = 7U;
        }
    } else if ((7U == (IData)(vlSelf->TranAndRecei__DOT__tx_current_state))) {
        if (((0U == (IData)(vlSelf->TranAndRecei__DOT__rx_current_state)) 
             & (IData)(vlSelf->TranAndRecei__DOT__rx_done))) {
            __Vdly__TranAndRecei__DOT__tx_next_state = 0U;
        }
    } else {
        __Vdly__TranAndRecei__DOT__tx_next_state = 0U;
    }
    if ((7U == (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
        __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0 = 1U;
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1 
            = vlSelf->TranAndRecei__DOT__number1;
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2 
            = vlSelf->TranAndRecei__DOT__number2;
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v3 
            = vlSelf->TranAndRecei__DOT__selection;
        if ((0x100U >= (IData)(vlSelf->TranAndRecei__DOT__result))) {
            __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4 
                = (0xffU & (IData)(vlSelf->TranAndRecei__DOT__result));
            __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v4 = 1U;
        } else {
            __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6 
                = (0xffU & ((IData)(vlSelf->TranAndRecei__DOT__result) 
                            >> 8U));
            __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v6 = 1U;
            __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v7 
                = (0xffU & (IData)(vlSelf->TranAndRecei__DOT__result));
        }
    }
    vlSelf->TranAndRecei__DOT__tx_data_in = ((0x31U 
                                              >= (0x3fU 
                                                  & (IData)(vlSelf->TranAndRecei__DOT__tx_index)))
                                              ? vlSelf->TranAndRecei__DOT__tx_Data_Buffer
                                             [(0x3fU 
                                               & (IData)(vlSelf->TranAndRecei__DOT__tx_index))]
                                              : 0U);
    vlSelf->TranAndRecei__DOT__tx_Send = ((0U != (IData)(vlSelf->TranAndRecei__DOT__tx_current_state)) 
                                          & (4U == (IData)(vlSelf->TranAndRecei__DOT__tx_current_state)));
    vlSelf->TranAndRecei__DOT__rx_index = __Vdly__TranAndRecei__DOT__rx_index;
    vlSelf->TranAndRecei__DOT__tx_index = __Vdly__TranAndRecei__DOT__tx_index;
    if (__Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0) {
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0U] = 0x32U;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[1U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[2U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[3U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v3;
    }
    if (__Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v4) {
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[4U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[5U] = 0xaU;
    }
    if (__Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v6) {
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[4U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[5U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v7;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[6U] = 0xaU;
    }
    vlSelf->TranAndRecei__DOT__result = (0xffffU & 
                                         ((4U & (IData)(vlSelf->TranAndRecei__DOT__selection))
                                           ? ((2U & (IData)(vlSelf->TranAndRecei__DOT__selection))
                                               ? 0U
                                               : ((1U 
                                                   & (IData)(vlSelf->TranAndRecei__DOT__selection))
                                                   ? 0U
                                                   : 
                                                  VL_DIV_III(16, (IData)(vlSelf->TranAndRecei__DOT__number1), (IData)(vlSelf->TranAndRecei__DOT__number2))))
                                           : ((2U & (IData)(vlSelf->TranAndRecei__DOT__selection))
                                               ? ((1U 
                                                   & (IData)(vlSelf->TranAndRecei__DOT__selection))
                                                   ? 
                                                  ((IData)(vlSelf->TranAndRecei__DOT__number1) 
                                                   * (IData)(vlSelf->TranAndRecei__DOT__number2))
                                                   : 
                                                  ((IData)(vlSelf->TranAndRecei__DOT__number1) 
                                                   - (IData)(vlSelf->TranAndRecei__DOT__number2)))
                                               : ((1U 
                                                   & (IData)(vlSelf->TranAndRecei__DOT__selection))
                                                   ? 
                                                  ((IData)(vlSelf->TranAndRecei__DOT__number1) 
                                                   + (IData)(vlSelf->TranAndRecei__DOT__number2))
                                                   : 0U))));
    vlSelf->TranAndRecei__DOT__number1 = __Vdly__TranAndRecei__DOT__number1;
    vlSelf->TranAndRecei__DOT__number2 = __Vdly__TranAndRecei__DOT__number2;
    vlSelf->TranAndRecei__DOT__tx_current_state = ((IData)(vlSelf->reset)
                                                    ? 0U
                                                    : (IData)(vlSelf->TranAndRecei__DOT__tx_next_state));
    vlSelf->TranAndRecei__DOT__tx_next_state = __Vdly__TranAndRecei__DOT__tx_next_state;
    if ((1U & (~ ((IData)(vlSelf->TranAndRecei__DOT__rx_current_state) 
                  >> 2U)))) {
        if ((2U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
            if ((1U & (IData)(vlSelf->TranAndRecei__DOT__rx_current_state))) {
                if ((((0x61U == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                       [8U]) & (0x64U == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                [9U])) & (0x64U == 
                                          vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                          [0xaU]))) {
                    vlSelf->TranAndRecei__DOT__selection = 1U;
                } else if ((((0x73U == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                              [8U]) & (0x75U == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                       [9U])) & (0x62U 
                                                 == 
                                                 vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                 [0xaU]))) {
                    vlSelf->TranAndRecei__DOT__selection = 2U;
                } else if ((((0x6dU == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                              [8U]) & (0x75U == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                       [9U])) & (0x6cU 
                                                 == 
                                                 vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                 [0xaU]))) {
                    vlSelf->TranAndRecei__DOT__selection = 3U;
                } else if ((((0x64U == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                              [8U]) & (0x69U == vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                       [9U])) & (0x76U 
                                                 == 
                                                 vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                 [0xaU]))) {
                    vlSelf->TranAndRecei__DOT__selection = 4U;
                }
            }
        }
    }
    vlSelf->TranAndRecei__DOT__rx_current_state = ((IData)(vlSelf->reset)
                                                    ? 0U
                                                    : (IData)(vlSelf->TranAndRecei__DOT__rx_next_state));
    if (__Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0) {
        vlSelf->TranAndRecei__DOT__rx_Data_Buffer[__Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0] 
            = __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0;
    }
    vlSelf->TranAndRecei__DOT__rx_next_state = __Vdly__TranAndRecei__DOT__rx_next_state;
}

VL_INLINE_OPT void VTranAndRecei___024root___nba_sequent__TOP__1(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___nba_sequent__TOP__1\n"); );
    // Body
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg 
        = ((IData)(vlSelf->reset) | (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next));
    if (vlSelf->reset) {
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg = 0U;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg = 0U;
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg = 0U;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg = 0U;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state = 0U;
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg = 0U;
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state = 0U;
        vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter = 0U;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg = 0U;
    } else {
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg 
            = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg 
            = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next;
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg 
            = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg 
            = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state 
            = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state;
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg 
            = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next;
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state 
            = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state;
        vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter 
            = vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__next;
        vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg 
            = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next;
    }
    vlSelf->o_uart_tx = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg;
    vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__next 
        = ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))
            ? 0U : (0x3fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))));
    vlSelf->TranAndRecei__DOT__rx_done = 0U;
    vlSelf->TranAndRecei__DOT__tx_done = 0U;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg;
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg;
    if ((2U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
        vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next 
            = (1U & ((IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state) 
                     | (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg)));
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__tx_done = 1U;
                }
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
                }
            }
        }
    }
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state;
    vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next 
        = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg;
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
}

VL_INLINE_OPT void VTranAndRecei___024root___nba_comb__TOP__0(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___nba_comb__TOP__0\n"); );
    // Body
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg;
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state;
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next 
        = vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg;
    if ((2U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU != (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next 
                        = (0x1fU & ((IData)(1U) + (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg)));
                }
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state = 0U;
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
                    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next 
                        = (0xffU & ((IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg) 
                                    >> 1U));
                }
            }
        }
    } else {
        if ((1U & (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state))) {
            if ((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))) {
                if ((0xfU == (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg))) {
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

void VTranAndRecei___024root___eval_nba(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_nba\n"); );
    // Body
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VTranAndRecei___024root___nba_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
    if (vlSelf->__VnbaTriggered.at(1U)) {
        VTranAndRecei___024root___nba_sequent__TOP__1(vlSelf);
        vlSelf->__Vm_traceActivity[2U] = 1U;
    }
    if ((vlSelf->__VnbaTriggered.at(0U) | vlSelf->__VnbaTriggered.at(1U))) {
        VTranAndRecei___024root___nba_comb__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[3U] = 1U;
    }
}

void VTranAndRecei___024root___eval_triggers__ico(VTranAndRecei___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__ico(VTranAndRecei___024root* vlSelf);
#endif  // VL_DEBUG
void VTranAndRecei___024root___eval_triggers__act(VTranAndRecei___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__act(VTranAndRecei___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndRecei___024root___dump_triggers__nba(VTranAndRecei___024root* vlSelf);
#endif  // VL_DEBUG

void VTranAndRecei___024root___eval(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval\n"); );
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
        VTranAndRecei___024root___eval_triggers__ico(vlSelf);
        if (vlSelf->__VicoTriggered.any()) {
            __VicoContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VicoIterCount))) {
#ifdef VL_DEBUG
                VTranAndRecei___024root___dump_triggers__ico(vlSelf);
#endif
                VL_FATAL_MT("TranAndRecei.v", 3, "", "Input combinational region did not converge.");
            }
            vlSelf->__VicoIterCount = ((IData)(1U) 
                                       + vlSelf->__VicoIterCount);
            VTranAndRecei___024root___eval_ico(vlSelf);
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
            VTranAndRecei___024root___eval_triggers__act(vlSelf);
            if (vlSelf->__VactTriggered.any()) {
                vlSelf->__VactContinue = 1U;
                if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                    VTranAndRecei___024root___dump_triggers__act(vlSelf);
#endif
                    VL_FATAL_MT("TranAndRecei.v", 3, "", "Active region did not converge.");
                }
                vlSelf->__VactIterCount = ((IData)(1U) 
                                           + vlSelf->__VactIterCount);
                __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
                vlSelf->__VnbaTriggered.set(vlSelf->__VactTriggered);
                VTranAndRecei___024root___eval_act(vlSelf);
            }
        }
        if (vlSelf->__VnbaTriggered.any()) {
            __VnbaContinue = 1U;
            if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
                VTranAndRecei___024root___dump_triggers__nba(vlSelf);
#endif
                VL_FATAL_MT("TranAndRecei.v", 3, "", "NBA region did not converge.");
            }
            __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
            VTranAndRecei___024root___eval_nba(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
void VTranAndRecei___024root___eval_debug_assertions(VTranAndRecei___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->i_uart_rx & 0xfeU))) {
        Verilated::overWidthError("i_uart_rx");}
    if (VL_UNLIKELY((vlSelf->reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
}
#endif  // VL_DEBUG
