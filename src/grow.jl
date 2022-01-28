




function grow_nc_var!(ds::Dataset, var::String, in_data)
    # make sure the data to grow has -1 or the same dimensions as the target, e.g., a 3D dataset can grow with 2D or 3D input
    _dim_ds = length(ds[var]);
    _dim_in = length(in_data);
    @assert _dim_in in [_dim_ds, _dim_ds - 1] "Data to grow must have same or -1 dimensions compared to data in the netcdf file!";

    # if the input data dimension is lower
    if _dim_in < _dim_ds
        if _dim_ds == 1
        end
    end
end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Jan-27: define the function to grow a netcdf file
#
#######################################################################################################################################################################################################
function grow_nc!(file::String, vars_name::Vector{String}, vars_data::Vector; growing_dim::String = "ind") where {T<:Union{AbstractFloat,Int,String}}
    # read a dataset using "a" mode
    _dset = Dataset(file, "a");

    # grow the target dimension

    # make sure the variable in the dataset is growable
    for _var_name in vars_name
        @show typeof(_dset.dim);
        @show typeof(_dset.dim["ind"]);
    end
end
