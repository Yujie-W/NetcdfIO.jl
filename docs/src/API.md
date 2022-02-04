# API
```@meta
CurrentModule = NetcdfIO
```


## Create netcdf file
```@docs
create_nc!
create_nc!(file::String)
create_nc!(file::String, dim_names::Vector{String}, dim_sizes::Vector)
add_nc_dim!
add_nc_dim!(ds::Dataset, dim_name::String, dim_size::Int)
add_nc_dim!(ds::Dataset, dim_name::String, dim_size::AbstractFloat)
add_nc_dim!(file::String, dim_name::String, dim_size::Union{Int, AbstractFloat})
```


## Append new variables
```@docs
append_nc!
append_nc!(ds::Dataset, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}
append_nc!(file::String, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}
```


## Grow existing variables
```@docs
grow_nc!
grow_nc!(ds::Dataset, var_name::String, in_data::Union{AbstractFloat,Array,Int,String}, pending::Bool)
grow_nc!(file::String, var_name::String, in_data::Union{AbstractFloat,Array,Int,String}, pending::Bool)
```


## Information of the dataset
```@docs
dimname_nc
varname_nc
varname_nc(file::String)
varname_nc(ds::Dataset)
size_nc
```


## Read existing variables
```@docs
find_variable
read_nc
read_nc(file::String, var_name::String; transform::Bool = true)
read_nc(T, file::String, var_name::String; transform::Bool = true)
read_nc(file::String, var_name::String, indz::Int; transform::Bool = true)
read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true)
read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)
read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)
read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)
read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)
read_nc(file::String, selections::Vector{String} = varname_nc(file); transform::Bool = true)
```


## Quick save
```@docs
save_nc!
save_nc!(file::String, var_name::String, var_data::Array{T,N}, var_attribute::Dict{String,String}; compress::Int = 4, growable::Bool = false) where {T<:Union{AbstractFloat,Int,String},N}
save_nc!(file::String, df::DataFrame, var_names::Vector{String}, var_attributes::Vector{Dict{String,String}}; compress::Int = 4, growable::Bool = false)
save_nc!(file::String, df::DataFrame; compress::Int = 4, growable::Bool = false)
```
