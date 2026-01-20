function tournament_selection(
    fitness::Vector{Float64}, tournament_size::Int64, rng::AbstractRNG
)
    popsize = length(fitness)
    tournament = randchoice(rng, popsize, tournament_size)
    bestindex = argmin(fitness[tournament])
    return tournament[bestindex]
end

function uniform_crossover(
    parent1::AbstractVector{Float64},
    parent2::AbstractVector{Float64},
    crossover_rate::Float64,
    rng::AbstractRNG,
)
    dimension = length(parent1)
    offspring = similar(parent1)

    for d in 1:dimension
        offspring[d] = rand(rng) < crossover_rate ? parent1[d] : parent2[d]
    end

    return offspring
end

function uniform_mutation!(
    individual::AbstractVector{Float64},
    problem::Problem,
    mutation_rate::Float64,
    rng::AbstractRNG,
)
    for d in 1:problem.dimension
        if rand(rng) < mutation_rate
            individual[d] =
                problem.lowerbound + rand(rng) * (problem.upperbound - problem.lowerbound)
        end
    end
end

"""
    ga(feval, problem, criterion; popsize=50, tournament_size=5, crossover_rate=0.7, mutation_rate=0.05, seed=nothing, kwargs...)

Steady-state Genetic Algorithm with tournament selection, uniform crossover, and
per-gene mutation. Populations are clamped to the `Problem` bounds each generation.
"""
function ga(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=50,
    tournament_size::Int64=5,
    crossover_rate::Float64=0.7,
    mutation_rate::Float64=0.05,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if popsize < 2
        throw(DomainError("popsize < 2"))
    end

    if tournament_size < 1 || tournament_size > popsize
        throw(DomainError("tournament_size must be in [1, popsize]"))
    end

    if crossover_rate < 0.0 || crossover_rate > 1.0
        throw(DomainError("crossover_rate must be in [0.0, 1.0]"))
    end

    if mutation_rate < 0.0 || mutation_rate > 1.0
        throw(DomainError("mutation_rate must be in [0.0, 1.0]"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    pop = initpopulation(popsize, problem, rng)
    fitness = zeros(popsize)
    bestfitness = Inf

    for (i, individual) in enumerate(eachrow(pop))
        fitness[i] = feval(individual; problem=problem, kwargs...)
        if fitness[i] < bestfitness
            bestfitness = fitness[i]
        end
        evals += 1

        if terminate(stoppingcriterion, evals, iters, bestfitness)
            return bestfitness
        end
    end

    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        for i in 1:popsize
            parent1_idx = tournament_selection(fitness, tournament_size, rng)
            parent2_idx = tournament_selection(fitness, tournament_size, rng)

            x = uniform_crossover(
                pop[parent1_idx, :], pop[parent2_idx, :], crossover_rate, rng
            )

            uniform_mutation!(x, problem, mutation_rate, rng)

            clamp!(x, problem.lowerbound, problem.upperbound)

            fx = feval(x; problem=problem, kwargs...)

            if fx < bestfitness
                bestfitness = fx
            end

            evals += 1

            pop[i, :] = x
            fitness[i] = fx

            if terminate(stoppingcriterion, evals, iters, bestfitness)
                return bestfitness
            end
        end

        iters += 1
    end

    return bestfitness
end
