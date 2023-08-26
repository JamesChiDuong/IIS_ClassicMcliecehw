// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VData_Receiver.h for the primary calling header

#include "verilated.h"

#include "VData_Receiver__Syms.h"
#include "VData_Receiver___024root.h"

void VData_Receiver___024root___ctor_var_reset(VData_Receiver___024root* vlSelf);

VData_Receiver___024root::VData_Receiver___024root(VData_Receiver__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    VData_Receiver___024root___ctor_var_reset(this);
}

void VData_Receiver___024root::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

VData_Receiver___024root::~VData_Receiver___024root() {
}
