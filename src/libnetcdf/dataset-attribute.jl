# julia implementation of libnetcdf functions
""" Read attribute data from a netCDF dataset """
function nc_get_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol})
    xtype,len = nc_inq_att(ncid, varid, name);

    if xtype == NC_CHAR
        val = Vector{UInt8}(undef,len);
        ccall_act = ccall((:nc_get_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,Ptr{Nothing}), ncid, varid, name, val);
        check_status!(ccall_act);

        # fillvalues for character attributes must be returns as Char and not a strings
        if name == "_FillValue"
            return Char(val[1])
        end;

        # consider the null terminating character if present
        return any(val .== 0) ? unsafe_string(pointer(val)) : unsafe_string(pointer(val),length(val))
    elseif xtype == NC_STRING
        val = Vector{Ptr{UInt8}}(undef,len);
        ccall_act = ccall((:nc_get_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,Ptr{Nothing}), ncid, varid, name, val);
        check_status!(ccall_act);
        str = unsafe_string.(val);

        return len == 1 ? str[1] : str
    else
        val = Vector{JL_TYPES[xtype]}(undef,len)
        ccall_act = ccall((:nc_get_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,Ptr{Nothing}), ncid, varid, name, val);
        check_status!(ccall_act);

        return len == 1 ? val[1] : val
    end;
end;


""" Inquire attribute information from a netCDF dataset """
function nc_inq_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol})
    xtypep = Ref(NC_TYPE(0));
    lenp = Ref(Csize_t(0));
    ccall_act = ccall((:nc_inq_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,Ptr{NC_TYPE},Ptr{Csize_t}), ncid, varid, name, xtypep, lenp);
    check_status!(ccall_act);

    return xtypep[],lenp[]
end;


""" Inquire attribute name from a netCDF dataset """
function nc_inq_attname(ncid::Integer, varid::Integer, attnum::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1);
    ccall_act = ccall((:nc_inq_attname,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cint,Ptr{UInt8}), ncid, varid, attnum, cname);
    check_status!(ccall_act);
    cname[end]=0;

   return unsafe_string(pointer(cname))
end;


""" Write attribute data to a netCDF dataset """
function nc_put_att end;

# Single string, char, number
nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::AbstractString) = (
    return if name == "_FillValue"
        nc_put_att_string(ncid, varid, "_FillValue", [data])
    else
        ccall_act = ccall((:nc_put_att_text,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,Csize_t,Cstring), ncid, varid, name, sizeof(data), data);
        check_status!(ccall_act)
    end;
);

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Vector{Char}) = nc_put_att(ncid, varid, name, join(data));

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Char) = (
    ccall_act = ccall((:nc_put_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,NC_TYPE,Csize_t,Ptr{Nothing}), ncid, varid, name, NC_TYPES[typeof(data)], 1, [UInt8(data)]);

    return check_status!(ccall_act)
);

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Number) = (
    ccall_act = ccall((:nc_put_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,NC_TYPE,Csize_t,Ptr{Nothing}), ncid, varid, name, NC_TYPES[typeof(data)], 1, [data]);

    return check_status!(ccall_act)
);

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Int64) = nc_put_att(ncid, varid, name, Int32(data));

# Vector of strings
nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, typeid::Integer, data::Vector) = (
    ccall_act = ccall((:nc_put_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,NC_TYPE,Csize_t,Ptr{Nothing}), ncid, varid, name, typeid, length(data), data);

    return check_status!(ccall_act)
);

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Vector{<:AbstractString}) = (
    ccall_act = ccall((:nc_put_att,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,NC_TYPE,Csize_t,Ptr{Nothing}), ncid, varid, name, NC_TYPES[eltype(data)], length(data), pointer.(data));

    return check_status!(ccall_act)
);

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Vector{T}) where {T} = nc_put_att(ncid, varid, name, NC_TYPES[T], data);

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Vector{Int64}) = nc_put_att(ncid, varid, name, Int32.(data))

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::AbstractVector) = nc_put_att(ncid, varid, name, Vector(data));

nc_put_att(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data) = error("attributes can only be scalars or vectors");


""" Write string attribute data to a netCDF dataset (calling nc_put_att_string) """
function nc_put_att_string(ncid::Integer, varid::Integer, name::Union{AbstractString,Symbol}, data::Vector{String})
    len = length(data);
    op = pointer(pointer.(data));
    ccall_act = ccall((:nc_put_att_string,NetCDF_jll.libnetcdf), Cint, (Cint,Cint,Cstring,Cint,Ptr{Cstring}), ncid, varid, name, len, op);

    return check_status!(ccall_act)
end;
