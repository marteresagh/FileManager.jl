@testset "LAS" begin
    workdir = dirname(@__FILE__)
    file = joinpath(workdir,"Files/PC.las")
    @show file
    PC = FileManager.PointCloud(rand(3,100),LasIO.FixedPointNumbers.N0f16.(rand(3,100)))
    FileManager.save_pointcloud(file, PC,  "TEST")
    PC_load = FileManager.source2pc(file)
    @test PC_load.n_points == PC.n_points
    @test PC_load.dimension == PC.dimension
end
