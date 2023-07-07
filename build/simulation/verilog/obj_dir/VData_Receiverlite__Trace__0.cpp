// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VData_Receiverlite__Syms.h"


void VData_Receiverlite___024root__trace_chg_sub_0(VData_Receiverlite___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void VData_Receiverlite___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiverlite___024root__trace_chg_top_0\n"); );
    // Init
    VData_Receiverlite___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VData_Receiverlite___024root*>(voidSelf);
    VData_Receiverlite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    VData_Receiverlite___024root__trace_chg_sub_0((&vlSymsp->TOP), bufp);
}

void VData_Receiverlite___024root__trace_chg_sub_0(VData_Receiverlite___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiverlite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiverlite___024root__trace_chg_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        bufp->chgCData(oldp+0,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg),8);
        bufp->chgBit(oldp+1,(vlSelf->Data_Receiver__DOT__rx_done));
        bufp->chgBit(oldp+2,(vlSelf->Data_Receiver__DOT__tx_done));
        bufp->chgBit(oldp+3,((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))));
        bufp->chgCData(oldp+4,(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter),6);
        bufp->chgCData(oldp+5,(((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))
                                 ? 0U : (0x3fU & ((IData)(1U) 
                                                  + (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))))),6);
        bufp->chgCData(oldp+6,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state),2);
        bufp->chgCData(oldp+7,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg),5);
        bufp->chgCData(oldp+8,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg),4);
        bufp->chgCData(oldp+9,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next),4);
        bufp->chgCData(oldp+10,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state),2);
        bufp->chgCData(oldp+11,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state),2);
        bufp->chgCData(oldp+12,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg),5);
        bufp->chgCData(oldp+13,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next),5);
        bufp->chgCData(oldp+14,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg),4);
        bufp->chgCData(oldp+15,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next),4);
        bufp->chgCData(oldp+16,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg),8);
        bufp->chgCData(oldp+17,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next),8);
        bufp->chgBit(oldp+18,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_reg));
        bufp->chgBit(oldp+19,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_next));
    }
    bufp->chgBit(oldp+20,(vlSelf->clk));
    bufp->chgBit(oldp+21,(vlSelf->i_uart_rx));
    bufp->chgBit(oldp+22,(vlSelf->o_uart_tx));
    bufp->chgBit(oldp+23,(vlSelf->Data_Receiver__DOT__reset));
    bufp->chgCData(oldp+24,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state),2);
    bufp->chgCData(oldp+25,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next),5);
    bufp->chgCData(oldp+26,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next),8);
}

void VData_Receiverlite___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiverlite___024root__trace_cleanup\n"); );
    // Init
    VData_Receiverlite___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VData_Receiverlite___024root*>(voidSelf);
    VData_Receiverlite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
