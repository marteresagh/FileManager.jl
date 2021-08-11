# Script Usage

## potree2las.jl

Convert potree projects into one single LAS file.  

#### Input parameters description:
 - potrees: a potree project or a text file with potree directories by row
 - output: output name of file LAS

#### Output:
  - `output.las`: point cloud converted
  - `execution.probe`: success file

#### Options:
```
$ julia potree2las.jl -h

usage: potree2las.jl -o OUTPUT [-h] potrees

positional arguments:
  potrees              Potree projects directory

optional arguments:
  -o, --output OUTPUT  output file .las
  -h, --help           show this help message and exit
```

#### Examples:

    # convert a single potree project
    julia potree2las.jl "C:\MY_POTREE" -o "C:\MY_POTREE.las"

    # convert more potree project in a single file
    julia potree2las.jl "C:\potreeDirs.txt" -o "C:\POTREES.las"
