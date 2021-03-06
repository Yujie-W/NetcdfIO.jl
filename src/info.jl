#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Jan-04: add a short cut function to read the dimension names
#     2022-Jan-28: fix documentation
#
#######################################################################################################################################################################################################
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


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Feb-03: abstractize the function to read the variable names recursively
#
#######################################################################################################################################################################################################
"""
This function returns the variable names in the netcdf dataset, and the supported methids are

$(METHODLIST)

"""
function varname_nc end


#######################################################################################################################################################################################################
#
# Changes to the method
# General
#     2022-Jan-04: add a short cut function to read the variable names excluding dimension names
#     2022-Jan-28: fix documentation
#     2022-Feb-03: remove dimension name control
#
#######################################################################################################################################################################################################
"""

    varname_nc(file::String)

Return all the names of the variables (excluding the dimensions), given
- `file` Path of the netcdf dataset

---
# Examples
```julia
vars = varname_nc("test.nc");
```
"""
varname_nc(file::String) = (
    _dset = Dataset(file, "r");
    _vars = varname_nc(_dset);
    close(_dset);

    return _vars
);


#######################################################################################################################################################################################################
#
# Changes to the method
# General
#     2022-Feb-03: add recursive variable query feature
#
#######################################################################################################################################################################################################
"""

    varname_nc(ds::Dataset)

Return all the names of the variables (excluding the dimensions), given
- `ds` NCDatasets.Dataset type dataset

---
# Examples
```julia
dset = Dataset("test.nc");
vars = varname_nc(dset);
close(dset);
```
"""
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


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: add a short cut function to read the size of a dataset
#     2022-Jan-28: move the function from size.jl to info.jl
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add recursive variable query feature
#
#######################################################################################################################################################################################################
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
function size_nc(file::String, var_name::String)
    _dset = Dataset(file, "r");

    _fvar = find_variable(_dset, var_name);
    if _fvar === nothing
        close(_dset)
        return error("$(var_name) does not exist in $(file)!");
    end;

    _ndim = ndims(_fvar);
    _size = size(_fvar);
    close(_dset);

    return _ndim, _size
end
