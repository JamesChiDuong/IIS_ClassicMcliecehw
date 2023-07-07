// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VData_Receiver.h for the primary calling header

#include "verilated.h"

#include "VData_Receiver__Syms.h"
#include "VData_Receiver___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__ico(VData_Receiver___024root* vlSelf);
#endif  // VL_DEBUG

void VData_Receiver___024root___eval_triggers__ico(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.at(0U) = (0U == vlSelf->__VicoIterCount);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VData_Receiver___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VData_Receiver___024root___dump_triggers__act(VData_Receiver___024root* vlSelf);
#endif  // VL_DEBUG

void VData_Receiver___024root___eval_triggers__act(VData_Receiver___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VData_Receiver___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.at(0U) = ((IData)(vlSelf->clk) 
                                      & (~ (IData)(vlSelf->__Vtrigrprev__TOP__clk)));
    vlSelf->__VactTriggered.at(1U) = (((IData)(vlSelf->Data_Receiver__DOT__reset) 
                                       & (~ (IData)(vlSelf->__Vtrigrprev__TOP__Data_Receiver__DOT__reset))) 
                                      | ((IData)(vlSelf->clk) 
                                         & (~ (IData)(vlSelf->__Vtrigrprev__TOP__clk))));
    vlSelf->__Vtrigrprev__TOP__clk = vlSelf->clk;
    vlSelf->__Vtrigrprev__TOP__Data_Receiver__DOT__reset 
        = vlSelf->Data_Receiver__DOT__reset;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VData_Receiver___024root___dump_triggers__act(vlSelf);
    }
#endif
}
