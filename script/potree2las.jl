println("loading packages... ")

using ArgParse
using Common
using FileManager

println("packages OK")


function parse_commandline()
	s = ArgParseSettings()

	@add_arg_table! s begin
	"potree"
		help = "Potree"
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

	potree = args["potree"]
	output = args["output"]

	flushprintln("")
	flushprintln("== PARAMETERS ==")
	flushprintln("Potree  =>  $potree")
	flushprintln("Output  =>  $output")
	flushprintln("")
	flushprintln("== PROCESSING ==")
	# save new LAS source

	cloudmetadata = FileManager.CloudMetadata(potree)
	aabb = cloudmetadata.tightBoundingBox
	n_points = cloudmetadata.points
	trie = FileManager.potree2trie(potree)
	node_files = FileManager.get_all_values(trie)

	# creo l'header
	mainHeader = FileManager.newHeader(aabb,"Potree2Las",FileManager.SIZE_DATARECORD,n_points)
	# apro il las
	t = open(output,"w")
		write(t, FileManager.LasIO.magic(FileManager.LasIO.format"LAS"))
		write(t,mainHeader)
		for file in node_files
			s = open(file, "r")
				h, laspoints = FileManager.read_LAS_LAZ(file) # read file
				for laspoint in laspoints # read each point
					plas = FileManager.newPointRecord(laspoint,h,FileManager.LasIO.LasPoint2,mainHeader)
					write(t,plas) # write this record on temporary file
					flush(t)
				end
			close(s)
		end
	close(t)

	FileManager.successful(true,splitdir(output)[1])
end

@time main()
