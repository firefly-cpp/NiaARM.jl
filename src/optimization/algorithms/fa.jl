"""
    fa(feval, problem, criterion; popsize=20, alpha=1.0, beta0=1.0, gamma=0.01, theta=0.97, seed=nothing, kwargs...)

Firefly Algorithm where attraction decreases exponentially with distance. Random walk
amplitude decays by `theta` each iteration to balance exploration and exploitation.
"""
function fa(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=20,
    alpha::Float64=1.0,
    beta0::Float64=1.0,
    gamma::Float64=0.01,
    theta::Float64=0.97,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if popsize <= 0
        throw(DomainError("popsize <= 0"))
    end

    if alpha < 0 || alpha > 1
        throw(DomainError("alpha must be in [0, 1]"))
    end

    if beta0 < 0 || beta0 > 1
        throw(DomainError("beta0 must be in [0, 1]"))
    end

    if gamma < 0 || gamma > 1
        throw(DomainError("gamma must be in [0, 1]"))
    end

    if theta < 0 || theta > 1
        throw(DomainError("theta must be in [0, 1]"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    dim = problem.dimension
    lb = problem.lowerbound
    ub = problem.upperbound
    searchrange = ub - lb

    population = initpopulation(popsize, problem, rng)
    fitness = zeros(popsize)

    bestfitness = Inf
    for (i, individual) in enumerate(eachrow(population))
        fitness[i] = feval(individual; problem=problem, kwargs...)
        bestfitness = min(bestfitness, fitness[i])

        evals += 1
        if terminate(stoppingcriterion, evals, iters, bestfitness)
            return bestfitness
        end
    end

    newalpha = alpha
    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        newalpha *= theta
        for i in 1:popsize
            for j in 1:popsize
                if fitness[i] > fitness[j]
                    r = sum((population[i, :] .- population[j, :]) .^ 2)
                    beta = beta0 * exp(-gamma * r)
                    steps = newalpha .* (rand(rng, dim) .- 0.5) .* searchrange
                    population[i, :] .=
                        population[i, :] + beta .* (population[j, :] .- population[i, :]) .+
                        steps
                    clamp!(view(population, i, :), lb, ub)
                end
            end

            fitness[i] = feval(view(population, i, :); problem=problem, kwargs...)
            bestfitness = min(bestfitness, fitness[i])

            evals += 1
            if terminate(stoppingcriterion, evals, iters, bestfitness)
                return bestfitness
            end
        end

        iters += 1
    end
    return bestfitness
end
