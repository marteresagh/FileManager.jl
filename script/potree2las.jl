println("loading packages... ")

using ArgParse
using Common
using FileManager

println("packages OK")


"""
	get_potree_dirs(txtpotreedirs::String)

Return collection of potree directories.
"""
function get_potree_dirs(txtpotreedirs::String)
    if isfile(txtpotreedirs)
        return FileManager.readlines(txtpotreedirs)
    elseif isdir(txtpotreedirs)
        return [txtpotreedirs]
    end
end


function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "potrees"
            help = "Potree projects directory"
            arg_type = String
            required = true
        "--output", "-o"
            help = "output file .las"
            arg_type = String
            required = true
    end

    return parse_args(s)
end


function main()
    args = parse_commandline()

    txtpotreedirs = args["potrees"]
    output = args["output"]

    sources = get_potree_dirs(txtpotreedirs)
    flushprintln("")
    flushprintln("== PARAMETERS ==")

    for i in eachindex(sources)
        println("source[$i]: $(sources[i])")
    end

    flushprintln("Output  =>  $output")

    # creo l'header: mi serve il bb che contiene tutto il modello e il numero di punti totali
    full_aabb = AABB()
    n_points_total = 0
    for potree in sources
        cloudmetadata = FileManager.CloudMetadata(potree)
        aabb = cloudmetadata.tightBoundingBox
        Common.update_boundingbox!(full_aabb, aabb)
        n_points_total += cloudmetadata.points
    end

    flushprintln("")
    flushprintln("AABB:")
    flushprintln("min: [$(full_aabb.x_min),$(full_aabb.y_min),$(full_aabb.z_min)]")
    flushprintln("max: [$(full_aabb.x_max),$(full_aabb.y_max),$(full_aabb.z_max)]")

    flushprintln("")
    flushprintln("Points: $n_points_total")

    mainHeader = FileManager.newHeader(
        full_aabb,
        "Potree2Las",
        FileManager.SIZE_DATARECORD,
        n_points_total
    )

    t = open(output, "w")
    write(t, FileManager.LasIO.magic(FileManager.LasIO.format"LAS"))
    write(t, mainHeader)

    flushprintln("")
    flushprintln("== PROCESSING ==")
    # per ogni potree
    for potree in sources
        pointsProcessed = 0
        cloudmetadata = FileManager.CloudMetadata(potree)
        n_points = cloudmetadata.points
        trie = FileManager.potree2trie(potree)
        node_files = FileManager.get_all_values(trie)


        # apro il las
        for file in node_files
            s = open(file, "r")
            h, laspoints = FileManager.read_LAS_LAZ(file) # read file
            for laspoint in laspoints # read each point
                plas = FileManager.newPointRecord(
                    laspoint,
                    h,
                    FileManager.LasIO.LasPoint2,
                    mainHeader,
                )
                write(t, plas) # write this record on temporary file
                flush(t)
                pointsProcessed += 1
                if pointsProcessed % 1_000_000 == 0
                    println("$pointsProcessed points processed of $n_points")
                end
            end
            close(s)
        end

    end

    close(t)
    FileManager.successful(true, splitdir(output)[1])
end

@time main()
