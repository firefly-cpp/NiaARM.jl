"""
    sa(feval, problem, criterion; initial_temp=100.0, min_temp=1e-12, cooling_rate=0.95, step_size=0.1, seed=nothing, kwargs...)

Simulated Annealing with Gaussian perturbations. Accepts worse solutions according to
the current temperature to escape local minima and cools multiplicatively.
"""
function sa(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    initial_temp::Float64=100.0,
    min_temp=1e-12,
    cooling_rate::Float64=0.95,
    step_size::Float64=0.1,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if initial_temp <= 0.0
        throw(DomainError("initial_temp <= 0.0"))
    end

    if cooling_rate <= 0.0 || cooling_rate >= 1.0
        throw(DomainError("cooling_rate must be in (0, 1)"))
    end

    if step_size <= 0.0
        throw(DomainError("step_size <= 0.0"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    current =
        problem.lowerinit .+
        rand!(rng, zeros(problem.dimension)) .* (problem.upperinit - problem.lowerinit)
    current_fitness = feval(current; problem=problem, kwargs...)

    best = copy(current)
    bestfitness = current_fitness

    evals += 1

    if terminate(stoppingcriterion, evals, iters, bestfitness)
        return bestfitness
    end

    temperature = initial_temp

    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        neighbor = current .+ step_size .* randn!(rng, similar(current))
        neighbor = clamp!(neighbor, problem.lowerbound, problem.upperbound)

        neighbor_fitness = feval(neighbor; problem=problem, kwargs...)
        evals += 1

        delta = neighbor_fitness - current_fitness

        if delta < 0.0 || rand(rng) < exp(-delta / temperature)
            current = neighbor
            current_fitness = neighbor_fitness

            if current_fitness < bestfitness
                best = copy(current)
                bestfitness = current_fitness
            end
        end

        temperature *= cooling_rate
        iters += 1
    end

    return bestfitness
end
