# julia implementation of libnetcdf functions
""" Write data to a netcdf dataset (nc_put_var) """
function nc_put_var end;

nc_put_var(ncid::Integer, varid::Integer, data) = (
    dimids = nc_inq_vardimid(ncid, varid);
    ndims = length(dimids);
    ncsize = ntuple(i -> nc_inq_dimlen(ncid,dimids[ndims-i+1]), ndims);

    return if isempty(nc_inq_unlimdims(ncid))
        @assert ncsize == size(data) "wrong size of variable in file for an array of size $(size(data))";
        nc_unsafe_put_var(ncid, varid, data)
    else
        # honor this good advice: https://github.com/Unidata/netcdf-c/blob/48cc56ea3833df455337c37186fa6cd7fac9dc7e/libdispatch/dvarput.c#L895
        nc_put_vara(ncid, varid, zeros(ndims), Int[reverse(size(data))...,], data)
    end;
);

nc_put_var(ncid::Integer, varid::Integer, data::Array{Char,N}) where {N} = nc_put_var(ncid, varid, convert(Array{UInt8,N}, data));

nc_put_var(ncid::Integer, varid::Integer, data::Array{String,N}) where {N} = nc_put_var(ncid, varid, map(pointer,data));

nc_put_var(ncid::Integer, varid::Integer, data::Array{Vector{T},N}) where {T,N} = nc_put_var(ncid, varid, convert(Array{VariableLength{T},N},data));

nc_unsafe_put_var(ncid::Integer, varid::Integer, data::Array) = (
    ccall_act = ccall((:nc_put_var,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Nothing}), ncid, varid, data);

    return check_status!(ccall_act)
);

nc_unsafe_put_var(ncid::Integer, varid::Integer, data) = nc_unsafe_put_var(ncid, varid, Array(data));


""" Write data to a netcdf dataset (nc_put_var1) """
function nc_put_var1 end;

nc_put_var1(ncid::Integer, varid::Integer, indexp, op::Vector{T}) where {T} = (
    tmp = VariableLength{T}(length(op), pointer(op));
    ccall_act = ccall((:nc_put_var1,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Nothing}), ncid, varid, indexp, Ref(tmp));

    return check_status!(ccall_act)
);

nc_put_var1(ncid::Integer, varid::Integer, indexp, op::T) where {T} = (
    ccall_act = ccall((:nc_put_var1,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Nothing}), ncid, varid, indexp, T[op]);

    return check_status!(ccall_act)
);

nc_put_var1(ncid::Integer, varid::Integer, indexp, op::Char) = (
    ccall_act = ccall((:nc_put_var1,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Nothing}), ncid, varid, indexp, [UInt8(op)]);

    return check_status!(ccall_act)
);

nc_put_var1(ncid::Integer, varid::Integer, indexp, op::String) = (
    ccall_act = ccall((:nc_put_var1_string,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Cstring}), ncid, varid, indexp, [op]);

    return check_status!(ccall_act)
);


""" Write data to a netcdf dataset (nc_put_vara) """
function nc_put_vara end;

nc_put_vara(ncid::Integer, varid::Integer, startp, countp, op) = (
    ccall_act = ccall((:nc_put_vara,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Nothing}), ncid, varid, startp, countp, op);

    return check_status!(ccall_act)
);

nc_put_vara(ncid::Integer, varid::Integer, startp, countp, op::Array{Char,N}) where {N} = nc_put_vara(ncid, varid, startp, countp, convert(Array{UInt8,N},op));

nc_put_vara(ncid::Integer, varid::Integer, startp, countp, op::Array{String,N}) where {N} = nc_put_vara(ncid, varid, startp, countp, pointer.(op));

nc_put_vara(ncid::Integer, varid::Integer, startp, countp, op::Array{Vector{T},N}) where {T,N} = nc_put_vara(ncid, varid, startp, countp, convert(Array{VariableLength{T},N},op));


""" Write data to a netcdf dataset (nc_put_vars) """
function nc_put_vars end;

nc_put_vars(ncid::Integer, varid::Integer, startp, countp, stridep, op) = (
    check_put_vars_size!(ncid, varid, countp, op);
    ccall_act = ccall((:nc_put_vars,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Cint},Ptr{Nothing}), ncid, varid, startp, countp, stridep, op);

    return check_status!(ccall_act)
);

nc_put_vars(ncid::Integer, varid::Integer, startp, countp, stridep, op::Array{Char,N}) where {N} = nc_put_vars(ncid, varid, startp, countp, stridep, convert(Array{UInt8,N}, op));

nc_put_vars(ncid::Integer, varid::Integer, startp, countp, stridep, op::Array{String,N}) where {N} = nc_put_vars(ncid, varid, startp, countp, stridep, pointer.(op));

nc_put_vars(ncid::Integer, varid::Integer, startp, countp, stridep, op::Array{Vector{T},N}) where {T,N} = nc_put_vars(ncid, varid, startp, countp, stridep, convert(Array{VariableLength{T},N},op));

check_put_vars_size!(ncid::Integer, varid::Integer, countp, op) = (
    i_nc = 1;
    i_data = 1;

    # not_one(x) = x != 1
    # if filter(not_one,reverse(countp)) != filter(not_one,[size(op)...])
    #     path = nc_inq_path(ncid)
    #     varname = nc_inq_varname(ncid,varid)
    #     throw(DimensionMismatch("size mismatch for variable '$(varname)' in file '$(path)'. Trying to write $(size(op)) elements while $(countp) are expected"))
    # end

    unlimdims = nc_inq_unlimdims(ncid);
    countp = reverse(countp);
    dimids = reverse(nc_inq_vardimid(ncid,varid));

    while true
        # break when no extra dimensions are left
        if (i_data > ndims(op)) && (i_nc > length(countp))
            break
        end;

        count_i_nc = i_nc <= length(countp) ? countp[i_nc] : 1;

        # ignore dimensions with only one element
        if (count_i_nc == 1) && (i_nc <= length(countp))
            i_nc += 1;
            continue
        end;

        if size(op,i_data) == 1 && (i_data <= ndims(op))
            i_data += 1;
            continue
        end;

        # no test for unlimited dimensions
        if (i_nc <= length(dimids)) && (dimids[i_nc] in unlimdims)
            # ok
        elseif (size(op,i_data) !== count_i_nc)
            path = nc_inq_path(ncid);
            varname = nc_inq_varname(ncid,varid);

            throw(NetCDFError(NC_EEDGE,"size mismatch for variable '$(varname)' in file '$(path)'. Trying to write $(size(op)) elements while $(countp) are expected"));
        end;

        i_nc += 1;
        i_data += 1;
    end;

    return nothing
);
