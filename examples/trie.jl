using FileManager
using Visualization

# potree source CAVA
potree = "C:/Users/marte/Documents/potreeDirectory/pointclouds/CAVA" # replace this path with local potree directory

trie = FileManager.potree2trie(potree)
depth = FileManager.max_depth(trie)
all_files = FileManager.get_all_values(trie)

PC = FileManager.las2pointcloud(all_files...)

# point cloud
GL.VIEW(
    [
    Visualization.points_color_from_rgb(PC.coordinates,PC.rgbs)
    ]
)

# subtrie
sub_trie = FileManager.sub_trie(trie,"r00")
all_files = FileManager.get_all_values(sub_trie)

PC = FileManager.las2pointcloud(all_files...)

# part of point cloud
GL.VIEW(
    [
    Visualization.points_color_from_rgb(PC.coordinates,PC.rgbs)
    ]
)

# cuttrie
cut_trie = deepcopy(trie)
FileManager.cut_trie!(cut_trie,1)
depth = FileManager.max_depth(cut_trie)
all_files = FileManager.get_all_values(cut_trie)

PC = FileManager.las2pointcloud(all_files...)

# first level of detail of point cloud
GL.VIEW(
    [
    Visualization.points_color_from_rgb(PC.coordinates,PC.rgbs)
    ]
)


# potree source CASALETTO
potree = "C:/Users/marte/Documents/potreeDirectory/pointclouds/CASALETTO" # replace this path with local potree directory
trie = FileManager.potree2trie(potree)
depth = FileManager.max_depth(trie)

# cuttrie
cut_trie = deepcopy(trie)
FileManager.cut_trie!(cut_trie,0)
depth = FileManager.max_depth(cut_trie)
all_files = FileManager.get_all_values(cut_trie)

PC = FileManager.las2pointcloud(all_files...)

# root of potree
GL.VIEW(
    [
    Visualization.points_color_from_rgb(PC.coordinates,PC.rgbs)
    ]
)
