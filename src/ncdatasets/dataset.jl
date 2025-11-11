#######################################################################################################################################################################################################
#
# Changes to the struct
# General:
#     2024-Feb-14: clean up the struct
#     2024-Feb-14: simply the constructor and remove unnecessary options that I won't use
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Struct for a NetCDF dataset

# Fields

$(TYPEDFIELDS)

"""
mutable struct NCDataset{TDS} <: AbstractDataset where TDS<:AbstractDataset
    "Parent dataset (nothing for the root dataset)"
    parentdataset::TDS
    "NetCDF dataset id"
    ncid::Cint
    "Whether the NetCDF is writable"
    iswritable::Bool
    "Whether the NetCDF is in define mode (i.e. metadata can be added, but not data)"
    isdefmode::Ref{Bool}
    "Attributes of the dataset"
    attrib::Attributes{NCDataset{TDS}}
    "Dimensions of the dataset"
    dim::Dimensions{NCDataset{TDS}}
    "Groups of the dataset"
    group::Groups{NCDataset{TDS}}

    # constructor
    NCDataset(ncid::Integer, iswritable::Bool, isdefmode::Ref{Bool}; parentdataset = nothing) = (
        ds = new{typeof(parentdataset)}();
        ds.parentdataset = parentdataset;
        ds.ncid = ncid;
        ds.iswritable = iswritable;
        ds.isdefmode = isdefmode;
        ds.attrib = Attributes(ds, NC_GLOBAL);
        ds.dim = Dimensions(ds);
        ds.group = Groups(ds);

        @inline _finalize(ds) = (
            # only close open root group
            if (ds.ncid != -1) && isnothing(ds.parentdataset)
                close(ds)
            end;
        );

        finalizer(_finalize, ds);

        return ds
    );
end;

NCDataset(filename::AbstractString, mode::AbstractString) = (
    @assert mode in ("r","a","c") "Unsupported mode: $(mode)!";

    ncid = -1;
    isdefmode = Ref(false);
    iswritable = mode != "r";

    if mode == "r"
        ncmode = NC_NOWRITE;
        ncid = nc_open(filename, ncmode);
    end;

    if mode == "a"
        ncmode = NC_WRITE;
        ncid = nc_open(filename, ncmode);
    end;

    if mode == "c"
        ncmode = NC_CLOBBER | NC_NETCDF4
        ncid = nc_create(filename, ncmode);
        isdefmode[] = true;
    end;

    return NCDataset(ncid, iswritable, isdefmode)
);

const Dataset = NCDataset;

close(ds::NCDataset) = (
    try
        nc_close(ds.ncid);
    catch err
        # like Base, allow close on closed file
        if err isa NetCDFError
            if err.code == NC_EBADID
                return nothing
            end;
        end;
        rethrow();
    end;

    # prevent finalize to close file as ncid can reused for future files
    ds.ncid = -1;

    return nothing
);

data_mode!(dset::NCDataset) = (
    if dset.isdefmode[]
        nc_enddef(dset.ncid);
        dset.isdefmode[] = false
    end;

    return nothing
);

def_mode!(dset::NCDataset) = (
    if !dset.isdefmode[]
        nc_redef(dset.ncid);
        dset.isdefmode[] = true;
    end;

    return nothing
);

"""

    defVar(dset::NCDataset,
           name::Union{AbstractString,Symbol},
           vtype::DataType,
           dimnames::Vector{String};
           deflatelevel::Union{Int,Nothing} = nothing,
           attrib::Dict{String,Any} = Dict{String,Any}())

Create a new variable in the dataset, given
- `dset` A netcdf dataset
- `name` Name of the variable
- `vtype` Type of the variable, for example `Float64`, `Int32`, `String`, etc.
- `dimnames` Dimension names in the netcdf file
- `deflatelevel` Compression level fro NetCDF, default is `nothing`
- `attrib` Variable attributes, default is an empty dictionary

"""
defVar(dset::NCDataset,
       name::Union{AbstractString,Symbol},
       vtype::DataType,
       dimnames::Vector{String};
       deflatelevel::Union{Int,Nothing} = nothing,
       attrib::Dict{String,Any} = Dict{String,Any}()) = (
    # make sure that the file is in define mode
    def_mode!(dset);

    dimids = Cint[nc_inq_dimid(dset.ncid, dimname) for dimname in dimnames[end:-1:1]];
    typeid = (vtype <: Vector) ? nc_def_vlen(dset.ncid, nothing, NC_TYPES[eltype(vtype)]) : NC_TYPES[vtype];
    varid = nc_def_var(dset.ncid, name, typeid, dimids);

    if !isnothing(deflatelevel)
        nc_def_var_deflate(dset.ncid, varid, false, true, deflatelevel);
    end;

    # note: element type of ds[name] potentially changed, so do not directly return v here
    v = dset[name];
    for (attname,attval) in attrib
        v.attrib[attname] = attval;
    end;

    return dset[name]
);

haskey(dset::NCDataset, name::Union{AbstractString,Symbol}) = name in keys(dset);

keys(dset::NCDataset) = String[nc_inq_varname(dset.ncid, varid) for varid in nc_inq_varids(dset.ncid)];

variable(dset::NCDataset, varid::Integer) = (
    dimids = nc_inq_vardimid(dset.ncid, varid);
    T = _jltype(dset.ncid, nc_inq_vartype(dset.ncid, varid));
    N = length(dimids);
    attrib = Attributes(dset, varid);
    TDS = typeof(dset);

    # reverse dimids to have the dimension order in Fortran style
    return Variable{T,N,TDS}(dset, varid, (reverse(dimids)...,), attrib)
);

variable(dset::NCDataset, varname::AbstractString) = variable(dset, nc_inq_varid(dset.ncid, varname));
