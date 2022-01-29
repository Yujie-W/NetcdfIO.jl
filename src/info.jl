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
#     2022-Jan-04: add a short cut function to read the variable names excluding dimension names
#     2022-Jan-28: fix documentation
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
function varname_nc(file::String)
    _dset = Dataset(file, "r");
    _dims = keys(_dset.dim);
    _vars = keys(_dset);
    close(_dset);

    _names = String[];
    for _var in _vars
        if !(_var in _dims)
            push!(_names, _var)
        end
    end

    return _names
end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: add a short cut function to read the size of a dataset
#     2022-Jan-28: move the function from size.jl to info.jl
#     2022-Jan-28: fix documentation
#
#######################################################################################################################################################################################################
"""

    size_nc(file::String, var::String)

Return the dimensions and size of a NetCDF dataset, given
- `file` Path of the netcdf dataset
- `var` Variable name

---
# Examples
```julia
ndims,sizes = size_nc("test.nc", "test");
```
"""
function size_nc(file::String, var::String)
    _dset = Dataset(file, "r");
    _dvar = _dset[var];
    _ndim = ndims(_dvar);
    _size = size(_dvar);
    close(_dset);

    return _ndim, _size
end
