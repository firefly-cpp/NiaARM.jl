"""
    mine(dataset, algorithm, criterion; metrics, kwargs...)

Run numerical association rule mining on a dataset using the provided optimization
`algorithm` and `StoppingCriterion`. Returns a list of discovered `Rule`s sorted by
fitness. `metrics` may be a `Dict` of weights or a list of metric names.
"""
function mine(
    dataset::Dataset,
    algorithm::Function,
    stoppingcriterion::StoppingCriterion;
    metrics::Union{Dict{Symbol,Float64},Vector{Symbol},Vector{String}},
    kwargs...,
)
    problem = Problem(dataset.dimension, 0.0, 1.0)
    rules = Rule[]
    algorithm(
        narm,
        problem,
        stoppingcriterion;
        features=dataset.features,
        transactions=dataset.transactions,
        rules=rules,
        metrics=metrics,
        kwargs...,
    )
    sort!(rules; by=rule -> rule.fitness, rev=true)
    return rules
end

function mine(
    path_or_df::Union{String,DataFrame},
    algorithm::Function,
    stoppingcriterion::StoppingCriterion;
    kwargs...,
)
    mine(Dataset(path_or_df), algorithm, stoppingcriterion; kwargs...)
end
