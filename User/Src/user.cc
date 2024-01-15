
#include "resource.hh"
namespace res = resource;
namespace ins = res::instance;

extern "C" {
    int user(void) {
        auto LED = &ins::_PB4;
        LED->set_low();
        while (true) {
            ins::_SysTick.mDelay(2000);
            LED->toggle();
        }
        return 0;
    }
}