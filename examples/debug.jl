using Common
using FileManager
using Visualization

file = "C:/Users/marte/Documents/GEOWEB/wrapper_file/sezioni/sezioneUIPotree_CC.las"
PC = FileManager.las2pointcloud(file)

GL.VIEW([
	Visualization.points_color_from_rgb(Common.apply_matrix(Lar.t(-Common.centroid(PC.coordinates)...),PC.coordinates), PC.rgbs)
])


NAME_PROJ = "MURI_LOD3"
folder = "C:/Users/marte/Documents/GEOWEB/TEST"

dirs, hyperplanes, OBBs, alpha_shapes, full_inliers = FileManager.read_data_vect2D(folder::String,NAME_PROJ::String)

function draw_all(hyperplanes, OBBs)
	mesh = []
	centroid = Common.centroid(hyperplanes[1].inliers.coordinates)
	for i in 1:length(hyperplanes)
		V,EV,FV = getmodel(OBBs[i])
		points = hyperplanes[i].inliers.coordinates
		col = GL.COLORS[rand(1:12)]
		push!(mesh,GL.GLGrid(Common.apply_matrix(Lar.t(-centroid...),V),FV,col));
		push!(mesh,	GL.GLPoints(convert(Lar.Points,Common.apply_matrix(Lar.t(-centroid...),points)'),col));
	end
	return mesh
end

GL.VIEW(draw_all(hyperplanes, OBBs))
