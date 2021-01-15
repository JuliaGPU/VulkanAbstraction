"""
Represents any kind of wrapper structure that was generated from a Vulkan structure.
`D` is a `Bool` parameter indicating whether the structure has specific dependencies or not.
"""
abstract type VulkanStruct{D} end

"""
Opaque handle referring to internal Vulkan data.
Finalizer registration is taken care of by constructors.
"""
abstract type Handle <: VulkanStruct{false} end

"""
Represents a structure that will never be requested by API functions.
"""
abstract type ReturnedOnly <: VulkanStruct{false} end

const FunctionPtr = Union{Ptr{Cvoid}, Base.CFunction}

Base.cconvert(T::Type, x::VulkanStruct) = x
Base.cconvert(T::Type{<:Ptr}, x::AbstractVector{<:VulkanStruct{false}}) = getproperty.(x, :vks)
Base.cconvert(T::Type{<:Ptr}, x::AbstractVector{<:VulkanStruct{true}}) = (x, getproperty.(x, :vks))
Base.cconvert(T::Type{<:Ptr}, x::VulkanStruct{false}) = Ref(x.vks)
Base.cconvert(T::Type{<:Ptr}, x::VulkanStruct{true}) = (x, Ref(x.vks))
Base.cconvert(T::Type{<:Ptr}, x::Handle) = x

Base.unsafe_convert(T::Type, x::VulkanStruct) = x.vks
Base.unsafe_convert(T::Type, x::Tuple{<:VulkanStruct{true}, <:Ref}) = Base.unsafe_convert(T, last(x))
Base.unsafe_convert(T::Type, x::Tuple{<:AbstractVector{<:VulkanStruct{true}}, <:Any}) = Base.unsafe_convert(T, last(x))

Base.broadcastable(x::VulkanStruct) = Ref(x)

struct VulkanError <: Exception
    msg::AbstractString
    return_code
end

Base.showerror(io::IO, e::VulkanError) = print(io, "$(e.return_code): ", e.msg)

"""
    @check vkFunctionSomething()

Checks whether the expression returned VK_SUCCESS or any non-error codes. Else, throw an error printing the corresponding code.
"""
macro check(expr)
    quote
        local msg = "failed to execute " * $(string(expr))
        @check $(esc(expr)) msg
    end
end

macro check(expr, msg)
    quote
        return_code = $(esc(expr))
        if Int(return_code) > 0
            @debug "Non-success return code $return_code"
        elseif Int(return_code) < 0
            throw(VulkanError($msg, return_code))
        end
        return_code
    end
end

pointer_length(arr::Ptr{Nothing}) = 0
pointer_length(arr::AbstractArray) = length(arr)
pointer_length(arr::RefArray) = length(arr.roots)
pointer_length(arr::Tuple{<:Any,<:Any}) = length(first(arr))

to_vk(T, x) = convert(T, x)
to_vk(T::Type{UInt32}, version::VersionNumber) = VK_MAKE_VERSION(version.major, version.minor, version.patch)
to_vk(T::Type{NTuple{N,UInt8}}, s::AbstractString) where {N} = T(s * '\0' ^ (N - length(s)))

from_vk(T::Type{<:VulkanStruct{false}}, x) = T(x)
from_vk(T::Type{<:VulkanStruct{true}}, x) = T(x, [])
from_vk(T, x) = convert(T, x)
from_vk(T::Type{VersionNumber}, version::UInt32) = T(VK_VERSION_MAJOR(version), VK_VERSION_MINOR(version), VK_VERSION_PATCH(version))
from_vk(T::Type{S}, str::NTuple{N,UInt8}) where {N,S <: AbstractString} = T(filter!(x -> x ≠ 0, UInt8[str...]))

Base.show(io::IO, h::Handle) = print(io, typeof(h), '(', h.vks, ')')

function try_destroy(f, handle::Handle)
    handle.refcount -= 1
    if handle.refcount == 0
        f(handle)
    end
end

function (T::Type{<:Handle})(ptr::Ptr{Cvoid}, destructor)
    handle = T(ptr, 1)
    maybe_destroy = () -> try_destroy(destructor, handle)
    handle.destructor = maybe_destroy
    finalizer(x -> handle.destructor(), handle)
end

function (T::Type{<:Handle})(ptr::Ptr{Cvoid}, destructor, parent::Handle)
    parent.refcount += 1
    finalizer(x -> parent.destructor(), T(ptr, destructor))
end
