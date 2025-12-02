# julia implementation of libnetcdf functions
""" Close a netcdf dataset (nc_close) """
function nc_close(ncid::Integer)
    ccall_act = ccall((:nc_close,NetCDF_jll.libnetcdf), Cint, (Cint,), ncid);

    return check_status!(ccall_act)
end;


""" Create a new netcdf dataset (nc_create) """
function nc_create(path::AbstractString, cmode::Integer)
    ncidp = Ref(Cint(0));
    ccall_act = ccall((:nc_create,NetCDF_jll.libnetcdf), Cint, (Cstring,Cint,Ptr{Cint}), path, cmode, ncidp);
    check_status!(ccall_act);

    return ncidp[]
end;


""" End define mode for the dataset (nc_enddef) """
function nc_enddef(ncid::Integer)
    ccall_act = ccall((:nc_enddef,NetCDF_jll.libnetcdf), Cint, (Cint,), ncid);

    return check_status!(ccall_act)
end;


""" Inquire the file path of a netcdf dataset (nc_inq_path) """
function nc_inq_path(ncid::Integer)
    pathlenp = Ref(Csize_t(0))
    ccall_act = ccall((:nc_inq_path,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Csize_t},Ptr{UInt8}), ncid, pathlenp, C_NULL);
    check_status!(ccall_act);
    path = zeros(UInt8,pathlenp[]+1);
    ccall_act = ccall((:nc_inq_path,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Csize_t},Ptr{UInt8}), ncid, pathlenp, path);
    check_status!(ccall_act);

    return unsafe_string(pointer(path))
end;


""" Open an existing netcdf dataset (nc_open) """
function nc_open(path::AbstractString, mode::Integer)
    ncidp = Ref(Cint(0));
    dlsym = Base.Libc.Libdl.dlsym(NetCDF_jll.libnetcdf_handle, :nc_open);
    ccall_act = ccall(dlsym, Cint,(Cstring,Cint,Ptr{Cint}),path,mode,ncidp);

    return ccall_act != NC_NOERR ? throw(NetCDFError(ccall_act, "Opening path $(path): $(nc_strerror(ccall_act))")) : ncidp[]
end;


""" Put the dataset into define mode (nc_redef) """
function nc_redef(ncid::Integer)
    ccall_act = ccall((:nc_redef,NetCDF_jll.libnetcdf), Cint, (Cint,), ncid);

    return check_status!(ccall_act)
end;
