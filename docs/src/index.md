# NetcdfIO.jl
```@meta
CurrentModule = NetcdfIO
```

Functions to read and write netcdf files. The core functions to read data from netcdf files is adapted from an old version of [`NCDatasets.jl`](https://github.com/JuliaGeo/NCDatasets.jl). Some convenient features have been added, for example, one can read the dataset without diving into the nested structure of dataset/group/variable, with the use of `find_variable` function which detect the variable name recursively.

## Installation
```julia
julia> using Pkg;
julia> Pkg.add("NetcdfIO");
```

## Read the general information
```@docs
dimname_nc
varname_nc
size_nc
read_attributes
```

## Read the variable
```@docs
find_variable
read_nc
```

## Write to a new file
```@docs
create_nc!
add_nc_dim!
append_nc!
```

## Add new data to unlimited dim
```@docs
grow_nc!
```

## Automatic attribute detection (for global data)
```@docs
save_nc!
detect_attribute
```

## Support to HDF4
```@docs
switch_netcdf_lib!
```
