"""
    ba(feval, problem, criterion; popsize=40, loudness0=1.0, pulse_rate0=1.0, fmin=0.0, fmax=2.0, alpha=0.97, gamma=0.1, seed=nothing, kwargs...)

Bat Algorithm implementation following frequency-tuned velocity updates and adaptive
loudness/pulse rate schedules. Exploits the current global best while injecting random
walks for local search.
"""
function ba(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=40,
    loudness0::Float64=1.0,
    pulse_rate0::Float64=1.0,
    fmin::Float64=0.0,
    fmax::Float64=2.0,
    alpha::Float64=0.97,
    gamma::Float64=0.1,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if popsize <= 0
        throw(DomainError("popsize <= 0"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    dim = problem.dimension
    pop = initpopulation(popsize, problem, rng)
    velocity = zeros(popsize, dim)
    freq = zeros(popsize)
    fitness = zeros(popsize)

    candidate = zeros(dim)
    randbuf = similar(candidate)
    best = similar(candidate)
    loudness = loudness0
    base_pulse_rate = pulse_rate0

    bestfitness = Inf
    bestindex = 1

    for (i, individual) in enumerate(eachrow(pop))
        f = feval(individual; problem=problem, kwargs...)
        fitness[i] = f
        if f < bestfitness
            bestfitness = f
            bestindex = i
        end
        evals += 1

        if terminate(stoppingcriterion, evals, iters, bestfitness)
            return bestfitness
        end
    end

    best .= pop[bestindex, :]

    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        loudness *= alpha
        current_pulse_rate = base_pulse_rate * (1 - exp(-gamma * (iters + 1)))

        for i in 1:popsize
            freq[i] = fmin + (fmax - fmin) * rand(rng)

            @views begin
                vi = velocity[i, :]
                xi = pop[i, :]
                @. vi = vi + (xi - best) * freq[i]
                @. candidate = xi + vi
            end

            if rand(rng) < current_pulse_rate
                randn!(rng, randbuf)
                @. candidate = best + 0.1 * loudness * randbuf
            end

            clamp!(candidate, problem.lowerbound, problem.upperbound)

            newfitness = feval(candidate; problem=problem, kwargs...)

            if newfitness <= fitness[i] && rand(rng) > loudness
                @views pop[i, :] .= candidate
                fitness[i] = newfitness
            end

            if newfitness <= bestfitness
                bestfitness = newfitness
                best .= candidate
            end

            evals += 1

            if terminate(stoppingcriterion, evals, iters, bestfitness)
                return bestfitness
            end
        end

        iters += 1
    end

    return bestfitness
end
