"""
Potree project metadata:
 - version:  the version number is needed to know how to interpret the data,
 - octreeDir: the name of the directory where files of octree are contained,
 - tightBoundingBox: it contains the minimum and maximum coordinates of the bounding box,
 - boundingBox: it contains the minimum and maximum coordinates of the cubic bounding box aligned to the axes which contains the root node,
 - pointAttributes: declares the format of points. It can be LAS, LAZ or in the case of binary format it contains an array of attributes such as `["POSITION_CARTESIAN", "COLOR_PACKED", "INTENSITY"]`,
 - spacing: spacing value at the root node,
 - hierarchyStepSize: the number of levels in each chunk.

# Example
```
{
    "version": "1.7",
    "octreeDir": "data",
    "projection": "",
    "points": 2502516,
    "boundingBox": {
        "lx": 295370.8436816006,
        "ly": 4781124.438537028,
        "lz": 225.44601794335939,
        "ux": 295632.16918208889,
        "uy": 4781385.764037516,
        "uz": 486.77151843164065
    },
    "tightBoundingBox": {
        "lx": 295370.8436816006,
        "ly": 4781124.438537028,
        "lz": 225.44601794335939,
        "ux": 295632.16918208889,
        "uy": 4781376.7190012,
        "uz": 300.3583829030762
    },
    "pointAttributes": "LAS",
    "spacing": 2.2631452083587648,
    "scale": 0.001,
    "hierarchyStepSize": 5
}
```

# Fields
```jldoctest
version           :: String
octreeDir         :: String
projection        :: String
points            :: Int64
boundingBox       :: AABB
tightBoundingBox  :: AABB
pointAttributes   :: String
spacing           :: Float64
scale             :: Float64
hierarchyStepSize :: Int32
```
"""
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
        open(joinpath(path, "cloud.js"), "r") do f
            dict = JSON.parse(f)  # parse and transform data
        end

        @assert haskey(dict, "version") "cloud.js: version key not found"
        @assert haskey(dict, "octreeDir") "cloud.js: octreeDir key not found"
        @assert haskey(dict, "projection") "cloud.js: projection key not found"
        @assert haskey(dict, "points") "cloud.js: points key not found"
        @assert haskey(dict, "boundingBox") "cloud.js: boundingBox key not found"
        @assert haskey(dict, "tightBoundingBox") "cloud.js: tightBoundingBox key not found"
        @assert haskey(dict, "pointAttributes") "cloud.js: pointAttributes key not found"
        @assert haskey(dict, "spacing") "cloud.js: spacing key not found"
        @assert haskey(dict, "scale") "cloud.js: scale key not found"
        @assert haskey(dict, "hierarchyStepSize") "cloud.js: hierarchyStepSize key not found"

        version = dict["version"]
        @assert version == "1.7" || version == "1.8" "cloud.js: not compatible version, 1.7 or 1.8 required"

        octreeDir = dict["octreeDir"]
        projection = dict["projection"]
        points = dict["points"]
        dictAABB = dict["boundingBox"]
        dicttightBB = dict["tightBoundingBox"]
        boundingBox = AABB(
            dictAABB["ux"],
            dictAABB["lx"],
            dictAABB["uy"],
            dictAABB["ly"],
            dictAABB["uz"],
            dictAABB["lz"],
        )
        tightBoundingBox = AABB(
            dicttightBB["ux"],
            dicttightBB["lx"],
            dicttightBB["uy"],
            dicttightBB["ly"],
            dicttightBB["uz"],
            dicttightBB["lz"],
        )

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
            Int32(hierarchyStepSize),
        )

    end

end
