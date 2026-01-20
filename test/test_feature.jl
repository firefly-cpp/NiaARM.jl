@testset "Feature Tests" begin
    @test_throws ArgumentError NumericalFeature("name", 12, 3)
    @test dtype(NumericalFeature("name", 0, 1)) == Int64
    @test dtype(NumericalFeature("name", 0.0, 1.0)) == Float64
    @test dtype(CategoricalFeature("gender", ["M", "F"])) == String
    @test isnumerical(NumericalFeature("name", 0, 1))
    @test !isnumerical(CategoricalFeature("gender", ["M", "F"]))
    @test iscategorical(CategoricalFeature("gender", ["M", "F"]))
    @test !iscategorical(NumericalFeature("name", 0, 1))
    @test repr(NumericalFeature("name", 0, 1)) == "name(min = 0, max = 1)"
    @test repr(CategoricalFeature("gender", ["M", "F"])) ==
        "gender(categories = [\"M\", \"F\"])"
end
