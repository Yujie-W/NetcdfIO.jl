"""

    read_dimnames(file::String)

Return all the names of the dimensions, given
- `file` Path of the netcdf dataset

"""
function read_dimnames(file::String)
    dset = Dataset(file, "r");
    dims = keys(dset.dim);
    close(dset);

    return dims
end


"""

    read_varnames(ds::Dataset)
    read_varnames(file::String)

Return all the names of the variables (excluding the dimensions), given
- `ds` NCDatasets.Dataset type dataset
- `file` Path of the netcdf dataset

"""
function read_varnames end

read_varnames(ds::Dataset) = (
    # read the variables from dataset directly
    vars = [keys(ds)...];

    # loop through the groups
    for grp in keys(ds.group)
        grp_vars = read_varnames(ds.group[grp]);
        vars = [vars...; grp_vars...];
    end;

    return vars
);

read_varnames(file::String) = (
    dset = Dataset(file, "r");
    vars = read_varnames(dset);
    close(dset);

    return vars
);


"""

    read_dims(file::String, var_name::UnionNameTypes)

Return the dimensions and size of a NetCDF dataset, given
- `file` Path of the netcdf dataset
- `var_name` Variable name

"""
function read_dims end

read_dims(ds::Dataset, var_name::UnionNameTypes) = (
    fvar = find_variable(ds, var_name);
    if isnothing(fvar)
        return error("$(var_name) does not exist in the given dataset!");
    end;

    ndim = ndims(fvar);
    sizes = size(fvar);

    return ndim, sizes
);

read_dims(file::String, var_name::UnionNameTypes) = (
    dset = Dataset(file, "r");
    (ndim, sizes) = read_dims(dset, var_name);
    close(dset);

    return ndim, sizes
);
