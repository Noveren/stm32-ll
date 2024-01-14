Rust 关于 STM32F1xx 相关生态感觉不够成熟；芯片配置没有 STM32CubeMX 方便

+   先使用 STM32CubeMX 选择特定芯片，生成底层配置代码，产生 Makefile 文件

+   xmake 读取 Makefile 的配置，生成 build.json 缓存，然后使用 xmake 调用 gcc-arm-eabi-none 工具链进行编译

TODO xmake 支持读取 STM32CubeMX 的工程文件

TODO xmake 支持