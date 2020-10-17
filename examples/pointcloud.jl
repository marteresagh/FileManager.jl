using FileManager
using Visualization

fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
all_files = FileManager.get_files_in_potree_folder(fname,0)
PC = FileManager.las2pointcloud(all_files...)

GL.VIEW(
    [
    Visualization.points_color_from_rgb(PC.coordinates,PC.rgbs)
    ]
)
