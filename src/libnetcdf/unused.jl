#=
function nc_inq_libvers()
    unsafe_string(ccall((:nc_inq_libvers,NetCDF_jll.libnetcdf),Cstring,()))
end

function nc_open_mem(path,mode::Integer,memory::Vector{UInt8})
    @debug "nc_open $path with mode $mode"
    ncidp = Ref(Cint(0))

    code = ccall(
        (:nc_open_mem,NetCDF_jll.libnetcdf),Cint,
        (Cstring,Cint,Csize_t,Ptr{UInt8},Ptr{Cint}),
        path,mode,length(memory),memory,ncidp)

    if code == NC_NOERR
        return ncidp[]
    else
        # otherwise throw an error message
        # with a more helpful error message (i.e. with the path)
        throw(NetCDFError(code, "Opening path $(path): $(nc_strerror(code))"))
    end
end

function nc_inq_typeids(ncid::Integer)
    ntypesp = Ref(Cint(0))
    check_status!(ccall((:nc_inq_typeids,NetCDF_jll.libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,ntypesp,C_NULL))

    typeids = Vector{Cint}(undef,ntypesp[])
    check_status!(ccall((:nc_inq_typeids,NetCDF_jll.libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,C_NULL,typeids))

    return typeids
end

function nc_def_grp(parent_ncid::Integer,name)
    new_ncid = Ref(Cint(0))
    check_status!(ccall((:nc_def_grp,NetCDF_jll.libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),parent_ncid,name,new_ncid))

    return new_ncid[]
end

function nc_def_compound(ncid::Integer,size::Integer,name)
    typeidp = Ref{NC_TYPE}()
    check_status!(ccall((:nc_def_compound,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{NC_TYPE}),ncid,size,name,typeidp))
    return typeidp[]
end

function nc_insert_compound(ncid::Integer,xtype::Integer,name,offset::Integer,field_typeid::Integer)
    check_status!(ccall((:nc_insert_compound,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Csize_t,NC_TYPE),ncid,xtype,name,offset,field_typeid))
end

function nc_insert_array_compound(ncid::Integer,xtype::Integer,name,offset::Integer,field_typeid::Integer,dim_sizes)
    ndims = length(dim_sizes)
    check_status!(ccall((:nc_insert_array_compound,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,name,offset,field_typeid,ndims,dim_sizes))
end

function nc_inq_compound(ncid::Integer,xtype::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    sizep = Ref{Csize_t}()
    nfieldsp = Ref{Csize_t}()

    check_status!(ccall((:nc_inq_compound,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8},Ptr{Csize_t},Ptr{Csize_t}),ncid,xtype,name,sizep,nfieldsp))

    return unsafe_string(pointer(name)), sizep[], nfieldsp[]
end

function nc_inq_compound_name(ncid::Integer,xtype::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    check_status!(ccall((:nc_inq_compound_name,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8}),ncid,xtype,name))
    return unsafe_string(pointer(name))
end

function nc_inq_compound_size(ncid::Integer,xtype::Integer)
    sizep = Ref{Csize_t}()
    check_status!(ccall((:nc_inq_compound_size,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Ptr{Csize_t}),ncid,xtype,sizep))
    return sizep[]
end

function nc_inq_compound_nfields(ncid::Integer,xtype::Integer)
    nfieldsp = Ref{Csize_t}()
    check_status!(ccall((:nc_inq_compound_nfields,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Ptr{Csize_t}),ncid,xtype,nfieldsp))
    return nfieldsp[]
end

function nc_inq_compound_fieldname(ncid::Integer,xtype::Integer,fieldid::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    check_status!(ccall((:nc_inq_compound_fieldname,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{UInt8}),ncid,xtype,fieldid,name))
    return unsafe_string(pointer(name))
end

function nc_inq_compound_fieldindex(ncid::Integer,xtype::Integer,name)
    fieldidp = Ref{Cint}()
    check_status!(ccall((:nc_inq_compound_fieldindex,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Ptr{Cint}),ncid,xtype,name,fieldidp))
    return fieldidp[]
end

function nc_inq_compound_fieldoffset(ncid::Integer,xtype::Integer,fieldid::Integer)
    offsetp = Ref{Cint}()
    check_status!(ccall((:nc_inq_compound_fieldoffset,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,fieldid,offsetp))
    return offsetp[]
end

function nc_inq_compound_fieldtype(ncid::Integer,xtype::Integer,fieldid::Integer)
    field_typeidp = Ref{NC_TYPE}()
    check_status!(ccall((:nc_inq_compound_fieldtype,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{NC_TYPE}),ncid,xtype,fieldid,field_typeidp))
    return field_typeidp[]
end

function nc_inq_compound_fieldndims(ncid::Integer,xtype::Integer,fieldid::Integer)
    ndimsp = Ref{Cint}()
    check_status!(ccall((:nc_inq_compound_fieldndims,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,fieldid,ndimsp))
    return ndimsp[]
end

function nc_inq_compound_fielddim_sizes(ncid::Integer,xtype::Integer,fieldid::Integer)
    ndims = nc_inq_compound_fieldndims(ncid,xtype,fieldid)
    dim_sizes = zeros(Cint,ndims)
    check_status!(ccall((:nc_inq_compound_fielddim_sizes,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,fieldid,dim_sizes))
    return dim_sizes
end

function nc_inq_vlen(ncid::Integer,xtype::Integer)
    datum_sizep = Ref(Csize_t(0))
    base_nc_typep = Ref(NC_TYPE(0))
    name = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_vlen,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8},Ptr{Csize_t},Ptr{NC_TYPE}),ncid,xtype,name,datum_sizep,base_nc_typep))

    return unsafe_string(pointer(name)),datum_sizep[],base_nc_typep[]
end

function nc_del_att(ncid::Integer,varid::Integer,name)
     check_status!(ccall((:nc_del_att,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cstring),ncid,varid,name))
end

function nc_def_enum(ncid::Integer,base_typeid::Integer,name)
    typeidp = Ref(NC_TYPE(0))
    check_status!(ccall((:nc_def_enum,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Ptr{NC_TYPE}),ncid,base_typeid,name,typeidp))

    return typeidp[]
end

function nc_inq_enum(ncid::Integer,xtype::Integer)

    base_nc_typep = Ref(NC_TYPE(0))
    base_sizep = Ref(Csize_t(0))
    num_membersp = Ref(Csize_t(0))
    cname = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_enum,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8},Ptr{NC_TYPE},Ptr{Csize_t},Ptr{Csize_t}),ncid,xtype,cname,base_nc_typep,base_sizep,num_membersp))

    type_name = unsafe_string(pointer(cname))
    base_nc_type = base_nc_typep[]
    num_members = num_membersp[]
    base_size = base_sizep[]

    return type_name,JL_TYPES[base_nc_type],base_size,num_members
