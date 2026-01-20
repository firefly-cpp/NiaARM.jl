@testset "Genetic Algorithm Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = ga(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = ga(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = ga(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    f4 = ga(sphere, problem, StoppingCriterion(maxevals=10), seed=1234)
    f5 = ga(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)

    @test_throws DomainError ga(
        sphere, problem, StoppingCriterion(maxiters=1000), popsize=1
    )
    @test_throws DomainError ga(
        sphere, problem, StoppingCriterion(maxiters=1000), tournament_size=0
    )
    @test_throws DomainError ga(
        sphere, problem, StoppingCriterion(maxiters=1000), tournament_size=51
    )
    @test_throws DomainError ga(
        sphere, problem, StoppingCriterion(maxiters=1000), crossover_rate=-0.1
    )
    @test_throws DomainError ga(
        sphere, problem, StoppingCriterion(maxiters=1000), crossover_rate=1.1
    )
    @test_throws DomainError ga(
        sphere, problem, StoppingCriterion(maxiters=1000), mutation_rate=-0.1
    )
    @test_throws DomainError ga(
        sphere, problem, StoppingCriterion(maxiters=1000), mutation_rate=1.1
    )
    @test f3 <= 1e-5
    @test f1 == ga(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == ga(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == ga(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    @test f4 == ga(sphere, problem, StoppingCriterion(maxevals=10), seed=1234)
    @test f5 == ga(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)
end
