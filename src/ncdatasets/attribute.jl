#######################################################################################################################################################################################################
#
# Changes to the struct
# General:
#     2024-Feb-14: remove unnecessary abstract type
#     2024-Feb-14: move all associated functions to the same file
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Struct to store the attributes of a variable or a dataset

$(TYPEDFIELDS)

"""
mutable struct Attributes{TDS<:AbstractDataset}
    "Parent NetCDF dataset"
    ds::TDS
    "NetCDF variable id"
    varid::Cint
end;

get(attrs::Attributes, name::Union{Symbol,AbstractString}, default) = haskey(attrs, name) ? attrs[name] : default;

getindex(attrs::Attributes, name::Union{Symbol,AbstractString}) = nc_get_att(attrs.ds.ncid, attrs.varid, name);

haskey(attrs::Attributes, name::AbstractString) = name in keys(attrs);

keys(attrs::Attributes) = (
    ncid = attrs.ds.ncid;
    varid = attrs.varid;

    natts = nc_inq_varnatts(ncid, varid);
    names = Vector{String}(undef, natts);

    for attnum in 1:natts
        names[attnum] = nc_inq_attname(ncid, varid, attnum-1);
    end;

    return names
);

setindex!(attrs::Attributes, data, name::Union{Symbol,AbstractString}) = (
    # make sure that the file is in define mode
    defmode(attrs.ds);

    return nc_put_att(attrs.ds.ncid, attrs.varid, name, data)
);
