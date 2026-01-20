"""
    Dataset(df_or_path)

Wrap a tabular dataset and derive feature metadata used by optimizers. Accepts either a
`DataFrame` or path to a CSV file. Features are inferred from column types and overall
problem dimensionality is computed for use with optimization algorithms.
"""
struct Dataset
    transactions::DataFrame
    features::Vector{AbstractFeature}
    dimension::Int64

    function Dataset(df::DataFrame)
        features = getfeatures(df)
        dim = problemdim(features)
        return new(df, features, dim)
    end

    function Dataset(path::String)
        df = DataFrame(CSV.File(path; header=1, delim=","))
        return Dataset(df)
    end
end

function getfeatures(df::DataFrame)
    features = AbstractFeature[]
    for name in names(df)
        curr_feature = df[:, name]
        if eltype(curr_feature) <: Real
            min = minimum(curr_feature)
            max = maximum(curr_feature)
            push!(features, NumericalFeature(name, min, max))
        else
            categories = unique(string.(curr_feature))
            push!(features, CategoricalFeature(name, categories))
        end
    end
    return features
end

function problemdim(features::Vector{AbstractFeature})
    dimension = length(features) + 1
    for feature in features
        dimension += 2 + Int(isnumerical(feature))
    end
    return dimension
end
