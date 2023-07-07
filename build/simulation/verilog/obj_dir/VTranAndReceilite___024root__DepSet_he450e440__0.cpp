// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTranAndReceilite.h for the primary calling header

#include "verilated.h"

#include "VTranAndReceilite___024root.h"

VL_INLINE_OPT void VTranAndReceilite___024root___ico_sequent__TOP__0(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___ico_sequent__TOP__0\n"); );
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

void VTranAndReceilite___024root___eval_ico(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___eval_ico\n"); );
    // Body
    if (vlSelf->__VicoTriggered.at(0U)) {
        VTranAndReceilite___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void VTranAndReceilite___024root___eval_act(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___eval_act\n"); );
}

VL_INLINE_OPT void VTranAndReceilite___024root___nba_sequent__TOP__0(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___nba_sequent__TOP__0\n"); );
    // Init
    CData/*7:0*/ TranAndRecei__DOT____Vlvbound_hd9e068fe__0;
    TranAndRecei__DOT____Vlvbound_hd9e068fe__0 = 0;
    CData/*2:0*/ __Vdly__TranAndRecei__DOT__rx_index;
    __Vdly__TranAndRecei__DOT__rx_index = 0;
    CData/*1:0*/ __Vdly__TranAndRecei__DOT__str_index;
    __Vdly__TranAndRecei__DOT__str_index = 0;
    CData/*2:0*/ __Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0;
    __Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0;
    __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0;
    CData/*0:0*/ __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0;
    __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0;
    CData/*7:0*/ __Vdly__TranAndRecei__DOT__number1;
    __Vdly__TranAndRecei__DOT__number1 = 0;
    CData/*7:0*/ __Vdly__TranAndRecei__DOT__number2;
    __Vdly__TranAndRecei__DOT__number2 = 0;
    IData/*27:0*/ __Vdly__TranAndRecei__DOT__counter;
    __Vdly__TranAndRecei__DOT__counter = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v0;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v0 = 0;
    CData/*0:0*/ __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v5;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v5 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v8;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v8 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v9;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v9 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v10;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v10 = 0;
    CData/*7:0*/ __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v12;
    __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v12 = 0;
    SData/*10:0*/ __Vdly__TranAndRecei__DOT__tx_index;
    __Vdly__TranAndRecei__DOT__tx_index = 0;
    CData/*0:0*/ __Vdly__TranAndRecei__DOT__tx_Send;
    __Vdly__TranAndRecei__DOT__tx_Send = 0;
    // Body
    __Vdly__TranAndRecei__DOT__counter = vlSelf->TranAndRecei__DOT__counter;
    __Vdly__TranAndRecei__DOT__number2 = vlSelf->TranAndRecei__DOT__number2;
    __Vdly__TranAndRecei__DOT__number1 = vlSelf->TranAndRecei__DOT__number1;
    __Vdly__TranAndRecei__DOT__tx_index = vlSelf->TranAndRecei__DOT__tx_index;
    __Vdly__TranAndRecei__DOT__rx_index = vlSelf->TranAndRecei__DOT__rx_index;
    __Vdly__TranAndRecei__DOT__str_index = vlSelf->TranAndRecei__DOT__str_index;
    __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0 = 0U;
    __Vdly__TranAndRecei__DOT__tx_Send = vlSelf->TranAndRecei__DOT__tx_Send;
    __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0 = 0U;
    if (vlSelf->TranAndRecei__DOT__CHECKOK) {
        __Vdly__TranAndRecei__DOT__counter = (0xfffffffU 
                                              & ((IData)(1U) 
                                                 + vlSelf->TranAndRecei__DOT__counter));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v0 
            = (0xffU & ((IData)(0x30U) + VL_DIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__number1), (IData)(0x64U))));
        __Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0 = 1U;
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1 
            = (0xffU & ((IData)(0x30U) + VL_DIV_III(32, 
                                                    VL_MODDIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__number1), (IData)(0x64U)), (IData)(0xaU))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2 
            = (0xffU & ((IData)(0x30U) + VL_MODDIV_III(32, 
                                                       VL_MODDIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__number1), (IData)(0x64U)), (IData)(0xaU))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4 
            = (0xffU & ((IData)(0x30U) + VL_DIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__number2), (IData)(0x64U))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v5 
            = (0xffU & ((IData)(0x30U) + VL_DIV_III(32, 
                                                    VL_MODDIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__number2), (IData)(0x64U)), (IData)(0xaU))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6 
            = (0xffU & ((IData)(0x30U) + VL_MODDIV_III(32, 
                                                       VL_MODDIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__number2), (IData)(0x64U)), (IData)(0xaU))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v8 
            = (0xffU & ((IData)(0x30U) + VL_DIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__sum), (IData)(0x64U))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v9 
            = (0xffU & ((IData)(0x30U) + VL_DIV_III(32, 
                                                    VL_MODDIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__sum), (IData)(0x64U)), (IData)(0xaU))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v10 
            = (0xffU & ((IData)(0x30U) + VL_MODDIV_III(32, 
                                                       VL_MODDIV_III(32, (IData)(vlSelf->TranAndRecei__DOT__sum), (IData)(0x64U)), (IData)(0xaU))));
        __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v12 
            = ((0x100U & ((IData)(vlSelf->TranAndRecei__DOT__number1) 
                          + ((IData)(vlSelf->TranAndRecei__DOT__number2) 
                             + (IData)(vlSelf->TranAndRecei__DOT__cin))))
                ? 0x31U : 0x30U);
    }
    if (((IData)(vlSelf->TranAndRecei__DOT__tx_Send) 
         & (IData)(vlSelf->TranAndRecei__DOT__tx_done))) {
        __Vdly__TranAndRecei__DOT__tx_index = (0x7ffU 
                                               & ((IData)(1U) 
                                                  + (IData)(vlSelf->TranAndRecei__DOT__tx_index)));
    }
    if (((0xaU != (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg)) 
         & (IData)(vlSelf->TranAndRecei__DOT__rx_done))) {
        __Vdly__TranAndRecei__DOT__rx_index = (7U & 
                                               ((IData)(1U) 
                                                + (IData)(vlSelf->TranAndRecei__DOT__rx_index)));
    }
    if ((((0xdU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg)) 
          | (0xaU == (IData)(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg))) 
         & (IData)(vlSelf->TranAndRecei__DOT__rx_done))) {
        __Vdly__TranAndRecei__DOT__str_index = (3U 
                                                & ((IData)(1U) 
                                                   + (IData)(vlSelf->TranAndRecei__DOT__str_index)));
    }
    TranAndRecei__DOT____Vlvbound_hd9e068fe__0 = vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg;
    if ((5U >= (IData)(vlSelf->TranAndRecei__DOT__rx_index))) {
        __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0 
            = TranAndRecei__DOT____Vlvbound_hd9e068fe__0;
        __Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0 = 1U;
        __Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0 
            = vlSelf->TranAndRecei__DOT__rx_index;
    }
    if ((((0xfffffffU == vlSelf->TranAndRecei__DOT__counter) 
          & (0x28U >= (IData)(vlSelf->TranAndRecei__DOT__tx_index))) 
         & (IData)(vlSelf->TranAndRecei__DOT__CHECKOK))) {
        __Vdly__TranAndRecei__DOT__tx_Send = 1U;
    }
    if ((2U & (IData)(vlSelf->TranAndRecei__DOT__str_index))) {
        __Vdly__TranAndRecei__DOT__number2 = (0xffU 
                                              & ((1U 
                                                  & (IData)(vlSelf->TranAndRecei__DOT__str_index))
                                                  ? (IData)(vlSelf->TranAndRecei__DOT__number2)
                                                  : 
                                                 ((((IData)(0x64U) 
                                                    * 
                                                    (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                     [3U] 
                                                     - (IData)(0x30U))) 
                                                   + 
                                                   ((IData)(0xaU) 
                                                    * 
                                                    (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                     [4U] 
                                                     - (IData)(0x30U)))) 
                                                  + 
                                                  (vlSelf->TranAndRecei__DOT__rx_Data_Buffer
                                                   [5U] 
                                                   - (IData)(0x30U)))));
        __Vdly__TranAndRecei__DOT__number1 = (0xffU 
                                              & (IData)(vlSelf->TranAndRecei__DOT__number1));
        if ((1U & (~ (IData)(vlSelf->TranAndRecei__DOT__str_index)))) {
            vlSelf->TranAndRecei__DOT__CHECKOK = 1U;
        }
    } else {
        __Vdly__TranAndRecei__DOT__number2 = 0U;
        __Vdly__TranAndRecei__DOT__number1 = (0xffU 
                                              & ((1U 
                                                  & (IData)(vlSelf->TranAndRecei__DOT__str_index))
                                                  ? 
                                                 ((((IData)(0x64U) 
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
                                                   - (IData)(0x30U)))
                                                  : 0U));
    }
    if ((((IData)(vlSelf->TranAndRecei__DOT__tx_Send) 
          & (IData)(vlSelf->TranAndRecei__DOT__tx_done)) 
         & (0x28U <= (IData)(vlSelf->TranAndRecei__DOT__tx_index)))) {
        __Vdly__TranAndRecei__DOT__tx_Send = 0U;
    }
    vlSelf->TranAndRecei__DOT__tx_data_in = ((0x28U 
                                              >= (0x3fU 
                                                  & (IData)(vlSelf->TranAndRecei__DOT__tx_index)))
                                              ? vlSelf->TranAndRecei__DOT__tx_Data_Buffer
                                             [(0x3fU 
                                               & (IData)(vlSelf->TranAndRecei__DOT__tx_index))]
                                              : 0U);
    vlSelf->TranAndRecei__DOT__rx_index = __Vdly__TranAndRecei__DOT__rx_index;
    if (__Vdlyvset__TranAndRecei__DOT__rx_Data_Buffer__v0) {
        vlSelf->TranAndRecei__DOT__rx_Data_Buffer[__Vdlyvdim0__TranAndRecei__DOT__rx_Data_Buffer__v0] 
            = __Vdlyvval__TranAndRecei__DOT__rx_Data_Buffer__v0;
    }
    vlSelf->TranAndRecei__DOT__counter = __Vdly__TranAndRecei__DOT__counter;
    vlSelf->TranAndRecei__DOT__tx_Send = __Vdly__TranAndRecei__DOT__tx_Send;
    vlSelf->TranAndRecei__DOT__number1 = __Vdly__TranAndRecei__DOT__number1;
    vlSelf->TranAndRecei__DOT__number2 = __Vdly__TranAndRecei__DOT__number2;
    vlSelf->TranAndRecei__DOT__tx_index = __Vdly__TranAndRecei__DOT__tx_index;
    if (__Vdlyvset__TranAndRecei__DOT__tx_Data_Buffer__v0) {
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[9U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v0;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0xaU] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v1;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0xbU] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v2;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0xcU] = 0x20U;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x15U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v4;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x16U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v5;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x17U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v6;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x18U] = 0x20U;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x1dU] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v8;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x1eU] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v9;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x1fU] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v10;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x20U] = 0x20U;
        vlSelf->TranAndRecei__DOT__tx_Data_Buffer[0x26U] 
            = __Vdlyvval__TranAndRecei__DOT__tx_Data_Buffer__v12;
    }
    vlSelf->TranAndRecei__DOT__sum = (0xffU & ((IData)(vlSelf->TranAndRecei__DOT__number1) 
                                               + ((IData)(vlSelf->TranAndRecei__DOT__number2) 
                                                  + (IData)(vlSelf->TranAndRecei__DOT__cin))));
    vlSelf->TranAndRecei__DOT__str_index = __Vdly__TranAndRecei__DOT__str_index;
}

