using NiaARM
using DataFrames
using CSV
using Random
using Test

@testset verbose = true "NiaARM.jl Tests" begin
    include("test_aqua.jl")
    include("test_attribute.jl")
    include("test_feature.jl")
    include("test_dataset.jl")
    include("test_rule.jl")
    include("test_metrics.jl")
    include("test_narm.jl")
    include("test_problem.jl")
    include("test_stoppingcriterion.jl")
    include("test_population.jl")
    include("test_randomsearch.jl")
    include("test_de.jl")
    include("test_pso.jl")
    include("test_ba.jl")
    include("test_sa.jl")
    include("test_ga.jl")
    include("test_lshade.jl")
    include("test_es.jl")
    include("test_abc.jl")
    include("test_cs.jl")
    include("test_fa.jl")
    include("test_fpa.jl")
    include("test_mine.jl")
end
