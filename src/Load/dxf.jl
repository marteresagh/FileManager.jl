function load_dxf_line(filename::String)
    io = open(filename, "r")
    DXF = readlines(io)
    close(io)
    i = 1
    lines = Array{Float64,1}[]
    while DXF[i] != "EOF"
        if DXF[i] == "LINE"
            global line = Float64[]
        end
        if DXF[i] == "10"
            push!(line, parse(Float64,DXF[i+1]))
            i = i+1
        end
        if DXF[i] == "20"
            push!(line, parse(Float64,DXF[i+1]))
            i = i+1
        end
        if DXF[i] == "30"
            push!(line, parse(Float64,DXF[i+1]))
            i = i+1
        end
        if DXF[i] == "11"
            push!(line, parse(Float64,DXF[i+1]))
            i = i+1
        end
        if DXF[i] == "21"
            push!(line, parse(Float64,DXF[i+1]))
            i = i+1
        end
        if DXF[i] == "31"
            push!(line, parse(Float64,DXF[i+1]))
            i = i+1
            push!(lines,line)
        end
        i = i+1
    end

    V = hcat(reshape.(lines,3,2)...)
    EV = [[i,i+1] for i in range(1, size(V,2), step=2)]
    return V,EV
end

# V,EV = load_dxf_line("C:/Users/marte/Documents/GEOWEB/TEST/CONTEA_SEZIONE_z250/DXF/RAW/segment3D.dxf")
#
# using Visualization
# Visualization.VIEW([
#     Visualization.GLGrid(V,EV)
# ])
