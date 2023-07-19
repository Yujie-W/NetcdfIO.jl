module NetcdfIO

import NCDatasets: nc_open

using DataFrames: DataFrame
using DocStringExtensions: METHODLIST
using NCDatasets: Dataset, NC_NOERR, NetCDFError, defDim, defVar, nc_strerror


# constants
const ATTR_LAT   = Dict("description" => "Latitude", "unit" => "°");
const ATTR_LON   = Dict("description" => "Longitude", "unit" => "°");
const ATTR_CYC   = Dict("description" => "Cycle index", "unit" => "-");
const ATTR_ABOUT = Dict("about" => "This is a file generated using NetcdfIO.jl",
                        "notes" => "NetcdfIO.jl uses NCDatasets.jl to read and write NC files");


# include the files
include("append.jl");
include("create.jl");
include("grow.jl");
include("hdf4.jl");
include("info.jl");
include("read.jl");
include("save.jl");


end # module
