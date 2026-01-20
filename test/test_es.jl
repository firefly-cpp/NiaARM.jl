@testset "Evolution Strategy Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = es(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = es(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = es(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    f4 = es(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    f5 = es(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)

    @test_throws DomainError es(sphere, problem, StoppingCriterion(maxiters=1000), mu=-1)
    @test_throws DomainError es(
        sphere, problem, StoppingCriterion(maxiters=1000), mu=20, lambda=10
    )

    @test f3 <= 1e-5
    @test f1 == es(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == es(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == es(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    @test f4 == es(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    @test f5 == es(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)
end
