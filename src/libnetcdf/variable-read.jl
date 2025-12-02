""" Read data from a NetCDF variable into a Julia array (calling nc_get_var) """
function nc_get_var! end;

nc_get_var!(ncid::Integer, varid::Integer, ip) = (
    ccall_act = ccall((:nc_get_var,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Nothing}), ncid, varid, ip);

    return check_status!(ccall_act)
);

nc_get_var!(ncid::Integer, varid::Integer, ip::Array{Char,N}) where {N} = (
    tmp = Array{UInt8,N}(undef,size(ip));
    nc_get_var!(ncid, varid, tmp);
    ip .= convert.(Char, tmp);

    return nothing
);

nc_get_var!(ncid::Integer, varid::Integer, ip::Array{String,N}) where {N} = (
    tmp = Array{Ptr{UInt8},N}(undef,size(ip));
    nc_get_var!(ncid, varid, tmp);
    for i in eachindex(tmp)
        ip[i] = unsafe_string(tmp[i]);
    end;

    return nothing
);

nc_get_var!(ncid::Integer,varid::Integer,ip::Array{Vector{T},N}) where {T,N} = (
    tmp = Array{VariableLength{T},N}(undef,size(ip));
    nc_get_var!(ncid, varid, tmp);

    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T}, tmp[i].p, (tmp[i].len,));
    end;

    return nothing
);


""" Read a single value from a NetCDF variable (nc_get_var1) """
function nc_get_var1 end;

nc_get_var1(::Type{Char}, ncid::Integer, varid::Integer, indexp) = (
    tmp = Ref(UInt8(0));
    ccall_act = ccall((:nc_get_var1,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Nothing}), ncid, varid, indexp, tmp);
    check_status!(ccall_act);

    return Char(tmp[])
);

nc_get_var1(::Type{String}, ncid::Integer, varid::Integer, indexp) = (
    tmp = Ref(Ptr{UInt8}(0));
    ccall_act = ccall((:nc_get_var1_string,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Ptr{UInt8}}), ncid, varid, indexp, tmp);
    check_status!(ccall_act);

    return unsafe_string(tmp[])
);

nc_get_var1(::Type{T}, ncid::Integer, varid::Integer, indexp) where {T} = (
    ip = Ref{T}();
    ccall_act = ccall((:nc_get_var1,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Nothing}), ncid, varid, indexp, ip);
    check_status!(ccall_act);

    return ip[]
);

nc_get_var1(::Type{Vector{T}},ncid::Integer,varid::Integer,indexp) where {T} = (
    ip = Ref(VariableLength{T}(zero(T),Ptr{T}()));
    ccall_act = ccall((:nc_get_var1,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Nothing}), ncid, varid, indexp, ip);
    check_status!(ccall_act);
    data = copy(unsafe_wrap(Vector{T},ip[].p,(ip[].len,)));
    nc_free_vlen(ip[]);

    return data
);


""" Read data from a NetCDF variable into a Julia array (calling nc_get_vara) """
function nc_get_vara! end;

nc_get_vara!(ncid::Integer, varid::Integer, startp, countp, ip) = (
    ccall_act = ccall((:nc_get_vara,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Nothing}), ncid, varid, startp, countp, ip);

    return check_status!(ccall_act)
);

nc_get_vara!(ncid::Integer, varid::Integer, startp, countp, ip::Array{Char,N}) where N = (
    tmp = Array{UInt8,N}(undef,size(ip));
    nc_get_vara!(ncid, varid, startp, countp, tmp);
    ip .= convert.(Char, tmp);

    return nothing
);

nc_get_vara!(ncid::Integer, varid::Integer, startp, countp, ip::Array{String,N}) where N = (
    tmp = Array{Ptr{UInt8},N}(undef,size(ip));
    nc_get_vara!(ncid, varid, startp, countp, tmp);
    for i in eachindex(tmp)
        ip[i] = unsafe_string(tmp[i]);
    end;

    return nothing
);

nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip::Array{Vector{T},N}) where {T,N} = (
    tmp = Array{VariableLength{T},N}(undef,size(ip));
    nc_get_vara!(ncid, varid, startp, countp, tmp);
    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T}, tmp[i].p, (tmp[i].len,));
    end;

    return nothing
);


""" Read data from a NetCDF variable into a Julia array (calling nc_get_vars) """
function nc_get_vars! end;

nc_get_vars!(ncid::Integer, varid::Integer, startp, countp, stridep, ip) = (
    ccall_act = ccall((:nc_get_vars,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Cint},Ptr{Nothing}), ncid, varid, startp, countp, stridep, ip);

    return check_status!(ccall_act)
);

nc_get_vars!(ncid::Integer, varid::Integer, startp, countp, stridep, ip::Array{Char,N}) where {N} = (
    tmp = Array{UInt8,N}(undef,size(ip));
    nc_get_vars!(ncid, varid, startp, countp, stridep, tmp);
    ip .= convert.(Char, tmp);

    return nothing
);

nc_get_vars!(ncid::Integer, varid::Integer, startp, countp, stridep, ip::Array{String,N}) where {N} = (
    tmp = Array{Ptr{UInt8},N}(undef,size(ip));
    nc_get_vars!(ncid, varid, startp, countp, stridep, tmp);
    for i in eachindex(tmp)
        ip[i] = unsafe_string(tmp[i]);
    end;

    return nothing
);

nc_get_vars!(ncid::Integer, varid::Integer, startp, countp, stridep, ip::Array{Vector{T},N}) where {T,N} = (
    tmp = Array{VariableLength{T},N}(undef,size(ip));
    nc_get_vars!(ncid, varid, startp, countp, stridep, tmp);
    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T}, tmp[i].p, (tmp[i].len,));
    end;

    return nothing
);
