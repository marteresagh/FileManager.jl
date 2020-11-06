function load_segment(filename::String)
    io = open(filename, "r")
    LINES = readlines(io)
    close(io)

    b = [tryparse.(Float64,split(LINES[i], " ")) for i in 1:length(LINES)]
    V = hcat(reshape.(b,3,2)...)
    EV = [[i,i+1] for i in range(1, size(V,2), step=2)]
    return V,EV
end