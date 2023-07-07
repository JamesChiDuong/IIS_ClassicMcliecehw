// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTranAndRecei__Syms.h"


void VTranAndRecei___024root__trace_chg_sub_0(VTranAndRecei___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void VTranAndRecei___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_chg_top_0\n"); );
    // Init
    VTranAndRecei___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VTranAndRecei___024root*>(voidSelf);
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    VTranAndRecei___024root__trace_chg_sub_0((&vlSymsp->TOP), bufp);
}

void VTranAndRecei___024root__trace_chg_sub_0(VTranAndRecei___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_chg_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[0U])) {
        bufp->chgBit(oldp+0,(vlSelf->TranAndRecei__DOT__cin));
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        bufp->chgCData(oldp+1,(vlSelf->TranAndRecei__DOT__rx_index),3);
        bufp->chgSData(oldp+2,(vlSelf->TranAndRecei__DOT__tx_index),11);
        bufp->chgCData(oldp+3,(vlSelf->TranAndRecei__DOT__str_index),2);
        bufp->chgCData(oldp+4,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[0]),8);
        bufp->chgCData(oldp+5,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[1]),8);
        bufp->chgCData(oldp+6,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[2]),8);
        bufp->chgCData(oldp+7,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[3]),8);
        bufp->chgCData(oldp+8,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[4]),8);
        bufp->chgCData(oldp+9,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[5]),8);
        bufp->chgCData(oldp+10,(vlSelf->TranAndRecei__DOT__tx_data_in),8);
        bufp->chgCData(oldp+11,(vlSelf->TranAndRecei__DOT__number1),8);
        bufp->chgCData(oldp+12,(vlSelf->TranAndRecei__DOT__number2),8);
        bufp->chgCData(oldp+13,(vlSelf->TranAndRecei__DOT__sum),8);
        bufp->chgBit(oldp+14,((1U & (((IData)(vlSelf->TranAndRecei__DOT__number1) 
                                      + ((IData)(vlSelf->TranAndRecei__DOT__number2) 
                                         + (IData)(vlSelf->TranAndRecei__DOT__cin))) 
                                     >> 8U))));
        bufp->chgBit(oldp+15,(vlSelf->TranAndRecei__DOT__tx_Send));
        bufp->chgIData(oldp+16,(vlSelf->TranAndRecei__DOT__counter),28);
        bufp->chgBit(oldp+17,(vlSelf->TranAndRecei__DOT__CHECKOK));
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[2U])) {
        bufp->chgCData(oldp+18,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg),8);
        bufp->chgBit(oldp+19,(vlSelf->TranAndRecei__DOT__tx_done));
        bufp->chgBit(oldp+20,(vlSelf->TranAndRecei__DOT__rx_done));
        bufp->chgBit(oldp+21,((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))));
        bufp->chgCData(oldp+22,(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter),6);
        bufp->chgCData(oldp+23,(((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))
                                  ? 0U : (0x3fU & ((IData)(1U) 
                                                   + (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))))),6);
        bufp->chgCData(oldp+24,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state),2);
        bufp->chgCData(oldp+25,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg),5);
        bufp->chgCData(oldp+26,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg),4);
        bufp->chgCData(oldp+27,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next),4);
        bufp->chgCData(oldp+28,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state),2);
        bufp->chgCData(oldp+29,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg),5);
        bufp->chgCData(oldp+30,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg),4);
        bufp->chgCData(oldp+31,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next),4);
        bufp->chgCData(oldp+32,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg),8);
        bufp->chgBit(oldp+33,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg));
        bufp->chgBit(oldp+34,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next));
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[3U])) {
        bufp->chgCData(oldp+35,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state),2);
        bufp->chgCData(oldp+36,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next),5);
        bufp->chgCData(oldp+37,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next),8);
    }
    bufp->chgBit(oldp+38,(vlSelf->clk));
    bufp->chgBit(oldp+39,(vlSelf->i_uart_rx));
    bufp->chgBit(oldp+40,(vlSelf->o_uart_tx));
    bufp->chgBit(oldp+41,(vlSelf->TranAndRecei__DOT__reset));
    bufp->chgCData(oldp+42,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state),2);
    bufp->chgCData(oldp+43,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next),5);
    bufp->chgCData(oldp+44,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next),8);
}

void VTranAndRecei___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_cleanup\n"); );
    // Init
    VTranAndRecei___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VTranAndRecei___024root*>(voidSelf);
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
}
