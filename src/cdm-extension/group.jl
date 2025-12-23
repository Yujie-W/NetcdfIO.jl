# extensions to CommonDataModel for Groups
group(ds::NCDataset, groupname::UnionNameTypes) = NCDataset(nc_inq_grp_ncid(ds.ncid, groupname), ds.iswritable, ds.isdefmode; parentdataset = ds);

groupnames(ds::NCDataset) = String[nc_inq_grpname(ncid) for ncid in nc_inq_grps(ds.ncid)];


# extensions to Base functions for Groups
getindex(grps::Groups, name::UnionNameTypes) = (
    grp_ncid = nc_inq_grp_ncid(grps.ds.ncid, name);

    return NCDataset(grp_ncid, grps.ds.iswritable, grps.ds.isdefmode; parentdataset = grps.ds)
);

haskey(grps::Groups, name::UnionNameTypes) = name in keys(grps);
