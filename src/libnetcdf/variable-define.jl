# julia implementation of libnetcdf functions
""" Define a variable in a netcdf dataset """
function nc_def_var(ncid::Integer, name::Union{AbstractString,Symbol}, xtype::Integer, dimids::Vector{Cint})
    varidp = Ref(Cint(0));
    ccall_act = ccall((:nc_def_var,NetCDF_jll.libnetcdf), Cint, (Cint,Cstring,NC_TYPE,Cint,Ptr{Cint},Ptr{Cint}), ncid, name, xtype, length(dimids), dimids, varidp);
    check_status!(ccall_act);

    return varidp[]
end;


""" Define variable compression settings in a netcdf dataset """
function nc_def_var_deflate(ncid::Integer,varid::Integer,shuffle::Bool,deflate::Integer,deflate_level::Integer)
    ccall_act =  ccall((:nc_def_var_deflate,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cint,Cint,Cint), ncid, varid, shuffle, deflate, deflate_level);

    return check_status!(ccall_act)
end;
