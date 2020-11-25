function save_new_ply(filename::String, PC::PointCloud; comment="julia"::String, ascii=true::Bool)
   # per ora funziona solo in formato ascii BUG nella libreria
   ply = Ply()
   push!(ply, PlyComment(comment))

   points = PC.coordinates
   # position and colors
   if !isempty(PC.rgbs)
      rgbs = PC.rgbs
      vertex = PlyElement("vertex",
                          ArrayProperty("x", points[1,:]),
                          ArrayProperty("y", points[2,:]),
                          ArrayProperty("z", points[3,:]),
                          ArrayProperty("r", rgbs[1,:]),
                          ArrayProperty("g", rgbs[2,:]),
                          ArrayProperty("b", rgbs[3,:]))
   else
      vertex = PlyElement("vertex",
                          ArrayProperty("x", points[1,:]),
                          ArrayProperty("y", points[2,:]),
                          ArrayProperty("z", points[3,:]))
   end

   push!(ply, vertex)

   # For the sake of the example, ascii format is used, the default binary mode is faster.
   save_ply(ply, filename, ascii=true)
end
