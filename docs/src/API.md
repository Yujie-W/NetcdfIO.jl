# API
```@meta
CurrentModule = NetcdfIO
```


## Read variable size from netcdf
```@docs
size_nc
```


## Read variable from netcdf
```@docs
read_nc
read_nc(file::String, var::String)
read_nc(T, file::String, var::String)
read_nc(file::String, var::String, indz::Int)
read_nc(T, file::String, var::String, indz::Int)
read_nc(file::String, var::String, indx::Int, indy::Int)
read_nc(T, file::String, var::String, indx::Int, indy::Int)
read_nc(file::String, var::String, indx::Int, indy::Int, indz::Int)
read_nc(T, file::String, var::String, indx::Int, indy::Int, indz::Int)
```


## Save variable to netcdf
```@docs
save_nc!
save_nc!(file::String, var_name::String, var_attr::Dict{String,String}, var_data::Array{T,N}, atts_name::Vector{String}, atts_attr::Vector{Dict{String,String}}, atts_data::Vector{Vector},
    notes::Dict{String,String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}
save_nc!(file::String, var_name::String, var_attr::Dict{String,String}, var_data::Array{T,N}; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}
save_nc!(file::String, var_names::Vector{String}, var_attrs::Vector{Dict{String,String}}, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4)
save_nc!(file::String, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4)
```


## Append variable to netcdf
```@docs
append_nc!
append_nc!(file::String, var_name::String, var_attr::Dict{String,String}, var_data::Array{FT,N}, atts_name::Vector{String}, atts_attr::Vector{Dict{String,String}}, atts_data::Vector; compress::Int =
    4) where {FT<:AbstractFloat,N}
```
