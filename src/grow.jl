#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Jan-27: define the function to create grow netcdf file
#
#######################################################################################################################################################################################################



function growable_nc!(file::String, dims::Vector{String})
    # create a dataset using "c" mode
    _dset = Dataset(file, "c");

    # make all dimensions in dims as growable
    for _dim in dims
        _dset.dim[_dim] = Inf;
    end

    close(_dset);

    return nothing
end





function grow_nc!(file::String, vars_name::Vector{String}, vars_data::Vector) where {T<:Union{AbstractFloat,Int,String}}
    # create a dataset using "c" mode
    _dset = Dataset(file, "a");

    # make sure the variable in the dataset is growable
    for _var_name in vars_name
        @show typeof(_dset.dim);
        @show typeof(_dset.dim["ind"]);
    end
end
