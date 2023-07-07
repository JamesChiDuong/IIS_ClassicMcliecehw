// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "VData_Receiverlite.h"
#include "VData_Receiverlite__Syms.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

VData_Receiverlite::VData_Receiverlite(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new VData_Receiverlite__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , i_uart_rx{vlSymsp->TOP.i_uart_rx}
    , o_uart_tx{vlSymsp->TOP.o_uart_tx}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

VData_Receiverlite::VData_Receiverlite(const char* _vcname__)
    : VData_Receiverlite(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

VData_Receiverlite::~VData_Receiverlite() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void VData_Receiverlite___024root___eval_debug_assertions(VData_Receiverlite___024root* vlSelf);
#endif  // VL_DEBUG
void VData_Receiverlite___024root___eval_static(VData_Receiverlite___024root* vlSelf);
void VData_Receiverlite___024root___eval_initial(VData_Receiverlite___024root* vlSelf);
void VData_Receiverlite___024root___eval_settle(VData_Receiverlite___024root* vlSelf);
void VData_Receiverlite___024root___eval(VData_Receiverlite___024root* vlSelf);

void VData_Receiverlite::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VData_Receiverlite::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    VData_Receiverlite___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        VData_Receiverlite___024root___eval_static(&(vlSymsp->TOP));
        VData_Receiverlite___024root___eval_initial(&(vlSymsp->TOP));
        VData_Receiverlite___024root___eval_settle(&(vlSymsp->TOP));
    }
    // MTask 0 start
    VL_DEBUG_IF(VL_DBG_MSGF("MTask0 starting\n"););
    Verilated::mtaskId(0);
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    VData_Receiverlite___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfThreadMTask(vlSymsp->__Vm_evalMsgQp);
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool VData_Receiverlite::eventsPending() { return false; }

uint64_t VData_Receiverlite::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* VData_Receiverlite::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void VData_Receiverlite___024root___eval_final(VData_Receiverlite___024root* vlSelf);

VL_ATTR_COLD void VData_Receiverlite::final() {
    VData_Receiverlite___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* VData_Receiverlite::hierName() const { return vlSymsp->name(); }
const char* VData_Receiverlite::modelName() const { return "VData_Receiverlite"; }
unsigned VData_Receiverlite::threads() const { return 1; }
std::unique_ptr<VerilatedTraceConfig> VData_Receiverlite::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void VData_Receiverlite___024root__trace_init_top(VData_Receiverlite___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    VData_Receiverlite___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VData_Receiverlite___024root*>(voidSelf);
    VData_Receiverlite__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->scopeEscape(' ');
    tracep->pushNamePrefix(std::string{vlSymsp->name()} + ' ');
    VData_Receiverlite___024root__trace_init_top(vlSelf, tracep);
    tracep->popNamePrefix();
    tracep->scopeEscape('.');
}

VL_ATTR_COLD void VData_Receiverlite___024root__trace_register(VData_Receiverlite___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void VData_Receiverlite::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'VData_Receiverlite::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    if (false && levels && options) {}  // Prevent unused
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    VData_Receiverlite___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
