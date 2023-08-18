"""
NCDatasets.jl are copied from the original NCDatasets.jl, with the following changes:
1. Add support to change the libnetcdf library dynamically
"""
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

include("ncdatasets/CatArrays.jl");
include("ncdatasets/types.jl");
include("ncdatasets/colors.jl");
include("ncdatasets/errorhandling.jl");
include("ncdatasets/netcdf_c.jl");
include("ncdatasets/dataset.jl");
include("ncdatasets/attributes.jl");
include("ncdatasets/dimensions.jl");
include("ncdatasets/groupes.jl");
include("ncdatasets/variable.jl");
include("ncdatasets/cfvariable.jl");
include("ncdatasets/subvariable.jl");
include("ncdatasets/cfconventions.jl");
include("ncdatasets/defer.jl");
include("ncdatasets/multifile.jl");
include("ncdatasets/ncgen.jl");
include("ncdatasets/select.jl");
include("ncdatasets/precompile.jl");

export CatArrays
export CFTime
export daysinmonth, daysinyear, yearmonthday, yearmonth, monthday
export dayofyear, firstdayofyear
export DateTimeStandard, DateTimeJulian, DateTimeProlepticGregorian,
    DateTimeAllLeap, DateTimeNoLeap, DateTime360Day, AbstractCFDateTime

end # module
