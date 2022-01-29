#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2022-Jan-28: add general function create_nc! for multiple dispatch
#     2022-Jan-28: add documentation
#
#######################################################################################################################################################################################################
"""
This function creates a netcdf file, and the supported methods are

$(METHODLIST)

"""
function create_nc! end


#######################################################################################################################################################################################################
#
# Changes to this method
# General
#     2022-Jan-28: add the basic function to create an empty netcdf file
#     2022-Jan-28: add documentation
#     2022-Jan-28: add global attributes to the generated file
#
#######################################################################################################################################################################################################
"""

    create_nc!(file::String)

Create an empty netcdf file, given
- `file` Path to save the netcdf dataset

---
# Examples
```julia
create_nc!("test.nc");
```
"""
create_nc!(file::String) = (
    # create a dataset using "c" mode
    _dset = Dataset(file, "c");

    # global title attribute
    for (_title,_notes) in ATTR_ABOUT
        _dset.attrib[_title] = _notes;
    end;

    close(_dset);

    return nothing
);


#######################################################################################################################################################################################################
#
# Changes to the method
# General
#     2022-Jan-27: define the function to create an empty growable netcdf file
#     2022-Jan-27: add documentation and examples
#     2022-Jan-28: add input sizes to signal which dimensions are growable
#     2022-Jan-28: add global attributes to the generated file
#
#######################################################################################################################################################################################################
"""

    create_nc!(file::String, dim_names::Vector{String}, dim_sizes::Vector)

Create an empty netcdf file with dimensions, given
- `file` Path to save the netcdf dataset
- `dim_names` Dimension names in the netcdf file
- `dim_sizes` Sizes of the dimensions (must be Integer or Inf), the dimension is growable if size is Integer 0

---
# Examples
```julia
create_nc!("test1.nc", String["lon", "lat", "ind"], [36, 18, 0]);
create_nc!("test2.nc", String["lon", "lat", "ind"], [36, 18, Inf]);
```
"""
create_nc!(file::String, dim_names::Vector{String}, dim_sizes::Vector) = (
    # create a dataset using "c" mode
    _dset = Dataset(file, "c");

    # global title attribute
    for (_title,_notes) in ATTR_ABOUT
        _dset.attrib[_title] = _notes;
    end;

    add_nc_dim!.([_dset], dim_names, dim_sizes);

    close(_dset);

    return nothing
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2022-Jan-28: add general function add_nc_dim! for multiple dispatch
#     2022-Jan-28: add documentation
#
#######################################################################################################################################################################################################
"""
This function adds dim name and size information to netcdf file, and the supported methods are

$(METHODLIST)

"""
function add_nc_dim! end


#######################################################################################################################################################################################################
#
# Changes to the method
# General:
#     2022-Jan-28: add method to add dim information to Dataset using Int
#     2022-Jan-28: add documentation
#     2022-Jan-28: remove nested if else statement
#
#######################################################################################################################################################################################################
"""

    add_nc_dim!(ds::Dataset, dim_name::String, dim_size::Int)

Add dimension information to netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `dim_name` Dimension name
- `dim_size` Integer dimension size (0 for Inf, growable)

---
# Examples
```julia
ds = Dataset("test.nc", "a");
add_nc_dim!(ds, "lat", 180);
add_nc_dim!(ds, "ind", 0);
close(ds);
```
"""
add_nc_dim!(ds::Dataset, dim_name::String, dim_size::Int) = (
    # if dim exists already, do nothing
    if dim_name in keys(ds.dim)
        @warn "Dimension $(dim_name) exists already, do nothing...";

        return nothing
    end;

    # if dim does not exist, define the dimension (0 for unlimited)
    ds.dim[dim_name] = (dim_size == 0 ? Inf : dim_size);

    return nothing
);


#######################################################################################################################################################################################################
#
# Changes to the method
# General:
#     2022-Jan-28: add method to add dim information to Dataset using Inf
#     2022-Jan-28: add documentation
#     2022-Jan-28: call the method for Int rather rather than duplicating the code
#
#######################################################################################################################################################################################################
"""

    add_nc_dim!(ds::Dataset, dim_name::String, dim_size::AbstractFloat)

Add dimension information to netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `dim_name` Dimension name
- `dim_size` Float dimension size, can be Inf

---
# Examples
```julia
ds = Dataset("test.nc", "a");
add_nc_dim!("test.nc", "ind", Inf);
close(ds);
```
"""
add_nc_dim!(ds::Dataset, dim_name::String, dim_size::AbstractFloat) = (
    _size = (dim_size == Inf ? 0 : Int(dim_size));
    add_nc_dim!(ds, dim_name, _size);

    return nothing
);


#######################################################################################################################################################################################################
#
# Changes to the method
# General:
#     2022-Jan-28: add method to add dim information to file directly
#     2022-Jan-28: add documentation
#
#######################################################################################################################################################################################################
"""

    add_nc_dim!(file::String, dim_name::String, dim_size::Union{Int, AbstractFloat})

Add dimension information to netcdf file, given
- `file` Path of the netcdf dataset
- `dim_name` Dimension name
- `dim_size` Dimension size, must be Inf or Integer

---
# Examples
```julia
add_nc_dim!("test.nc", "lat", 180);
add_nc_dim!("test.nc", "ind", Inf);
```
"""
add_nc_dim!(file::String, dim_name::String, dim_size::Union{Int, AbstractFloat}) = (
    _dset = Dataset(file, "a");
    add_nc_dim!(_dset, dim_name, dim_size);
    close(_dset);

    return nothing
);
