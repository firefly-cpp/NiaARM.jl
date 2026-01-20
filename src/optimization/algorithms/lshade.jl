"""
    lshade(feval, problem, criterion; popsize=18, memorysize=6, pbestrate=0.11, archiverate=2.6, seed=nothing, kwargs...)

L-SHADE with current-to-pbest/1/bin mutation, success-history based parameter
adaptation, an external archive, and linear population size reduction. Requires
`StoppingCriterion.maxevals` to be set for the reduction schedule.
"""
function lshade(
    feval::Function,
    problem::Problem,
    stoppingcriterion::StoppingCriterion;
    popsize::Int64=18,
    memorysize::Int64=6,
    pbestrate::Float64=0.11,
    archiverate::Float64=2.6,
    seed::Union{Int64,Nothing}=nothing,
    kwargs...,
)
    if stoppingcriterion.maxevals == typemax(Int64)
        throw(
            DomainError(
                stoppingcriterion.maxevals, "StoppingCriterion::maxevals must be set"
            ),
        )
    end

    if popsize < 4
        throw(DomainError(popsize, "popsize < 4"))
    end

    if memorysize < 1
        throw(DomainError(memorysize, "memorysize < 1"))
    end

    if pbestrate <= 0.0 || pbestrate > 1.0
        throw(DomainError(pbestrate, "pbestrate must be in [0.0, 1.0]"))
    end

    if archiverate < 1.0
        throw(DomainError(archiverate, "archiverate < 1.0"))
    end

    evals = 0
    iters = 0
    rng = Xoshiro(seed)

    popsizeinit = popsize
    population = initpopulation(popsize, problem, rng)
    fitness = Vector{Float64}(undef, popsize)
    bestfitness = Inf

    children = similar(population)
    childrenfitness = similar(fitness)

    archivesize = round(Int, archiverate * popsize)
    archive = Matrix{Float64}(undef, archivesize, problem.dimension)
    archivecount = 0

    memory_cr = fill(0.5, memorysize)
    memory_sf = fill(0.5, memorysize)
    memorypos = 1

    pop_sf = zeros(popsize)
    pop_cr = zeros(popsize)

    success_sf = Float64[]
    success_cr = Float64[]
    diff_fit = Float64[]

    sizehint!(success_sf, popsize)
    sizehint!(success_cr, popsize)
    sizehint!(diff_fit, popsize)

    pnum = max(2, round(Int, popsize * pbestrate))

    for (i, individual) in enumerate(eachrow(population))
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
        sortedindices = partialsortperm(fitness, 1:pnum)
        for i in 1:popsize
            random_selected_period = rand(rng, 1:memorysize)
            mu_sf = memory_sf[random_selected_period]
            mu_cr = memory_cr[random_selected_period]

            if mu_cr == -1
                pop_cr[i] = 0
            else
                pop_cr[i] = clamp(mu_cr + 0.1 * randn(rng), 0.0, 1.0)
            end

            sfi = randcauchy(rng, mu_sf, 0.1)
            while sfi <= 0
                sfi = randcauchy(rng, mu_sf, 0.1)
            end
            pop_sf[i] = clamp(sfi, 0.0, 1.0)

            # current_to_pbest_1_bin
            pbestindividual = sortedindices[rand(rng, 1:pnum)]
            cr = pop_cr[i]
            sf = pop_sf[i]
            r1 = rand(rng, 1:popsize)
            while r1 == i
                r1 = rand(rng, 1:popsize)
            end

            r2 = rand(rng, 1:(popsize + archivecount))
            while r2 == i || r2 == r1
                r2 = rand(rng, 1:(popsize + archivecount))
            end

            rdim = rand(rng, 1:problem.dimension)
            if r2 > popsize
                r2 -= popsize
                for d in 1:problem.dimension
                    if rand(rng) < cr || d == rdim
                        children[i, d] =
                            population[i, d] +
                            sf * (population[pbestindividual, d] - population[i, d]) +
                            sf * (population[r1, d] - archive[r2, d])
                    else
                        children[i, d] = population[i, d]
                    end
                end
            else
                for d in 1:problem.dimension
                    if rand(rng) < cr || d == rdim
                        children[i, d] =
                            population[i, d] +
                            sf * (population[pbestindividual, d] - population[i, d]) +
                            sf * (population[r1, d] - population[r2, d])
                    else
                        children[i, d] = population[i, d]
                    end
                end
            end

            parentmedium!(view(children, i, :), view(population, i, :), problem)

            childrenfitness[i] = feval(view(children, i, :); problem=problem, kwargs...)
            evals += 1

            if childrenfitness[i] < bestfitness
                bestfitness = childrenfitness[i]
            end

            if terminate(stoppingcriterion, evals, iters, bestfitness)
                return bestfitness
            end
        end

        for i in 1:popsize
            if childrenfitness[i] == fitness[i]
                copyto!(view(population, i, :), view(children, i, :))
            elseif childrenfitness[i] < fitness[i]
                push!(diff_fit, abs(fitness[i] - childrenfitness[i]))
                push!(success_sf, pop_sf[i])
                push!(success_cr, pop_cr[i])

                if archivesize > 1
                    if archivecount < archivesize
                        archivecount += 1
                        copyto!(view(archive, archivecount, :), view(population, i, :))
                    else
                        archiveind = rand(rng, 1:archivesize)
                        copyto!(view(archive, archiveind, :), view(population, i, :))
                    end
                end

                fitness[i] = childrenfitness[i]
                copyto!(view(population, i, :), view(children, i, :))
            end
        end

        successcount = length(success_sf)
        if successcount > 0
            sumdiff = sum(diff_fit)
            sumsf = 0.0
            sumcr = 0.0
            sumsf_sq = 0.0
            sumcr_sq = 0.0
            for i in 1:successcount
                w = diff_fit[i] / sumdiff
                sumsf += w * success_sf[i]
                sumcr += w * success_cr[i]
                sumsf_sq += w * success_sf[i] * success_sf[i]
                sumcr_sq += w * success_cr[i] * success_cr[i]
            end

            memory_sf[memorypos] = sumsf_sq / sumsf

            if sumcr == 0 || memory_cr[memorypos] == -1
                memory_cr[memorypos] = -1
            else
                memory_cr[memorypos] = sumcr_sq / sumcr
            end

            memorypos += 1
            if memorypos > memorysize
                memorypos = 1
            end

            empty!(diff_fit)
            empty!(success_sf)
            empty!(success_cr)
        end

        newpopsize = round(
            Int, ((4 - popsizeinit) / stoppingcriterion.maxevals) * evals + popsizeinit
        )
        if popsize > newpopsize
            reduction_num = popsize - newpopsize
            if popsize - reduction_num < 4
                reduction_num = popsize - 4
            end

            worstindices = partialsortperm(fitness, 1:reduction_num; rev=true)
            keep = trues(popsize)
            keep[worstindices] .= false

            population = population[keep, :]
            fitness = fitness[keep]
            popsize -= reduction_num

            archivesize = round(Int, popsize * archiverate)
            if archivecount > archivesize
                archivecount = archivesize
            end
            pnum = max(2, round(Int, popsize * pbestrate))
        end
        iters += 1
    end
    return bestfitness
end
