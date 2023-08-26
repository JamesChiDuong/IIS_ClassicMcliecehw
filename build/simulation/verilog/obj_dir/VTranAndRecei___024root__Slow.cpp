// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTranAndRecei.h for the primary calling header

#include "verilated.h"

#include "VTranAndRecei__Syms.h"
#include "VTranAndRecei___024root.h"

void VTranAndRecei___024root___ctor_var_reset(VTranAndRecei___024root* vlSelf);

VTranAndRecei___024root::VTranAndRecei___024root(VTranAndRecei__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    VTranAndRecei___024root___ctor_var_reset(this);
}

void VTranAndRecei___024root::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

VTranAndRecei___024root::~VTranAndRecei___024root() {
}
