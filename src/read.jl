"""

    find_variable(ds::Dataset, var_name::String)

Return the path to dataset if it exists, given
- `ds` NCDatasets.Dataset type dataset
- `var_name` Variable to read

"""
function find_variable(ds::Dataset, var_name::String)
    # if var_name is in the current dataset, return it
    if var_name in keys(ds)
        return ds[var_name]
    end;

    # loop through the groups and find the data
    _dvar = nothing;
    for _group in keys(ds.group)
        _dvar = find_variable(ds.group[_group], var_name)
        if !isnothing(_dvar)
            break;
        end;
    end;

    # return the variable if it exists, otherwise return nothing
    return _dvar
end


"""

    read_nc(file::String, var_name::String; transform::Bool = true)
    read_nc(T, file::String, var_name::String; transform::Bool = true)

Read entire data from NC file, given
- `file` Path of the netcdf dataset
- `var_name` Variable to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

#
    read_nc(file::String, var_name::String, indz::Int; transform::Bool = true)
    read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true)

Read a subset from nc file, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indz` The 3rd index of subset data to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

Note that the dataset must be a 1D or 3D array to use this method.

#
    read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)
    read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)

Read the subset data for a grid, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

#
    read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)
    read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)

Read the data at a grid, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `indz` The 3rd index of subset data to read, typically time
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

#
    read_nc(file::String, selections::Vector{String} = varname_nc(file); transform::Bool = true)

Read the selected variables from a netcdf file as a DataFrame, given
- `file` Path of the netcdf dataset
- `selections` Variables to read from the file
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

#
    read_nc(file::String, var_name::String, dim_array::Vector; transform::Bool = true)

Read parts of the data specified in an array
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `dim_array` Vector containing the parts of the data to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

"""
function read_nc end

read_nc(ds::Dataset, var_name::String; transform::Bool = true) = (
    fvar = find_variable(ds, var_name);
    if isnothing(fvar)
        @error "$(var_name) does not exist!";
    end;

    indexes = ntuple(i -> Colon(), ndims(fvar));
    if transform
        dvar = fvar[indexes...];
    else
        dvar = fvar.var[indexes...];
    end;

    if sum(ismissing.(dvar)) == 0
        return dvar
    end;

    return replace(dvar, missing=>NaN)
);

read_nc(file::String, var_name::String; transform::Bool = true) = (
    dset = Dataset(file, "r");
    dvar = read_nc(dset, var_name; transform = transform);
    close(dset);

    return dvar
);

read_nc(T, ds::Dataset, var_name::String; transform::Bool = true) = T.(read_nc(ds, var_name; transform = transform));

read_nc(T, file::String, var_name::String; transform::Bool = true) = T.(read_nc(file, var_name; transform = transform));

read_nc(ds::Dataset, var_name::String, indz::Int; transform::Bool = true) = (
    ndim = size_nc(ds, var_name)[1];
    @assert ndim in [1,3] "The dataset must be a 1D or 3D array to use this method!";

    fvar = find_variable(ds, var_name);
    indexes = (ntuple(i -> Colon(), ndim-1)..., indz);
    if transform
        dvar = fvar[indexes...];
    else
        dvar = fvar.var[indexes...];
    end;

    if sum(ismissing.(dvar)) == 0
        return dvar
    end;

    return replace(dvar, missing=>NaN)
);

read_nc(file::String, var_name::String, indz::Int; transform::Bool = true) = (
    dset = Dataset(file, "r");
    dvar = read_nc(dset, var_name, indz; transform = transform);
    close(dset);

    return dvar
);

read_nc(T, ds::Dataset, var_name::String, indz::Int; transform::Bool = true) = T.(read_nc(ds, var_name, indz; transform = transform));

read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indz; transform = transform));

read_nc(ds::Dataset, var_name::String, indx::Int, indy::Int; transform::Bool = true) = (
    ndim = size_nc(ds, var_name)[1];
    @assert 2 <= ndim <= 3 "The dataset must be a 2D or 3D array to use this method!";

    fvar = find_variable(ds, var_name);
    if transform
        dvar = (ndim==2 ? fvar[indx,indy] : fvar[indx,indy,:]);
    else
        dvar = (ndim==2 ? fvar.var[indx,indy] : fvar.var[indx,indy,:]);
    end;

    if sum(ismissing.(dvar)) == 0
        return dvar
    end;

    return replace(dvar, missing=>NaN)
);

read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = (
    dset = Dataset(file, "r");
    dvar = read_nc(dset, var_name, indx, indy; transform = transform);
    close(dset);

    return dvar
);

read_nc(T, ds::Dataset, var_name::String, indx::Int, indy::Int; transform::Bool = true) = T.(read_nc(ds, var_name, indx, indy; transform = transform));

read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy; transform = transform));

read_nc(ds::Dataset, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = (
    @assert size_nc(ds, var_name)[1] == 3 "The dataset must be a 3D array to use this method!";

    fvar = find_variable(ds, var_name);
    if transform
        dvar = fvar[indx,indy,indz];
    else
        dvar = fvar.var[indx,indy,indz];
    end;

    return ismissing(dvar) ? NaN : dvar
);

read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = (
    dset = Dataset(file, "r");
    dvar = read_nc(dset, var_name, indx, indy, indz; transform = transform);
    close(dset);

    return dvar
);

read_nc(T, ds::Dataset, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = T.(read_nc(ds, var_name, indx, indy, indz; transform = transform));

read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy, indz; transform = transform));

read_nc(file::String, selections::Vector{String} = varname_nc(file); transform::Bool = true) = (
    # open the dataset and get the dimensions
    dset = Dataset(file, "r");
    dims = [size_nc(dset, var)[1] for var in selections];
    lens = [size_nc(dset, var)[2][1] for var in selections];
    @assert all(dims .== 1) "All variables need to be 1D!";
    @assert all(lens .== lens[1]) "Dimensions of the variables need to be the same!";
    # read the data and close the dataset
    df = DataFrame( [Pair(var, read_nc(dset, var; transform = transform)) for var in selections] );
    close(dset);

    return df
);

read_nc(file::String, var_name::String, dim_array::Vector; transform::Bool = true) = (
    dset = Dataset(file, "r");
    fvar = find_variable(dset, var_name);
    if transform
        dvar = fvar[dim_array...];
    else
        dvar = fvar.var[dim_array...];
    end;
    close(dset);

    if sum(ismissing.(dvar)) == 0
        return dvar
    end;

    return replace(dvar, missing=>NaN)
);
