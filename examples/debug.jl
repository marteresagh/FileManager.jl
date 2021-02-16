using Common
using FileManager

filename = "C:/Users/marte/Documents/GEOWEB/wrapper_file/sezioni/sezioneUIPotree.las"
filename = "C:/Users/marte/Documents/potreeDirectory/pointclouds/SEZIONE_POTREE"

PC = FileManager.source2pc(filename,-1)
cp(filename,"slice.las"; force::Bool=false, follow_symlinks::Bool=false)
