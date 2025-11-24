"""

    dimname_nc(file::String)

Return all the names of the dimensions, given
- `file` Path of the netcdf dataset

"""
function dimname_nc(file::String)
    dset = Dataset(file, "r");
    dims = keys(dset.dim);
    close(dset);

    return dims
end


"""

    varname_nc(ds::Dataset)
    varname_nc(file::String)

Return all the names of the variables (excluding the dimensions), given
- `ds` NCDatasets.Dataset type dataset
- `file` Path of the netcdf dataset

"""
function varname_nc end


varname_nc(ds::Dataset) = (
    # read the variables from dataset directly
    vars = [keys(ds)...];

    # loop through the groups
    for grp in keys(ds.group)
        grp_vars = varname_nc(ds.group[grp]);
        vars = [vars...; grp_vars...];
    end;

    return vars
);

varname_nc(file::String) = (
    dset = Dataset(file, "r");
    vars = varname_nc(dset);
    close(dset);

    return vars
);


"""

    size_nc(file::String, var_name::String)

Return the dimensions and size of a NetCDF dataset, given
- `file` Path of the netcdf dataset
- `var_name` Variable name

"""
function size_nc end

size_nc(ds::Dataset, var_name::String) = (
    fvar = find_variable(ds, var_name);
    if isnothing(fvar)
        return error("$(var_name) does not exist in the given dataset!");
    end;

    ndim = ndims(fvar);
    sizes = size(fvar);

    return ndim, sizes
);

size_nc(file::String, var_name::String) = (
    dset = Dataset(file, "r");
    (ndim, sizes) = size_nc(dset, var_name);
    close(dset);

    return ndim, sizes
);
