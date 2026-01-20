@testset "Fitness Tests" begin
    wiki = Dataset("test_data/wiki.csv")
    rules = Rule[]
    problem = Problem(wiki.dimension, 0.0, 1.0)
    solution = [
        0.45328107,
        0.20655004,
        0.2060223,
        0.19727931,
        0.10291945,
        0.18117294,
        0.50567635,
        0.33333333,
    ]
    metrics = [:support, :confidence]
    fitness = narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules,
        metrics=metrics,
    )

    @test length(rules) == 1
    @test rules[1].fitness == 33 / 56
    @test rules[1].fitness == -fitness
    @test_throws DimensionMismatch narm(
        [1.0, 2.0, 3.0],
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules,
        metrics=metrics,
    )
end

@testset "Custom Metrics Tests" begin
    wiki = Dataset("test_data/wiki.csv")
    problem = Problem(wiki.dimension, 0.0, 1.0)
    solution = [
        0.45328107,
        0.20655004,
        0.2060223,
        0.19727931,
        0.10291945,
        0.18117294,
        0.50567635,
        0.33333333,
    ]

    # Test with support only using Vector{Symbol}
    rules_support = Rule[]
    metrics_support = [:support]
    fitness = narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules_support,
        metrics=metrics_support,
    )

    @test length(rules_support) == 1
    @test rules_support[1].fitness ≈ support(rules_support[1])

    # Test with confidence only using Vector{String}
    rules_conf = Rule[]
    metrics_conf = ["confidence"]
    fitness = narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules_conf,
        metrics=metrics_conf,
    )

    @test length(rules_conf) == 1
    @test rules_conf[1].fitness ≈ confidence(rules_conf[1])

    # Test with weighted combination using Dict
    rules_weighted = Rule[]
    metrics_weighted = Dict(:support => 2.0, :confidence => 1.0)
    fitness = narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules_weighted,
        metrics=metrics_weighted,
    )

    @test length(rules_weighted) == 1
    expected_fitness =
        (2.0 * support(rules_weighted[1]) + 1.0 * confidence(rules_weighted[1])) / 3.0
    @test rules_weighted[1].fitness ≈ expected_fitness

    # Test with multiple metrics using Vector{Symbol}
    rules_multi = Rule[]
    metrics_multi = [:support, :confidence, :coverage]
    fitness = narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules_multi,
        metrics=metrics_multi,
    )

    @test length(rules_multi) == 1
    expected_fitness =
        (support(rules_multi[1]) + confidence(rules_multi[1]) + coverage(rules_multi[1])) /
        3.0
    @test rules_multi[1].fitness ≈ expected_fitness

    # Test with all supported metrics
    rules_all = Rule[]
    metrics_all = [
        :support,
        :confidence,
        :coverage,
        :interestingness,
        :comprehensibility,
        :amplitude,
        :inclusion,
        :rhs_support,
    ]
    fitness = narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules_all,
        metrics=metrics_all,
    )

    @test length(rules_all) == 1
    @test rules_all[1].fitness > 0.0

    # Test error on invalid metric
    rules_error = Rule[]
    metrics_error = [:invalid_metric]
    @test_throws ArgumentError narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules_error,
        metrics=metrics_error,
    )

    # Test error on zero total weight
    rules_zero = Rule[]
    metrics_zero = Dict(:support => 0.0)
    @test_throws ArgumentError narm(
        solution,
        problem=problem,
        transactions=wiki.transactions,
        features=wiki.features,
        rules=rules_zero,
        metrics=metrics_zero,
    )
end
