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

include("general-attributes.jl");
include("general-switch-libnetcdf.jl");
include("read-attributes.jl");
include("read-info.jl");
include("read-recursive.jl");
include("read-var.jl");
include("write-append.jl");
include("write-create.jl");
include("write-grow.jl");
include("write-save.jl");


end # module
