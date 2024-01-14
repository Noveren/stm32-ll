--[[
    目前仅强耦合地支持 STM32F103C8T6
--]]

import("core.base.json")

local utils = {
    is_same = function(...)
        local args = {...}
        for i, v in ipairs(args) do
            if (i > 1) and (args[i] ~= args[i-1]) then
                return false
            end
        end
        return true
    end,
    get_file_time = function(file)
        --> { "[%d]+" "[%d]+:[%d]+" }
        local outdata, _ = os.iorun("ls -l --time=ctime %s", file)
        return string.match(
            outdata,
            "[%d]+ [%d]+:[%d]+"
        ):split(' ', { plain = true, strict = true })
    end
}

---@class ConfigOpt
---@field conf     string  配置文件路径，为该脚本文件路径
---@field make_src string  Makefile 源文件路径
---@field make_dst string  输出文件路径
---@field debug    boolean 是否为调试模式

function config(target, opt)
    local file = {
        conf     = vformat(opt.conf     or path.join("$(projectdir)", "STM32F1xx.lua")),
        make_src = vformat(opt.make_src or path.join("$(projectdir)", "Makefile"     )),
        make_dst = vformat(opt.make_dst or path.join("$(projectdir)", "build.json"   ))
    }

    if not os.exists(file.make_src) then
        raise(format("Not Found: %s", file.make_src))
    end

    if is_need_to_update(
        file.conf, file.make_src, file.make_dst
    ) then
        makefile2json(file.make_src, file.make_dst, json.savefile)
        print("Gen Cache Into " .. path.relative(file.make_dst, vformat("$(projectdir)")))
    else
        print("Get Cache From " .. path.relative(file.make_dst, vformat("$(projectdir)")))
    end

    __config(target, json.loadfile(file.make_dst))
end

function __config(target, makefile)
    local opt = "-Og"
    local cpu = "-mcpu=cortex-m3"
    local ins = "-mthumb"

    for _, v in ipairs(makefile.defines) do
        target:add("defines", v)
    end
    target:add("cxflags", cpu, ins,
        "-Wall", "-fdata-sections", "-ffunction-sections",
        opt,
        { force = true }
    )
    target:add("asflags", cpu, ins,
        "-Wall", "-fdata-sections", "-ffunction-sections",
        opt,
        { force = true }
    )
    target:add("ldflags", cpu, ins,
        "-T./STM32F103C8TX_FLASH.ld",
        "-specs=nosys.specs",
        "-specs=nano.specs",
        "-lc", "-lnosys", "-Wl,--gc-sections",
        { force = true }
    )
    target:add("includedirs",
        "Drivers/CMSIS/Device/ST/STM32F1xx/Include",
        "Drivers/CMSIS/Include",
        "Drivers/STM32F1xx_HAL_Driver/Inc",
        "Core/Inc"
    )
    target:add("files",
        "./startup_stm32f103xb.s", { rule = "asm.build" }
    )
    for _, file in ipairs(makefile.c_sources) do
        target:add("files", file, { rule = "c.build" })
    end
    if opt.debug then
        target:add("defines", "DEBUG")
        target:add("cflags", "-g", "-gdwarf-2", { force = true })
    end

end

function makefile2json(src, dst, func_savefile)
    local makefile_json = {
        c_sources = {}, -- str
        defines   = {}, -- str
    }

    local makefile = io.readfile(src)

    for file in string.gmatch(makefile, "[%w/_]+%.c") do
        table.insert(makefile_json.c_sources, file)
    end

    for define in string.gmatch(makefile, "%-D[%w_%=]+") do
        table.insert(makefile_json.defines, string.sub(define, 3))
    end

    func_savefile(dst, makefile_json)
end

function is_need_to_update(conf, src, dst)
    -- xmake.lua -> STM32F1xx; xmake.lua 所在的路径
    local root = vformat("$(curdir)")
    local conf = path.relative(conf, root)
    local src  = path.relative(src,  root)
    local dst  = path.relative(dst,  root)
    -- print(conf, src, dst)

    if not os.exists(dst) then
        return true
    end

    local time_conf, time_src, time_dst = 
        utils.get_file_time(conf), utils.get_file_time(src), utils.get_file_time(dst)
    -- print(time_conf[1], time_src[1], time_dst[1])
    -- print(time_conf[2], time_src[2], time_dst[2])

    if not utils.is_same(time_conf[1], time_dst[1]) then
        return true
    end
    
    return (time_src[2] > time_dst[2]) or (time_conf[2] > time_dst[2])
end