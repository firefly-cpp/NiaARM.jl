import Base: show, ==

"""
    ContingencyTable(antecedent, consequent, transactions)

Sufficient statistics for evaluating a candidate rule against a dataset. Counts cover
the four quadrants of a 2x2 contingency table and store amplitude/inclusion metadata
computed during rule construction.
"""
struct ContingencyTable
    countall::Int64
    countlhs::Int64
    countrhs::Int64
    countnull::Int64

    amplitude::Float64
    inclusion::Float64

    ContingencyTable() = new(0, 0, 0, 0, 0.0, 0.0)

    function ContingencyTable(
        countall::Int64,
        countlhs::Int64,
        countrhs::Int64,
        countnull::Int64,
        amplitude::Float64,
        inclusion::Float64,
    )
        return new(countall, countlhs, countrhs, countnull, amplitude, inclusion)
    end

    function ContingencyTable(
        antecedent::Vector{<:AbstractAttribute},
        consequent::Vector{<:AbstractAttribute},
        transactions::DataFrame,
    )
        num_transactions = nrow(transactions)
        contains_antecedent = trues(num_transactions)
        contains_consequent = trues(num_transactions)

        featuresmin = combine(
            transactions, names(transactions, Real) .=> minimum; renamecols=false
        )
        featuresmax = combine(
            transactions, names(transactions, Real) .=> maximum; renamecols=false
        )

        acc = 0
        for attribute in antecedent
            if isnumerical(attribute)
                featuremin = featuresmin[1, attribute.name]
                featuremax = featuresmax[1, attribute.name]
                if featuremax == featuremin
                    acc += 1
                else
                    acc += (attribute.max - attribute.min) / (featuremax - featuremin)
                end
                contains_antecedent .&= transactions[:, attribute.name] .>= attribute.min
                contains_antecedent .&= transactions[:, attribute.name] .<= attribute.max
            else
                contains_antecedent .&=
                    transactions[:, attribute.name] .== attribute.category
            end
        end

        for attribute in consequent
            if isnumerical(attribute)
                featuremin = featuresmin[1, attribute.name]
                featuremax = featuresmax[1, attribute.name]
                if featuremax == featuremin
                    acc += 1
                else
                    acc += (attribute.max - attribute.min) / (featuremax - featuremin)
                end
                contains_consequent .&= transactions[:, attribute.name] .>= attribute.min
                contains_consequent .&= transactions[:, attribute.name] .<= attribute.max
            else
                contains_consequent .&=
                    transactions[:, attribute.name] .== attribute.category
            end
        end

        countall = sum(contains_antecedent .& contains_consequent)
        countlhs = sum(contains_antecedent .& .!contains_consequent)
        countrhs = sum(.!contains_antecedent .& contains_consequent)
        countnull = sum(.!contains_antecedent .& .!contains_consequent)

        amplitude = 1 - (1 / (length(antecedent) + length(consequent))) * acc
        inclusion = (length(antecedent) + length(consequent)) / ncol(transactions)

        return new(countall, countlhs, countrhs, countnull, amplitude, inclusion)
    end
end

"""
    Rule(antecedent, consequent[, fitness, ct])

Represents a mined association rule with its antecedent and consequent attribute
constraints, the current fitness value, and a cached `ContingencyTable`.
"""
struct Rule
    antecedent::Vector{AbstractAttribute}
    consequent::Vector{AbstractAttribute}
    fitness::Float64
    ct::ContingencyTable

    function Rule(
        antecedent::Vector{<:AbstractAttribute},
        consequent::Vector{<:AbstractAttribute},
        fitness::Float64,
        ct::ContingencyTable,
    )
        return new(antecedent, consequent, fitness, ct)
    end

    function Rule(
        antecedent::Vector{<:AbstractAttribute}, consequent::Vector{<:AbstractAttribute}
    )
        return new(antecedent, consequent, -Inf, ContingencyTable())
    end

    function Rule(
        antecedent::Vector{<:AbstractAttribute},
        consequent::Vector{<:AbstractAttribute},
        transactions::DataFrame,
    )
        return new(
            antecedent,
            consequent,
            -Inf,
            ContingencyTable(antecedent, consequent, transactions),
        )
    end

    function Rule(rule::Rule, transactions::DataFrame)
        return new(
            rule.antecedent,
            rule.consequent,
            rule.fitness,
            ContingencyTable(rule.antecedent, rule.consequent, transactions),
        )
    end
end

"""
    countall(ct::ContingencyTable)
    countall(rule::Rule)

Number of transactions satisfying both antecedent and consequent.
"""
countall(ct::ContingencyTable) = ct.countall

countall(r::Rule) = countall(r.ct)

"""
    countlhs(ct::ContingencyTable)
    countlhs(rule::Rule)

Number of transactions satisfying the antecedent only.
"""
countlhs(ct::ContingencyTable) = ct.countlhs

countlhs(r::Rule) = countlhs(r.ct)

"""
    countrhs(ct::ContingencyTable)
    countrhs(rule::Rule)

Number of transactions satisfying the consequent only.
"""
countrhs(ct::ContingencyTable) = ct.countrhs

countrhs(r::Rule) = countrhs(r.ct)

"""
    countnull(ct::ContingencyTable)
    countnull(rule::Rule)

Number of transactions satisfying neither antecedent nor consequent.
"""
countnull(ct::ContingencyTable) = ct.countnull

countnull(r::Rule) = countnull(r.ct)

function show(io::IO, rule::Rule)
    print(io, "[$(join(rule.antecedent, ", "))] => [$(join(rule.consequent, ", "))]")
end

function ==(lhs::Rule, rhs::Rule)
    return lhs.antecedent == rhs.antecedent && lhs.consequent == rhs.consequent
end
