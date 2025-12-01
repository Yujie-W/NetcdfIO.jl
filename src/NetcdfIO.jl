module NetcdfIO

import NetCDF_jll

import Base: close, convert, haskey, get, getindex, keys, setindex!, showerror, size
import CommonDataModel: attrib, attribnames, defVar, dim, dimnames, group, groupnames, variable
import DiskArrays: readblock!, writeblock!

using CommonDataModel: AbstractDataset, AbstractVariable, Attributes, CFVariable, Dimensions, Groups
using DataFrames: DataFrame
using DocStringExtensions: METHODLIST, TYPEDEF, TYPEDFIELDS
using OrderedCollections: OrderedDict


# constants
const LIBNETCDF = deepcopy(NetCDF_jll.libnetcdf);

# libnetcdf functions and constants (local changes made from NCDataset.jl)
include("libnetcdf/const.jl");
include("libnetcdf/ccall.jl");
include("libnetcdf/error.jl");

# ncdataset types (local changes made from NCDataset.jl)
include("ncdataset/type.jl");
include("ncdataset/mode.jl");
include("ncdataset/parent-id.jl");
include("ncdataset/variable.jl");

# extensions to use the CommonDataModel (local changes made from NCDataset.jl)
include("cdm-extension/attribute.jl");
include("cdm-extension/dataset.jl");
include("cdm-extension/dimension.jl");
include("cdm-extension/group.jl");
include("cdm-extension/variable.jl");

# core NetcdfIO functionalities
include("netcdfio/general-attributes.jl");
include("netcdfio/general-switch-libnetcdf.jl");
include("netcdfio/read-attributes.jl");
include("netcdfio/read-info.jl");
include("netcdfio/read-recursive.jl");
include("netcdfio/read-var.jl");
include("netcdfio/write-append.jl");
include("netcdfio/write-create.jl");
include("netcdfio/write-grow.jl");
include("netcdfio/write-save.jl");


end # module
