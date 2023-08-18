module NetcdfIO

using DataFrames: DataFrame
using DocStringExtensions: METHODLIST


# constants
const ATTR_LAT   = Dict("description" => "Latitude", "unit" => "°");
const ATTR_LON   = Dict("description" => "Longitude", "unit" => "°");
const ATTR_CYC   = Dict("description" => "Cycle index", "unit" => "-");
const ATTR_ABOUT = Dict("about" => "This is a file generated using NetcdfIO.jl");


# local NCDatasets.jl
include("NCDatasets.jl");

using .NCDatasets: Dataset, defDim, defVar

# my wrapper functions
include("append.jl");
include("create.jl");
include("grow.jl");
include("info.jl");
include("read.jl");
include("save.jl");


end # module
