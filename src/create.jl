#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Jan-27: define the function to create an empty growable netcdf file
#     2022-Jan-27: add documentation and examples
#     2022-Jan-28: add input sizes to signal which dimensions are growable
#
#######################################################################################################################################################################################################
"""

    create_nc!(file::String, dims::Vector{String}, sizes::Vector{Int})

Create an empty netcdf file, given
- `file` Path to save the netcdf dataset
- `dims` Dimension names in the netcdf file
- `sizes` Sizes of the dimensions, the dimension is growable if size is 0

---
# Examples
```julia
create_nc!("test.nc", String["lon", "lat", "ind"], Int[36,18,0]);
```
"""
function create_nc!(file::String, dims::Vector{String}, sizes::Vector{Int})
    @assert length(dims) == length(sizes) "Input dims and sizes must be equally long!";

    # create a dataset using "c" mode
    _dset = Dataset(file, "c");

    # make all dimensions with 0 size growable
    for _i in eachindex(dims)
        _dset.dim[dims[_i]] = (sizes[_i] == 0 ? Inf : sizes[_i]);
    end

    close(_dset);

    return nothing
end
