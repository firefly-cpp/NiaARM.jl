"""
    Problem(dimension, lowerbound, upperbound[, lowerinit, upperinit])

Continuous search-space description used by optimization algorithms. Bounds constrain
candidate solutions and initialization ranges; validation guards against invalid
domains.
"""
struct Problem
    dimension::Int64
    lowerbound::Float64
    upperbound::Float64
    lowerinit::Float64
    upperinit::Float64

    function Problem(
        dimension::Int64,
        lowerbound::Float64,
        upperbound::Float64,
        lowerinit::Float64,
        upperinit::Float64,
    )
        if dimension <= 0
            throw(DomainError("dimension <= 0"))
        end

        if lowerbound >= upperbound
            throw(ArgumentError("lowerbound >= upperbound"))
        end

        if lowerinit >= upperinit
            throw(ArgumentError("lowerinit >= upperinit"))
        end

        return new(dimension, lowerbound, upperbound, lowerinit, upperinit)
    end

    function Problem(dimension::Int64, lowerbound::Float64, upperbound::Float64)
        return Problem(dimension, lowerbound, upperbound, lowerbound, upperbound)
    end
end
