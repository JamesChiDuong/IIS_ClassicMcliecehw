// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VData_Receiver__Syms.h"


VL_ATTR_COLD void VData_Receiver___024root__trace_init_sub__TOP__0(VData_Receiver___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+21,"clk", false,-1);
    tracep->declBit(c+22,"i_uart_rx", false,-1);
    tracep->declBit(c+23,"o_uart_tx", false,-1);
    tracep->pushNamePrefix("Data_Receiver ");
    tracep->declBit(c+21,"clk", false,-1);
    tracep->declBit(c+22,"i_uart_rx", false,-1);
    tracep->declBit(c+23,"o_uart_tx", false,-1);
    tracep->declBus(c+28,"DBITS", false,-1, 31,0);
    tracep->declBus(c+29,"BR_BITS", false,-1, 31,0);
    tracep->declBus(c+30,"BR_LIMIT", false,-1, 31,0);
    tracep->declBus(c+31,"SB_TICK", false,-1, 31,0);
    tracep->declBit(c+24,"reset", false,-1);
    tracep->declBus(c+1,"rx_data_out", false,-1, 7,0);
    tracep->declBus(c+32,"data_buffer", false,-1, 7,0);
    tracep->declBus(c+33,"tx_fifo_out", false,-1, 7,0);
    tracep->declBit(c+2,"rx_done", false,-1);
    tracep->declBit(c+3,"tx_done", false,-1);
    tracep->declBit(c+34,"tx_empty", false,-1);
    tracep->declBit(c+35,"tx_fifo_not_empty", false,-1);
    tracep->declBit(c+4,"tick", false,-1);
    tracep->declBit(c+36,"rx_empty", false,-1);
    tracep->declBit(c+37,"rx_full", false,-1);
    tracep->declBit(c+38,"tx_full", false,-1);
    tracep->pushNamePrefix("BAUD_RATE_GEN ");
    tracep->declBus(c+29,"N", false,-1, 31,0);
    tracep->declBus(c+30,"M", false,-1, 31,0);
    tracep->declBit(c+21,"clk", false,-1);
    tracep->declBit(c+24,"reset", false,-1);
    tracep->declBit(c+4,"tick", false,-1);
    tracep->declBus(c+5,"counter", false,-1, 5,0);
    tracep->declBus(c+6,"next", false,-1, 5,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("UART_RX_UNIT ");
    tracep->declBus(c+28,"DBITS", false,-1, 31,0);
    tracep->declBus(c+31,"SB_TICK", false,-1, 31,0);
    tracep->declBit(c+21,"clk", false,-1);
    tracep->declBit(c+24,"reset", false,-1);
    tracep->declBit(c+22,"rx", false,-1);
    tracep->declBit(c+4,"sample_tick", false,-1);
    tracep->declBit(c+2,"data_ready", false,-1);
    tracep->declBus(c+1,"data_out", false,-1, 7,0);
    tracep->declBus(c+39,"idle", false,-1, 1,0);
    tracep->declBus(c+40,"start", false,-1, 1,0);
    tracep->declBus(c+41,"data", false,-1, 1,0);
    tracep->declBus(c+42,"stop", false,-1, 1,0);
    tracep->declBus(c+7,"state", false,-1, 1,0);
    tracep->declBus(c+25,"next_state", false,-1, 1,0);
    tracep->declBus(c+8,"tick_reg", false,-1, 4,0);
    tracep->declBus(c+26,"tick_next", false,-1, 4,0);
    tracep->declBus(c+9,"nbits_reg", false,-1, 3,0);
    tracep->declBus(c+10,"nbits_next", false,-1, 3,0);
    tracep->declBus(c+1,"data_reg", false,-1, 7,0);
    tracep->declBus(c+27,"data_next", false,-1, 7,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("UART_TX_UNIT ");
    tracep->declBus(c+28,"DBITS", false,-1, 31,0);
    tracep->declBus(c+31,"SB_TICK", false,-1, 31,0);
    tracep->declBit(c+21,"clk", false,-1);
    tracep->declBit(c+24,"reset", false,-1);
    tracep->declBit(c+2,"tx_start", false,-1);
    tracep->declBit(c+4,"sample_tick", false,-1);
    tracep->declBus(c+1,"data_in", false,-1, 7,0);
    tracep->declBit(c+3,"tx_done", false,-1);
    tracep->declBit(c+23,"tx", false,-1);
    tracep->declBus(c+39,"idle", false,-1, 1,0);
    tracep->declBus(c+40,"start", false,-1, 1,0);
    tracep->declBus(c+41,"data", false,-1, 1,0);
    tracep->declBus(c+42,"stop", false,-1, 1,0);
    tracep->declBus(c+11,"state", false,-1, 1,0);
    tracep->declBus(c+12,"next_state", false,-1, 1,0);
    tracep->declBus(c+13,"tick_reg", false,-1, 4,0);
    tracep->declBus(c+14,"tick_next", false,-1, 4,0);
    tracep->declBus(c+15,"nbits_reg", false,-1, 3,0);
    tracep->declBus(c+16,"nbits_next", false,-1, 3,0);
    tracep->declBus(c+17,"data_reg", false,-1, 7,0);
    tracep->declBus(c+18,"data_next", false,-1, 7,0);
    tracep->declBit(c+19,"tx_reg", false,-1);
    tracep->declBit(c+20,"tx_next", false,-1);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void VData_Receiver___024root__trace_init_top(VData_Receiver___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root__trace_init_top\n"); );
    // Body
    VData_Receiver___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void VData_Receiver___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VData_Receiver___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VData_Receiver___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void VData_Receiver___024root__trace_register(VData_Receiver___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&VData_Receiver___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&VData_Receiver___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&VData_Receiver___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void VData_Receiver___024root__trace_full_sub_0(VData_Receiver___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void VData_Receiver___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root__trace_full_top_0\n"); );
    // Init
    VData_Receiver___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VData_Receiver___024root*>(voidSelf);
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    VData_Receiver___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void VData_Receiver___024root__trace_full_sub_0(VData_Receiver___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullCData(oldp+1,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_reg),8);
    bufp->fullBit(oldp+2,(vlSelf->Data_Receiver__DOT__rx_done));
    bufp->fullBit(oldp+3,(vlSelf->Data_Receiver__DOT__tx_done));
    bufp->fullBit(oldp+4,((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))));
    bufp->fullCData(oldp+5,(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter),6);
    bufp->fullCData(oldp+6,(((0x34U == (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))
                              ? 0U : (0x3fU & ((IData)(1U) 
                                               + (IData)(vlSelf->Data_Receiver__DOT__BAUD_RATE_GEN__DOT__counter))))),6);
    bufp->fullCData(oldp+7,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__state),2);
    bufp->fullCData(oldp+8,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_reg),5);
    bufp->fullCData(oldp+9,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_reg),4);
    bufp->fullCData(oldp+10,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__nbits_next),4);
    bufp->fullCData(oldp+11,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__state),2);
    bufp->fullCData(oldp+12,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__next_state),2);
    bufp->fullCData(oldp+13,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_reg),5);
    bufp->fullCData(oldp+14,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tick_next),5);
    bufp->fullCData(oldp+15,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_reg),4);
    bufp->fullCData(oldp+16,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__nbits_next),4);
    bufp->fullCData(oldp+17,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_reg),8);
    bufp->fullCData(oldp+18,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__data_next),8);
    bufp->fullBit(oldp+19,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_reg));
    bufp->fullBit(oldp+20,(vlSelf->Data_Receiver__DOT__UART_TX_UNIT__DOT__tx_next));
    bufp->fullBit(oldp+21,(vlSelf->clk));
    bufp->fullBit(oldp+22,(vlSelf->i_uart_rx));
    bufp->fullBit(oldp+23,(vlSelf->o_uart_tx));
    bufp->fullBit(oldp+24,(vlSelf->Data_Receiver__DOT__reset));
    bufp->fullCData(oldp+25,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__next_state),2);
    bufp->fullCData(oldp+26,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__tick_next),5);
    bufp->fullCData(oldp+27,(vlSelf->Data_Receiver__DOT__UART_RX_UNIT__DOT__data_next),8);
    bufp->fullIData(oldp+28,(8U),32);
    bufp->fullIData(oldp+29,(6U),32);
    bufp->fullIData(oldp+30,(0x35U),32);
    bufp->fullIData(oldp+31,(0x10U),32);
    bufp->fullCData(oldp+32,(vlSelf->Data_Receiver__DOT__data_buffer),8);
    bufp->fullCData(oldp+33,(vlSelf->Data_Receiver__DOT__tx_fifo_out),8);
    bufp->fullBit(oldp+34,(vlSelf->Data_Receiver__DOT__tx_empty));
    bufp->fullBit(oldp+35,(vlSelf->Data_Receiver__DOT__tx_fifo_not_empty));
    bufp->fullBit(oldp+36,(vlSelf->Data_Receiver__DOT__rx_empty));
    bufp->fullBit(oldp+37,(vlSelf->Data_Receiver__DOT__rx_full));
    bufp->fullBit(oldp+38,(vlSelf->Data_Receiver__DOT__tx_full));
    bufp->fullCData(oldp+39,(0U),2);
    bufp->fullCData(oldp+40,(1U),2);
    bufp->fullCData(oldp+41,(2U),2);
    bufp->fullCData(oldp+42,(3U),2);
}
