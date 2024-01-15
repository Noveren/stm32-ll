## 阶段性小结

**Rust**：Rust 对于嵌入式开发的支持分为两个方面

+   一是完善的工具链，包括交叉编译、构建系统
+   二是由 Rust Embedded Work Group 主导的生态，包括内核、内核运行时、PAC 库、HAL 库，其中关于 PAC 库有提供重要工具 `svd2rust`，能够根据 SVD MCU 说明文件，自动生成 PAC 库，提供操作寄存器的接口
+   HAL 库方面，`embedded-hal` 利用 Trait 机制，尝试约束具体 HAL 的实现，提供通用的 Trait；具体 HAL 的实现，如 `stm32f1xx-hal`，感觉不够成熟，芯片配置没有 STM32CubeMX 那种图形化的界面方便，而且这些库，相对 HAL、LL 没有提供较为详细的文档，有些问题（如时钟配置）难以寻找解决方案；同时，由于 Rust 赋予 HAL 极高的抽象，导致 LSP 或人工难以分析代码

**嵌入式软件开发**：

+   内核特性、寄存器访问是最基础的核心
+   应该对外设寄存器访问进行适当的抽象，而非高度的抽象，嵌入式的底层部分开发必须易于调试；安全性应该主要由开发者负责，语言应该只提供特性进行辅助，不应该有过多的语法噪声
+   GUI 进行配置和代码生成能够大大提高开发效率
+   根据 SVD 生成寄存器访问代码是十分方便的

C 语言的痛点：

+   头文件宏定义常量的污染性

**Zig**：

+   Zig 使用目标是用于系统编程的语言，目标是更好的使用 C 代码，但是比 Rust 更年轻

基于 **C/C++** 的解决方案设想：

1.   使用 STM32CubeMX 生成项目 LL 代码、项目配置及 Makefile；
2.   xmake 读取 Makefile 的配置，生成 build.json 缓存，然后使用 xmake 调用 gcc-arm-eabi-none 工具链进行编译
3.   clangd 作为语言服务器
4.   openocd 进行烧录和调试

+   问题：后续实验室项目大概率会使用 GD32，GD32 虽然与 STM32 对应的型号能够 Pin2Pin 地兼容，但是具体的引脚电气特性、时钟系统、寄存器等等可能不同，因此可能不方便使用 STM32CubeMX 开发；GD32 需要使用官方给定的标准库

TODO xmake 支持读取 STM32CubeMX 的工程文件

TODO xmake 将只用于 HAL/LL 库编译时，在命令行中定义的宏，只适用于库的编译

-   [ ] 从 Makefile 生成的 xmake 向工具链传入的参数，应该 Makefile 完全相同

开发思路：

1.   使用 STM32CubeMX 生成基础代码

     ```shell
     - project\
      - .mxproject             # STM32CubeMX 工程配置文件
      - project.ioc            # STM32CubeMX 工程配置文件
      - Drivers\			      # STM32CubeMX HAL/LL 驱动库
      - chip_FLASH.ld          # STM32CubeMX 链接脚本
      - startup_stm32f103xb.s  # STM32CubeMX 启动代码
      - Makefile               # STM32CubeMX
      - Core\				  # STM32CubeMX & User
     ```

2.   引入生成 xmake 的相关工具（是否要用其他语言写一个工具？），配置构建系统

3.   Core：完成外设配置

4.   Core：引出外设接口；该接口应该屏蔽 HAL/LL/STD 实现，做到业务与硬件分离；；调用接口处可以使用 C++

```shell
- project\
  - Drivers\                 # MCU 外设库
  - Core\                    # Core 接口层
  - User\                    # 业务层
```

xmake 辅助工具（目前暂时可用）

1.   初始化 xmake 交叉编译配置
2.   解析 Makefile 文件内容，生成可以被 xmake 使用的配置



xmake 目前配置偶尔出现，导致编译失败

```shell
error: cannot make xxhash128 for build\.objs\demo\cortex-m3\thumbv7\release\Drivers\STM32F1xx_HAL_Driver\Src\__cpp_stm32f1xx_ll_gpio.c.c, unknown errors
  > in Drivers\STM32F1xx_HAL_Driver\Src\stm32f1xx_ll_gpio.c
```

添加 C++ 模式后，需要如此更改

```
        "-specs=nosys.specs",
        -- "-specs=nano.specs",
```

否则出现 libc 相关的链接错误

```
error: C:/Users/10791/Software/Portable/Scoop/apps/gcc-arm-none-eabi/current/bin/../lib/gcc/arm-none-eabi/13.2.1/../../../../arm-none-eabi/bin/ld.exe: warning: build\demo.elf has a LOAD segment with RWX permissions
C:/Users/10791/Software/Portable/Scoop/apps/gcc-arm-none-eabi/current/bin/../lib/gcc/arm-none-eabi/13.2.1/../../../../arm-none-eabi/bin/ld.exe: C:/Users/10791/Software/Portable/Scoop/apps/gcc-arm-none-eabi/current/bin/../lib/gcc/arm-none-eabi/13.2.1/thumb/v7-m/nofp\libc_nano.a(libc_a-abort.o): in function `abort':
abort.c:(.text.abort+0xa): undefined reference to `_exit'
C:/Users/10791/Software/Portable/Scoop/apps/gcc-arm-none-eabi/current/bin/../lib/gcc/arm-none-eabi/13.2.1/../../../../arm-none-eabi/bin/ld.exe: C:/Users/10791/Software/Portable/Scoop/apps/gcc-arm-none-eabi/current/bin/../lib/gcc/arm-none-eabi/13.2.1/thumb/v7-m/nofp\libc_nano.a(libc_a-signalr.o): in function `_kill_r':
signalr.c:(.text._kill_r+0xe): undefined reference to `_kill'
C:/Users/10791/Software/Portable/Scoop/apps/gcc-arm-none-eabi/current/bin/../lib/gcc/arm-none-eabi/13.2.1/../../../../arm-none-eabi/bin/ld.exe: C:/Users/10791/Software/Portable/Scoop/apps/gcc-arm-none-eabi/current/bin/../lib/gcc/arm-none-eabi/13.2.1/thumb/v7-m/nofp\libc_nano.a(libc_a-signalr.o): in function `_getpid_r':
signalr.c:(.text._getpid_r+0x0): undefined reference to `_getpid'
collect2.exe: error: ld returned 1 exit status
```

虽然实现 blinky Demo，但是引入 C++ 后，编译产物体积变大

```
create ok!
   text    data     bss     dec     hex filename
   6248     312    2292    8852    2294 build\demo.elf
The size of bin is 6560 bytes
```

改为 C 实现

```
   text    data     bss     dec     hex filename
   1528      12    1564    3104     c20 build\demo.elf
The size of bin is 1540 bytes
```

有可能是  "-specs=nosys.specs" 的原因

```
-- 关闭异常相关，大大减少编译产物体积
        "-fno-unwind-tables",
        "-fno-exceptions",
        "-fno-asynchronous-unwind-tables",
```





构造函数

+   默认构造函数：无参数，在没有显式提供初始化式时调用的构造函数，由编译器自动提供；但只要有下面某一种构造函数，系统就不会再自动生成这样一个默认的构造函数。如果希望有一个这样的无参构造函数，则需要显示地写出来。
+   一般构造函数：有参数，由用户创建
+   拷贝构造函数：`C(C& c)`，系统会默认创建
+   移动构造函数
+   继承构造函数
+   委托构造函数
+   析构函数
