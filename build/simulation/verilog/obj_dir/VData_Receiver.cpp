// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "VData_Receiver.h"
#include "VData_Receiver__Syms.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

VData_Receiver::VData_Receiver(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new VData_Receiver__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , i_uart_rx{vlSymsp->TOP.i_uart_rx}
    , o_uart_tx{vlSymsp->TOP.o_uart_tx}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

VData_Receiver::VData_Receiver(const char* _vcname__)
    : VData_Receiver(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

VData_Receiver::~VData_Receiver() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void VData_Receiver___024root___eval_debug_assertions(VData_Receiver___024root* vlSelf);
#endif  // VL_DEBUG
void VData_Receiver___024root___eval_static(VData_Receiver___024root* vlSelf);
void VData_Receiver___024root___eval_initial(VData_Receiver___024root* vlSelf);
void VData_Receiver___024root___eval_settle(VData_Receiver___024root* vlSelf);
void VData_Receiver___024root___eval(VData_Receiver___024root* vlSelf);

void VData_Receiver::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VData_Receiver::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    VData_Receiver___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        VData_Receiver___024root___eval_static(&(vlSymsp->TOP));
        VData_Receiver___024root___eval_initial(&(vlSymsp->TOP));
        VData_Receiver___024root___eval_settle(&(vlSymsp->TOP));
    }
    // MTask 0 start
    VL_DEBUG_IF(VL_DBG_MSGF("MTask0 starting\n"););
    Verilated::mtaskId(0);
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    VData_Receiver___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfThreadMTask(vlSymsp->__Vm_evalMsgQp);
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool VData_Receiver::eventsPending() { return false; }

uint64_t VData_Receiver::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* VData_Receiver::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void VData_Receiver___024root___eval_final(VData_Receiver___024root* vlSelf);

VL_ATTR_COLD void VData_Receiver::final() {
    VData_Receiver___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* VData_Receiver::hierName() const { return vlSymsp->name(); }
const char* VData_Receiver::modelName() const { return "VData_Receiver"; }
unsigned VData_Receiver::threads() const { return 1; }
std::unique_ptr<VerilatedTraceConfig> VData_Receiver::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void VData_Receiver___024root__trace_init_top(VData_Receiver___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    VData_Receiver___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VData_Receiver___024root*>(voidSelf);
    VData_Receiver__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->scopeEscape(' ');
    tracep->pushNamePrefix(std::string{vlSymsp->name()} + ' ');
    VData_Receiver___024root__trace_init_top(vlSelf, tracep);
    tracep->popNamePrefix();
    tracep->scopeEscape('.');
}

VL_ATTR_COLD void VData_Receiver___024root__trace_register(VData_Receiver___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void VData_Receiver::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'VData_Receiver::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    if (false && levels && options) {}  // Prevent unused
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    VData_Receiver___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
