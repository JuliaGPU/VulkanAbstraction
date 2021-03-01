"""
Exception type indicating that an API function
returned a non-success code.
"""
struct VulkanError <: Exception
    msg::AbstractString
    code::VkResult
end

Base.showerror(io::IO, e::VulkanError) = print(io, e.code, ": ", e.msg)

"""
    @check vkCreateInstance(args...)

Assign the expression to a variable named `_return_code`. Then, if the value is not a success code, return a [`VulkanError`](@ref) holding the return code.

"""
macro check(expr)
    msg = string("failed to execute ", expr)
    esc(:(@check $expr $msg))
end

macro check(expr, msg)
    esc(quote
        _return_code = $expr
        if Int32(_return_code) < 0
            return VulkanError($msg, _return_code)
        end
    end)
end
