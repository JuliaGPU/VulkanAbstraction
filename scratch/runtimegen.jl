using RuntimeGeneratedFunctions

RuntimeGeneratedFunctions.init(@__MODULE__)

using BenchmarkTools

function f(x)
    x + rand()
end

@btime f($2)

function init()
    ex = :(x -> :(x + rand()))
    g = @RuntimeGeneratedFunction ex
    @btime $g($2)
end

init()
