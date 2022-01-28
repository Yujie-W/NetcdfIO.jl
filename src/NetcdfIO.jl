module NetcdfIO

using DataFrames: DataFrame
using DocStringExtensions: METHODLIST
using NCDatasets: Dataset, defDim, defVar


# export public functions
export append_nc!, create_nc!, dimname_nc, grow_nc!, read_nc, save_nc!, size_nc, varname_nc


# constants
const ATTR_LAT   = Dict("description" => "Latitude", "unit" => "°");
const ATTR_LON   = Dict("description" => "Longitude", "unit" => "°");
const ATTR_CYC   = Dict("description" => "Cycle index", "unit" => "-");
const ATTR_ABOUT = Dict("about" => "This is a file generated using NetcdfIO.jl",
                        "notes" => "NetcdfIO.jl uses NCDatasets.jl to read and write NC files");


# include the files
include("append.jl")
include("create.jl")
include("grow.jl"  )
include("info.jl"  )
include("read.jl"  )
include("save.jl"  )
include("size.jl"  )


end # module
