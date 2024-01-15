#pragma once

#include <stdint.h>

namespace resource {

// ================================================================
// 声明所需资源
namespace pin {
    class PushPull;
}

namespace timer {
    class Timer;
}

namespace spi {
    class SerialPeripheralInterface;
}

namespace instance {
    extern pin::PushPull _PB4;
    extern timer::Timer _SysTick;
    // extern spi::SerialPeripheralInterface _SPI1;
}


// ================================================================
// 声明资源类型（方法）
class pin::PushPull {
    private:
        uint32_t GPIOx;
        uint32_t PinMask;
        PushPull()=delete;
    public:
        ~PushPull() { }
        PushPull(uint32_t GPIOx, uint32_t PinMask);
        void toggle(void);
        void set_high(void);
        void set_low(void);
};

class timer::Timer {
    private:
    public:
        Timer()=default;
        ~Timer() {}
        void mDelay(uint32_t ms);
};

class spi::SerialPeripheralInterface {

};

} // namespace resource;