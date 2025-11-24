"""

$(TYPEDEF)

Struct to store the groups of a dataset

# Fields

$(TYPEDFIELDS)

"""
struct Groups{TDS<:AbstractDataset}
    "Parent NetCDF dataset"
    ds::TDS
end;

getindex(grps::Groups, name::Union{AbstractString,Symbol}) = (
    grp_ncid = nc_inq_grp_ncid(grps.ds.ncid, name);

    return NCDataset(grp_ncid, grps.ds.iswritable, grps.ds.isdefmode; parentdataset = grps.ds)
);

haskey(grps::Groups, name::Union{AbstractString,Symbol}) = name in keys(grps);

keys(grps::Groups) = String[nc_inq_grpname(ncid) for ncid in nc_inq_grps(grps.ds.ncid)];
