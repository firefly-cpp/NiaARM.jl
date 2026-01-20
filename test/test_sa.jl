@testset "Simulated Annealing Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = sa(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = sa(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = sa(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    f4 = sa(sphere, problem, StoppingCriterion(maxevals=10), seed=1234)
    f5 = sa(
        sphere,
        problem,
        StoppingCriterion(maxevals=500),
        initial_temp=50.0,
        cooling_rate=0.98,
        seed=1234,
    )
    f6 = sa(sphere, problem, StoppingCriterion(maxevals=500), step_size=0.2, seed=1234)

    @test_throws DomainError sa(
        sphere, problem, StoppingCriterion(maxiters=1000), initial_temp=-1.0
    )
    @test_throws DomainError sa(
        sphere, problem, StoppingCriterion(maxiters=1000), cooling_rate=1.5
    )
    @test_throws DomainError sa(
        sphere, problem, StoppingCriterion(maxiters=1000), step_size=-0.1
    )
    @test f3 <= 1e-5
    @test f1 == sa(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == sa(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == sa(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    @test f4 == sa(sphere, problem, StoppingCriterion(maxevals=10), seed=1234)
    @test f5 == sa(
        sphere,
        problem,
        StoppingCriterion(maxevals=500),
        initial_temp=50.0,
        cooling_rate=0.98,
        seed=1234,
    )
    @test f6 ==
        sa(sphere, problem, StoppingCriterion(maxevals=500), step_size=0.2, seed=1234)
end
