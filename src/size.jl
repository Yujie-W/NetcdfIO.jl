"""
    size_nc(file::String, var::String)

Return the dimensions and size of a NetCDF dataset, given
- `file` Dataset path
- `var` Variable name

---
# Examples
```julia
ndims,sizes = read_nc("test.nc", "test");
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
