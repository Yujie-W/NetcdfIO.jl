"""

    create_nc!(file::String)

Create an empty netcdf file, given
- `file` Path to save the netcdf dataset

#
    create_nc!(file::String, dim_names::Vector{String}, dim_sizes::Vector)

Create an empty netcdf file with dimensions, given
- `file` Path to save the netcdf dataset
- `dim_names` Dimension names in the netcdf file
- `dim_sizes` Sizes of the dimensions (must be Integer or Inf), the dimension is growable if size is Integer 0

---
## Examples
```julia
create_nc!("test.nc");
create_nc!("test1.nc", String["lon", "lat", "ind"], [36, 18, 0]);
create_nc!("test2.nc", String["lon", "lat", "ind"], [36, 18, Inf]);
```

"""
function create_nc! end

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


"""

    add_nc_dim!(ds::Dataset, dim_name::String, dim_size::Int)
    add_nc_dim!(ds::Dataset, dim_name::String, dim_size::AbstractFloat)
    add_nc_dim!(file::String, dim_name::String, dim_size::Union{AbstractFloat,Int})

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
add_nc_dim!(ds, "idx", Inf);
close(ds);

add_nc_dim!("test.nc", "lon", 360);
add_nc_dim!("test.nc", "idy", Inf);
```

"""
function add_nc_dim! end

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

add_nc_dim!(ds::Dataset, dim_name::String, dim_size::AbstractFloat) = (
    _size = (dim_size == Inf ? 0 : Int(dim_size));
    add_nc_dim!(ds, dim_name, _size);

    return nothing
);

add_nc_dim!(file::String, dim_name::String, dim_size::Union{AbstractFloat,Int}) = (
    _dset = Dataset(file, "a");
    add_nc_dim!(_dset, dim_name, dim_size);
    close(_dset);

    return nothing
);
