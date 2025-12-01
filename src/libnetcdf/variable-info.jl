# julia implementation of libnetcdf functions
""" Inquire the user-defined type information of a netcdf dataset (nc_inq_user_type) """
function nc_inq_user_type(ncid::Integer, xtype::Integer)
    name = Vector{UInt8}(undef,NC_MAX_NAME+1);
    sizep = Ref(Csize_t(0));
    base_nc_typep = Ref(NC_TYPE(0));
    nfieldsp = Ref(Csize_t(0));
    classp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_user_type,NetCDF_jll.libnetcdf), Cint,
                      (Cint,NC_TYPE,Ptr{UInt8},Ptr{Csize_t},Ptr{NC_TYPE},Ptr{Csize_t},Ptr{Cint}), ncid, xtype, name, sizep, base_nc_typep, nfieldsp, classp);
    check_status!(ccall_act);

    return unsafe_string(pointer(name)),sizep[],base_nc_typep[],nfieldsp[],classp[]
end;


""" Inquire the number of attributes of a netcdf variable (nc_inq_varnatts) """
function nc_inq_varnatts(ncid::Integer, varid::Integer)
    nattsp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_varnatts,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,nattsp);
    check_status!(ccall_act);

    return nattsp[]
end;


""" Inquire the variable dimension IDs of a netcdf dataset (nc_inq_vardimid) """
function nc_inq_vardimid(ncid::Integer, varid::Integer)
    ndims = nc_inq_varndims(ncid,varid)
    dimids = zeros(Cint,ndims)
    ccall_act = ccall((:nc_inq_vardimid,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Cint}), ncid, varid, dimids);
    check_status!(ccall_act);

    return dimids
end;


""" Inquire the number of dimensions of a netcdf variable (nc_inq_varndims) """
function nc_inq_varndims(ncid::Integer, varid::Integer)
    ndimsp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_varndims,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Cint}), ncid, varid, ndimsp);
    check_status!(ccall_act);

    return ndimsp[]
end;


""" Inquire the variable ID of a netcdf dataset (nc_inq_varid) """
function nc_inq_varid(ncid::Integer, name::Union{AbstractString,Symbol})
    varidp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_varid,NetCDF_jll.libnetcdf), Cint, (Cint,Cstring,Ptr{Cint}), ncid, name, varidp);

    return (ccall_act == NC_NOERR) ? varidp[] : throw(NetCDFError(ccall_act, "Variable '$name' not found"))
end;


""" Inquire the variable IDs of a netcdf dataset (nc_inq_varids) """
function nc_inq_varids(ncid::Integer)::Vector{Cint}
    dlsym = Base.Libc.Libdl.dlsym(NetCDF_jll.libnetcdf_handle, :nc_inq_varids);

    nvarsp = Ref(Cint(0));
    ccall_act = ccall(dlsym, Cint, (Cint,Ptr{Cint},Ptr{Cint}), ncid, nvarsp, C_NULL);
    check_status!(ccall_act);
    nvars = nvarsp[];
    varids = zeros(Cint, nvars);
    ccall_act = ccall(dlsym, Cint, (Cint,Ptr{Cint},Ptr{Cint}), ncid, nvarsp, varids);
    check_status!(ccall_act);

    return varids
end;


""" Inquire the variable name of a netcdf dataset (nc_inq_varname) """
function nc_inq_varname(ncid::Integer,varid::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1);
    ccall_act = ccall((:nc_inq_varname,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{UInt8}), ncid, varid, cname);
    check_status!(ccall_act);

    return unsafe_string(pointer(cname))
end;


""" Inquire the variable type of a netcdf dataset (nc_inq_vartype) """
function nc_inq_vartype(ncid::Integer,varid::Integer)
    xtypep = Ref(NC_TYPE(0));
    ccall_act = ccall((:nc_inq_vartype,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{NC_TYPE}), ncid, varid, xtypep);
    check_status!(ccall_act);

    return xtypep[]
end;
