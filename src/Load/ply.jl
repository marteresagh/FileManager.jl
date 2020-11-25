function ply2pointcloud(filename::String)
        V = Array{T where T,1}[]
        rgbs = Array{T where T,1}[]
        ply = load_ply(filename)
        props = plyname.(ply["vertex"].properties)

        for prop in props
                if prop == "x"
                        push!(V,ply["vertex"][prop])
                elseif prop == "y"
                        push!(V,ply["vertex"][prop])
                elseif prop == "z"
                        push!(V,ply["vertex"][prop])
                elseif prop == "red"
                        push!(rgbs,ply["vertex"][prop])
                elseif prop == "green"
                        push!(rgbs,ply["vertex"][prop])
                elseif prop == "blue"
                        push!(rgbs,ply["vertex"][prop])
                end
        end
        coords = convert(Matrix,hcat(V...)')

        if !isempty(rgbs)
                rgbs = convert(Matrix,hcat(rgbs...)')
                if isinteger(rgbs[1,1])
                        rgbs/=255
                end
                return PointCloud(coords,rgbs)
        end

        PointCloud(coords)
end
