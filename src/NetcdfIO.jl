module NetcdfIO

import NetCDF_jll

using DataFrames: DataFrame
using DocStringExtensions: METHODLIST


# constants
const ATTR_LAT   = Dict{String,Any}("description" => "Latitude", "unit" => "°");
const ATTR_LON   = Dict{String,Any}("description" => "Longitude", "unit" => "°");
const ATTR_CYC   = Dict{String,Any}("description" => "Cycle index", "unit" => "-");
const ATTR_ABOUT = Dict{String,Any}("about" => "This is a file generated using NetcdfIO.jl");
const LIBNETCDF = deepcopy(NetCDF_jll.libnetcdf);


# local NCDatasets.jl
include("ncdatasets/NCDatasets.jl");

using .NCDatasets: Dataset, defVar


# my wrapper functions
include("append.jl");
include("create.jl");
include("grow.jl");
include("info.jl");
include("libnetcdf.jl");
include("read.jl");
include("save.jl");


end # module
