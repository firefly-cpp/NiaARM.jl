"""
    narm(solution; problem, features, transactions, rules, metrics)

Objective function used by optimization algorithms. Decodes `solution` into a rule,
evaluates it on `transactions` with the provided `metrics`, and inserts novel rules into
`rules`. Returns the negated fitness so minimizers can be used for maximization.
"""
function narm(
    solution::AbstractVector{Float64};
    problem::Problem,
    features::Vector{AbstractFeature},
    transactions::DataFrame,
    rules::Vector{Rule},
    metrics::Union{Dict{Symbol,Float64},Vector{Symbol},Vector{String}},
    kwargs...,
)
    if length(solution) != problem.dimension
        throw(DimensionMismatch("$(length(solution)) != $(problem.dimension)"))
    end

    fitness = -Inf
    # obtain cut point value and remove this value from a vector of solutions
    cut_value = last(solution)

    # calculate cut point
    cut = cut_point(cut_value, length(features))
    # build a rule from candidate solution
    rule = build_rule(solution[begin:(end - 1)], features)

    # get antecedent and consequent of rule
    antecedent = rule[begin:cut]
    consequent = rule[(cut + 1):end]

    antecedent = collect(skipmissing(antecedent))
    consequent = collect(skipmissing(consequent))

    if length(antecedent) > 0 && length(consequent) > 0
        ct = ContingencyTable(antecedent, consequent, transactions)
        supp = support(ct)
        conf = confidence(ct)
        # Create temporary rule for fitness calculation
        temp_rule = Rule(antecedent, consequent, -Inf, ct)
        fitness = calculate_fitness(temp_rule, metrics)
        newrule = Rule(antecedent, consequent, fitness, ct)

        if supp > 0.0 && conf > 0.0 && newrule ∉ rules
            push!(rules, newrule)
        end
    end

    return -fitness  # Maximization
end

function cut_point(var::Float64, numfeatures::Int64)
    cut = trunc(Int, (var * numfeatures))
    if cut == 0
        cut = 1
    end
    if cut > numfeatures - 1
        cut = numfeatures - 2
    end
    return cut
end

function calculate_fitness(
    rule::Rule, metrics::Union{Dict{Symbol,Float64},Vector{Symbol},Vector{String}}
)
    # Convert metrics to Dict format
    metrics_dict = normalize_metrics(metrics)

    # Calculate weighted sum of metrics
    total_weight = sum(values(metrics_dict))
    if total_weight == 0.0
        throw(ArgumentError("Total weight of metrics cannot be zero"))
    end

    fitness_sum = 0.0
    for (metric_name, weight) in metrics_dict
        metric_value = get_metric_value(rule, metric_name)
        fitness_sum += weight * metric_value
    end

    return fitness_sum / total_weight
end

function normalize_metrics(metrics::Dict{Symbol,Float64})
    # Already in correct format
    return metrics
end

function normalize_metrics(metrics::Vector{Symbol})
    # Convert vector of symbols to dict with weight 1.0
    return Dict(metric => 1.0 for metric in metrics)
end

function normalize_metrics(metrics::Vector{String})
    # Convert vector of strings to dict with weight 1.0
    return Dict(Symbol(metric) => 1.0 for metric in metrics)
end

function get_metric_value(rule::Rule, metric_name::Symbol)
    if metric_name == :support
        return support(rule)
    elseif metric_name == :confidence
        return confidence(rule)
    elseif metric_name == :coverage
        return coverage(rule)
    elseif metric_name == :interestingness
        return interestingness(rule)
    elseif metric_name == :comprehensibility
        return comprehensibility(rule)
    elseif metric_name == :amplitude
        return amplitude(rule)
    elseif metric_name == :inclusion
        return inclusion(rule)
    elseif metric_name == :rhs_support
        return rhs_support(rule)
    else
        throw(
            ArgumentError(
                "Unknown metric: $metric_name. Valid metrics are: support, confidence, coverage, interestingness, comprehensibility, amplitude, inclusion, rhs_support",
            ),
        )
    end
end

function build_rule(solution::Vector{Float64}, features::Vector{AbstractFeature})
    rule = Union{Missing,AbstractAttribute}[]

    # obtain permutation vector
    permutation = last(solution, length(features))
    permutation = sortperm(permutation)

    for i in permutation
        feature = features[i]

        # set current position in the vector
        vector_position = feature_position(features, i)

        threshold_position = vector_position + 1 + Int(isnumerical(feature))

        if solution[vector_position] > solution[threshold_position]
            if isnumerical(feature)
                min = solution[vector_position] * (feature.max - feature.min) + feature.min
                vector_position = vector_position + 1
                max = solution[vector_position] * (feature.max - feature.min) + feature.min
                min, max = minmax(min, max)
                feature_type = dtype(feature)
                if feature_type <: Integer
                    push!(
                        rule,
                        NumericalAttribute(
                            feature.name, round(feature_type, min), round(feature_type, max)
                        ),
                    )
                else
                    push!(rule, NumericalAttribute(feature.name, min, max))
                end
            else
                categories = feature.categories
                selected = trunc(Int, solution[vector_position] * (length(categories)))
                selected = selected == 0 ? 1 : selected
                push!(rule, CategoricalAttribute(feature.name, categories[selected]))
            end
        else
            push!(rule, missing)
        end
    end
    return rule
end

function feature_position(features::Vector{AbstractFeature}, index::Int64)
    position = 1
    for f in features[begin:(index - 1)]
        position += isnumerical(f) + 2
    end
    return position
end
