module NetcdfIO

import NetCDF_jll

using DataFrames: DataFrame
using DocStringExtensions: METHODLIST
using OrderedCollections: OrderedDict


# constants
const LIBNETCDF = deepcopy(NetCDF_jll.libnetcdf);


# local NCDatasets.jl
include("ncdatasets/NCDatasets.jl");

using .NCDatasets: Dataset, defVar


include("append.jl");
include("attributes.jl");
include("create.jl");
include("grow.jl");
include("info.jl");
include("libnetcdf.jl");
include("read.jl");
include("save.jl");


end # module
