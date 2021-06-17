using Vulkan

struct Instance2
    handle::vk.VkInstance
    refcount
    destructor
    table::Dict{Symbol,Ptr{Cvoid}}
end

fptr(inst::Instance2, symbol) = @inbounds inst.table[symbol]

function init_dispatch_table!(obj)
    append!(function_pointer.(inst, INSTANCE_SYMBOLS))
    for sym in API_SYMBOLS
        push!(inst.table, function_pointer(inst; name=string(sym)))
    end
end

function enumerate_physical_devices(inst::Instance2)
    vk.vkEnumeratePhysicalDevices(inst, ..., fptr(inst, :vkEnumeratePhysicalDevices))
end

DispatchTable(inst::Instance) = DispatchTable{Instance}(inst, Dict{})

Base.getproperty(d::DispatchTable, prop::Symbol) = prop == :obj ? getfield(d, :obj) : d.functions[prop]

instance = Instance(["VK_LAYER_KHRONOS_validation"], [])

device = let pdevice = first(unwrap(enumerate_physical_devices(instance)))
    Device(
        pdevice,
        [DeviceQueueCreateInfo(find_queue_family(pdevice, QUEUE_GRAPHICS_BIT & QUEUE_COMPUTE_BIT), [1.0])],
        [], []
    )
end

function_pointer(device, "vkAllocateCommandBuffers")
