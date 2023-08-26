// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "VTranAndRecei.h"
#include "VTranAndRecei__Syms.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

VTranAndRecei::VTranAndRecei(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new VTranAndRecei__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , i_uart_rx{vlSymsp->TOP.i_uart_rx}
    , o_uart_tx{vlSymsp->TOP.o_uart_tx}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

VTranAndRecei::VTranAndRecei(const char* _vcname__)
    : VTranAndRecei(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

VTranAndRecei::~VTranAndRecei() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void VTranAndRecei___024root___eval_debug_assertions(VTranAndRecei___024root* vlSelf);
#endif  // VL_DEBUG
void VTranAndRecei___024root___eval_static(VTranAndRecei___024root* vlSelf);
void VTranAndRecei___024root___eval_initial(VTranAndRecei___024root* vlSelf);
void VTranAndRecei___024root___eval_settle(VTranAndRecei___024root* vlSelf);
void VTranAndRecei___024root___eval(VTranAndRecei___024root* vlSelf);

void VTranAndRecei::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VTranAndRecei::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    VTranAndRecei___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        VTranAndRecei___024root___eval_static(&(vlSymsp->TOP));
        VTranAndRecei___024root___eval_initial(&(vlSymsp->TOP));
        VTranAndRecei___024root___eval_settle(&(vlSymsp->TOP));
    }
    // MTask 0 start
    VL_DEBUG_IF(VL_DBG_MSGF("MTask0 starting\n"););
    Verilated::mtaskId(0);
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    VTranAndRecei___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfThreadMTask(vlSymsp->__Vm_evalMsgQp);
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool VTranAndRecei::eventsPending() { return false; }

uint64_t VTranAndRecei::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* VTranAndRecei::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void VTranAndRecei___024root___eval_final(VTranAndRecei___024root* vlSelf);

VL_ATTR_COLD void VTranAndRecei::final() {
    VTranAndRecei___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* VTranAndRecei::hierName() const { return vlSymsp->name(); }
const char* VTranAndRecei::modelName() const { return "VTranAndRecei"; }
unsigned VTranAndRecei::threads() const { return 1; }
std::unique_ptr<VerilatedTraceConfig> VTranAndRecei::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void VTranAndRecei___024root__trace_init_top(VTranAndRecei___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    VTranAndRecei___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VTranAndRecei___024root*>(voidSelf);
    VTranAndRecei__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->scopeEscape(' ');
    tracep->pushNamePrefix(std::string{vlSymsp->name()} + ' ');
    VTranAndRecei___024root__trace_init_top(vlSelf, tracep);
    tracep->popNamePrefix();
    tracep->scopeEscape('.');
}

VL_ATTR_COLD void VTranAndRecei___024root__trace_register(VTranAndRecei___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void VTranAndRecei::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'VTranAndRecei::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    if (false && levels && options) {}  // Prevent unused
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    VTranAndRecei___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
