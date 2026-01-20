"""
    cs(feval, problem, criterion; popsize=25, pa=0.25, seed=nothing, kwargs...)

Cuckoo Search using Lévy flights and discovery probability `pa` for nest replacement.
Maintains best nest while generating new solutions via random permutations and heavy-
tailed steps.
"""
function cs(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=25,
    pa::Float64=0.25,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if popsize <= 0
        throw(DomainError("popsize <= 0"))
    end

    if pa < 0 || pa > 1
        throw(DomainError("pa must be in [0, 1]"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    dim = problem.dimension
    lb = problem.lowerbound
    ub = problem.upperbound

    population = initpopulation(popsize, problem, rng)
    fitness = zeros(popsize)
    newpopulation = similar(population)
    newfitness = zeros(popsize)

    bestfitness = Inf
    bestindex = 1

    levy_steps = zeros(popsize, dim)
    random_steps = zeros(popsize, dim)
    stepsize = zeros(popsize, dim)
    abandoned = zeros(popsize, dim)
    perm_i = Vector{Int64}(undef, popsize)
    perm_j = Vector{Int64}(undef, popsize)

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
        randlevy!(rng, levy_steps)
        randn!(rng, random_steps)

        for i in 1:popsize
            for j in 1:dim
                stepsize[i, j] =
                    levy_steps[i, j] * (population[i, j] - population[bestindex, j])
                newpopulation[i, j] = clamp(
                    population[i, j] + stepsize[i, j] * random_steps[i, j], lb, ub
                )
            end

            newfitness[i] = feval(view(newpopulation, i, :); problem=problem, kwargs...)
            if newfitness[i] < fitness[i]
                population[i, :] .= newpopulation[i, :]
                fitness[i] = newfitness[i]
                if newfitness[i] < bestfitness
                    bestfitness = newfitness[i]
                    bestindex = i
                end
            end
            evals += 1
            if terminate(stoppingcriterion, evals, iters, bestfitness)
                return bestfitness
            end
        end

        rand!(rng, abandoned)
        abandoned .= abandoned .> pa
        randperm!(rng, perm_i)
        randperm!(rng, perm_j)
        r = rand(rng)

        for i in 1:popsize
            for j in 1:dim
                stepsize[i, j] = r * (population[perm_i[i], j] - population[perm_j[i], j])
                newpopulation[i, j] = clamp(
                    population[i, j] + stepsize[i, j] * abandoned[i, j], lb, ub
                )
            end

            newfitness[i] = feval(view(newpopulation, i, :); problem=problem, kwargs...)
            if newfitness[i] < fitness[i]
                population[i, :] .= newpopulation[i, :]
                fitness[i] = newfitness[i]
                if newfitness[i] < bestfitness
                    bestfitness = newfitness[i]
                    bestindex = i
                end
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
