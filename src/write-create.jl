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

"""
function create_nc! end

create_nc!(file::String) = (
    # create a dataset using "c" mode
    dset = Dataset(file, "c");

    # global title attribute
    for (attr,note) in ATTR_ABOUT
        dset.attrib[attr] = note;
    end;

    close(dset);

    return nothing
);

create_nc!(file::String, dim_names::Vector{String}, dim_sizes::Vector) = (
    # create a dataset using "c" mode
    dset = Dataset(file, "c");

    # global title attribute
    for (attr,note) in ATTR_ABOUT
        dset.attrib[attr] = note;
    end;

    add_nc_dim!.([dset], dim_names, dim_sizes);

    close(dset);

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
    sizes = (dim_size == Inf ? 0 : Int(dim_size));
    add_nc_dim!(ds, dim_name, sizes);

    return nothing
);

add_nc_dim!(file::String, dim_name::String, dim_size::Union{AbstractFloat,Int}) = (
    dset = Dataset(file, "a");
    add_nc_dim!(dset, dim_name, dim_size);
    close(dset);

    return nothing
);
