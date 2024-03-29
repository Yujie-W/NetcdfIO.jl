#######################################################################################################################################################################################################
#
# NCDatasets.jl are copied from the original NCDatasets.jl, with the following changes:
#     1. Add support to change the libnetcdf library dynamically
#     2. Remove unnecessary code that is not used by NetcdfIO
#     3. Clean up the code that is already moved to CommonDataModel.jl
#
#######################################################################################################################################################################################################
module NCDatasets

import Base: close, convert, haskey, get, getindex, keys, setindex!, showerror, size
import CommonDataModel: defVar, variable

using NetCDF_jll

using CommonDataModel: AbstractDataset, AbstractVariable, CFVariable
using CommonDataModel: name
using DocStringExtensions: TYPEDEF, TYPEDFIELDS


include("attribute.jl");
include("config.jl");
include("dimension.jl");
include("error.jl");
include("group.jl");

include("variable.jl");

include("dataset.jl");


# TODO: clean up these files after more testing
include("netcdf_c.jl");
include("precompile.jl");


end # module
