using Common
using FileManager
using Visualization

file = "C:/Users/marte/Documents/GEOWEB/wrapper_file/sezioni/sezioneUIPotree_CC.las"
PC = FileManager.las2pointcloud(file)

GL.VIEW([
	Visualization.points_color_from_rgb(Common.apply_matrix(Lar.t(-Common.centroid(PC.coordinates)...),PC.coordinates), PC.rgbs)
])
