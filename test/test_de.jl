@testset "Differential Evolution Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = de(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = de(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = de(sphere, problem, StoppingCriterion(acceptable_fitness=0.0), seed=1234)
    f4 = de(sphere, problem, StoppingCriterion(maxevals=10), seed=1234)
    f5 = de(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)

    @test_throws DomainError de(
        sphere, problem, StoppingCriterion(maxiters=1000), popsize=2
    )
    @test f3 <= 0.0
    @test f1 == de(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == de(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == de(sphere, problem, StoppingCriterion(acceptable_fitness=0.0), seed=1234)
    @test f2 == de(sphere, problem, StoppingCriterion(maxevals=25050), seed=1234)
    @test f4 == de(sphere, problem, StoppingCriterion(maxevals=10), seed=1234)
    @test f5 == de(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)
end
