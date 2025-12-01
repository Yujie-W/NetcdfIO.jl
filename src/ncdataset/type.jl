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

    # constructor
    NCDataset(ncid::Integer, iswritable::Bool, isdefmode::Ref{Bool}; parentdataset = nothing) = (
        ds = new{typeof(parentdataset)}();
        ds.parentdataset = parentdataset;
        ds.ncid = ncid;
        ds.iswritable = iswritable;
        ds.isdefmode = isdefmode;

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


"""

$(TYPEDEF)

Struct to represent a NetCDF variable

# Fields

$(TYPEDFIELDS)

"""
struct Variable{T,N,TDS<:AbstractDataset} <: AbstractVariable{T,N}
    "Parent NetCDF dataset"
    ds::TDS
    "NetCDF variable id"
    varid::Cint
    "NetCDF dimension ids"
    dimids::NTuple{N,Cint}
end;
