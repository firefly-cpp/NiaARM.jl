@testset "Metrics Tests" begin
    transactions = CSV.read("test_data/wiki.csv", DataFrame)
    rule1 = Rule(
        [CategoricalAttribute("Feat1", "A")],
        [NumericalAttribute("Feat2", 0, 0)],
        transactions,
    )
    rule2 = Rule(
        [CategoricalAttribute("Feat1", "B")],
        [NumericalAttribute("Feat2", 1, 1)],
        transactions,
    )

    # support
    @test support(rule1) == 3 / 7
    @test support(rule2) == 2 / 7

    # confidence
    @test confidence(rule1) == 3 / 4
    @test confidence(rule2) == 2 / 3

    # rhs Support
    @test rhs_support(rule1) == 4 / 7
    @test rhs_support(rule2) == 3 / 7

    # coverage
    @test coverage(rule1) == 4 / 7
    @test coverage(rule2) == 3 / 7

    # lift
    @test lift(rule1) == 21 / 16
    @test lift(rule2) == 14 / 9

    # conviction
    @test isapprox(conviction(rule1), 4 * 3 / 7)
    @test isapprox(conviction(rule2), 3 * 4 / 7)

    # interestingness
    @test interestingness(rule1) == (3 / 4) * (3 / 4) * (46 / 49)
    @test interestingness(rule2) == (2 / 3) * (2 / 3) * (47 / 49)

    # yulesq
    @test isapprox(yulesq(rule1), (6 - 1) / (6 + 1))
    @test isapprox(yulesq(rule2), (6 - 1) / (6 + 1))

    # netconf
    @test isapprox(netconf(rule1), ((3 / 7) - (16 / 49)) / (12 / 49))
    @test isapprox(netconf(rule2), ((2 / 7) - (9 / 49)) / (12 / 49))

    # zhang
    @test isapprox(zhang(rule1), 5 / 9)
    @test isapprox(zhang(rule2), 5 / 8)

    # leverage
    @test isapprox(leverage(rule1), 0.102040816326)
    @test isapprox(leverage(rule2), 0.102040816326)

    # amplitude
    @test amplitude(rule1) == 1
    @test amplitude(rule2) == 1

    # inclusion
    @test inclusion(rule1) == 1
    @test inclusion(rule2) == 1

    # comprehensibility
    @test isapprox(comprehensibility(rule1), 0.630929753571)
    @test isapprox(comprehensibility(rule2), 0.630929753571)
end
