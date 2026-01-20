module NiaARM

using CategoricalArrays
using CSV
using DataFrames
using Random
using SpecialFunctions

export AbstractAttribute
export NumericalAttribute
export CategoricalAttribute
export AbstractFeature
export NumericalFeature
export CategoricalFeature
export isnumerical
export iscategorical
export dtype
export Rule
export ContingencyTable
export countall
export countlhs
export countrhs
export countnull
export support
export confidence
export rhs_support
export coverage
export lift
export conviction
export interestingness
export yulesq
export netconf
export zhang
export leverage
export amplitude
export inclusion
export comprehensibility
export Dataset
export mine
export narm
export Problem
export StoppingCriterion
export terminate
export initpopulation
export randomsearch
export pso
export de
export ba
export sa
export ga
export lshade
export es
export abc
export cs
export fa
export fpa

include("optimization/problem.jl")
include("optimization/stoppingcriterion.jl")
include("optimization/utils.jl")
include("optimization/algorithms/randomsearch.jl")
include("optimization/algorithms/pso.jl")
include("optimization/algorithms/de.jl")
include("optimization/algorithms/ba.jl")
include("optimization/algorithms/sa.jl")
include("optimization/algorithms/ga.jl")
include("optimization/algorithms/lshade.jl")
include("optimization/algorithms/es.jl")
include("optimization/algorithms/abc.jl")
include("optimization/algorithms/cs.jl")
include("optimization/algorithms/fa.jl")
include("optimization/algorithms/fpa.jl")
include("feature.jl")
include("attribute.jl")
include("rule.jl")
include("metrics.jl")
include("dataset.jl")
include("narm.jl")
include("mine.jl")

end
