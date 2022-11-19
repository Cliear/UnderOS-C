-- lua/lua.lua
-- premake.modules.lua = {}
-- local m = premake.modules.lua

-- local p = premake

local emulator_command = 'qemu-system-x86_64 -L "D:\app center\qemu"  -bios OVMF.fd -M "pc" -m 256 -cpu "qemu64" -smp cores=2 -vga cirrus -serial vc -parallel vc -name "UEFI" -boot order=dc -hdc fat:rw:.\BootLoaderFileSystem'
local compile_command = 'gcc -ffreestanding -mno-red-zone -fno-exceptions -nostdlib -fPIE -e _main_ test.c -o output\result.exe'
local objcopy_command = 'objcopy -S -R ".eh.frame" -R ".comment" -j .text -j .data -j .rdata -j .dynamic -j .got -j .rodata -O binary App output'

function script_help()
    
end

newaction {
    trigger = "script",
    description = "Run the project script with some paraments",

    onStart = function()
        print("Starting script command....");
    end,

    -- onWorkspace = function(wks)
    --     printf("Generating Lua for workspace '%s'", wks.name)
    -- end,

    -- onProject = function(prj)
    --     printf("Generating Lua for project '%s'", prj.name)
    -- end,

    -- execute = function()
    --     print("Executing Lua action")
    -- end,

    -- onEnd = function()
    --     print("Lua generation complete")
    -- end
}

-- return m