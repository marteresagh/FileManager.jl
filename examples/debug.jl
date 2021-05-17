using FileManager
using Plots
using Visualization
using Common

potree = "C:/Users/marte/Documents/potreeDirectory/pointclouds/CASALETTO"
cloudmeta = CloudMetadata(potree)
trie = FileManager.potree2trie(potree)
depth = FileManager.max_depth(trie)

# all_files = FileManager.get_all_values(trie)
foglie = FileManager.get_leaf(trie)
# files = FileManager.get_files_in_potree_folder(potree, 2, true)
# files = setdiff(all_files,foglie)

PC = FileManager.las2pointcloud(foglie...)
out = Array{Common.Struct,1}()
for i in 1:length(foglie)
    aabb = FileManager.las2aabb(foglie[i])
    V,EV = Common.getmodel(aabb)
    out = push!(out, Common.Struct([(V, EV)]))
end
out = Common.Struct(out)
V,EV = Common.struct2lar(out)



Visualization.VIEW([
    Visualization.points(Common.apply_matrix(Common.t(-Common.centroid(PC.coordinates)...),PC.coordinates), PC.rgbs)
    Visualization.GLGrid(Common.apply_matrix(Common.t(-Common.centroid(PC.coordinates)...),V),EV)
])

N = []
for i in 1:length(foglie)
    h,ps = FileManager.read_LAS_LAZ(foglie[i])
    push!(N,convert(Int64,h.records_count))
end

histogram(N)
