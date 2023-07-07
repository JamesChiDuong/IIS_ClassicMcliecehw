// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTranAndReceilite__Syms.h"


VL_ATTR_COLD void VTranAndReceilite___024root__trace_init_sub__TOP__0(VTranAndReceilite___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+39,"clk", false,-1);
    tracep->declBit(c+40,"i_uart_rx", false,-1);
    tracep->declBit(c+41,"o_uart_tx", false,-1);
    tracep->pushNamePrefix("TranAndRecei ");
    tracep->declBit(c+39,"clk", false,-1);
    tracep->declBit(c+40,"i_uart_rx", false,-1);
    tracep->declBit(c+41,"o_uart_tx", false,-1);
    tracep->declBus(c+46,"DBITS", false,-1, 31,0);
    tracep->declBus(c+47,"DATA_LENGTH", false,-1, 31,0);
    tracep->declBus(c+48,"BR_BITS", false,-1, 31,0);
    tracep->declBus(c+49,"BR_LIMIT", false,-1, 31,0);
    tracep->declBus(c+50,"SB_TICK", false,-1, 31,0);
    tracep->declBus(c+2,"rx_index", false,-1, 2,0);
    tracep->declBus(c+3,"tx_index", false,-1, 10,0);
    tracep->declBus(c+4,"str_index", false,-1, 1,0);
    for (int i = 0; i < 6; ++i) {
        tracep->declBus(c+5+i*1,"rx_Data_Buffer", true,(i+0), 7,0);
    }
    tracep->declBus(c+19,"rx_data_out", false,-1, 7,0);
    tracep->declBus(c+11,"tx_data_in", false,-1, 7,0);
    tracep->declBus(c+12,"number1", false,-1, 7,0);
    tracep->declBus(c+13,"number2", false,-1, 7,0);
    tracep->declBus(c+14,"sum", false,-1, 7,0);
    tracep->declBit(c+1,"cin", false,-1);
    tracep->declBit(c+15,"cout", false,-1);
    tracep->declBit(c+42,"reset", false,-1);
    tracep->declBit(c+16,"tx_Send", false,-1);
    tracep->declBit(c+20,"tx_done", false,-1);
    tracep->declBit(c+21,"rx_done", false,-1);
    tracep->declBit(c+22,"tick", false,-1);
    tracep->declBus(c+17,"counter", false,-1, 27,0);
    tracep->declBit(c+18,"CHECKOK", false,-1);
    tracep->declBus(c+51,"current_state", false,-1, 2,0);
    tracep->declBus(c+52,"next_state", false,-1, 2,0);
    tracep->pushNamePrefix("BAUD_RATE_GEN ");
    tracep->declBus(c+48,"N", false,-1, 31,0);
    tracep->declBus(c+49,"M", false,-1, 31,0);
    tracep->declBit(c+39,"clk", false,-1);
    tracep->declBit(c+42,"reset", false,-1);
    tracep->declBit(c+22,"tick", false,-1);
    tracep->declBus(c+23,"counter", false,-1, 5,0);
    tracep->declBus(c+24,"next", false,-1, 5,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("FA ");
    tracep->declBus(c+12,"number1", false,-1, 7,0);
    tracep->declBus(c+13,"number2", false,-1, 7,0);
    tracep->declBit(c+1,"cin", false,-1);
    tracep->declBus(c+14,"sum", false,-1, 7,0);
    tracep->declBit(c+15,"cout", false,-1);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("UART_RX_UNIT ");
    tracep->declBus(c+46,"DBITS", false,-1, 31,0);
    tracep->declBus(c+50,"SB_TICK", false,-1, 31,0);
    tracep->declBit(c+39,"clk", false,-1);
    tracep->declBit(c+42,"reset", false,-1);
    tracep->declBit(c+40,"rx", false,-1);
    tracep->declBit(c+22,"sample_tick", false,-1);
    tracep->declBit(c+21,"data_ready", false,-1);
    tracep->declBus(c+19,"data_out", false,-1, 7,0);
    tracep->declBus(c+53,"idle", false,-1, 1,0);
    tracep->declBus(c+54,"start", false,-1, 1,0);
    tracep->declBus(c+55,"data", false,-1, 1,0);
    tracep->declBus(c+56,"stop", false,-1, 1,0);
    tracep->declBus(c+25,"state", false,-1, 1,0);
    tracep->declBus(c+43,"next_state", false,-1, 1,0);
    tracep->declBus(c+26,"tick_reg", false,-1, 4,0);
    tracep->declBus(c+44,"tick_next", false,-1, 4,0);
    tracep->declBus(c+27,"nbits_reg", false,-1, 3,0);
    tracep->declBus(c+28,"nbits_next", false,-1, 3,0);
    tracep->declBus(c+19,"data_reg", false,-1, 7,0);
    tracep->declBus(c+45,"data_next", false,-1, 7,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("UART_TX_UNIT ");
    tracep->declBus(c+46,"DBITS", false,-1, 31,0);
    tracep->declBus(c+50,"SB_TICK", false,-1, 31,0);
    tracep->declBit(c+39,"clk", false,-1);
    tracep->declBit(c+42,"reset", false,-1);
    tracep->declBit(c+16,"tx_start", false,-1);
    tracep->declBit(c+22,"sample_tick", false,-1);
    tracep->declBus(c+11,"data_in", false,-1, 7,0);
    tracep->declBit(c+20,"tx_done", false,-1);
    tracep->declBit(c+41,"tx", false,-1);
    tracep->declBus(c+53,"idle", false,-1, 1,0);
    tracep->declBus(c+54,"start", false,-1, 1,0);
    tracep->declBus(c+55,"data", false,-1, 1,0);
    tracep->declBus(c+56,"stop", false,-1, 1,0);
    tracep->declBus(c+29,"state", false,-1, 1,0);
    tracep->declBus(c+36,"next_state", false,-1, 1,0);
    tracep->declBus(c+30,"tick_reg", false,-1, 4,0);
    tracep->declBus(c+37,"tick_next", false,-1, 4,0);
    tracep->declBus(c+31,"nbits_reg", false,-1, 3,0);
    tracep->declBus(c+32,"nbits_next", false,-1, 3,0);
    tracep->declBus(c+33,"data_reg", false,-1, 7,0);
    tracep->declBus(c+38,"data_next", false,-1, 7,0);
    tracep->declBit(c+34,"tx_reg", false,-1);
    tracep->declBit(c+35,"tx_next", false,-1);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void VTranAndReceilite___024root__trace_init_top(VTranAndReceilite___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root__trace_init_top\n"); );
    // Body
    VTranAndReceilite___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void VTranAndReceilite___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VTranAndReceilite___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VTranAndReceilite___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void VTranAndReceilite___024root__trace_register(VTranAndReceilite___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&VTranAndReceilite___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&VTranAndReceilite___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&VTranAndReceilite___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void VTranAndReceilite___024root__trace_full_sub_0(VTranAndReceilite___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void VTranAndReceilite___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root__trace_full_top_0\n"); );
    // Init
    VTranAndReceilite___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VTranAndReceilite___024root*>(voidSelf);
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    VTranAndReceilite___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void VTranAndReceilite___024root__trace_full_sub_0(VTranAndReceilite___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelf->TranAndRecei__DOT__cin));
    bufp->fullCData(oldp+2,(vlSelf->TranAndRecei__DOT__rx_index),3);
    bufp->fullSData(oldp+3,(vlSelf->TranAndRecei__DOT__tx_index),11);
    bufp->fullCData(oldp+4,(vlSelf->TranAndRecei__DOT__str_index),2);
    bufp->fullCData(oldp+5,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[0]),8);
    bufp->fullCData(oldp+6,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[1]),8);
    bufp->fullCData(oldp+7,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[2]),8);
    bufp->fullCData(oldp+8,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[3]),8);
    bufp->fullCData(oldp+9,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[4]),8);
    bufp->fullCData(oldp+10,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[5]),8);
    bufp->fullCData(oldp+11,(vlSelf->TranAndRecei__DOT__tx_data_in),8);
    bufp->fullCData(oldp+12,(vlSelf->TranAndRecei__DOT__number1),8);
    bufp->fullCData(oldp+13,(vlSelf->TranAndRecei__DOT__number2),8);
    bufp->fullCData(oldp+14,(vlSelf->TranAndRecei__DOT__sum),8);
    bufp->fullBit(oldp+15,((1U & (((IData)(vlSelf->TranAndRecei__DOT__number1) 
                                   + ((IData)(vlSelf->TranAndRecei__DOT__number2) 
                                      + (IData)(vlSelf->TranAndRecei__DOT__cin))) 
                                  >> 8U))));
    bufp->fullBit(oldp+16,(vlSelf->TranAndRecei__DOT__tx_Send));
    bufp->fullIData(oldp+17,(vlSelf->TranAndRecei__DOT__counter),28);
    bufp->fullBit(oldp+18,(vlSelf->TranAndRecei__DOT__CHECKOK));
    bufp->fullCData(oldp+19,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg),8);
    bufp->fullBit(oldp+20,(vlSelf->TranAndRecei__DOT__tx_done));
    bufp->fullBit(oldp+21,(vlSelf->TranAndRecei__DOT__rx_done));
    bufp->fullBit(oldp+22,((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))));
    bufp->fullCData(oldp+23,(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter),6);
    bufp->fullCData(oldp+24,(((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))
                               ? 0U : (0x3fU & ((IData)(1U) 
                                                + (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))))),6);
    bufp->fullCData(oldp+25,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state),2);
    bufp->fullCData(oldp+26,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg),5);
    bufp->fullCData(oldp+27,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg),4);
    bufp->fullCData(oldp+28,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next),4);
    bufp->fullCData(oldp+29,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state),2);
    bufp->fullCData(oldp+30,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg),5);
    bufp->fullCData(oldp+31,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg),4);
    bufp->fullCData(oldp+32,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next),4);
    bufp->fullCData(oldp+33,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg),8);
    bufp->fullBit(oldp+34,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg));
    bufp->fullBit(oldp+35,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next));
    bufp->fullCData(oldp+36,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state),2);
    bufp->fullCData(oldp+37,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next),5);
    bufp->fullCData(oldp+38,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next),8);
    bufp->fullBit(oldp+39,(vlSelf->clk));
    bufp->fullBit(oldp+40,(vlSelf->i_uart_rx));
    bufp->fullBit(oldp+41,(vlSelf->o_uart_tx));
    bufp->fullBit(oldp+42,(vlSelf->TranAndRecei__DOT__reset));
    bufp->fullCData(oldp+43,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state),2);
    bufp->fullCData(oldp+44,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next),5);
    bufp->fullCData(oldp+45,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next),8);
    bufp->fullIData(oldp+46,(8U),32);
    bufp->fullIData(oldp+47,(5U),32);
    bufp->fullIData(oldp+48,(6U),32);
    bufp->fullIData(oldp+49,(0x35U),32);
    bufp->fullIData(oldp+50,(0x10U),32);
    bufp->fullCData(oldp+51,(vlSelf->TranAndRecei__DOT__current_state),3);
    bufp->fullCData(oldp+52,(vlSelf->TranAndRecei__DOT__next_state),3);
    bufp->fullCData(oldp+53,(0U),2);
    bufp->fullCData(oldp+54,(1U),2);
    bufp->fullCData(oldp+55,(2U),2);
    bufp->fullCData(oldp+56,(3U),2);
}
