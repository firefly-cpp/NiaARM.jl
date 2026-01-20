@testset "Stopping Criterion Tests" begin
    criterion = StoppingCriterion(maxiters=100, acceptable_fitness=0.0)
    evals = 0
    iters = 0
    bestfitness = Inf

    while !terminate(criterion, evals, iters, bestfitness)
        iters += 1
    end

    @test_throws ArgumentError StoppingCriterion()
    @test_throws DomainError StoppingCriterion(maxiters=-1)
    @test terminate(criterion, typemax(Int), 0, 1.0)
    @test terminate(criterion, 0, typemax(Int), 0.5)
    @test terminate(criterion, 0, 0, 0.0)
    @test !terminate(criterion, 0, 0, Inf)
    @test iters == 100
end
