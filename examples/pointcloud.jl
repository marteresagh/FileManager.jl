using FileManager
using Visualization
using Common

## descrizione degli octree relativi ai file che gli passo
function view_octree(files, affineMatrix)
    mesh = []
    for file in files
        octree = FileManager.las2aabb(file)
        V, EV, FV = Common.getmodel(octree)
        PC = FileManager.las2pointcloud(file)
        push!(
            mesh,
            Visualization.points(
                Common.apply_matrix(affineMatrix, PC.coordinates),
                PC.rgbs,
            ),
        )
        push!(
            mesh,
            Visualization.GLGrid(
                Common.apply_matrix(affineMatrix, V),
                EV,
                Visualization.COLORS[7],
            ),
        )
    end
    return mesh
end

function merge_pointcloud(cloud1,cloud2)
    @assert cloud1.dimension == cloud2.dimension "not same dimension"
    positions = hcat(cloud1.coordinates,cloud2.coordinates)

    rgbs = reshape([],3,0)
    if !isempty(cloud1.rgbs) && !isempty(cloud2.rgbs)
        rgbs = hcat(cloud1.rgbs,cloud2.rgbs)
    end

    normals = reshape([],Int64(cloud1.dimension),0)
    if !isempty(cloud1.normals) && !isempty(cloud2.normals)
        hcat(cloud1.normals,cloud2.normals)
    end

    if size(normals,2) == 0
        return Common.PointCloud(positions,rgbs)
    end

    return Common.PointCloud(positions,rgbs,normals)
end

function To_PointCloud(files)
    mesh = []
    PC = FileManager.las2pointcloud(files[1])
    for file in files[2:end]
        PC1 = FileManager.las2pointcloud(file)
        PC = merge_pointcloud(PC,PC1)
    end
    return PC
end


function decimate_pointcloud1(
    trie::DataStructures.Trie{String},
    level_to_cut::Int,
    data = String[]::Array{String,1};
    current_level = 0::Int,
)


    @show trie.value
    @show current_level
    if current_level < level_to_cut - 1
        for key in collect(keys(trie.children))
            decimate_pointcloud(
                trie.children[key],
                level_to_cut,
                data;
                current_level = current_level + 1,
            )
        end
    elseif current_level == level_to_cut - 1
        father_take = false
        for key in collect(keys(trie.children))
            @show "figlio" key
            if length(trie.children[key].children) == 0
                @show "è foglia"
                push!(data, trie.value)
                father_take = true
                break
            end
        end
        if !father_take
            for key in collect(keys(trie.children))
                decimate_pointcloud(
                    trie.children[key],
                    level_to_cut,
                    data;
                    current_level = current_level + 1,
                )
            end
        end
    elseif current_level == level_to_cut
        if length(trie.children) != 0
            push!(data, trie.value)
        end
    end

    return data
end



function decimate_pointcloud2(
    trie::DataStructures.Trie{String},
    level_to_cut::Int,
    data = String[]::Array{String,1};
    current_level = 0::Int,
)

    if current_level == level_to_cut
        if length(trie.children) != 0
            push!(data, trie.value)
        end
    elseif current_level < level_to_cut
        for key in collect(keys(trie.children))
            decimate_pointcloud2(
                trie.children[key],
                level_to_cut,
                data;
                current_level = current_level + 1,
            )
        end
    end

    if current_level == level_to_cut - 1
        for key in collect(keys(trie.children))
            if length(trie.children[key].children) == 0
                push!(data, trie.value)
                break
            end
        end
    end

    return data
end


potree = raw"C:\Users\marte\Documents\potreeDirectory\pointclouds\CUCINA"
cloudMets = FileManager.CloudMetadata(potree)

vector_t = [
    cloudMets.boundingBox.x_min,
    cloudMets.boundingBox.y_min,
    cloudMets.boundingBox.z_min,
]

trie = FileManager.potree2trie(potree)

#
max_level = FileManager.max_depth(trie)
# files = FileManager.get_files_in_potree_folder(potree, 5, false)
# leaves = FileManager.get_leaf(trie)
# # PC = FileManager.las2pointcloud(files...)
# affineMatrix = Common.t(-vector_t...)
#
# mesh = view_octree(leaves, affineMatrix)
# V,EV,FV = Common.getmodel(cloudMets.boundingBox)
# push!(mesh,Visualization.GLGrid(Common.apply_matrix(affineMatrix,V),EV,Visualization.COLORS[3]))

# Visualization.VIEW(mesh)

data = decimate_pointcloud2(trie, 2)

# affineMatrix = Common.t(-vector_t...)
# mesh = view_octree(data, affineMatrix)
# Visualization.VIEW(mesh)

PC = To_PointCloud(data)
FileManager.save_pointcloud(raw"C:\Users\marte\Documents\GEOWEB\test\cucina_decimate.las", PC, "decimate")
