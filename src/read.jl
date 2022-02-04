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
        if _dvar !== nothing
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
#     2022-Jan-28: fix documentation
#
#######################################################################################################################################################################################################
"""
NCDatasets.jl and NetCDF.jl both provide function to read data out from NC dataset. However, while NetCDF.jl is more convenient to use (less lines of code to read data), NCDatasets.jl is better to
    read a subset from the dataset and is able to detect the scale factor and offset. Here, we used a wrapper function to read NC dataset using NCDatasets.jl:

$(METHODLIST)

"""
function read_nc end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add recursive variable query feature
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
# Bug fixes
#     2021-Dec-24: fix the bug that reads integer as float (e.g., ind)
#
#######################################################################################################################################################################################################
"""
When only file name and variable label are provided, `read_nc` function reads out all the data:

    read_nc(file::String, var_name::String; transform::Bool = true)

Read data from NC file, given
- `file` Path of the netcdf dataset
- `var_name` Variable to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

Note that the missing data will be labeled as NaN.

---
# Examples
```julia
# read data labeled as test from test.nc
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc("test.nc", "test");
```
"""
read_nc(file::String, var_name::String; transform::Bool = true) = (
    _dset = Dataset(file, "r");

    _fvar = find_variable(_dset, var_name);
    if _fvar === nothing
        close(_dset)
        @error "$(var_name) does not exist in $(file)!";
    end;

    if transform
        _dvar = _fvar[:,:];
    else
        _dvar = _fvar.var[:,:];
    end;
    close(_dset);

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
#
#######################################################################################################################################################################################################
"""
If a float type is given, the data will be converted to T, namely the output will be an array of T type numbers:

    read_nc(T, file::String, var_name::String; transform::Bool = true)

Read data from nc file, given
- `T` Number type
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

---
# Examples
```julia
# read data labeled as test from test.nc as Float32
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc(Float32, "test.nc", "test");
```
"""
read_nc(T, file::String, var_name::String; transform::Bool = true) = T.(read_nc(file, var_name; transform = transform));


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add recursive variable query feature
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
#     2022-Feb-04: allow to read value from 1D array as well
# Bug fixes
#     2021-Dec-24: fix the bug that reads integer as float (e.g., ind)
#     2022-Jan-20: add dimension control to avoid errors
#
#######################################################################################################################################################################################################
"""
In many cases, the NC dataset can be very huge, and reading all the data points into one array could be time and memory consuming. In this case, reading a subset of data would be the best option:

    read_nc(file::String, var_name::String, indz::Int; transform::Bool = true)

Read a subset from nc file, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indz` The 3rd index of subset data to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

Note that the dataset must be a 3D array to use this method.

---
# Examples
```julia
# read 1st layer data labeled as test from test.nc
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc("test.nc", "test", 1);
```
"""
read_nc(file::String, var_name::String, indz::Int; transform::Bool = true) = (
    _ndim = size_nc(file, var_name)[1];
    @assert _ndim in [1,3] "The dataset must be a 1D or 3D array to use this method!";

    _dset = Dataset(file, "r");
    _fvar = find_variable(_dset, var_name);
    if transform
        _dvar = (_ndim == 1 ? _fvar[indz] : _fvar[:,:,indz]);
    else
        _dvar = (_ndim == 1 ? _fvar.var[indz] : _fvar.var[:,:,indz]);
    end;
    close(_dset);

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
#
#######################################################################################################################################################################################################
"""
Similarly, one may want to read the subset as a certain type using

    read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true)

Read a subset from nc file, given
- `T` Number type
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indz` The 3rd index of subset data to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

---
# Examples
```julia
# read 1st layer data labeled as test from test.nc as Float32
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc(Float32, "test.nc", "test", 1);
```
"""
read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indz; transform = transform));


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add recursive variable query feature
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
# Bug fixes
#     2021-Dec-24: fix the bug that reads integer as float (e.g., ind)
#     2022-Jan-20: add dimension control to avoid errors
#
#######################################################################################################################################################################################################
"""
Another convenient wrapper is to read all the data for given index in x and y, for example, if one wants to read the time series of data at a given site:

    read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)

Read the time series of data for a site, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

---
# Examples
```julia
save_nc!("test1.nc", "test", rand(36,18), Dict("description" => "Random randoms"));
save_nc!("test2.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data1 = read_nc("test1.nc", "test", 1, 1);
data2 = read_nc("test2.nc", "test", 1, 1);
```
"""
read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = (
    _ndim = size_nc(file, var_name)[1];
    @assert 2 <= _ndim <= 3 "The dataset must be a 2D or 3D array to use this method!";

    _dset = Dataset(file, "r");
    _fvar = find_variable(_dset, var_name);
    if transform
        _dvar = (_ndim==2 ? _fvar[indx,indy] : _fvar[indx,indy,:]);
    else
        _dvar = (_ndim==2 ? _fvar.var[indx,indy] : _fvar.var[indx,indy,:]);
    end;
    close(_dset);

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
#
#######################################################################################################################################################################################################
"""
Similarly, one may want to read the subset as a certain type using

    read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)

Read the time series of data for a site, given
- `T` Number type
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

---
# Examples
```julia
save_nc!("test1.nc", "test", rand(36,18), Dict("description" => "Random randoms"));
save_nc!("test2.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data1 = read_nc(Float32, "test1.nc", "test", 1, 1);
data2 = read_nc(Float32, "test2.nc", "test", 1, 1);
```
"""
read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy; transform = transform));


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add recursive variable query feature
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
# Bug fixes
#     2021-Dec-24: fix the bug that reads integer as float (e.g., ind)
#     2022-Jan-20: add dimension control to avoid errors
#
#######################################################################################################################################################################################################
"""
Another convenient wrapper is to read the data for given index in x, y, and z, for example, if one wants to read the time series of data at a given site:

    read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)

Read the time series of data for a site, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `indz` The 3rd index of subset data to read, typically time
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

---
# Examples
```julia
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc("test.nc", "test", 1, 1, 1);
```
"""
read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = (
    @assert size_nc(file, var_name)[1] == 3 "The dataset must be a 3D array to use this method!";

    _dset = Dataset(file, "r");
    _fvar = find_variable(_dset, var_name);
    if transform
        _dvar = _fvar[indx,indy,indz];
    else
        _dvar = _fvar.var[indx,indy,indz];
    end;
    close(_dset);

    return ismissing(_dvar) ? NaN : _dvar
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
#
#######################################################################################################################################################################################################
"""
Similarly, one may want to read the data as a certain type using

    read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)

Read the time series of data for a site, given
- `T` Number type
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `indz` The 3rd index of subset data to read, typically time
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

---
# Examples
```julia
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc(Float32, "test.nc", "test", 1, 1, 1);
```
"""
read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy, indz; transform = transform));


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Jan-04: add this function to read netcdf as DataFrame
#     2022-Jan-28: fix documentation
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
# Bug fixes
#     2021-Dec-24: fix the bug that reads integer as float (e.g., ind)
#
#######################################################################################################################################################################################################
"""
The method below reads all the 1D data (with the same length) into a DataFrame

    read_nc(file::String, selections::Vector{String} = varname_nc(file); transform::Bool = true)

Read the selected variables from a netcdf file as a DataFrame, given
- `file` Path of the netcdf dataset
- `selections` Variables to read from the file
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data

---
# Examples
```julia
df_raw = DataFrame();
df_raw[!,"A"] = rand(5);
df_raw[!,"B"] = rand(5);
df_raw[!,"C"] = rand(5);
save_nc!("test.nc", df_raw);
df_new = read_nc("test.nc");
df_new = read_nc("test.nc", ["A", "B"]);
```
"""
read_nc(file::String, selections::Vector{String} = varname_nc(file); transform::Bool = true) = (
    _dims = [size_nc(file, _var)[1] for _var in selections];
    _lens = [size_nc(file, _var)[2][1] for _var in selections];
    @assert all(_dims .== 1) "All variables need to be 1D!";
    @assert all(_lens .== _lens[1]) "Dimensions of the variables need to be the same!";

    return DataFrame( [Pair(_var, read_nc(file, _var; transform = transform)) for _var in selections] )
);