end


function nc_insert_enum(ncid::Integer,xtype::Integer,name,value, T = nc_inq_enum(ncid,xtype)[2])
    valuep = Ref{T}(value)
    check_status!(ccall((:nc_insert_enum,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Ptr{Nothing}),ncid,xtype,name,valuep))
end

function nc_inq_enum_member(ncid::Integer,xtype::Integer,idx::Integer, T::Type = nc_inq_enum(ncid,xtype)[2])
    valuep = Ref{T}()
    cmember_name = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_enum_member,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{UInt8},Ptr{Nothing}),ncid,xtype,idx,cmember_name,valuep))

    member_name = unsafe_string(pointer(cmember_name))

    return member_name,valuep[]
end

function nc_inq_enum_ident(ncid::Integer,xtype::Integer,value)
    cidentifier = zeros(UInt8,NC_MAX_NAME+1)
    check_status!(ccall((:nc_inq_enum_ident,NetCDF_jll.libnetcdf),Cint,(Cint,NC_TYPE,Clonglong,Ptr{UInt8}),ncid,xtype,Clonglong(value),cidentifier))
    identifier = unsafe_string(pointer(cidentifier))
    return identifier
end

function nc_inq_var_deflate(ncid::Integer,varid::Integer)
    shufflep = Ref(Cint(0))
    deflatep = Ref(Cint(0))
    deflate_levelp = Ref(Cint(0))

    ncerr = ccall((:nc_inq_var_deflate,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,shufflep,deflatep,deflate_levelp)

    if ncerr == NC_ENOTNC4
       # work-around for netcdf 4.7.4
       # https://github.com/Unidata/netcdf-c/issues/1691
       return false, false, Cint(0)
    else
       check_status!(ncerr)
       return shufflep[] == 1, deflatep[] == 1, deflate_levelp[]
    end
end

function nc_def_var_fletcher32(ncid::Integer,varid::Integer,fletcher32)
    check_status!(ccall((:nc_def_var_fletcher32,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cint),ncid,varid,NC_CHECKSUM_CONSTANTS[fletcher32]))
end

function nc_inq_var_fletcher32(ncid::Integer,varid::Integer)
    fletcher32p = Ref(Cint(0))
    check_status!(ccall((:nc_inq_var_fletcher32,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,fletcher32p))
    return NC_CHECKSUMS[fletcher32p[]]
end

function nc_def_var_chunking(ncid::Integer,varid::Integer,storage,chunksizes)

    check_status!(ccall((:nc_def_var_chunking,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Csize_t}),ncid,varid,NC_CONSTANTS[storage],chunksizes))
end

function nc_inq_var_chunking(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims(ncid,varid)
    storagep = Ref(Cint(0))
    chunksizes = zeros(Csize_t,ndims)

    check_status!(ccall((:nc_inq_var_chunking,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Csize_t}),ncid,varid,storagep,chunksizes))

    return NC_SYMBOLS[storagep[]],Int.(chunksizes)
end

function nc_def_var_fill(ncid::Integer,varid::Integer,no_fill::Bool,fill_value)
    check_status!(ccall((:nc_def_var_fill,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Nothing}),
                ncid,
                varid,
                Cint(no_fill),
                [fill_value]))
