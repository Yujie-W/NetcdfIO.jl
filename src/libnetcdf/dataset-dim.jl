# julia implementation of libnetcdf functions
""" Define the dimension with a netcdf dataset """
function nc_def_dim(ncid::Integer, name::Union{AbstractString,Symbol}, len::Integer)
    idp = Ref(Cint(0));
    ccall_act = ccall((:nc_def_dim,NetCDF_jll.libnetcdf), Cint, (Cint,Cstring,Cint,Ptr{Cint}), ncid, name, len, idp);
    check_status!(ccall_act);

    return idp[]
end


""" Inquire the dimension ID of a netcdf dataset (nc_inq_dimid) """
function nc_inq_dimid(ncid::Integer, name::Union{AbstractString,Symbol})
    dimidp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_dimid,NetCDF_jll.libnetcdf), Cint, (Cint,Cstring,Ptr{Cint}), ncid, name, dimidp);
    check_status!(ccall_act);

    return dimidp[]
end;


""" Inquire the dimension IDs of a netcdf dataset (nc_inq_dimids) """
function nc_inq_dimids(ncid::Integer, include_parents::Bool)
    ndimsp = Ref(Cint(0));
    ndims = nc_inq_ndims(ncid);
    dimids = Vector{Cint}(undef,ndims);
    ccall_act = ccall((:nc_inq_dimids,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Cint},Ptr{Cint},Cint), ncid, ndimsp, dimids, include_parents);
    check_status!(ccall_act);

    return dimids
end;


""" Inquire the dimension length of a netcdf dataset (nc_inq_dimlen) """
function nc_inq_dimlen(ncid::Integer,dimid::Integer)
    lengthp = Ref(Csize_t(0));
    ccall_act = ccall((:nc_inq_dimlen,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t}), ncid, dimid, lengthp);
    check_status!(ccall_act);

    return Int(lengthp[])
end;

``
""" Inquire the dimension name of a netcdf dataset (nc_inq_dimname) """
function nc_inq_dimname(ncid::Integer, dimid::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1);
    ccall_act = ccall((:nc_inq_dimname,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{UInt8}), ncid, dimid, cname);
    check_status!(ccall_act);

    return unsafe_string(pointer(cname))
end;


""" Inquire the number of dimensions in a netcdf dataset (nc_inq_ndims) """
function nc_inq_ndims(ncid::Integer)
    ndimsp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_ndims,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Cint}), ncid, ndimsp);
    check_status!(ccall_act);

    return ndimsp[]
end;


""" Inquire the unlimited dimension IDs of a netcdf dataset (nc_inq_unlimdims) """
function nc_inq_unlimdims(ncid::Integer)
    nunlimdimsp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_unlimdims,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Cint},Ptr{Cint}), ncid, nunlimdimsp, C_NULL);
    check_status!(ccall_act);
    unlimdimids = Vector{Cint}(undef,nunlimdimsp[]);
    ccall_act = ccall((:nc_inq_unlimdims,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Cint},Ptr{Cint}), ncid, nunlimdimsp, unlimdimids);
    check_status!(ccall_act);

    return unlimdimids
end;
