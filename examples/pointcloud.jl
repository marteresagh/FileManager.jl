using FileManager
using Visualization

source = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\SEZIONE_LACONTEA"
trie = FileManager.potree2trie(source)
max_level = FileManager.max_depth(trie)
all_files = FileManager.get_files_in_potree_folder(source,5)
PC = FileManager.las2pointcloud(all_files...)

GL.VIEW(
    [
    Visualization.points_color_from_rgb(PC.coordinates,PC.rgbs)
    ]
)
