"""
    de(feval, problem, criterion; popsize=50, cr=0.8, f=0.9, seed=nothing, kwargs...)

Differential Evolution using DE/rand/1/bin strategy. Generates trial vectors via
differential mutation and binomial crossover, selecting improvements greedily.
"""
function de(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=50,
    cr::Float64=0.8,
    f::Float64=0.9,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if popsize < 4
        throw(DomainError("popsize < 4"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    pop = initpopulation(popsize, problem, rng)

    fitness = zeros(popsize)
    bestfitness = Inf
    for (i, individual) in enumerate(eachrow(pop))
        fx = feval(individual; problem=problem, kwargs...)
        fitness[i] = fx
        if fx < bestfitness
            bestfitness = fx
        end
        evals += 1

        if terminate(stoppingcriterion, evals, iters, bestfitness)
            return bestfitness
        end
    end

    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        for i in 1:popsize
            perm = randchoice(rng, popsize, 4)
            a = perm[1]
            b = perm[2]
            c = perm[3]
            k = perm[4]

            if a == i
                a = k
            elseif b == i
                b = k
            elseif c == i
                c = k
            end

            r = rand(rng, 1:problem.dimension)

            y = pop[i, :]

            for d in 1:problem.dimension
                if d == r || rand(rng) < cr
                    y[d] = pop[a, d] + f * (pop[b, d] - pop[c, d])
                    y[d] = clamp(y[d], problem.lowerbound, problem.upperbound)
                end
            end

            newfitness = feval(y; problem=problem, kwargs...)

            if newfitness < fitness[i]
                fitness[i] = newfitness
                pop[i, :] = y

                if newfitness < bestfitness
                    bestfitness = newfitness
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
