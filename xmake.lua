set_config("plat", "cortex-m3")
set_config("arch", "thumbv7")

set_config("cross", "arm-none-eabi-")
set_config("target_os", "none")
set_config("sdk", "$(env GCC_ARM_NONE_EABI_ROOT)")


set_languages("c99", "cxx17")
set_targetdir("$(buildir)")

after_build(function(target)
    if target:kind() == "binary" then
        os.exec("arm-none-eabi-size %s", target:targetfile())
        local bin = path.join(target:targetdir(), target:basename() .. ".bin")
        os.run(
            "arm-none-eabi-objcopy %s %s -O binary",
            target:targetfile(),
            bin
        )
        print("The size of bin is " .. os.filesize(bin) .." bytes")
    end
end)

on_install(function(target)
    if target:kind() == "binary" then
        local bin = path.join(target:targetdir(), target:basename() .. ".bin")
        os.exec("st-info --probe")
        os.exec("st-flash write %s 0x08000000", bin)
    end
end)

target("demo") do
    set_extension(".elf")

    add_includedirs(
        "Drivers/CMSIS/Include",
        "Drivers/CMSIS/Device/ST/STM32F1xx/Include",
        "Drivers/STM32F1xx_HAL_Driver/Inc",
        "Core/Inc",
        "User/Inc"
    )
    add_files(
        "startup_stm32f103xb.s",
        { force = { asflags = {
            "-mcpu=cortex-m3",
            "-mthumb",
            "-Wall",
            "-Og",
            "-fdata-sections",
            "-ffunction-sections"
        }}}
    )
    add_files(
        "Drivers/STM32F1xx_HAL_Driver/Src/*.c",
        "Core/Src/*.c",
        "Core/Src/resource.cc",
        {
            defines = {
                "STM32F1",
                "STM32F103xB",
                "HSE_VALUE=8000000",
                "HSI_VALUE=8000000",
                "LSE_VALUE=32768",
                "LSI_VALUE=40000",
                "HSE_STARTUP_TIMEOUT=100",
                "LSE_STARTUP_TIMEOUT=100",
                "VDD_VALUE=3300",
                "PREFETCH_ENABLE=1",
                "USE_FULL_LL_DRIVER"
            }
        }
    )

    add_cxflags(
        "-mcpu=cortex-m3",
        "-mthumb",
        "-Wall",
        "-Og",
        "-fdata-sections",
        "-ffunction-sections",
        { force = true }
    )
    add_cxxflags(
        "-fno-rtti",
        -- 关闭异常相关，大大减少编译产物体积
        "-fno-unwind-tables",
        "-fno-exceptions",
        "-fno-asynchronous-unwind-tables",
        { force = true }
    )
    add_ldflags(
        "-mcpu=cortex-m3",
        "-mthumb",
        "-TSTM32F103C8Tx_FLASH.ld",
        "-specs=nano.specs",
        "-specs=nosys.specs",
        "-lc",
        "-lnosys",
        -- "-nostdlib",      -- 不可启用，启动文件中调用 __libc_init_array 进行初始化
        "-Wl,--gc-sections",
        { force = true }
    )
    add_files("User/Src/user.cc")
end