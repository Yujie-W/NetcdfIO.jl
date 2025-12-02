# julia implementation of libnetcdf functions
""" Inquire the group ncid of a netcdf dataset (nc_inq_grp_ncid) """
function nc_inq_grp_ncid(ncid::Integer, grp_name::Union{AbstractString,Symbol})
    grp_ncid = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_grp_ncid,NetCDF_jll.libnetcdf), Cint, (Cint,Cstring,Ptr{Cint}), ncid, grp_name, grp_ncid);
    check_status!(ccall_act);

    return grp_ncid[]
end;


""" Inquire the group names of a netcdf dataset (nc_inq_grpname) """
function nc_inq_grpname(ncid::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1);
    ccall_act = ccall((:nc_inq_grpname,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{UInt8}), ncid, name);
    check_status!(ccall_act);

    return unsafe_string(pointer(name))
end;


""" Inquire the group IDs of a netcdf dataset (nc_inq_grps) """
function nc_inq_grps(ncid::Integer)
    numgrpsp = Ref(Cint(0));
    ccall_act = ccall((:nc_inq_grps,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Cint},Ptr{Cint}), ncid, numgrpsp, C_NULL);
    check_status!(ccall_act);
    numgrps = numgrpsp[];
    groupids = Vector{Cint}(undef,numgrps);
    ccall_act = ccall((:nc_inq_grps,NetCDF_jll.libnetcdf), Cint, (Cint,Ptr{Cint},Ptr{Cint}), ncid, numgrpsp, groupids);
    check_status!(ccall_act);

    return groupids
end;
