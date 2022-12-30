module NumAssociationRules
using DataFrames
using Random
using CSV
using CategoricalArrays

export Attribute, Feature, Rule, ContingencyTable, countall, countlhs, countrhs, countnull, support, confidence, dataset, mine,
        narm, Problem, StoppingCriterion, terminate, initpopulation, randomsearch, pso, de

include("optimization/problem.jl")
include("optimization/stoppingcriterion.jl")
include("optimization/population.jl")
include("optimization/randomsearch.jl")
include("optimization/pso.jl")
include("optimization/de.jl")
include("feature.jl")
include("attribute.jl")
include("rule.jl")
include("metrics.jl")
include("dataset.jl")
include("narm.jl")
include("mine.jl")

end
