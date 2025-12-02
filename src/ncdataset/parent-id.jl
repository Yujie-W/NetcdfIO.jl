function parent_dataset end;

parent_dataset(ds::NCDataset) = ds;
parent_dataset(var::Variable) = parent_dataset(var.ds);
parent_dataset(attr::Attributes) = parent_dataset(attr.ds);
parent_dataset(dims::Dimensions) = parent_dataset(dims.ds);


function parent_ncid end;

parent_ncid(ds::NCDataset) = ds.ncid;
parent_ncid(var::Variable) = parent_ncid(var.ds);
parent_ncid(attr::Attributes) = parent_ncid(attr.ds);
parent_ncid(dims::Dimensions) = parent_ncid(dims.ds);


function parent_varid end;

parent_varid(ds::NCDataset) = NC_GLOBAL;
parent_varid(var::Variable) = var.varid;
parent_varid(attr::Attributes) = parent_varid(attr.ds);
parent_varid(dims::Dimensions) = parent_varid(dims.ds);