VL_INLINE_OPT void VTranAndReceilite___024root___nba_sequent__TOP__1(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___nba_sequent__TOP__1\n"); );
    // Body
    vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg 
        = ((IData)(vlSelf->TranAndRecei__DOT__reset) 
           | (IData)(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next));
    if (vlSelf->TranAndRecei__DOT__reset) {
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

VL_INLINE_OPT void VTranAndReceilite___024root___nba_sequent__TOP__2(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___nba_sequent__TOP__2\n"); );
    // Body
    vlSelf->TranAndRecei__DOT__reset = 0U;
}

VL_INLINE_OPT void VTranAndReceilite___024root___nba_comb__TOP__0(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___nba_comb__TOP__0\n"); );
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

void VTranAndReceilite___024root___eval_nba(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___eval_nba\n"); );
    // Body
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VTranAndReceilite___024root___nba_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
    if (vlSelf->__VnbaTriggered.at(1U)) {
        VTranAndReceilite___024root___nba_sequent__TOP__1(vlSelf);
        vlSelf->__Vm_traceActivity[2U] = 1U;
    }
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VTranAndReceilite___024root___nba_sequent__TOP__2(vlSelf);
    }
    if ((vlSelf->__VnbaTriggered.at(0U) | vlSelf->__VnbaTriggered.at(1U))) {
        VTranAndReceilite___024root___nba_comb__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[3U] = 1U;
    }
}

void VTranAndReceilite___024root___eval_triggers__ico(VTranAndReceilite___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndReceilite___024root___dump_triggers__ico(VTranAndReceilite___024root* vlSelf);
#endif  // VL_DEBUG
void VTranAndReceilite___024root___eval_triggers__act(VTranAndReceilite___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndReceilite___024root___dump_triggers__act(VTranAndReceilite___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndReceilite___024root___dump_triggers__nba(VTranAndReceilite___024root* vlSelf);
#endif  // VL_DEBUG

void VTranAndReceilite___024root___eval(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___eval\n"); );
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
        VTranAndReceilite___024root___eval_triggers__ico(vlSelf);
        if (vlSelf->__VicoTriggered.any()) {
            __VicoContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VicoIterCount))) {
#ifdef VL_DEBUG
                VTranAndReceilite___024root___dump_triggers__ico(vlSelf);
#endif
                VL_FATAL_MT("TranAndRecei.v", 2, "", "Input combinational region did not converge.");
            }
            vlSelf->__VicoIterCount = ((IData)(1U) 
                                       + vlSelf->__VicoIterCount);
            VTranAndReceilite___024root___eval_ico(vlSelf);
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
            VTranAndReceilite___024root___eval_triggers__act(vlSelf);
            if (vlSelf->__VactTriggered.any()) {
                vlSelf->__VactContinue = 1U;
                if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                    VTranAndReceilite___024root___dump_triggers__act(vlSelf);
#endif
                    VL_FATAL_MT("TranAndRecei.v", 2, "", "Active region did not converge.");
                }
                vlSelf->__VactIterCount = ((IData)(1U) 
                                           + vlSelf->__VactIterCount);
                __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
                vlSelf->__VnbaTriggered.set(vlSelf->__VactTriggered);
                VTranAndReceilite___024root___eval_act(vlSelf);
            }
        }
        if (vlSelf->__VnbaTriggered.any()) {
            __VnbaContinue = 1U;
            if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
                VTranAndReceilite___024root___dump_triggers__nba(vlSelf);
#endif
                VL_FATAL_MT("TranAndRecei.v", 2, "", "NBA region did not converge.");
            }
            __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
            VTranAndReceilite___024root___eval_nba(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
void VTranAndReceilite___024root___eval_debug_assertions(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->i_uart_rx & 0xfeU))) {
        Verilated::overWidthError("i_uart_rx");}
}
#endif  // VL_DEBUG
