module NCDatasets

import Base: close, convert, haskey, get, getindex, keys, setindex!, showerror, size
import CommonDataModel: attrib, attribnames, defVar, dim, dimnames, group, groupnames, variable
import DiskArrays: readblock!, writeblock!

using NetCDF_jll

using CommonDataModel: AbstractDataset, AbstractVariable, Attributes, CFVariable, Dimensions, Groups
using DocStringExtensions: TYPEDEF, TYPEDFIELDS
using OrderedCollections: OrderedDict


include("libnetcdf-const.jl");
include("libnetcdf-ccall.jl");
include("libnetcdf-error.jl");

include("dataset-type.jl");
include("dataset-mode.jl");
include("dataset-parent-id.jl");
include("dataset-variable.jl");

include("cdm-attribute.jl");
include("cdm-dataset.jl");
include("cdm-dimension.jl");
include("cdm-group.jl");
include("cdm-variable.jl");


end # module
