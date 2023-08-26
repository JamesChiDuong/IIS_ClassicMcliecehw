// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTranAndRecei__Syms.h"


VL_ATTR_COLD void VTranAndRecei___024root__trace_init_sub__TOP__0(VTranAndRecei___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+46,"clk", false,-1);
    tracep->declBit(c+47,"i_uart_rx", false,-1);
    tracep->declBit(c+48,"reset", false,-1);
    tracep->declBit(c+49,"o_uart_tx", false,-1);
    tracep->pushNamePrefix("TranAndRecei ");
    tracep->declBit(c+46,"clk", false,-1);
    tracep->declBit(c+47,"i_uart_rx", false,-1);
    tracep->declBit(c+48,"reset", false,-1);
    tracep->declBit(c+49,"o_uart_tx", false,-1);
    tracep->declBus(c+53,"DBITS", false,-1, 31,0);
    tracep->declBus(c+54,"DATA_LENGTH", false,-1, 31,0);
    tracep->declBus(c+55,"BR_BITS", false,-1, 31,0);
    tracep->declBus(c+56,"BR_LIMIT", false,-1, 31,0);
    tracep->declBus(c+57,"SB_TICK", false,-1, 31,0);
    tracep->declBus(c+2,"rx_index", false,-1, 3,0);
    tracep->declBus(c+3,"tx_index", false,-1, 10,0);
    tracep->declBus(c+58,"str_index", false,-1, 1,0);
    for (int i = 0; i < 12; ++i) {
        tracep->declBus(c+4+i*1,"rx_Data_Buffer", true,(i+0), 7,0);
    }
    tracep->declBus(c+26,"rx_data_out", false,-1, 7,0);
    tracep->declBus(c+16,"tx_data_in", false,-1, 7,0);
    tracep->declBus(c+17,"number1", false,-1, 7,0);
    tracep->declBus(c+18,"number2", false,-1, 7,0);
    tracep->declBus(c+19,"selection", false,-1, 2,0);
    tracep->declBus(c+20,"result", false,-1, 15,0);
    tracep->declBit(c+1,"cin", false,-1);
    tracep->declBit(c+21,"tx_Send", false,-1);
    tracep->declBit(c+27,"tx_done", false,-1);
    tracep->declBit(c+28,"rx_done", false,-1);
    tracep->declBit(c+29,"tick", false,-1);
    tracep->declBus(c+59,"counter", false,-1, 27,0);
    tracep->declBit(c+60,"CHECKOK", false,-1);
    tracep->declBus(c+22,"rx_current_state", false,-1, 2,0);
    tracep->declBus(c+23,"rx_next_state", false,-1, 2,0);
    tracep->declBus(c+24,"tx_current_state", false,-1, 2,0);
    tracep->declBus(c+25,"tx_next_state", false,-1, 2,0);
    tracep->declBus(c+61,"START", false,-1, 2,0);
    tracep->declBus(c+62,"NUMBER1", false,-1, 2,0);
    tracep->declBus(c+63,"NUMBER2", false,-1, 2,0);
    tracep->declBus(c+64,"OPERAND", false,-1, 2,0);
    tracep->declBus(c+65,"SEND", false,-1, 2,0);
    tracep->declBus(c+66,"STOP", false,-1, 2,0);
    tracep->declBus(c+62,"ADD", false,-1, 2,0);
    tracep->declBus(c+63,"SUB", false,-1, 2,0);
    tracep->declBus(c+64,"MUL", false,-1, 2,0);
    tracep->declBus(c+65,"DIV", false,-1, 2,0);
    tracep->pushNamePrefix("ALU1 ");
    tracep->declBit(c+46,"clk", false,-1);
    tracep->declBus(c+17,"number1", false,-1, 7,0);
    tracep->declBus(c+18,"number2", false,-1, 7,0);
    tracep->declBus(c+19,"sel", false,-1, 2,0);
    tracep->declBus(c+20,"alu_out", false,-1, 15,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("BAUD_RATE_GEN ");
    tracep->declBus(c+55,"N", false,-1, 31,0);
    tracep->declBus(c+56,"M", false,-1, 31,0);
    tracep->declBit(c+46,"clk", false,-1);
    tracep->declBit(c+48,"reset", false,-1);
    tracep->declBit(c+29,"tick", false,-1);
    tracep->declBus(c+30,"counter", false,-1, 5,0);
    tracep->declBus(c+31,"next", false,-1, 5,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("UART_RX_UNIT ");
    tracep->declBus(c+53,"DBITS", false,-1, 31,0);
    tracep->declBus(c+57,"SB_TICK", false,-1, 31,0);
    tracep->declBit(c+46,"clk", false,-1);
    tracep->declBit(c+48,"reset", false,-1);
    tracep->declBit(c+47,"rx", false,-1);
    tracep->declBit(c+29,"sample_tick", false,-1);
    tracep->declBit(c+28,"data_ready", false,-1);
    tracep->declBus(c+26,"data_out", false,-1, 7,0);
    tracep->declBus(c+67,"idle", false,-1, 1,0);
    tracep->declBus(c+68,"start", false,-1, 1,0);
    tracep->declBus(c+69,"data", false,-1, 1,0);
    tracep->declBus(c+70,"stop", false,-1, 1,0);
    tracep->declBus(c+32,"state", false,-1, 1,0);
    tracep->declBus(c+50,"next_state", false,-1, 1,0);
    tracep->declBus(c+33,"tick_reg", false,-1, 4,0);
    tracep->declBus(c+51,"tick_next", false,-1, 4,0);
    tracep->declBus(c+34,"nbits_reg", false,-1, 3,0);
    tracep->declBus(c+35,"nbits_next", false,-1, 3,0);
    tracep->declBus(c+26,"data_reg", false,-1, 7,0);
    tracep->declBus(c+52,"data_next", false,-1, 7,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("UART_TX_UNIT ");
    tracep->declBus(c+53,"DBITS", false,-1, 31,0);
    tracep->declBus(c+57,"SB_TICK", false,-1, 31,0);
    tracep->declBit(c+46,"clk", false,-1);
    tracep->declBit(c+48,"reset", false,-1);
    tracep->declBit(c+21,"tx_start", false,-1);
    tracep->declBit(c+29,"sample_tick", false,-1);
    tracep->declBus(c+16,"data_in", false,-1, 7,0);
    tracep->declBit(c+27,"tx_done", false,-1);
    tracep->declBit(c+49,"tx", false,-1);
    tracep->declBus(c+67,"idle", false,-1, 1,0);
    tracep->declBus(c+68,"start", false,-1, 1,0);
    tracep->declBus(c+69,"data", false,-1, 1,0);
    tracep->declBus(c+70,"stop", false,-1, 1,0);
    tracep->declBus(c+36,"state", false,-1, 1,0);
    tracep->declBus(c+43,"next_state", false,-1, 1,0);
    tracep->declBus(c+37,"tick_reg", false,-1, 4,0);
    tracep->declBus(c+44,"tick_next", false,-1, 4,0);
    tracep->declBus(c+38,"nbits_reg", false,-1, 3,0);
    tracep->declBus(c+39,"nbits_next", false,-1, 3,0);
    tracep->declBus(c+40,"data_reg", false,-1, 7,0);
    tracep->declBus(c+45,"data_next", false,-1, 7,0);
    tracep->declBit(c+41,"tx_reg", false,-1);
    tracep->declBit(c+42,"tx_next", false,-1);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void VTranAndRecei___024root__trace_init_top(VTranAndRecei___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_init_top\n"); );
    // Body
    VTranAndRecei___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void VTranAndRecei___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VTranAndRecei___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VTranAndRecei___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void VTranAndRecei___024root__trace_register(VTranAndRecei___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&VTranAndRecei___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&VTranAndRecei___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&VTranAndRecei___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void VTranAndRecei___024root__trace_full_sub_0(VTranAndRecei___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void VTranAndRecei___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_full_top_0\n"); );
    // Init
    VTranAndRecei___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VTranAndRecei___024root*>(voidSelf);
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    VTranAndRecei___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void VTranAndRecei___024root__trace_full_sub_0(VTranAndRecei___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndRecei___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelf->TranAndRecei__DOT__cin));
    bufp->fullCData(oldp+2,(vlSelf->TranAndRecei__DOT__rx_index),4);
    bufp->fullSData(oldp+3,(vlSelf->TranAndRecei__DOT__tx_index),11);
    bufp->fullCData(oldp+4,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[0]),8);
    bufp->fullCData(oldp+5,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[1]),8);
    bufp->fullCData(oldp+6,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[2]),8);
    bufp->fullCData(oldp+7,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[3]),8);
    bufp->fullCData(oldp+8,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[4]),8);
    bufp->fullCData(oldp+9,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[5]),8);
    bufp->fullCData(oldp+10,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[6]),8);
    bufp->fullCData(oldp+11,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[7]),8);
    bufp->fullCData(oldp+12,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[8]),8);
    bufp->fullCData(oldp+13,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[9]),8);
    bufp->fullCData(oldp+14,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[10]),8);
    bufp->fullCData(oldp+15,(vlSelf->TranAndRecei__DOT__rx_Data_Buffer[11]),8);
    bufp->fullCData(oldp+16,(vlSelf->TranAndRecei__DOT__tx_data_in),8);
    bufp->fullCData(oldp+17,(vlSelf->TranAndRecei__DOT__number1),8);
    bufp->fullCData(oldp+18,(vlSelf->TranAndRecei__DOT__number2),8);
    bufp->fullCData(oldp+19,(vlSelf->TranAndRecei__DOT__selection),3);
    bufp->fullSData(oldp+20,(vlSelf->TranAndRecei__DOT__result),16);
    bufp->fullBit(oldp+21,(vlSelf->TranAndRecei__DOT__tx_Send));
    bufp->fullCData(oldp+22,(vlSelf->TranAndRecei__DOT__rx_current_state),3);
    bufp->fullCData(oldp+23,(vlSelf->TranAndRecei__DOT__rx_next_state),3);
    bufp->fullCData(oldp+24,(vlSelf->TranAndRecei__DOT__tx_current_state),3);
    bufp->fullCData(oldp+25,(vlSelf->TranAndRecei__DOT__tx_next_state),3);
    bufp->fullCData(oldp+26,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_reg),8);
    bufp->fullBit(oldp+27,(vlSelf->TranAndRecei__DOT__tx_done));
    bufp->fullBit(oldp+28,(vlSelf->TranAndRecei__DOT__rx_done));
    bufp->fullBit(oldp+29,((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))));
    bufp->fullCData(oldp+30,(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter),6);
    bufp->fullCData(oldp+31,(((0x34U == (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))
                               ? 0U : (0x3fU & ((IData)(1U) 
                                                + (IData)(vlSelf->TranAndRecei__DOT__BAUD_RATE_GEN__DOT__counter))))),6);
    bufp->fullCData(oldp+32,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__state),2);
    bufp->fullCData(oldp+33,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_reg),5);
    bufp->fullCData(oldp+34,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_reg),4);
    bufp->fullCData(oldp+35,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__nbits_next),4);
    bufp->fullCData(oldp+36,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__state),2);
    bufp->fullCData(oldp+37,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_reg),5);
    bufp->fullCData(oldp+38,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_reg),4);
    bufp->fullCData(oldp+39,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__nbits_next),4);
    bufp->fullCData(oldp+40,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_reg),8);
    bufp->fullBit(oldp+41,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_reg));
    bufp->fullBit(oldp+42,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tx_next));
    bufp->fullCData(oldp+43,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__next_state),2);
    bufp->fullCData(oldp+44,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__tick_next),5);
    bufp->fullCData(oldp+45,(vlSelf->TranAndRecei__DOT__UART_TX_UNIT__DOT__data_next),8);
    bufp->fullBit(oldp+46,(vlSelf->clk));
    bufp->fullBit(oldp+47,(vlSelf->i_uart_rx));
    bufp->fullBit(oldp+48,(vlSelf->reset));
    bufp->fullBit(oldp+49,(vlSelf->o_uart_tx));
    bufp->fullCData(oldp+50,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__next_state),2);
    bufp->fullCData(oldp+51,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__tick_next),5);
    bufp->fullCData(oldp+52,(vlSelf->TranAndRecei__DOT__UART_RX_UNIT__DOT__data_next),8);
    bufp->fullIData(oldp+53,(8U),32);
    bufp->fullIData(oldp+54,(0xbU),32);
    bufp->fullIData(oldp+55,(6U),32);
    bufp->fullIData(oldp+56,(0x35U),32);
    bufp->fullIData(oldp+57,(0x10U),32);
    bufp->fullCData(oldp+58,(vlSelf->TranAndRecei__DOT__str_index),2);
    bufp->fullIData(oldp+59,(vlSelf->TranAndRecei__DOT__counter),28);
    bufp->fullBit(oldp+60,(vlSelf->TranAndRecei__DOT__CHECKOK));
    bufp->fullCData(oldp+61,(0U),3);
    bufp->fullCData(oldp+62,(1U),3);
    bufp->fullCData(oldp+63,(2U),3);
    bufp->fullCData(oldp+64,(3U),3);
    bufp->fullCData(oldp+65,(4U),3);
    bufp->fullCData(oldp+66,(7U),3);
    bufp->fullCData(oldp+67,(0U),2);
    bufp->fullCData(oldp+68,(1U),2);
    bufp->fullCData(oldp+69,(2U),2);
    bufp->fullCData(oldp+70,(3U),2);
}
