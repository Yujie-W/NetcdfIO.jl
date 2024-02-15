#######################################################################################################################################################################################################
#
# Changes to the struct
# General:
#     2024-Feb-14: clean up the struct
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








############################################################
# High-level
############################################################

"""
    NCDataset(filename::AbstractString, mode = "r";
              format::Symbol = :netcdf4,
              share::Bool = false,
              diskless::Bool = false,
              persist::Bool = false,
              memory::Union{Vector{UInt8},Nothing} = nothing,
              attrib = [])

Load, create, or even overwrite a NetCDF file at `filename`, depending on `mode`

* `"r"` (default) : open an existing netCDF file or OPeNDAP URL
   in read-only mode.
* `"c"` : create a new NetCDF file at `filename` (an existing file with the same
  name will be overwritten).
* `"a"` : open `filename` into append mode (i.e. existing data in the netCDF
  file is not overwritten and a variable can be added).


If `share` is true, the `NC_SHARE` flag is set allowing to have multiple
processes to read the file and one writer process. Likewise setting `diskless`
or `persist` to `true` will enable the flags `NC_DISKLESS` or `NC_PERSIST` flag.
More information is available in the [NetCDF C-API](https://www.unidata.ucar.edu/software/netcdf/docs/).

Notice that this does not close the dataset, use `close` on the
result (or see below the `do`-block).

The optional parameter `attrib` is an iterable of attribute name and attribute
value pairs, for example a `Dict`, `DataStructures.OrderedDict` or simply a
vector of pairs (see example below).

# Supported `format` values:

* `:netcdf4` (default): HDF5-based NetCDF format.
* `:netcdf4_classic`: Only netCDF 3 compatible API features will be used.
* `:netcdf3_classic`: classic netCDF format supporting only files smaller than 2GB.
* `:netcdf3_64bit_offset`: improved netCDF format supporting files larger than 2GB.
* `:netcdf5_64bit_data`: improved netCDF format supporting 64-bit integer data types.


Files can also be open and automatically closed with a `do` block.

```julia
NCDataset("file.nc") do ds
    data = ds["temperature"][:,:]
end
```

Here is an attribute example:
```julia
using DataStructures
NCDataset("file.nc", "c", attrib = OrderedDict("title" => "my first netCDF file")) do ds
   defVar(ds,"temp",[10.,20.,30.],("time",))
end;
```

The NetCDF dataset can also be a `memory` as a vector of bytes. A non-empty string
a `filename` is still required, for example:

```julia
using NCDataset, HTTP
resp = HTTP.get("https://www.unidata.ucar.edu/software/netcdf/examples/ECMWF_ERA-40_subset.nc")
ds = NCDataset("some_string","r",memory = resp.body)
total_precipitation = ds["tp"][:,:,:]
close(ds)
```

`Dataset` is an alias of `NCDataset`.
"""
function NCDataset(filename::AbstractString,
                   mode::AbstractString = "r";
                   format::Symbol = :netcdf4,
                   share::Bool = false,
                   diskless::Bool = false,
                   persist::Bool = false,
                   memory::Union{Vector{UInt8},Nothing} = nothing,
                   attrib = [])

    ncid = -1
    isdefmode = Ref(false)

    ncmode =
        if mode == "r"
            NC_NOWRITE
        elseif mode == "a"
            NC_WRITE
        elseif mode == "c"
            NC_CLOBBER
        else
            throw(NetCDFError(-1, "Unsupported mode '$(mode)' for filename '$(filename)'"))
        end

    if diskless
        ncmode = ncmode | NC_DISKLESS

        if persist
            ncmode = ncmode | NC_PERSIST
        end
    end

    if share
        @debug "share mode"
        ncmode = ncmode | NC_SHARE
    end

    @debug "ncmode: $ncmode"

    if (mode == "r") || (mode == "a")
        if isnothing(memory)
            ncid = nc_open(filename,ncmode)
        else
            ncid = nc_open_mem(filename,ncmode,memory)
        end
    elseif mode == "c"
        if format == :netcdf5_64bit_data
            ncmode = ncmode | NC_64BIT_DATA
        elseif format == :netcdf3_64bit_offset
            ncmode = ncmode | NC_64BIT_OFFSET
        elseif format == :netcdf4_classic
            ncmode = ncmode | NC_NETCDF4 | NC_CLASSIC_MODEL
        elseif format == :netcdf4
            ncmode = ncmode | NC_NETCDF4
        elseif format == :netcdf3_classic
            # do nothing
        else
            throw(NetCDFError(-1, "Unkown format '$(format)' for filename '$(filename)'"))
        end

        ncid = nc_create(filename,ncmode)
        isdefmode[] = true
    end

    iswritable = mode != "r"
    ds = NCDataset(ncid,iswritable,isdefmode)

    # set global attributes
    for (attname,attval) in attrib
        ds.attrib[attname] = attval
    end

    return ds
end
