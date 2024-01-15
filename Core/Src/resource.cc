
#include "resource.hh"
#include "stm32f103xb.h"
#include "stm32f1xx_ll_gpio.h"
#include "stm32f1xx_ll_utils.h"

namespace resource {
// 资源实例创建
namespace instance {
    pin::PushPull _PB4 = pin::PushPull(reinterpret_cast<uint32_t>(GPIOB), LL_GPIO_PIN_4);
    timer::Timer _SysTick = timer::Timer();
}

// 资源类型实现
namespace pin {
    PushPull::PushPull(uint32_t GPIOx, uint32_t PinMask)
        : GPIOx(GPIOx), PinMask(PinMask) { }
    
    void
    PushPull::toggle(void) {
        LL_GPIO_TogglePin(
            reinterpret_cast<GPIO_TypeDef*>(this->GPIOx), 
            this->PinMask
        );
    }

    void
    PushPull::set_high(void) {
        LL_GPIO_SetOutputPin(
            reinterpret_cast<GPIO_TypeDef*>(this->GPIOx),
            this->PinMask
        );
    }

    void
    PushPull::set_low(void) {
        LL_GPIO_ResetOutputPin(
            reinterpret_cast<GPIO_TypeDef*>(this->GPIOx),
            this->PinMask
        );
    }
}

namespace timer {
    void
    Timer::mDelay(uint32_t ms) {
        LL_mDelay(ms);
    }
}

} // namespace resource;