"""
    pso(feval, problem, criterion; popsize=10, omega=0.7, c1=2.0, c2=2.0, seed=nothing, kwargs...)

Particle Swarm Optimization with inertia weight. Maintains a swarm of candidate rules,
updating velocities toward personal and global best positions while respecting problem
bounds.
"""
function pso(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=10,
    omega::Float64=0.7,
    c1::Float64=2.0,
    c2::Float64=2.0,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    range = problem.upperbound - problem.lowerbound
    lowervelocity = -range
    uppervelocity = range
    pop = initpopulation(popsize, problem, rng)
    pbest = copy(pop)
    velocity = -lowervelocity .+ rand!(rng, similar(pop)) .* (uppervelocity - lowervelocity)

    fitness = zeros(popsize)
    bestfitness = Inf
    bestindex = 1
    for (i, individual) in enumerate(eachrow(pop))
        f = feval(individual; problem=problem, kwargs...)
        fitness[i] = f
        if f < bestfitness
            bestfitness = f
        end
        evals += 1

        if terminate(stoppingcriterion, evals, iters, bestfitness)
            return bestfitness
        end
    end

    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        for i in 1:popsize
            for d in 1:problem.dimension
                velocity[i, d] =
                    omega * velocity[i, d] +
                    c1 * rand(rng) * (pbest[i, d] - pop[i, d]) +
                    c2 * rand(rng) * (pop[bestindex, d] - pop[i, d])
                velocity[i, d] = clamp(velocity[i, d], lowervelocity, uppervelocity)
            end

            pop[i, :] = pop[i, :] .+ velocity[i, :]
            pop[i, :] = clamp!(pop[i, :], problem.lowerbound, problem.upperbound)

            newfitness = feval(pop[i, :]; problem=problem, kwargs...)

            if newfitness < fitness[i]
                fitness[i] = newfitness
                pbest[i, :] = pop[i, :]

                if newfitness < bestfitness
                    bestindex = i
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
