module NetcdfIO

using DocStringExtensions: METHODLIST
using NCDatasets: Dataset, defDim, defVar, listVar


# export public functions
export size_nc


# constants
const ATTR_LAT   = Dict("description" => "Latitude", "unit" => "°");
const ATTR_LON   = Dict("description" => "Longitude", "unit" => "°");
const ATTR_CYC   = Dict("description" => "Cycle index", "unit" => "-");
const ATTR_ABOUT = Dict("about" => "This is a file generated using PkgUtility.jl",
                        "notes" => "PkgUtility.jl uses NCDatasets.jl to create NC files");


# include the files
include("append.jl")
include("read.jl"  )
include("save.jl"  )
include("size.jl"  )


end # module
