"""

    dimname_nc(file::String)

Return all the names of the dimensions, given
- `file` Path of the netcdf dataset

---
# Examples
```julia
dims = dimname_nc("test.nc");
```

"""
function dimname_nc(file::String)
    _dset = Dataset(file, "r");
    _dims = keys(_dset.dim);
    close(_dset);

    return _dims
end


"""

    varname_nc(ds::Dataset)
    varname_nc(file::String)

Return all the names of the variables (excluding the dimensions), given
- `ds` NCDatasets.Dataset type dataset
- `file` Path of the netcdf dataset

---
# Examples
```julia
dset = Dataset("test.nc");
vars = varname_nc(dset);
close(dset);

vars = varname_nc("test.nc");
```
"""
function varname_nc end


varname_nc(ds::Dataset) = (
    _vars = String[];

    # read the variables from dataset directly
    _vars = [_vars...; keys(ds)...];

    # loop through the groups
    for _group in keys(ds.group)
        _group_vars = varname_nc(ds.group[_group]);
        _vars = [_vars...; _group_vars...];
    end;

    return _vars
);

varname_nc(file::String) = (
    _dset = Dataset(file, "r");
    _vars = varname_nc(_dset);
    close(_dset);

    return _vars
);


"""

    size_nc(file::String, var_name::String)

Return the dimensions and size of a NetCDF dataset, given
- `file` Path of the netcdf dataset
- `var_name` Variable name

---
# Examples
```julia
ndims,sizes = size_nc("test.nc", "test");
```
"""
function size_nc end

size_nc(ds::Dataset, var_name::String) = (
    _fvar = find_variable(ds, var_name);
    if isnothing(_fvar)
        return error("$(var_name) does not exist in the given dataset!");
    end;

    _ndim = ndims(_fvar);
    _size = size(_fvar);

    return _ndim, _size
);

size_nc(file::String, var_name::String) = (
    _dset = Dataset(file, "r");
    (_ndim,_size) = size_nc(_dset, var_name);
    close(_dset);

    return _ndim, _size
);
