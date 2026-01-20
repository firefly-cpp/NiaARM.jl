function calculatefitness(objval)
    return objval >= 0 ? 1.0 / (objval + 1) : 1.0 + abs(objval)
end

"""
    abc(feval, problem, criterion; popsize=20, limit=100, seed=nothing, kwargs...)

Artificial Bee Colony optimizer splitting workers and onlookers across a set of food
sources. Exploits neighbor differences to propose new points and periodically replaces
stagnant sources with scouts.
"""
function abc(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=20,
    limit::Int64=100,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if popsize < 2
        throw(DomainError("popsize < 2"))
    end

    if limit < 1
        throw(DomainError("limit < 1"))
    end

    n = problem.dimension
    lb = problem.lowerbound
    ub = problem.upperbound

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    foodnumber = div(popsize, 2)
    foods = initpopulation(foodnumber, problem, rng)
    objvals = zeros(foodnumber)
    fitness = zeros(foodnumber)

    trial = zeros(Int, foodnumber)

    # Temporary storage for new solutions
    sol = zeros(n)

    bestfitness = Inf
    for i in 1:foodnumber
        objval = feval(foods[i, :]; problem=problem, kwargs...)
        objvals[i] = objval
        fitness[i] = calculatefitness(objval)
        bestfitness = min(bestfitness, objval)

        evals += 1
        if terminate(stoppingcriterion, evals, iters, bestfitness)
            return bestfitness
        end
    end

    while !terminate(stoppingcriterion, evals, iters, bestfitness)
        # Worker bee phase
        for i in 1:foodnumber
            param2change = rand(rng, 1:n)

            neighbour = rand(rng, 1:foodnumber)
            while neighbour == i
                neighbour = rand(rng, 1:foodnumber)
            end

            sol = copy(foods[i, :])
            sol[param2change] =
                foods[i, param2change] +
                (foods[i, param2change] - foods[neighbour, param2change]) *
                (rand(rng) - 0.5) *
                2

            sol = clamp.(sol, lb, ub)

            objval = feval(sol; problem=problem, kwargs...)
            fitnessval = calculatefitness(objval)

            if fitnessval > fitness[i]
                foods[i, :] = sol
                fitness[i] = fitnessval
                objvals[i] = objval
                trial[i] = 0
            else
                trial[i] += 1
            end

            evals += 1
            if terminate(stoppingcriterion, evals, iters, bestfitness)
                return bestfitness
            end
        end

        prob = 0.9 .* fitness ./ maximum(fitness) .+ 0.1

        t = 0
        i = 1
        while t < foodnumber
            if rand(rng) < prob[i]
                t += 1

                param2change = rand(rng, 1:n)

                neighbour = rand(rng, 1:foodnumber)
                while neighbour == i
                    neighbour = rand(rng, 1:foodnumber)
                end

                sol = copy(foods[i, :])
                sol[param2change] =
                    foods[i, param2change] +
                    (foods[i, param2change] - foods[neighbour, param2change]) *
                    (rand(rng) - 0.5) *
                    2

                sol = clamp.(sol, lb, ub)

                objval = feval(sol; problem=problem, kwargs...)
                fitnessval = calculatefitness(objval)

                if fitnessval > fitness[i]
                    foods[i, :] = sol
                    fitness[i] = fitnessval
                    objvals[i] = objval
                    trial[i] = 0
                else
                    trial[i] += 1
                end

                evals += 1
                if terminate(stoppingcriterion, evals, iters, bestfitness)
                    return bestfitness
                end
            end

            i += 1
            if i == foodnumber + 1
                i = 1
            end
        end

        ind = argmin(objvals)
        if objvals[ind] < bestfitness
            bestfitness = objvals[ind]
        end

        # Scout bee phase
        ind = findlast(trial .== maximum(trial))
        if trial[ind] > limit
            trial[ind] = 0
            sol = (ub - lb) .* rand(rng, n) .+ lb
            objval = feval(sol; problem=problem, kwargs...)
            fitnessval = calculatefitness(objval)
            foods[ind, :] = sol
            fitness[ind] = fitnessval
            objvals[ind] = objval

            evals += 1
            if terminate(stoppingcriterion, evals, iters, bestfitness)
                return bestfitness
            end
        end

        iters += 1
    end

    return bestfitness
end
