# extensions to CommonDataModel for Groups
group(ds::NCDataset, grp_name::UnionNameTypes) = NCDataset(nc_inq_grp_ncid(ds.ncid, grp_name), ds.iswritable, ds.isdefmode; parentdataset = ds);

groupnames(ds::NCDataset) = String[nc_inq_grpname(ncid) for ncid in nc_inq_grps(ds.ncid)];


# extensions to Base functions for Groups
getindex(grps::Groups, grp_name::UnionNameTypes) = (
    grp_ncid = nc_inq_grp_ncid(grps.ds.ncid, grp_name);

    return NCDataset(grp_ncid, grps.ds.iswritable, grps.ds.isdefmode; parentdataset = grps.ds)
);

haskey(grps::Groups, grp_name::UnionNameTypes) = String(grp_name) in keys(grps);
