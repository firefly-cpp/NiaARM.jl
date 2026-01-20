@testset "Particle Swarm Optimization Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = pso(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = pso(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = pso(sphere, problem, StoppingCriterion(acceptable_fitness=0.0), seed=1234)
    f4 = pso(
        sphere, problem, StoppingCriterion(acceptable_fitness=0.0), popsize=13, seed=1234
    )
    f5 = pso(sphere, problem, StoppingCriterion(maxevals=10), popsize=30, seed=1234)

    @test f3 <= 0.0
    @test f1 == pso(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == pso(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f2 == pso(sphere, problem, StoppingCriterion(maxevals=5010), seed=1234)
    @test f3 == pso(sphere, problem, StoppingCriterion(acceptable_fitness=0.0), seed=1234)
    @test f4 == pso(
        sphere, problem, StoppingCriterion(acceptable_fitness=0.0), popsize=13, seed=1234
    )
    @test f5 == pso(sphere, problem, StoppingCriterion(maxevals=10), popsize=30, seed=1234)
end
