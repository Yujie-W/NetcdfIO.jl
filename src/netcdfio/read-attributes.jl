"""

    read_attributes(ds::Dataset) -> Dict{String, Any}
    read_attributes(file::String) -> Dict{String, Any}
    read_attributes(ds::Dataset, var_name::String) -> Dict{String, Any}
    read_attributes(file::String, var_name::String) -> Dict{String, Any}

Return all the attributes of a NetCDF dataset or variable, given
- `ds` NCDatasets.Dataset type dataset
- `var_name` Variable name
- `file` Path of the netcdf dataset

"""
function read_attributes end

read_attributes(ds::Dataset) = return Dict{String, Any}(k => v for (k, v) in ds.attrib);

read_attributes(file::String) = (
    dset = Dataset(file, "r");
    attrs = read_attributes(dset);
    close(dset);

    return attrs
);

read_attributes(ds::Dataset, var_name::String) = (
    fvar = find_variable(ds, var_name);
    if isnothing(fvar)
        @error "$(var_name) does not exist!";
    end;

    return Dict{String, Any}(k => v for (k, v) in fvar.attrib)
);

read_attributes(file::String, var_name::String) = (
    dset = Dataset(file, "r");
    attrs = read_attributes(dset, var_name);
    close(dset);

    return attrs
);
