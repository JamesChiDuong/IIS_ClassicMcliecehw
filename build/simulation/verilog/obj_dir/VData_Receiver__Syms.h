// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VDATA_RECEIVER__SYMS_H_
#define VERILATED_VDATA_RECEIVER__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "VData_Receiver.h"

// INCLUDE MODULE CLASSES
#include "VData_Receiver___024root.h"

// SYMS CLASS (contains all model state)
class VData_Receiver__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    VData_Receiver* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    VData_Receiver___024root       TOP;

    // CONSTRUCTORS
    VData_Receiver__Syms(VerilatedContext* contextp, const char* namep, VData_Receiver* modelp);
    ~VData_Receiver__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
