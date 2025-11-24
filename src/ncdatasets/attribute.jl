"""

$(TYPEDEF)

Struct to store the attributes of a variable or a dataset

# Fields

$(TYPEDFIELDS)

"""
struct Attributes{TDS<:AbstractDataset}
    "Parent NetCDF dataset"
    ds::TDS
    "NetCDF variable id"
    varid::Cint
end;

get(attrs::Attributes, name::Union{AbstractString,Symbol}, default) = haskey(attrs, name) ? attrs[name] : default;

getindex(attrs::Attributes, name::Union{AbstractString,Symbol}) = nc_get_att(attrs.ds.ncid, attrs.varid, name);

haskey(attrs::Attributes, name::Union{AbstractString,Symbol}) = name in keys(attrs);

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

setindex!(attrs::Attributes, data, name::Union{AbstractString,Symbol}) = (
    # make sure that the file is in define mode
    def_mode!(attrs.ds);
    nc_put_att(attrs.ds.ncid, attrs.varid, name, data);

    return nothing
);
