""" Julia representation of the C struct nc_vlen_t """
struct VariableLength{T}
    "Length of the variable-length data"
    len::Csize_t
    "Pointer to the variable-length data"
    p::Ptr{T}
end;

convert(::Type{Array{VariableLength{T},N}}, data::Array{Vector{T},N}) where {T,N} = (
    tmp = Array{VariableLength{T},N}(undef,size(data));

    for (i,d) in enumerate(data)
        tmp[i] = VariableLength{T}(length(d), pointer(d))
    end;

    return tmp
);


# julia implementation of libnetcdf functions
""" Define a variable-length type in a netcdf dataset (nc_def_vlen) """
function nc_def_vlen(ncid::Integer, name::Union{AbstractString,Symbol}, base_typeid::Integer)
    xtypep = Ref(NC_TYPE(0));
    ccall_act = ccall((:nc_def_vlen,NetCDF_jll.libnetcdf), Cint, (Cint,Cstring,NC_TYPE,Ptr{NC_TYPE}), ncid, name, base_typeid, xtypep);
    check_status!(ccall_act);

    return xtypep[]
end;


""" Free an array of VariableLength """
function nc_free_vlen(vl::VariableLength{T}) where {T}
    ccall_act = ccall((:nc_free_vlen,NetCDF_jll.libnetcdf), Cint, (Ptr{VariableLength{T}},), Ref(vl));

    return check_status!(ccall_act)
end;
