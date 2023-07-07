// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTranAndReceilite.h for the primary calling header

#include "verilated.h"

#include "VTranAndReceilite__Syms.h"
#include "VTranAndReceilite___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndReceilite___024root___dump_triggers__ico(VTranAndReceilite___024root* vlSelf);
#endif  // VL_DEBUG

void VTranAndReceilite___024root___eval_triggers__ico(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.at(0U) = (0U == vlSelf->__VicoIterCount);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VTranAndReceilite___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VTranAndReceilite___024root___dump_triggers__act(VTranAndReceilite___024root* vlSelf);
#endif  // VL_DEBUG

void VTranAndReceilite___024root___eval_triggers__act(VTranAndReceilite___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTranAndReceilite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTranAndReceilite___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.at(0U) = ((IData)(vlSelf->clk) 
                                      & (~ (IData)(vlSelf->__Vtrigrprev__TOP__clk)));
    vlSelf->__VactTriggered.at(1U) = (((IData)(vlSelf->TranAndRecei__DOT__reset) 
                                       & (~ (IData)(vlSelf->__Vtrigrprev__TOP__TranAndRecei__DOT__reset))) 
                                      | ((IData)(vlSelf->clk) 
                                         & (~ (IData)(vlSelf->__Vtrigrprev__TOP__clk))));
    vlSelf->__Vtrigrprev__TOP__clk = vlSelf->clk;
    vlSelf->__Vtrigrprev__TOP__TranAndRecei__DOT__reset 
        = vlSelf->TranAndRecei__DOT__reset;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VTranAndReceilite___024root___dump_triggers__act(vlSelf);
    }
#endif
}
