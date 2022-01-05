"""
    dimname_nc(file::String)

Return all the names of the dimensions, given
- `file` Dataset path

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
    varname_nc(file::String)

Return all the names of the variables (excluding the dimensions), given
- `file` Dataset path

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
