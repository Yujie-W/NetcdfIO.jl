# extensions to CommonDataModel for Dimensions
dim(ds::NCDataset, dim_name::UnionNameTypes) = nc_inq_dimlen(ds.ncid, nc_inq_dimid(ds.ncid, dim_name));

dimnames(ds::NCDataset) = String[nc_inq_dimname(ds.ncid, dimid) for dimid in nc_inq_dimids(ds.ncid, false)];


# extensions to Base functions for Dimensions
haskey(dims::Dimensions, dim_name::UnionNameTypes) = String(dim_name) in keys(dims);

setindex!(dims::Dimensions, len::Union{Int,AbstractFloat}, dim_name::UnionNameTypes) = (
    # make sure that the file is in define mode
    def_mode!(parent_dataset(dims));
    nc_def_dim(parent_ncid(dims), dim_name, (isinf(len) ? NC_UNLIMITED : len));

    return nothing
);
