@testset "LSHADE Tests" begin
    sphere(x; kwargs...) = sum(x .^ 2)
    problem = Problem(2, -5.12, 5.12)
    f1 = lshade(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    f2 = lshade(sphere, problem, StoppingCriterion(maxevals=500), popsize=40, seed=1234)

    @test_throws DomainError lshade(
        sphere, problem, StoppingCriterion(maxevals=1000), popsize=1
    )
    @test_throws DomainError lshade(
        sphere, problem, StoppingCriterion(maxevals=1000), memorysize=0
    )
    @test_throws DomainError lshade(
        sphere, problem, StoppingCriterion(maxevals=1000), archiverate=-0.1
    )
    @test_throws DomainError lshade(
        sphere, problem, StoppingCriterion(maxevals=1000), pbestrate=1.1
    )
    @test_throws DomainError lshade(
        sphere, problem, StoppingCriterion(maxevals=1000), pbestrate=-0.1
    )
    @test_throws DomainError lshade(sphere, problem, StoppingCriterion(maxiters=1000))
    @test_throws DomainError lshade(
        sphere, problem, StoppingCriterion(acceptable_fitness=0.1)
    )

    @test f1 == lshade(sphere, problem, StoppingCriterion(maxevals=500), seed=1234)
    @test f2 ==
        lshade(sphere, problem, StoppingCriterion(maxevals=500), popsize=40, seed=1234)
end
