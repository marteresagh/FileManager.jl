@testset "Potree" begin
    workdir = dirname(dirname(pathof(FileManager)))
    # test_file = joinpath(BASE_FOLDER, "data", "file.txt")

    potreeLAS = joinpath(workdir,"test","Files/stairsLAS")
    potreeLAZ = joinpath(workdir,"test","Files/stairsLAZ")

    oneNodeLAS = joinpath(workdir,"test","Files/stairsLAS/data/r/r0.las")
    oneNodeLAZ = joinpath(workdir,"test","Files/stairsLAZ/data/r/r0.laz")

    totalNodes = 71 # aka number of files
    maxDepth = 3    # depth of the tree
    totalPoints = (3, 357003) # using that to check coordinates and rgbs ( 3 (xyz/rgb), 357003 (total points))
    boundingbox = (1.4770147800445557, -0.7153962850570679, -1.4153246879577637, 5.361339569091797, 3.1689285039901735, 2.4690001010894777)

    @testset "las2pointcloud" begin
        @test size(FileManager.las2pointcloud((FileManager.get_all_values(FileManager.potree2trie(potreeLAS)))...).coordinates) == totalPoints
        @test size(FileManager.las2pointcloud((FileManager.get_all_values(FileManager.potree2trie(potreeLAZ)))...).coordinates) == totalPoints

        @test size(FileManager.las2pointcloud((FileManager.get_all_values(FileManager.potree2trie(potreeLAS)))...).rgbs) == totalPoints
        @test size(FileManager.las2pointcloud((FileManager.get_all_values(FileManager.potree2trie(potreeLAZ)))...).rgbs) == totalPoints
    end

    @testset "las2larpoints" begin
        @test (FileManager.las2larpoints(oneNodeLAS)) == (FileManager.las2larpoints(oneNodeLAZ))
    end

    @testset "max_depth" begin
        @test FileManager.max_depth(FileManager.potree2trie(potreeLAS)) == maxDepth
        @test FileManager.max_depth(FileManager.potree2trie(potreeLAZ)) == maxDepth
    end


    @testset "get_all_values" begin

        # size gives a tuple (totalNodes, ) so use [1] to check the first element
        @test size(FileManager.get_all_values(FileManager.potree2trie(potreeLAS)))[1] == totalNodes
        @test size(FileManager.get_all_values(FileManager.potree2trie(potreeLAZ)))[1] == totalNodes
    end

    @testset "sub_trie" begin

    end

    @testset "get_files_in_potree_folder + get_files" begin

    # size gives a tuple (totalNodes, ) so use [1] to check the first element

        # LOD = 0, just one node (radix node)
        @test size(FileManager.get_files_in_potree_folder(potreeLAS, 0))[1] == 1
        @test size(FileManager.get_files_in_potree_folder(potreeLAZ, 0))[1] == 1

        # LOD = 1, radix + 7 child
        @test size(FileManager.get_files_in_potree_folder(potreeLAS, 1))[1] == 8
        @test size(FileManager.get_files_in_potree_folder(potreeLAZ, 1))[1] == 8

        # LOD = 2, radix + 7 child + 26 child of child
        @test size(FileManager.get_files_in_potree_folder(potreeLAS, 2))[1] == 36
        @test size(FileManager.get_files_in_potree_folder(potreeLAZ, 2))[1] == 36

        # LOD = 3, radix + 7 child + 26 child of child + 35 child = totalNodes (71)
        @test size(FileManager.get_files_in_potree_folder(potreeLAS, 3))[1] == totalNodes
        @test size(FileManager.get_files_in_potree_folder(potreeLAZ, 3))[1] == totalNodes
    end
end
