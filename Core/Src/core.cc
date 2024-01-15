
#include "core.hh"
#include "stm32f1xx_ll_gpio.h"
#include "stm32f1xx_ll_utils.h"

void
LED::toggle(void) {
    LL_GPIO_TogglePin(GPIOB, LL_GPIO_PIN_4);
}

void delay(uint32_t ms) {
    LL_mDelay(ms);
}