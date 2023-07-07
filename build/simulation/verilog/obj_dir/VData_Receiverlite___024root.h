// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See VData_Receiverlite.h for the primary calling header

#ifndef VERILATED_VDATA_RECEIVERLITE___024ROOT_H_
#define VERILATED_VDATA_RECEIVERLITE___024ROOT_H_  // guard

#include "verilated.h"

class VData_Receiverlite__Syms;

class VData_Receiverlite___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    CData/*0:0*/ Data_Receiver__DOT__reset;
    VL_IN8(i_uart_rx,0,0);
    VL_OUT8(o_uart_tx,0,0);
    CData/*7:0*/ Data_Receiver__DOT__data_buffer;
    CData/*7:0*/ Data_Receiver__DOT__tx_fifo_out;
    CData/*0:0*/ Data_Receiver__DOT__rx_done;
    CData/*0:0*/ Data_Receiver__DOT__tx_done;
    CData/*0:0*/ Data_Receiver__DOT__tx_empty;
    CData/*0:0*/ Data_Receiver__DOT__tx_fifo_not_empty;
    CData/*0:0*/ Data_Receiver__DOT__rx_empty;
    CData/*0:0*/ Data_Receiver__DOT__rx_full;
    CData/*0:0*/ Data_Receiver__DOT__tx_full;
    CData/*5:0*/ Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter;
    CData/*5:0*/ Data_Receiver__DOT__BAUD_RATE_GEN__DOT__next;
    CData/*1:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__state;
    CData/*1:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state;
    CData/*4:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg;
    CData/*4:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next;
    CData/*3:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg;
    CData/*3:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next;
    CData/*7:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg;
    CData/*7:0*/ Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next;
    CData/*1:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__state;
    CData/*1:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state;
    CData/*4:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg;
    CData/*4:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next;
    CData/*3:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg;
    CData/*3:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next;
    CData/*7:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg;
    CData/*7:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next;
    CData/*0:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_reg;
    CData/*0:0*/ Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_next;
    CData/*0:0*/ __Vtrigrprev__TOP__clk;
    CData/*0:0*/ __Vtrigrprev__TOP__Data_Receiver__DOT__reset;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VstlIterCount;
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*0:0*/, 2> __Vm_traceActivity;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<2> __VactTriggered;
    VlTriggerVec<2> __VnbaTriggered;

    // INTERNAL VARIABLES
    VData_Receiverlite__Syms* const vlSymsp;

    // CONSTRUCTORS
    VData_Receiverlite___024root(VData_Receiverlite__Syms* symsp, const char* v__name);
    ~VData_Receiverlite___024root();
    VL_UNCOPYABLE(VData_Receiverlite___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
