@testset "Cuckoo Search Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = cs(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = cs(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = cs(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    f4 = cs(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    f5 = cs(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)

    @test_throws DomainError cs(
        sphere, problem, StoppingCriterion(maxiters=1000), popsize=0
    )
    @test_throws DomainError cs(sphere, problem, StoppingCriterion(maxiters=1000), pa=-0.1)
    @test_throws DomainError cs(sphere, problem, StoppingCriterion(maxiters=1000), pa=1.1)

    @test f3 <= 1e-5
    @test f1 == cs(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == cs(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == cs(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    @test f4 == cs(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    @test f5 == cs(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)
end
