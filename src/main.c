#include "CH58x_common.h"

int main(void) {
    HSECFG_Capacitance(HSECap_18p);
    SetSysClock(CLK_SOURCE_HSE_PLL_62_4MHz);

    for (;;) {
    }
}