// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See VTranAndRecei.h for the primary calling header

#ifndef VERILATED_VTRANANDRECEI___024ROOT_H_
#define VERILATED_VTRANANDRECEI___024ROOT_H_  // guard

#include "verilated.h"

class VTranAndRecei__Syms;

class VTranAndRecei___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    VL_IN8(i_uart_rx,0,0);
    VL_OUT8(o_uart_tx,0,0);
    CData/*3:0*/ TranAndRecei__DOT__rx_index;
    CData/*1:0*/ TranAndRecei__DOT__str_index;
    CData/*7:0*/ TranAndRecei__DOT__tx_data_in;
    CData/*7:0*/ TranAndRecei__DOT__number1;
    CData/*7:0*/ TranAndRecei__DOT__number2;
    CData/*2:0*/ TranAndRecei__DOT__selection;
    CData/*0:0*/ TranAndRecei__DOT__cin;
    CData/*0:0*/ TranAndRecei__DOT__tx_Send;
    CData/*0:0*/ TranAndRecei__DOT__tx_done;
    CData/*0:0*/ TranAndRecei__DOT__rx_done;
    CData/*0:0*/ TranAndRecei__DOT__CHECKOK;
    CData/*2:0*/ TranAndRecei__DOT__rx_current_state;
    CData/*2:0*/ TranAndRecei__DOT__rx_next_state;
    CData/*2:0*/ TranAndRecei__DOT__tx_current_state;
    CData/*2:0*/ TranAndRecei__DOT__tx_next_state;
    CData/*5:0*/ TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter;
    CData/*5:0*/ TranAndRecei__DOT__BAUD_RATE_GEN__DOT__next;
    CData/*1:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__state;
    CData/*1:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state;
    CData/*4:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg;
    CData/*4:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next;
    CData/*3:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg;
    CData/*3:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next;
    CData/*7:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg;
    CData/*7:0*/ TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next;
    CData/*1:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__state;
    CData/*1:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state;
    CData/*4:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg;
    CData/*4:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next;
    CData/*3:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg;
    CData/*3:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next;
    CData/*7:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg;
    CData/*7:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next;
    CData/*0:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg;
    CData/*0:0*/ TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next;
    CData/*0:0*/ __Vtrigrprev__TOP__clk;
    CData/*0:0*/ __Vtrigrprev__TOP__reset;
    CData/*0:0*/ __VactContinue;
    SData/*10:0*/ TranAndRecei__DOT__tx_index;
    SData/*15:0*/ TranAndRecei__DOT__result;
    IData/*27:0*/ TranAndRecei__DOT__counter;
    IData/*31:0*/ __VstlIterCount;
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*7:0*/, 12> TranAndRecei__DOT__rx_Data_Buffer;
    VlUnpacked<CData/*7:0*/, 50> TranAndRecei__DOT__tx_Data_Buffer;
    VlUnpacked<CData/*0:0*/, 4> __Vm_traceActivity;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<2> __VactTriggered;
    VlTriggerVec<2> __VnbaTriggered;

    // INTERNAL VARIABLES
    VTranAndRecei__Syms* const vlSymsp;

    // CONSTRUCTORS
    VTranAndRecei___024root(VTranAndRecei__Syms* symsp, const char* v__name);
    ~VTranAndRecei___024root();
    VL_UNCOPYABLE(VTranAndRecei___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
