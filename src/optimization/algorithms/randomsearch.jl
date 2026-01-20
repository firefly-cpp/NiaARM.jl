"""
    randomsearch(feval, problem, criterion; seed=nothing, kwargs...)

Baseline optimizer that samples solutions uniformly within the problem bounds until the
`StoppingCriterion` is met. Useful as a reference or for quick smoke tests.
"""
function randomsearch(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    bestfitness = Inf
    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        solution =
            problem.lowerinit .+
            rand!(rng, zeros(problem.dimension)) .* (problem.upperinit - problem.lowerinit)
        fitness = feval(solution; problem=problem, kwargs...)

        if fitness < bestfitness
            bestfitness = fitness
        end

        evals += 1
        iters += 1
    end
    return bestfitness
end
