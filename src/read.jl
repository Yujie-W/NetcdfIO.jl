#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Feb-03: add recursive variable query feature
#
#######################################################################################################################################################################################################
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


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Feb-03: add recursive variable query feature
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
#     2022-Feb-04: allow to read value from 1D array as well
# Bug fixes
#     2021-Dec-24: fix the bug that reads integer as float (e.g., ind)
#     2022-Jan-20: add dimension control to avoid errors
#     2023-Jul-25: add option to read any portion of the data
#
#######################################################################################################################################################################################################
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

---
# Examples
```julia
# read data labeled as test from test.nc
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc("test.nc", "test");
data = read_nc(Float32, "test.nc", "test");

# read 1st layer data labeled as test from test.nc
data = read_nc("test.nc", "test", 1);
data = read_nc(Float32, "test.nc", "test", 1);

# read the data (time series) at a grid
save_nc!("test1.nc", "test", rand(36,18), Dict("description" => "Random randoms"));
save_nc!("test2.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data1 = read_nc("test1.nc", "test", 1, 1);
data2 = read_nc("test2.nc", "test", 1, 1);
data1 = read_nc(Float32, "test1.nc", "test", 1, 1);
data2 = read_nc(Float32, "test2.nc", "test", 1, 1);

# read the data at a grid
data = read_nc("test.nc", "test", 1, 1, 1);
data = read_nc(Float32, "test.nc", "test", 1, 1, 1);

# read the data as a DataFrame
df_raw = DataFrame();
df_raw[!,"A"] = rand(5);
df_raw[!,"B"] = rand(5);
df_raw[!,"C"] = rand(5);
save_nc!("test.nc", df_raw);
df_new = read_nc("test.nc");
df_new = read_nc("test.nc", ["A", "B"]);
```

"""
function read_nc end

read_nc(ds::Dataset, var_name::String; transform::Bool = true) = (
    _fvar = find_variable(ds, var_name);
    if isnothing(_fvar)
        @error "$(var_name) does not exist!";
    end;

    if transform
        _dvar = _fvar[:,:];
    else
        _dvar = _fvar.var[:,:];
    end;

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);

read_nc(file::String, var_name::String; transform::Bool = true) = (
    _dset = Dataset(file, "r");
    _dvar = read_nc(_dset, var_name; transform = transform);
    close(_dset);

    return _dvar
);

read_nc(T, ds::Dataset, var_name::String; transform::Bool = true) = T.(read_nc(ds, var_name; transform = transform));

read_nc(T, file::String, var_name::String; transform::Bool = true) = T.(read_nc(file, var_name; transform = transform));

read_nc(ds::Dataset, var_name::String, indz::Int; transform::Bool = true) = (
    _ndim = size_nc(ds, var_name)[1];
    @assert _ndim in [1,3] "The dataset must be a 1D or 3D array to use this method!";

    _fvar = find_variable(ds, var_name);
    if transform
        _dvar = (_ndim == 1 ? _fvar[indz] : _fvar[:,:,indz]);
    else
        _dvar = (_ndim == 1 ? _fvar.var[indz] : _fvar.var[:,:,indz]);
    end;

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);

read_nc(file::String, var_name::String, indz::Int; transform::Bool = true) = (
    _dset = Dataset(file, "r");
    _dvar = read_nc(_dset, var_name, indz; transform = transform);
    close(_dset);

    return _dvar
);

read_nc(T, ds::Dataset, var_name::String, indz::Int; transform::Bool = true) = T.(read_nc(ds, var_name, indz; transform = transform));

read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indz; transform = transform));

read_nc(ds::Dataset, var_name::String, indx::Int, indy::Int; transform::Bool = true) = (
    _ndim = size_nc(ds, var_name)[1];
    @assert 2 <= _ndim <= 3 "The dataset must be a 2D or 3D array to use this method!";

    _fvar = find_variable(ds, var_name);
    if transform
        _dvar = (_ndim==2 ? _fvar[indx,indy] : _fvar[indx,indy,:]);
    else
        _dvar = (_ndim==2 ? _fvar.var[indx,indy] : _fvar.var[indx,indy,:]);
    end;

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);

read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = (
    _dset = Dataset(file, "r");
    _dvar = read_nc(_dset, var_name, indx, indy; transform = transform);
    close(_dset);

    return _dvar
);

read_nc(T, ds::Dataset, var_name::String, indx::Int, indy::Int; transform::Bool = true) = T.(read_nc(ds, var_name, indx, indy; transform = transform));

read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy; transform = transform));

read_nc(ds::Dataset, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = (
    @assert size_nc(ds, var_name)[1] == 3 "The dataset must be a 3D array to use this method!";

    _fvar = find_variable(ds, var_name);
    if transform
        _dvar = _fvar[indx,indy,indz];
    else
        _dvar = _fvar.var[indx,indy,indz];
    end;

    return ismissing(_dvar) ? NaN : _dvar
);

read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = (
    _dset = Dataset(file, "r");
    _dvar = read_nc(_dset, var_name, indx, indy, indz; transform = transform);
    close(_dset);

    return _dvar
);

read_nc(T, ds::Dataset, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = T.(read_nc(ds, var_name, indx, indy, indz; transform = transform));

read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy, indz; transform = transform));

read_nc(file::String, selections::Vector{String} = varname_nc(file); transform::Bool = true) = (
    # open the dataset and get the dimensions
    _dset = Dataset(file, "r");
    _dims = [size_nc(_dset, _var)[1] for _var in selections];
    _lens = [size_nc(_dset, _var)[2][1] for _var in selections];
    @assert all(_dims .== 1) "All variables need to be 1D!";
    @assert all(_lens .== _lens[1]) "Dimensions of the variables need to be the same!";

    # read the data and close the dataset
    df = DataFrame( [Pair(_var, read_nc(_dset, _var; transform = transform)) for _var in selections] );
    close(_dset);

    return df
);

read_nc(file::String, var_name::String, dim_array::Vector; transform::Bool = true) = (
    _dset = Dataset(file, "r");
    _fvar = find_variable(_dset, var_name);
    if transform
        _dvar = _fvar[dim_array...];
    else
        _dvar = _fvar.var[dim_array...];
    end;
    close(_dset);

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);
