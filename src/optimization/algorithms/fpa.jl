"""
    fpa(feval, problem, criterion; popsize=25, p=0.8, seed=nothing, kwargs...)

Flower Pollination Algorithm alternating global Lévy flights and local pollination
steps with switch probability `p`. Tracks the current best solution across the
population.
"""
function fpa(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=25,
    p::Float64=0.8,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if popsize <= 0
        throw(DomainError("popsize <= 0"))
    end

    if p < 0 || p > 1
        throw(DomainError("p must be in [0, 1]"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    dim = problem.dimension
    lb = problem.lowerbound
    ub = problem.upperbound

    population = initpopulation(popsize, problem, rng)
    fitness = zeros(popsize)

    solutions = copy(population)
    stepsize = zeros(dim)

    bestfitness = Inf
    bestindex = 1
    for (i, individual) in enumerate(eachrow(population))
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

    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        for i in 1:popsize
            if rand(rng) > p
                randlevy!(rng, stepsize)
                solutions[i, :] .=
                    population[i, :] .+
                    stepsize .* (solutions[i, :] .- population[bestindex, :])
                clamp!(view(solutions, i, :), lb, ub)
            else
                j, k = randchoice(rng, popsize, 2)
                solutions[i, :] .+= rand(rng) .* (population[j, :] .- population[k, :])
                clamp!(view(solutions, i, :), lb, ub)
            end

            fval = feval(view(solutions, i, :); problem=problem, kwargs...)
            if fval <= fitness[i]
                population[i, :] .= solutions[i, :]
                fitness[i] = fval
            end

            if fval <= bestfitness
                bestfitness = fval
                bestindex = i
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