end

function nc_def_var_fill(ncid::Integer,varid::Integer,no_fill::Bool,fill_value::String)
    check_status!(ccall((:nc_def_var_fill,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Nothing}),
                ncid,
                varid,
                Cint(no_fill),
                [pointer(fill_value)]))
end

function nc_inq_var_fill(ncid::Integer,varid::Integer)
    T = JL_TYPES[nc_inq_vartype(ncid,varid)]
    no_fillp = Ref(Cint(0))

    if T == String
        fill_valuep = Vector{Ptr{UInt8}}(undef,1)
        #fill_valuep = Ptr{UInt8}()
        check_status!(ccall((:nc_inq_var_fill,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),unsafe_string(fill_valuep[1])
    elseif T == Char
        fill_valuep = Ref(UInt8(0))
        check_status!(ccall((:nc_inq_var_fill,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),Char(fill_valuep[])
    else
        fill_valuep = Ref{T}()
        check_status!(ccall((:nc_inq_var_fill,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),fill_valuep[]
    end
end

function nc_set_chunk_cache(size::Integer,nelems::Integer,preemption::Number)
    check_status!(ccall((:nc_set_chunk_cache,NetCDF_jll.libnetcdf),Cint,(Csize_t,Csize_t,Cfloat),size,nelems,preemption))
end

function nc_get_chunk_cache()
    sizep = Ref{Csize_t}()
    nelemsp = Ref{Csize_t}()
    preemptionp = Ref{Cfloat}()
    check_status!(ccall((:nc_get_chunk_cache,NetCDF_jll.libnetcdf),Cint,(Ptr{Csize_t},Ptr{Csize_t},Ptr{Cfloat}),sizep,nelemsp,preemptionp))
    return Int(sizep[]),Int(nelemsp[]),preemptionp[]
end

function nc_sync(ncid::Integer)
    check_status!(ccall((:nc_sync,NetCDF_jll.libnetcdf),Cint,(Cint,),ncid))
end

function nc_rename_dim(ncid::Integer,dimid::Integer,name)
    check_status!(ccall((:nc_rename_dim,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cstring),ncid,dimid,name))
end

function _nc_has_att(ncid::Integer,varid::Integer,name)
    xtypep = Ref(NC_TYPE(0))
    lenp = Ref(Csize_t(0))
    code = ccall((:nc_inq_att,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{NC_TYPE},Ptr{Csize_t}),ncid,varid,name,xtypep,lenp)
    return code == NC_NOERR
end

function nc_inq_var(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims(ncid,varid)

    ndimsp = Ref(Cint(0))
    cname = zeros(UInt8,NC_MAX_NAME+1)
    dimids = zeros(Cint,ndims)
    nattsp = Ref(Cint(0))
    xtypep = Ref(NC_TYPE(0))

    check_status!(ccall((:nc_inq_var,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Ptr{UInt8},Ptr{NC_TYPE},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,cname,xtypep,ndimsp,dimids,nattsp))

    name = unsafe_string(pointer(cname))

    xtype = xtypep[]
    jltype = _jltype(ncid,xtype)

    return name,jltype,dimids,nattsp[]
end

function nc_rename_var(ncid::Integer,varid::Integer,name)
    check_status!(ccall((:nc_rename_var,NetCDF_jll.libnetcdf),Cint,(Cint,Cint,Cstring),ncid,varid,name))
end

function nc_rc_set(key,value)
    #nc_rc_set(const char* key, const char* value);
    check_status!(ccall((:nc_rc_set,NetCDF_jll.libnetcdf),Cint,(Cstring,Cstring),key,value))
end

function nc_rc_get(key)
    p = ccall((:nc_rc_get,NetCDF_jll.libnetcdf),Cstring,(Cstring,),key)
    if p !== C_NULL
        unsafe_string(p)
    else
        error("NetCDF: nc_rc_get: unable to get key $key")
    end
end
=#
