
#include "core.h"

int user(void) {
    while (1) {
        led_toggle();
        delay(500);
    }
    return 0;
}