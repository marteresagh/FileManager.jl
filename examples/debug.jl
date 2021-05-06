using FileManager
using Plots
using Visualization
using Common
potree = "C:/Users/marte/Documents/potreeDirectory/pointclouds/CASALETTO"
cloudmeta = CloudMetadata(potree)
trie = FileManager.potree2trie(potree)
depth = FileManager.max_depth(trie)
all_files = FileManager.get_all_values(trie)
files = FileManager.get_files_in_potree_folder(potree, 2, true)

foglie = FileManager.get_leaf(trie)
files = setdiff(files,foglie)

PC = FileManager.las2pointcloud(files...)

Visualization.VIEW([
    Visualization.points(Common.apply_matrix(Common.t(-Common.centroid(PC.coordinates)...),PC.coordinates), PC.rgbs)
])
files = FileManager.get_files_in_potree_folder(potree, 3, false)
N = []
for i in 1:length(files)
    h,ps = FileManager.read_LAS_LAZ(files[i])
    push!(N,convert(Int64,h.records_count))
end

histogram(N)
