"""

$(TYPEDEF)

Struct to store the dimension of a variable or a dataset

# Fields

$(TYPEDFIELDS)

"""
struct Dimensions{TDS<:AbstractDataset}
    "Parent NetCDF dataset"
    ds::TDS
end;

haskey(dims::Dimensions, name::Union{AbstractString,Symbol}) = name in keys(dims);

keys(dims::Dimensions) = String[nc_inq_dimname(dims.ds.ncid, dimid) for dimid in nc_inq_dimids(dims.ds.ncid, false)];

setindex!(dims::Dimensions, len::Union{Int,AbstractFloat}, name::Union{AbstractString,Symbol}) = (
    # make sure that the file is in define mode
    def_mode!(dims.ds);
    nc_def_dim(dims.ds.ncid, name, (isinf(len) ? NC_UNLIMITED : len));

    return nothing
);
