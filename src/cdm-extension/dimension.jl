# extensions to CommonDataModel for Dimensions
dim(ds::NCDataset, name::UnionNameTypes) = nc_inq_dimlen(ds.ncid, nc_inq_dimid(ds.ncid, name));

dimnames(ds::NCDataset) = String[nc_inq_dimname(ds.ncid, dimid) for dimid in nc_inq_dimids(ds.ncid, false)];


# extensions to Base functions for Dimensions
haskey(dims::Dimensions, name::UnionNameTypes) = name in keys(dims);

setindex!(dims::Dimensions, len::Union{Int,AbstractFloat}, name::UnionNameTypes) = (
    # make sure that the file is in define mode
    def_mode!(parent_dataset(dims));
    nc_def_dim(parent_ncid(dims), name, (isinf(len) ? NC_UNLIMITED : len));

    return nothing
);
