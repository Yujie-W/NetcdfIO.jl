# """
# NCDatasets.jl are copied from the original NCDatasets.jl, with the following changes:
# 1. Add support to change the libnetcdf library dynamically
# """
module NCDatasets

import Base: Array, close, collect, convert, delete!, display, filter, getindex, parent, parentindices, setindex!, show, showerror, size, view, cat
import CommonDataModel: AbstractDataset, AbstractVariable, CFVariable
import CommonDataModel: dataset, isopen, name, path, unlimited
import CommonDataModel: attrib, attribnames, defAttrib
import CommonDataModel: CFtransformdata!, cfvariable, defVar, variable
import CommonDataModel: defDim, dim, dimnames
import CommonDataModel: defGroup, group, groupnames
import CommonDataModel: add_offset, boundsParentVar, fillvalue, fill_and_missing_values, scale_factor
import CommonDataModel: time_origin, time_factor

using CFTime
using DataStructures: OrderedDict
using Dates
using NetCDF_jll
using NetworkOptions
using Printf
using CommonDataModel
using CommonDataModel: dims, attribs, groups

function __init__()
    NetCDF_jll.is_available() && init_certificate_authority()
end

const default_timeunits = "days since 1900-00-00 00:00:00"
const SymbolOrString = Union{Symbol, AbstractString}


include("CatArrays.jl");
include("types.jl");
include("errorhandling.jl");
include("netcdf_c.jl");
include("dataset.jl");
include("attributes.jl");
include("dimensions.jl");
include("groupes.jl");
include("variable.jl");
include("cfvariable.jl");
include("precompile.jl");


end # module
