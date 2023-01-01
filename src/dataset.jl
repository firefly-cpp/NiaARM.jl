struct Dataset
    transactions::DataFrame
    features::Vector{Feature}
    dimension::Int64

    function Dataset(df::DataFrame)
        features = getfeatures(df)
        dim = problemdim(features)
        new(df, features, dim)
    end

    function Dataset(path::String)
        df = DataFrame(CSV.File(path, header=1, delim=","))
        return Dataset(df)
    end
end

function getfeatures(df::DataFrame)
    features = Feature[]
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

function problemdim(features::Vector{Feature})
    dimension = length(features) + 1
    for feature in features
        dimension += 2 + Int(isnumerical(feature))
    end
    return dimension
end
