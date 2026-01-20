@testset "ABC Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = abc(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = abc(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = abc(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    f4 = abc(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    f5 = abc(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)

    @test_throws DomainError abc(
        sphere, problem, StoppingCriterion(maxiters=1000), popsize=0
    )
    @test_throws DomainError abc(sphere, problem, StoppingCriterion(maxiters=1000), limit=0)

    @test f3 <= 1e-5
    @test f1 == abc(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == abc(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == abc(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    @test f4 == abc(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    @test f5 == abc(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)
end
