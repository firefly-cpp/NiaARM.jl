"""
    randchoice(rng, n, k)

Pick `k` unique indices from `1:n` using `rng`.
"""
function randchoice(rng::AbstractRNG, n::Int64, k::Int64)
    perm = randperm(rng, n)
    return first(perm, k)
end

function randchoice(rng::AbstractRNG, n::AbstractArray, k::Int64)
    perm = shuffle(rng, n)
    return first(perm, k)
end

"""
    randlevy(rng; alpha=0.01, beta=1.5)

Draw a Lévy-distributed random variate using the Mantegna algorithm.
"""
function randlevy(rng::AbstractRNG; alpha::Float64=0.01, beta::Float64=1.5)
    sigma =
        (
            gamma(1 + beta) * sin(pi * beta / 2) /
            (gamma((1 + beta) / 2) * beta * 2 ^ ((beta - 1) / 2))
        ) ^ (1 / beta)
    u = sigma * randn(rng)
    v = randn(rng)
    return alpha * u / (abs(v) ^ (1 / beta))
end

function randlevy(
    rng::AbstractRNG, dims::Vararg{Int64}; alpha::Float64=0.01, beta::Float64=1.5
)
    sigma =
        (
            gamma(1 + beta) * sin(pi * beta / 2) /
            (gamma((1 + beta) / 2) * beta * 2 ^ ((beta - 1) / 2))
        ) ^ (1 / beta)
    u = sigma .* randn(rng, dims)
    v = randn(rng, dims)
    return alpha .* u ./ (abs.(v) .^ (1 / beta))
end

function randlevy!(
    rng::AbstractRNG, out::AbstractArray{Float64}; alpha::Float64=0.01, beta::Float64=1.5
)
    sigma =
        (
            gamma(1 + beta) * sin(pi * beta / 2) /
            (gamma((1 + beta) / 2) * beta * 2 ^ ((beta - 1) / 2))
        ) ^ (1 / beta)
    for i in eachindex(out)
        u = sigma * randn(rng)
        v = randn(rng)
        out[i] = alpha * u / abs(v)^(1/beta)
    end
end

function randcauchy(rng::AbstractRNG, loc::Float64, scale::Float64)
    u = rand(rng)
    return loc + scale * tan(pi * (u - 0.5))
end

function parentmedium!(
    trial::AbstractVector{Float64}, parent::AbstractVector{Float64}, problem::Problem
)
    for d in 1:problem.dimension
        if trial[d] < problem.lowerbound
            trial[d] = (problem.lowerbound + parent[d]) / 2
        elseif trial[d] > problem.upperbound
            trial[d] = (problem.upperbound + parent[d]) / 2
        end
    end
    return trial
end

"""
    initpopulation(popsize, problem, rng)

Sample an initial population uniformly within the problem initialization bounds.
"""
function initpopulation(popsize::Int64, problem::Problem, rng::AbstractRNG)
    return problem.lowerinit .+
           rand!(rng, zeros(popsize, problem.dimension)) .*
           (problem.upperinit - problem.lowerinit)
end
