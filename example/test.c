// ==============================================================================================================================
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//                   All of these should define in BootLoader shared dir, not here, this is just a example
#include <stdint.h>

typedef uintptr_t RegisterSize;

typedef enum { UNUSABLE_MEMORY, RAM_MEMORY, ROM_MEMORY, ACPI_RECLAIM_MEMORY, ACPI_NVS_MEMORY } DeviceMemoryType;

typedef struct
{
    RegisterSize address;
    RegisterSize size;
    RegisterSize type;  // value is DeviceMemoryType
} MemoryDescriptor;

typedef struct
{
    RegisterSize count;
    MemoryDescriptor * memory;
} DeviceMemoryInfo;

typedef enum {DEVICE_PIXEL_RGBA, DEVICE_PIXEL_BGRA, DEVICE_PIXEL_TYPE_COUNT} DisplayDevicePixelType;

typedef struct
{
    RegisterSize frame_buff;
    RegisterSize buff_size;
    RegisterSize width;
    RegisterSize height;
    RegisterSize pixs_per_line;
    RegisterSize format;        // value is from DisplayDevicePixelType
} DeviceVideoInfo;

typedef struct
{
    RegisterSize image_number;
    DeviceVideoInfo video;
    DeviceMemoryInfo memory;
} DeviceBootInfo;
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// ==============================================================================================================================

void _main_()
{
    DeviceBootInfo * info = (DeviceBootInfo *) 0;
    uint8_t * buff = (uint8_t *)(info->video.frame_buff);
    for (int i = 0; i < info->video.buff_size; i++)
    {
        buff[i] = 0xff;
    }
    while (1);
}