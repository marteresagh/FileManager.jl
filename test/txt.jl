workdir = dirname(dirname(pathof(FileManager)))

@testset "TXT" begin
    V = [0. 4. 4. 0. 2. 3. 3. 2;
    0. 0. 4. 4. 2. 2. 3. 3.]
    EV = [[1,2],[2,3],[3,4],[4,1],[5,6],[6,7],[7,8],[8,5]]

    file_V = joinpath(workdir,"test","Files/V.txt")
    file_EV = joinpath(workdir,"test","Files/EV.txt")
    FileManager.save_points_txt(file_V, V)
    FileManager.save_cells_txt(file_EV, EV)

    V_load = FileManager.load_points(file_V)
    EV_load = FileManager.load_cells(file_EV)
    @test V_load == V
    @test EV_load == EV

    file = joinpath(workdir,"Files/PC.txt")
    rgb = [1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0.]
    PC = FileManager.PointCloud(V,rgb)
    FileManager.save_points_rgbs_txt(file, PC)
    V_load = FileManager.load_points(file)
    @test V_load[1:2,:] == PC.coordinates
    @test V_load[3:5,:] == PC.rgbs*255
end
