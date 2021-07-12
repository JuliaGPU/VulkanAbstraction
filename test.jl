using DocStringExtensions

@template (FUNCTIONS, METHODS, MACROS) =
    """
    $(DOCSTRING)
    $(TYPEDSIGNATURES)
    """

@template TYPES =
    """
    $(DOCSTRING)
    $(TYPEDEF)
    $(TYPEDFIELDS)
    """

"""
Struct B with methods

$(SIGNATURES)
$(TYPEDFIELDS)
"""
struct B
    "Field a."
    a::Int
    "Field b. Quite important."
    b
end

"""
This is an important method!
"""
B(a::Integer) = A(a, a)

"""
This struct is C.
"""
struct C
    "Field c."
    c::Int
end

"Documented method for C."
C(::String) = C(2)

"""
Some function that does something.
$(TYPEDSIGNATURES)

!!! info
    I am testing something.
"""
function func2 end

"Another docstring"
function func2()
    3
end

"Yet [Another](@ref func2) docstring"
function func2(a::Integer)
    2
end

func2(b::String) = 0

"""
create_instance ← [vkCreateInstance](https://www.khronos.org/registry/vulkan/specs/1.2-extensions/man/html/vkCreateInstance.html)

1) `create_instance(create_info::InstanceCreateInfo; allocator = C_NULL) -> ResultTypes.Result{Instance, VulkanError}`

2) `create_instance(enabled_layer_names::AbstractArray, enabled_extension_names::AbstractArray; allocator = C_NULL, next = C_NULL, flags = 0, application_info = C_NULL) -> ResultTypes.Result{Instance, VulkanError}`

3) `create_instance(create_info::_InstanceCreateInfo; allocator = C_NULL) -> ResultTypes.Result{Instance, VulkanError}`

# Extended help

Return codes:
- Error:
    - `ERROR_OUT_OF_HOST_MEMORY`
    - `ERROR_OUT_OF_DEVICE_MEMORY`
    - `ERROR_INITIALIZATION_FAILED`
    - `ERROR_LAYER_NOT_PRESENT`
    - `ERROR_EXTENSION_NOT_PRESENT`
    - `ERROR_INCOMPATIBLE_DRIVER`

Optional function pointers (see [`function_pointer`](@ref)): vkCreateInstance, vkDestroyInstance
"""
function create_instance end

"""
set_event ← [vkSetEvent](https://www.khronos.org/registry/vulkan/specs/1.2-extensions/man/html/vkSetEvent.html)

`set_event(device::Device, event::Event) -> ResultTypes.Result{Instance, VulkanError}`

# Extended help

Return codes:
- Error:
    - `ERROR_OUT_OF_HOST_MEMORY`
    - `ERROR_OUT_OF_DEVICE_MEMORY`

Optional function pointers (see [`function_pointer`](@ref)): vkSetEvent

!!! warning
    Access to `event` must be synchronized.
"""
function set_event end
