@testset "Flower Pollination Algorithm Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = fpa(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = fpa(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    f3 = fpa(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    f4 = fpa(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    f5 = fpa(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)

    @test_throws DomainError fpa(
        sphere, problem, StoppingCriterion(maxiters=1000), popsize=0
    )
    @test_throws DomainError fpa(sphere, problem, StoppingCriterion(maxiters=1000), p=-0.1)
    @test_throws DomainError fpa(sphere, problem, StoppingCriterion(maxiters=1000), p=1.1)

    @test f3 <= 1e-5
    @test f1 == fpa(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 == fpa(sphere, problem, StoppingCriterion(maxiters=500), seed=1234)
    @test f3 == fpa(sphere, problem, StoppingCriterion(acceptable_fitness=1e-5), seed=1234)
    @test f4 == fpa(sphere, problem, StoppingCriterion(maxevals=9), seed=1234)
    @test f5 == fpa(sphere, problem, StoppingCriterion(maxevals=500), popsize=13, seed=1234)
end
