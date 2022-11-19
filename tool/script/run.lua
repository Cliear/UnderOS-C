-- lua/lua.lua
-- premake.modules.lua = {}
-- local m = premake.modules.lua
-- local p = premake
local emulator_command =
    'qemu-system-x86_64 -L BootLoaderFileSystem/etc -bios OVMF.fd -M "pc" -m 256 -cpu "qemu64" -smp cores=2 -vga cirrus -serial vc -parallel vc -name "UEFI" -boot order=dc -hdc fat:rw:./BootLoaderFileSystem'
local compile_command =
    'gcc -ffreestanding -mno-red-zone -fno-exceptions -nostdlib -fPIE -e _main_ test.c -o output/result.exe'
local objcopy_command =
    'objcopy -S -R ".eh.frame" -R ".comment" -j .text -j .data -j .rdata -j .dynamic -j .got -j .rodata -O binary App output'

function script_help()
    local help_string = 
[[

==========================================================
Usage: premake5 script [command] [paraments]...[example]
Command:
    help        Display this information.
    Compile     Compile the project.
    Collect     Collect the target into raw binary file
    Copy_target Copy the target into project file system
    Run         Run the target by qemu
]];
    print(help_string);
end

function script_compile()
    print("excute the compile command!");
    if #_ARGS >= 2 then
        local parament_string = string.lower(_ARGS[2]);
        if parament_string == "example" then
            print("Compile the example!");
            if os.locate(path.join(_WORKING_DIR, "output", "example")) == nil then
                os.mkdir(path.join(_WORKING_DIR, "output", "example"));
            end
            os.executef("gcc -ffreestanding -mno-red-zone -fno-exceptions -nostdlib -fPIE -e _main_ %s -o %s",
                path.join(_WORKING_DIR, "example", "test.c"), path.join(_WORKING_DIR, "output", "example", "example"));
        end
    end
    print("compile finished!");
end

function script_collect()
    print("excute the colloect command!");
    if #_ARGS >= 2 then
        local parament_string = string.lower(_ARGS[2]);
        if parament_string == "example" then
            print("colloect the example!");
            local src_file_name = path.join(_WORKING_DIR, "output", "example", "example");
            if os.host() == "windows" then
                src_file_name = src_file_name .. ".exe";
            end
            if os.locate(src_file_name) == nil then
                print("Don't find the target, now start to build it!");
                os.execute("premake5 script compile example");
            end
            os.executef(
                'objcopy -S -R ".eh.frame" -R ".comment" -j .text -j .data -j .rdata -j .dynamic -j .got -j .rodata -O binary %s %s',
                src_file_name, path.join(_WORKING_DIR, "output", "example", "example.bin"));
        end
    end
    print("colloect finished!");
end

function script_copy_target()
    print("copy the target!");
    if #_ARGS >= 2 then
        local parament_string = string.lower(_ARGS[2]);
        if parament_string == "example" then
            print("colloect the example!");
            local src_file_name = path.join(_WORKING_DIR, "output", "example", "example.bin");
            if os.locate(src_file_name) == nil then
                print("Don't find the target, now start to build it!");
                os.execute("premake5 script collect example");
            end
            local tartget_dir = path.join(_WORKING_DIR, "BootLoaderFileSystem", "system");
            if os.locate(tartget_dir) == nil then
                print("Don't find the target dir, now remake it!");
                os.mkdir(tartget_dir);
            end
            local ok, err = os.copyfile(src_file_name,
                path.join(_WORKING_DIR, "BootLoaderFileSystem", "system", "result.bin"))
            if ok == nil then
                error_excute(function()
                    print("Can't copy the target!");
                end)
            end
        end
    end
    print("colloect finished!");
end

function script_run()
    print("run the target!");
    if #_ARGS >= 2 then
        local parament_string = string.lower(_ARGS[2]);
        if parament_string == "example" then
            print("run the example!");
            local src_file_name = path.join(_WORKING_DIR, "BootLoaderFileSystem", "system", "result.bin");
            if os.locate(src_file_name) == nil then
                print("Don't find the target, now start to build it!");
                os.execute("premake5 script copy_target example");
            end
            local emulator_command_string = string.format(
                'qemu-system-x86_64 -L %s -bios OVMF.fd -M "pc" -m 256 -cpu "qemu64" -smp cores=2 -vga cirrus -serial vc -parallel vc -name "UEFI" -boot order=dc -hdc fat:rw:%s',
                path.join(_WORKING_DIR, "BootLoaderFileSystem", "etc"), path.join(_WORKING_DIR, "BootLoaderFileSystem"));
            os.execute(emulator_command_string);
        end
    end
    print("Run finished!");
end

function warn_excute(functor)
    local currentColor = term.getTextColor();
    term.setTextColor(term.warningColor);
    functor();
    term.setTextColor(currentColor);
end

function error_excute(functor)
    local currentColor = term.getTextColor();
    term.setTextColor(term.errorColor);
    functor();
    term.setTextColor(currentColor);
end

function highlight_excute(functor)
    local currentColor = term.getTextColor();
    term.setTextColor(term.infoColor);
    functor();
    term.setTextColor(currentColor);
end

local script_command = {
    help = script_help,
    compile = script_compile,
    collect = script_collect,
    copy_target = script_copy_target,
    run = script_run
};
function script_command_convert(command_string)
    for key, value in pairs(script_command) do
        if key == command_string then
            return value;
        end
    end
    local currentColor = term.getTextColor();
    term.setTextColor(term.errorColor);
    local error_prompt = string.format("command [%s] is invalid!", command_string);
    print("\n" .. error_prompt);
    term.setTextColor(currentColor);
    return script_command.help;
end

newaction {
    trigger = "script",
    description = "Run the project script with some paraments",

    onStart = function()
        if #_ARGS == 0 then
            script_help();
            return;
        end
        local command_callable = script_command_convert(_ARGS[1]);
        command_callable();
    end

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
