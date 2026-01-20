@testset "Mining Tests" begin
    transactions = CSV.read("test_data/sporty.csv", DataFrame)
    criterion = StoppingCriterion(maxevals=100)
    metrics = [:support, :confidence]
    rules_rs = mine(transactions, randomsearch, criterion, metrics=metrics, seed=1234)
    rules_de = mine(transactions, de, criterion, metrics=metrics, seed=1234)
    rules_pso = mine(transactions, pso, criterion, metrics=metrics, seed=1234)
    rules_wiki = mine("test_data/wiki.csv", de, criterion, metrics=metrics, seed=1234)

    @test length(rules_rs) > 0
    @test issorted(rules_rs, by=x -> x.fitness, rev=true)
    @test length(rules_de) > 0
    @test issorted(rules_de, by=x -> x.fitness, rev=true)
    @test length(rules_pso) > 0
    @test issorted(rules_pso, by=x -> x.fitness, rev=true)
    @test length(rules_wiki) > 0
    @test issorted(rules_wiki, by=x -> x.fitness, rev=true)
end

@testset "Mining with Custom Metrics" begin
    transactions = CSV.read("test_data/sporty.csv", DataFrame)
    criterion = StoppingCriterion(maxevals=100)

    metrics_support = [:support]
    rules_support = mine(transactions, de, criterion, metrics=metrics_support, seed=1234)
    @test length(rules_support) > 0
    @test issorted(rules_support, by=x -> x.fitness, rev=true)

    metrics_confidence = ["confidence"]
    rules_confidence = mine(
        transactions, de, criterion, metrics=metrics_confidence, seed=1234
    )
    @test length(rules_confidence) > 0
    @test issorted(rules_confidence, by=x -> x.fitness, rev=true)

    metrics_weighted = Dict(:support => 2.0, :confidence => 1.0, :coverage => 1.0)
    rules_weighted = mine(transactions, de, criterion, metrics=metrics_weighted, seed=1234)
    @test length(rules_weighted) > 0
    @test issorted(rules_weighted, by=x -> x.fitness, rev=true)

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
    rules_all = mine(transactions, de, criterion, metrics=metrics_all, seed=1234)
    @test length(rules_all) > 0
    @test issorted(rules_all, by=x -> x.fitness, rev=true)

    @test rules_support[1].fitness != rules_confidence[1].fitness ||
        rules_support[1] == rules_confidence[1]
end
