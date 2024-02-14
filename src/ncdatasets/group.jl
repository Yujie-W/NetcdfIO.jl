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

Struct to store the groups of a dataset

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
