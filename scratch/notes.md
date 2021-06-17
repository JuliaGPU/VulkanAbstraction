# Notes

1. _Enums generated.
 - (check that anything that may use enum types (function argument types, return types, struct fields) use the correct enum.)

2. All old structs now prefixed with an underscore.
- check that no no-underscore uses remain in the wrapper, in the prewrap code and in the tests.

3. HL structs defined for all non-returnedonly structs (these ones are considered already high-level structs). Uses `nice_julian_type` on undropped fields, the only difference being that it refers to high-level structs instead of the old ones wherever encountered.

4. VulkanCore types not exported anymore.
- check that no Vk\* types are used anywhere

===

1. _Enums now exposed in nice_julian_type.

2. Conversions from HL structs to LL structs were defined:
    - Explicitly via the overload of LL struct constructors.
        Pass on all HL struct fields as arg/kwarg of the high-level constructor for the LL struct.
    - Implicitly via the overload of Base.convert.
        Just call the explicit constructor.

3. Constructors with default keywords were added to HL structs.

4. Enum types given a `enum_type` method (instead of the original remove_vk_prefix)

5. Optional HL struct members that are not a flag nor pNext nor String nor Vector are made `Optional{T}`.

===

Make some tests on _DeviceQueueCreateInfo (struct + constructor + converters)
Possible variable preservation issue (InstanceCreateInfo in Vulkan tests)
Find a better way for converting new structs using `cconvert` and `unsafe_convert`.

===

Add docs on:
- namespacing: removal of prefixes, export everything, users can do `const vk = Vulkan` and `vk.MyType`, mention the underscore prefix for minimalist structs

