@testset "Random Search Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = randomsearch(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = randomsearch(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = randomsearch(sphere, problem, StoppingCriterion(acceptable_fitness=0.5), seed=1234)

    @test f3 <= 0.5
    @test f1 == randomsearch(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == randomsearch(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == randomsearch(
        sphere, problem, StoppingCriterion(acceptable_fitness=0.5), seed=1234
    )
    @test f1 == f2
end
