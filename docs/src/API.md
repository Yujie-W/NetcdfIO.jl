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
```
