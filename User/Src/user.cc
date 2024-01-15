
#include "core.hh"

extern "C" {
    int user(void) {
        LED led = {};
        while (true) {
            led.toggle();
            delay(1000);
        }
        return 0;
    }
}