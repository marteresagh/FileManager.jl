struct CloudMetadata
    version::String
    octreeDir::String
    projection::String
    points::Int64
    boundingBox::AABB
    tightBoundingBox::AABB
    pointAttributes::String
    spacing::Float64
    scale::Float64
    hierarchyStepSize::Int32

    function CloudMetadata(path::String)
        dict = Dict{String,Any}[]
        open(path * "\\cloud.js", "r") do f
            dict = JSON.parse(f)  # parse and transform data
        end
        version = dict["version"]
        if version == "1.7"
            octreeDir = dict["octreeDir"]
            projection = dict["projection"]
            points = dict["points"]
            dictAABB = dict["boundingBox"]
            dicttightBB = dict["tightBoundingBox"]
            boundingBox = AABB(dictAABB["ux"],dictAABB["lx"],dictAABB["uy"],dictAABB["ly"],dictAABB["uz"],dictAABB["lz"])
            tightBoundingBox = AABB(dicttightBB["ux"],dicttightBB["lx"],dicttightBB["uy"],dicttightBB["ly"],dicttightBB["uz"],dicttightBB["lz"])

            pointAttributes = dict["pointAttributes"]
            spacing = dict["spacing"]
            scale = dict["scale"]
            hierarchyStepSize = dict["hierarchyStepSize"]

            new(
            version,
            octreeDir,
            projection,
            points,
            boundingBox,
            tightBoundingBox,
            pointAttributes,
            spacing,
            scale,
            Int32(hierarchyStepSize)
            )
        end
    end

end
