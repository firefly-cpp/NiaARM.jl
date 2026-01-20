import Base: show, ==

"""
    AbstractFeature

Abstract supertype describing dataset columns used to build candidate rules.
"""
abstract type AbstractFeature end

"""
    NumericalFeature(name, min, max)

Metadata describing a numerical column along with its observed minimum and maximum.
Bounds are used to scale optimizer solutions back into meaningful ranges.
"""
struct NumericalFeature{T<:Real} <: AbstractFeature
    name::String
    min::T
    max::T

    function NumericalFeature{T}(name::String, min::T, max::T) where {T<:Real}
        return min > max ? throw(ArgumentError("min > max")) : new(name, min, max)
    end

    function NumericalFeature(name::String, min::T, max::T) where {T<:Real}
        return NumericalFeature{T}(name, min, max)
    end
end

dtype(feature::NumericalFeature) = first(typeof(feature).parameters)

function show(io::IO, feature::NumericalFeature)
    print(io, "$(feature.name)(min = $((feature.min)), max = $((feature.max)))")
end

function ==(lhs::NumericalFeature, rhs::NumericalFeature)
    return lhs.name == rhs.name &&
           isapprox(lhs.min, rhs.min; atol=1e-6, rtol=1e-6) &&
           isapprox(lhs.max, rhs.max; atol=1e-6, rtol=1e-6)
end

"""
    CategoricalFeature(name, categories)

Metadata describing a categorical column and its possible category values.
"""
struct CategoricalFeature <: AbstractFeature
    name::String
    categories::Vector{String}
end

dtype(::CategoricalFeature) = String

function show(io::IO, feature::CategoricalFeature)
    print(io, "$(feature.name)(categories = $((feature.categories)))")
end

function ==(lhs::CategoricalFeature, rhs::CategoricalFeature)
    return lhs.name == rhs.name && lhs.categories == rhs.categories
end

"""
    isnumerical(feature)

Return `true` when a feature is numerical.
"""
isnumerical(feature::AbstractFeature) = isa(feature, NumericalFeature)

"""
    iscategorical(feature)

Return `true` when a feature is categorical.
"""
iscategorical(feature::AbstractFeature) = isa(feature, CategoricalFeature)
