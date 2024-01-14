set_config("plat", "cortex-m3")
set_config("arch", "thumbv7")

set_config("cross", "arm-none-eabi-")
set_config("target_os", "none")
set_config("sdk", "$(env GCC_ARM_NONE_EABI_ROOT)")

target("demo") do
    set_targetdir("$(buildir)")
    set_kind("binary")
    set_extension(".elf")
    set_languages("c99", "cxx11")

    on_load(function(target)
        import("STM32F1xx").config(target, {
            conf  = path.join("$(projectdir)", "STM32F1xx.lua"),
            debug = false
        })
    end)

    add_includedirs(
        "$(env GCC_ARM_NONE_EABI_ROOT)/arm-none-eabi/include",
        "User/Inc"
    )

    -- Makefile 中的文件已导入
    add_files(
        "Core/Src/core.cc",
        "User/Src/user.cc"
    )

    after_build(function(target)
        import("core.base.task").run("project", {kind="compile_commands"})
        os.exec("arm-none-eabi-size %s", target:targetfile())
        local bin = path.join(target:targetdir(), target:basename() .. ".bin")
        os.run(
            "arm-none-eabi-objcopy %s %s -O binary",
            target:targetfile(),
            bin
        )
        print("The size of bin is " .. os.filesize(bin) .." bytes")
    end)

    on_install(function(target)
        local bin = path.join(target:targetdir(), target:basename() .. ".bin")
        os.exec("st-info --probe")
        os.exec("st-flash write %s 0x08000000", bin)
        -- 若使用 LL 库，可能需要 TODO
        -- os.exec("st-flash --connect-under-reset write %s 0x08000000", bin)
    end)
end