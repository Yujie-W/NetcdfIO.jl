#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2023-Sep-01: use dlsym method to call libnetcdf functions for nc_open and nc_inq_varids (more to do in the future)
#
# This file is originally based netcdf_c.jl from NetCDF.jl
#
#######################################################################################################################################################################################################


# type is immutable to ensure that it has the memory same layout
# as the C struct nc_vlen_t

struct nc_vlen_t{T}
    len::Csize_t
    p::Ptr{T}
end


function convert(::Type{Array{nc_vlen_t{T},N}},data::Array{Vector{T},N}) where {T,N}
    tmp = Array{nc_vlen_t{T},N}(undef,size(data))

    for (i,d) in enumerate(data)
        tmp[i] = nc_vlen_t{T}(length(d), pointer(d))
    end
    return tmp
end


function nc_inq_libvers()
    unsafe_string(ccall((:nc_inq_libvers,libnetcdf),Cstring,()))
end


function nc_strerror(ncerr::Integer)
    unsafe_string(ccall((:nc_strerror,libnetcdf),Cstring,(Cint,),ncerr))
end


function nc_create(path,cmode::Integer)
    ncidp = Ref(Cint(0))
    check_status!(ccall((:nc_create,libnetcdf),Cint,(Cstring,Cint,Ptr{Cint}),path,cmode,ncidp))
    return ncidp[]
end


function nc_open(path,mode::Integer)
    @debug "nc_open $path with mode $mode";
    ncidp = Ref(Cint(0));

    _sym = Base.Libc.Libdl.dlsym(NetCDF_jll.libnetcdf_handle, :nc_open);
    code = ccall(_sym,Cint,(Cstring,Cint,Ptr{Cint}),path,mode,ncidp);

    if code == NC_NOERR
        return ncidp[]
    else
        # otherwise throw an error message
        # with a more helpful error message (i.e. with the path)
        throw(NetCDFError(code, "Opening path $(path): $(nc_strerror(code))"))
    end
end

function nc_open_mem(path,mode::Integer,memory::Vector{UInt8})
    @debug "nc_open $path with mode $mode"
    ncidp = Ref(Cint(0))

    code = ccall(
        (:nc_open_mem,libnetcdf),Cint,
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

function nc_inq_path(ncid::Integer)
    pathlenp = Ref(Csize_t(0))
    check_status!(ccall((:nc_inq_path,libnetcdf),Cint,(Cint,Ptr{Csize_t},Ptr{UInt8}),ncid,pathlenp,C_NULL))

    path = zeros(UInt8,pathlenp[]+1)
    check_status!(ccall((:nc_inq_path,libnetcdf),Cint,(Cint,Ptr{Csize_t},Ptr{UInt8}),ncid,pathlenp,path))

    return unsafe_string(pointer(path))
end


function nc_inq_grps(ncid::Integer)
    numgrpsp = Ref(Cint(0))
    check_status!(ccall((:nc_inq_grps,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,numgrpsp,C_NULL))
    numgrps = numgrpsp[]

    ncids = Vector{Cint}(undef,numgrps)

    check_status!(ccall((:nc_inq_grps,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,numgrpsp,ncids))

    return ncids
end

function nc_inq_grpname(ncid::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_grpname,libnetcdf),Cint,(Cint,Ptr{UInt8}),ncid,name))

    return unsafe_string(pointer(name))
end


function nc_inq_grp_ncid(ncid::Integer,grp_name)
    grp_ncid = Ref(Cint(0))
    check_status!(ccall((:nc_inq_grp_ncid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,grp_name,grp_ncid))
    return grp_ncid[]
end


function nc_inq_varids(ncid::Integer)::Vector{Cint}
    _sym = Base.Libc.Libdl.dlsym(NetCDF_jll.libnetcdf_handle, :nc_inq_varids);

    # first get number of variables
    nvarsp = Ref(Cint(0));
    check_status!(ccall(_sym,Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nvarsp,C_NULL));
    nvars = nvarsp[];

    varids = zeros(Cint,nvars);
    check_status!(ccall(_sym,Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nvarsp,varids));

    return varids
end

function nc_inq_dimids(ncid::Integer,include_parents::Bool)
    ndimsp = Ref(Cint(0))
    ndims = nc_inq_ndims(ncid)
    dimids = Vector{Cint}(undef,ndims)
    check_status!(ccall((:nc_inq_dimids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint},Cint),ncid,ndimsp,dimids,include_parents))

    return dimids
end

function nc_inq_typeids(ncid::Integer)
    ntypesp = Ref(Cint(0))
    check_status!(ccall((:nc_inq_typeids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,ntypesp,C_NULL))

    typeids = Vector{Cint}(undef,ntypesp[])
    check_status!(ccall((:nc_inq_typeids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,C_NULL,typeids))

    return typeids
end


"""
Create a group with the name `name` returnings its id.
"""
function nc_def_grp(parent_ncid::Integer,name)
    new_ncid = Ref(Cint(0))
    check_status!(ccall((:nc_def_grp,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),parent_ncid,name,new_ncid))

    return new_ncid[]
end


function nc_def_compound(ncid::Integer,size::Integer,name)
    typeidp = Ref{NC_TYPE}()
    check_status!(ccall((:nc_def_compound,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{NC_TYPE}),ncid,size,name,typeidp))
    return typeidp[]
end

function nc_insert_compound(ncid::Integer,xtype::Integer,name,offset::Integer,field_typeid::Integer)
    check_status!(ccall((:nc_insert_compound,libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Csize_t,NC_TYPE),ncid,xtype,name,offset,field_typeid))
end

function nc_insert_array_compound(ncid::Integer,xtype::Integer,name,offset::Integer,field_typeid::Integer,dim_sizes)
    ndims = length(dim_sizes)
    check_status!(ccall((:nc_insert_array_compound,libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,name,offset,field_typeid,ndims,dim_sizes))
end


function nc_inq_compound(ncid::Integer,xtype::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    sizep = Ref{Csize_t}()
    nfieldsp = Ref{Csize_t}()

    check_status!(ccall((:nc_inq_compound,libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8},Ptr{Csize_t},Ptr{Csize_t}),ncid,xtype,name,sizep,nfieldsp))

    return unsafe_string(pointer(name)), sizep[], nfieldsp[]
end

function nc_inq_compound_name(ncid::Integer,xtype::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    check_status!(ccall((:nc_inq_compound_name,libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8}),ncid,xtype,name))
    return unsafe_string(pointer(name))
end

function nc_inq_compound_size(ncid::Integer,xtype::Integer)
    sizep = Ref{Csize_t}()
    check_status!(ccall((:nc_inq_compound_size,libnetcdf),Cint,(Cint,NC_TYPE,Ptr{Csize_t}),ncid,xtype,sizep))
    return sizep[]
end

function nc_inq_compound_nfields(ncid::Integer,xtype::Integer)
    nfieldsp = Ref{Csize_t}()
    check_status!(ccall((:nc_inq_compound_nfields,libnetcdf),Cint,(Cint,NC_TYPE,Ptr{Csize_t}),ncid,xtype,nfieldsp))
    return nfieldsp[]
end


function nc_inq_compound_fieldname(ncid::Integer,xtype::Integer,fieldid::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    check_status!(ccall((:nc_inq_compound_fieldname,libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{UInt8}),ncid,xtype,fieldid,name))
    return unsafe_string(pointer(name))
end

function nc_inq_compound_fieldindex(ncid::Integer,xtype::Integer,name)
    fieldidp = Ref{Cint}()
    check_status!(ccall((:nc_inq_compound_fieldindex,libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Ptr{Cint}),ncid,xtype,name,fieldidp))
    return fieldidp[]
end

function nc_inq_compound_fieldoffset(ncid::Integer,xtype::Integer,fieldid::Integer)
    offsetp = Ref{Cint}()
    check_status!(ccall((:nc_inq_compound_fieldoffset,libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,fieldid,offsetp))
    return offsetp[]
end

function nc_inq_compound_fieldtype(ncid::Integer,xtype::Integer,fieldid::Integer)
    field_typeidp = Ref{NC_TYPE}()
    check_status!(ccall((:nc_inq_compound_fieldtype,libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{NC_TYPE}),ncid,xtype,fieldid,field_typeidp))
    return field_typeidp[]
end

function nc_inq_compound_fieldndims(ncid::Integer,xtype::Integer,fieldid::Integer)
    ndimsp = Ref{Cint}()
    check_status!(ccall((:nc_inq_compound_fieldndims,libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,fieldid,ndimsp))
    return ndimsp[]
end

function nc_inq_compound_fielddim_sizes(ncid::Integer,xtype::Integer,fieldid::Integer)
    ndims = nc_inq_compound_fieldndims(ncid,xtype,fieldid)
    dim_sizes = zeros(Cint,ndims)
    check_status!(ccall((:nc_inq_compound_fielddim_sizes,libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{Cint}),ncid,xtype,fieldid,dim_sizes))
    return dim_sizes
end

function nc_def_vlen(ncid::Integer,name,base_typeid::Integer)
    xtypep = Ref(NC_TYPE(0))

    check_status!(ccall((:nc_def_vlen,libnetcdf),Cint,(Cint,Cstring,NC_TYPE,Ptr{NC_TYPE}),ncid,name,base_typeid,xtypep))

    return xtypep[]
end

"""
datum_size is sizeof(nc_vlen_t)
"""
function nc_inq_vlen(ncid::Integer,xtype::Integer)
    datum_sizep = Ref(Csize_t(0))
    base_nc_typep = Ref(NC_TYPE(0))
    name = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_vlen,libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8},Ptr{Csize_t},Ptr{NC_TYPE}),ncid,xtype,name,datum_sizep,base_nc_typep))

    return unsafe_string(pointer(name)),datum_sizep[],base_nc_typep[]
end

function nc_free_vlen(vl::nc_vlen_t{T}) where {T}
    check_status!(ccall((:nc_free_vlen,libnetcdf),Cint,(Ptr{nc_vlen_t{T}},),Ref(vl)))
end


"""
    name,size,base_nc_type,nfields,class = nc_inq_user_type(ncid::Integer,xtype::Integer)
"""
function nc_inq_user_type(ncid::Integer,xtype::Integer)
    name = Vector{UInt8}(undef,NC_MAX_NAME+1)
    sizep = Ref(Csize_t(0))
    base_nc_typep = Ref(NC_TYPE(0))
    nfieldsp = Ref(Csize_t(0))
    classp = Ref(Cint(0))

    check_status!(ccall((:nc_inq_user_type,libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8},Ptr{Csize_t},Ptr{NC_TYPE},Ptr{Csize_t},Ptr{Cint}),ncid,xtype,name,sizep,base_nc_typep,nfieldsp,classp))

    return unsafe_string(pointer(name)),sizep[],base_nc_typep[],nfieldsp[],classp[]
end


function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::AbstractString)
    if name == "_FillValue"
        nc_put_att_string(ncid,varid,"_FillValue",[data])
    else
        check_status!(ccall((:nc_put_att_text,libnetcdf),Cint,(Cint,Cint,Cstring,Csize_t,Cstring),
                    ncid,varid,name,sizeof(data),data))
    end
end

function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::Vector{Char})
    nc_put_att(ncid,varid,name,join(data))
end

# NetCDF does not necessarily support 64 bit attributes
nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::Int64) =
    nc_put_att(ncid,varid,name,Int32(data))

nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::Vector{Int64}) =
    nc_put_att(ncid,varid,name,Int32.(data))

function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::Number)
    check_status!(ccall((:nc_put_att,libnetcdf),Cint,(Cint,Cint,Cstring,NC_TYPE,Csize_t,Ptr{Nothing}),
                ncid,varid,name,NC_TYPES[typeof(data)],1,[data]))
end

function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::Char)
    # UInt8('α')
    # ERROR: InexactError: trunc(UInt8, 945)
    check_status!(ccall((:nc_put_att,libnetcdf),Cint,(Cint,Cint,Cstring,NC_TYPE,Csize_t,Ptr{Nothing}),
                ncid,varid,name,NC_TYPES[typeof(data)],1,[UInt8(data)]))
end

function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::Vector{T}) where T <: AbstractString
    check_status!(ccall((:nc_put_att,libnetcdf),Cint,(Cint,Cint,Cstring,
                                              NC_TYPE,Csize_t,Ptr{Nothing}),
                ncid,varid,name,NC_TYPES[eltype(data)],length(data),pointer.(data)))
end

function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::Vector{T}) where {T}
    nc_put_att(ncid,varid,name,NC_TYPES[T],data)
end

function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},typeid::Integer,data::Vector)
    check_status!(ccall((:nc_put_att,libnetcdf),Cint,(Cint,Cint,Cstring,NC_TYPE,Csize_t,Ptr{Nothing}),
                ncid,varid,name,typeid,length(data),data))
end

# convert e.g. ranges to vectors
function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data::AbstractVector)
    nc_put_att(ncid,varid,name,Vector(data))
end

function nc_put_att(ncid::Integer,varid::Integer,name::Union{AbstractString,Symbol},data)
    error("attributes can only be scalars or vectors")
end

function nc_get_att(ncid::Integer,varid::Integer,name)
    xtype,len = nc_inq_att(ncid,varid,name)

    if xtype == NC_CHAR
        val = Vector{UInt8}(undef,len)
        check_status!(ccall((:nc_get_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Nothing}),ncid,varid,name,val))

        # Note
        # fillvalues for character attributes must be returns as Char and not a strings
        if name == "_FillValue"
            return Char(val[1])
        end

        if any(val .== 0)
            # consider the null terminating character if present
            # see issue #12
            return unsafe_string(pointer(val))
        else
            return unsafe_string(pointer(val),length(val))
        end
    elseif xtype == NC_STRING
        val = Vector{Ptr{UInt8}}(undef,len)
        check_status!(ccall((:nc_get_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Nothing}),ncid,varid,name,val))

        str = unsafe_string.(val)
        if len == 1
            return str[1]
        else
            return str
        end
    else
        val = Vector{JL_TYPES[xtype]}(undef,len)
        check_status!(ccall((:nc_get_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Nothing}),ncid,varid,name,val))

        if len == 1
            return val[1]
        else
            return val
        end
    end
end

# Enum

function nc_def_enum(ncid::Integer,base_typeid::Integer,name)
    typeidp = Ref(NC_TYPE(0))
    check_status!(ccall((:nc_def_enum,libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Ptr{NC_TYPE}),ncid,base_typeid,name,typeidp))

    return typeidp[]
end

function nc_inq_enum(ncid::Integer,xtype::Integer)

    base_nc_typep = Ref(NC_TYPE(0))
    base_sizep = Ref(Csize_t(0))
    num_membersp = Ref(Csize_t(0))
    cname = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_enum,libnetcdf),Cint,(Cint,NC_TYPE,Ptr{UInt8},Ptr{NC_TYPE},Ptr{Csize_t},Ptr{Csize_t}),ncid,xtype,cname,base_nc_typep,base_sizep,num_membersp))

    type_name = unsafe_string(pointer(cname))
    base_nc_type = base_nc_typep[]
    num_members = num_membersp[]
    base_size = base_sizep[]

    return type_name,JL_TYPES[base_nc_type],base_size,num_members
end


function nc_insert_enum(ncid::Integer,xtype::Integer,name,value, T = nc_inq_enum(ncid,xtype)[2])
    valuep = Ref{T}(value)
    check_status!(ccall((:nc_insert_enum,libnetcdf),Cint,(Cint,NC_TYPE,Cstring,Ptr{Nothing}),ncid,xtype,name,valuep))
end

function nc_inq_enum_member(ncid::Integer,xtype::Integer,idx::Integer, T::Type = nc_inq_enum(ncid,xtype)[2])
    valuep = Ref{T}()
    cmember_name = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_enum_member,libnetcdf),Cint,(Cint,NC_TYPE,Cint,Ptr{UInt8},Ptr{Nothing}),ncid,xtype,idx,cmember_name,valuep))

    member_name = unsafe_string(pointer(cmember_name))

    return member_name,valuep[]
end

function nc_inq_enum_ident(ncid::Integer,xtype::Integer,value)
    cidentifier = zeros(UInt8,NC_MAX_NAME+1)
    check_status!(ccall((:nc_inq_enum_ident,libnetcdf),Cint,(Cint,NC_TYPE,Clonglong,Ptr{UInt8}),ncid,xtype,Clonglong(value),cidentifier))
    identifier = unsafe_string(pointer(cidentifier))
    return identifier
end


# can the NetCDF variable varid receive the data?
function _nc_shape_check(ncid,varid,data,start,count,stride)
    @debug ncid,varid,data,start,count,stride
end

function nc_put_var(ncid::Integer,varid::Integer,data::Array{Char,N}) where N
    nc_put_var(ncid,varid,convert(Array{UInt8,N},data))
end

function nc_put_var(ncid::Integer,varid::Integer,data::Array{String,N}) where N
    # pointer.(data) is surprisingly a scalar pointer Ptr{UInt8} if data is a
    # Array{T,0}
    tmp = map(pointer,data)
    nc_put_var(ncid,varid,tmp)
end

function nc_put_var(ncid::Integer,varid::Integer,data::Array{Vector{T},N}) where {T,N}
    nc_put_var(ncid,varid,convert(Array{nc_vlen_t{T},N},data))
end

function nc_unsafe_put_var(ncid::Integer,varid::Integer,data::Array)
    check_status!(ccall((:nc_put_var,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing}),ncid,varid,data))
end

# data can be a range that must first be converted to an array
function nc_unsafe_put_var(ncid::Integer,varid::Integer,data)
    check_status!(ccall((:nc_put_var,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing}),ncid,varid,Array(data)))
end

function nc_put_var(ncid::Integer,varid::Integer,data)
    dimids = nc_inq_vardimid(ncid,varid)
    ndims = length(dimids)
    ncsize = ntuple(i -> nc_inq_dimlen(ncid,dimids[ndims-i+1]), ndims)

    if isempty(nc_inq_unlimdims(ncid))
        if ncsize != size(data)
            path = nc_inq_path(ncid)
            varname = nc_inq_varname(ncid,varid)
            throw(NetCDFError(-1,"wrong size of variable '$varname' (size $ncsize) in file '$path' for an array of size $(size(data))"))
        end

        nc_unsafe_put_var(ncid,varid,data)
    else
        # honor this good advice:

        # Take care when using this function with record variables (variables
        # that use the ::NC_UNLIMITED dimension). If you try to write all the
        # values of a record variable into a netCDF file that has no record data
        # yet (hence has 0 records), nothing will be written. Similarly, if you
        # try to write all the values of a record variable but there are more
        # records in the file than you assume, more in-memory data will be
        # accessed than you supply, which may result in a segmentation
        # violation. To avoid such problems, it is better to use the nc_put_vara
        # interfaces for variables that use the ::NC_UNLIMITED dimension.

        # https://github.com/Unidata/netcdf-c/blob/48cc56ea3833df455337c37186fa6cd7fac9dc7e/libdispatch/dvarput.c#L895

        startp = zeros(ndims)
        countp = Int[reverse(size(data))...,]
        nc_put_vara(ncid,varid,startp,countp,data)
    end
end

function nc_get_var!(ncid::Integer,varid::Integer,ip::Array{Char,N}) where N
    tmp = Array{UInt8,N}(undef,size(ip))
    nc_get_var!(ncid,varid,tmp)
    for i in eachindex(tmp)
        ip[i] = Char(tmp[i])
    end
end

function nc_get_var!(ncid::Integer,varid::Integer,ip::Array{String,N}) where N
    tmp = Array{Ptr{UInt8},N}(undef,size(ip))
    nc_get_var!(ncid,varid,tmp)
    for i in eachindex(tmp)
        #ip[:] = unsafe_string.(tmp)
        ip[i] = unsafe_string(tmp[i])
    end
end

function nc_get_var!(ncid::Integer,varid::Integer,ip::Array{Vector{T},N}) where {T,N}
    tmp = Array{nc_vlen_t{T},N}(undef,size(ip))
    nc_get_var!(ncid,varid,tmp)

    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T},tmp[i].p,(tmp[i].len,))
    end
end

function nc_get_var!(ncid::Integer,varid::Integer,ip)
    check_status!(ccall((:nc_get_var,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing}),ncid,varid,ip))
end

function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::Vector{T}) where T
    tmp = nc_vlen_t{T}(length(op), pointer(op))
    check_status!(ccall((:nc_put_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,Ref(tmp)))
end

function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::T) where T
    @debug "nc_put_var1",indexp,op
    check_status!(ccall((:nc_put_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,T[op]))
end

function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::Char)
   @debug "nc_put_var1 char",indexp,op
   check_status!(ccall((:nc_put_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,[UInt8(op)]))
end

function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::String)
   @debug "nc_put_var1 String",indexp,op
   check_status!(ccall((:nc_put_var1_string,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Cstring}),ncid,varid,indexp,[op]))
end

function nc_get_var1(::Type{Char},ncid::Integer,varid::Integer,indexp)
    @debug "nc_get_var1",indexp
    tmp = Ref(UInt8(0))
    check_status!(ccall((:nc_get_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,tmp))
    return Char(tmp[])
end

function nc_get_var1(::Type{String},ncid::Integer,varid::Integer,indexp)
    tmp = Ref(Ptr{UInt8}(0))
    check_status!(ccall((:nc_get_var1_string,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Ptr{UInt8}}),ncid,varid,indexp,tmp))
    return unsafe_string(tmp[])
end

function nc_get_var1(::Type{T},ncid::Integer,varid::Integer,indexp) where T
    @debug "nc_get_var1" indexp
    ip = Ref{T}()
    check_status!(ccall((:nc_get_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,ip))
    return ip[]
end

function nc_get_var1(::Type{Vector{T}},ncid::Integer,varid::Integer,indexp) where T
    ip = Ref(nc_vlen_t{T}(zero(T),Ptr{T}()))
    check_status!(ccall((:nc_get_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,ip))
    #data = unsafe_wrap(Vector{T},ip[].p,(ip[].len,))
    data = copy(unsafe_wrap(Vector{T},ip[].p,(ip[].len,)))
    nc_free_vlen(ip[])
    return data
end

function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,op)
    check_status!(ccall((:nc_put_vara,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Nothing}),ncid,varid,startp,countp,op))
end

function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,op::Array{Char,N}) where N
    tmp = convert(Array{UInt8,N},op)
    nc_put_vara(ncid,varid,startp,countp,tmp)
end

function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,op::Array{String,N}) where N
    nc_put_vara(ncid,varid,startp,countp,pointer.(op))
end

function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,
                     op::Array{Vector{T},N}) where {T,N}

    nc_put_vara(ncid,varid,startp,countp,
                convert(Array{nc_vlen_t{T},N},op))
end

function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip)
    # @debug "nc_get_vara!",startp,indexp
    check_status!(ccall((:nc_get_vara,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Nothing}),ncid,varid,startp,countp,ip))
end

function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip::Array{Char,N}) where N
    tmp = Array{UInt8,N}(undef,size(ip))
    nc_get_vara!(ncid,varid,startp,countp,tmp)
    for i in eachindex(tmp)
        ip[i] = Char(tmp[i])
    end
end

function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip::Array{String,N}) where N
    tmp = Array{Ptr{UInt8},N}(undef,size(ip))
    nc_get_vara!(ncid,varid,startp,countp,tmp)
    for i in eachindex(tmp)
        #ip[:] = unsafe_string.(tmp)
        ip[i] = unsafe_string(tmp[i])
    end
end


function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip::Array{Vector{T},N}) where {T,N}
    tmp = Array{nc_vlen_t{T},N}(undef,size(ip))
    nc_get_vara!(ncid,varid,startp,countp,tmp)

    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T},tmp[i].p,(tmp[i].len,))
    end
end

function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,
                     op::Array{Char,N}) where N
    tmp = Array{UInt8,N}(undef,size(op))
    for i in eachindex(op)
        tmp[i] = UInt8(op[i])
    end

    nc_put_vars(ncid,varid,startp,countp,stridep,tmp)
end

function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,
                     op::Array{String,N}) where N
    nc_put_vars(ncid,varid,startp,countp,stridep,pointer.(op))
end

function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,
                     op::Array{Vector{T},N}) where {T,N}

    nc_put_vars(ncid,varid,startp,countp,stridep,
                convert(Array{nc_vlen_t{T},N},op))
end

function _nc_check_size_put_vars(ncid,varid,countp,op)
    # dimension index for NetCDF variable
    i1 = 1
    # dimension index of data op
    i2 = 1

    # not_one(x) = x != 1
    # if filter(not_one,reverse(countp)) != filter(not_one,[size(op)...])
    #     path = nc_inq_path(ncid)
    #     varname = nc_inq_varname(ncid,varid)
    #     throw(DimensionMismatch("size mismatch for variable '$(varname)' in file '$(path)'. Trying to write $(size(op)) elements while $(countp) are expected"))
    # end

    unlimdims = nc_inq_unlimdims(ncid)
    dimids = nc_inq_vardimid(ncid,varid)

    countp = reverse(countp)
    dimids = reverse(dimids)

    while true
        if (i2 > ndims(op)) && (i1 > length(countp))
            break
        end

        count_i1 =
            if i1 <= length(countp)
                countp[i1]
            else
                1
            end

        # ignore dimensions with only one element
        if (count_i1 == 1) && (i1 <= length(countp))
            i1 += 1
            continue
        end
        if size(op,i2) == 1 && (i2 <= ndims(op))
            i2 += 1
            continue
        end

        # no test for unlimited dimensions
        if (i1 <= length(dimids)) && (dimids[i1] in unlimdims)
            # ok
        elseif (size(op,i2) !== count_i1)
            path = nc_inq_path(ncid)
            varname = nc_inq_varname(ncid,varid)

            throw(NetCDFError(NC_EEDGE,"size mismatch for variable '$(varname)' in file '$(path)'. Trying to write $(size(op)) elements while $(countp) are expected"))
        end

        i1 += 1
        i2 += 1
    end
end

function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,op)
    @debug "nc_put_vars: $startp,$countp,$stridep"
    @debug "shape $(size(op))"
    _nc_check_size_put_vars(ncid,varid,countp,op)

    check_status!(ccall((:nc_put_vars,libnetcdf),Cint,
                (Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},
                 Ptr{Cint},Ptr{Nothing}),ncid,varid,startp,countp,stridep,op))
end


function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip::Array{Char,N}) where N
    @debug "nc_get_vars!: $startp,$countp,$stridep"
    tmp = Array{UInt8,N}(undef,size(ip))
    nc_get_vars!(ncid,varid,startp,countp,stridep,tmp)
    for i in eachindex(tmp)
        ip[i] = Char(tmp[i])
    end
    @debug "end nc_get_vars!"
end

function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip::Array{String,N}) where N
    @debug "nc_get_vars!: $startp,$countp,$stridep"
    tmp = Array{Ptr{UInt8},N}(undef,size(ip))
    nc_get_vars!(ncid,varid,startp,countp,stridep,tmp)
    for i in eachindex(tmp)
        #ip[:] = unsafe_string.(tmp)
        ip[i] = unsafe_string(tmp[i])
    end
end

function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip::Array{Vector{T},N}) where {T,N}
    @debug "nc_get_vars!: $startp,$countp,$stridep"
    tmp = Array{nc_vlen_t{T},N}(undef,size(ip))
    nc_get_vars!(ncid,varid,startp,countp,stridep,tmp)

    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T},tmp[i].p,(tmp[i].len,))
    end
end

function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
    @debug "nc_get_vars!: $startp,$countp,$stridep"
    check_status!(ccall((:nc_get_vars,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Cint},Ptr{Nothing}),ncid,varid,startp,countp,stridep,ip))
end


function nc_def_var_deflate(ncid::Integer,varid::Integer,shuffle::Bool,deflate::Integer,deflate_level::Integer)
    ishuffle = (shuffle ? 1 : 0)
    check_status!(ccall((:nc_def_var_deflate,libnetcdf),Cint,(Cint,Cint,Cint,Cint,Cint),ncid,varid,shuffle,deflate,deflate_level))
end

function nc_inq_var_deflate(ncid::Integer,varid::Integer)
    shufflep = Ref(Cint(0))
    deflatep = Ref(Cint(0))
    deflate_levelp = Ref(Cint(0))

    ncerr = ccall((:nc_inq_var_deflate,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,shufflep,deflatep,deflate_levelp)

    if ncerr == NC_ENOTNC4
       # work-around for netcdf 4.7.4
       # https://github.com/Unidata/netcdf-c/issues/1691
       return false, false, Cint(0)
    else
       check_status!(ncerr)
       return shufflep[] == 1, deflatep[] == 1, deflate_levelp[]
    end

end

# function nc_inq_var_szip(ncid::Integer,varid::Integer,options_maskp,pixels_per_blockp)
#     check_status!(ccall((:nc_inq_var_szip,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint}),ncid,varid,options_maskp,pixels_per_blockp))
# end

function nc_def_var_fletcher32(ncid::Integer,varid::Integer,fletcher32)
    check_status!(ccall((:nc_def_var_fletcher32,libnetcdf),Cint,(Cint,Cint,Cint),ncid,varid,NC_CHECKSUM_CONSTANTS[fletcher32]))
end

function nc_inq_var_fletcher32(ncid::Integer,varid::Integer)
    fletcher32p = Ref(Cint(0))
    check_status!(ccall((:nc_inq_var_fletcher32,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,fletcher32p))
    return NC_CHECKSUMS[fletcher32p[]]
end

function nc_def_var_chunking(ncid::Integer,varid::Integer,storage,chunksizes)

    check_status!(ccall((:nc_def_var_chunking,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Csize_t}),ncid,varid,NC_CONSTANTS[storage],chunksizes))
end

function nc_inq_var_chunking(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims(ncid,varid)
    storagep = Ref(Cint(0))
    chunksizes = zeros(Csize_t,ndims)

    check_status!(ccall((:nc_inq_var_chunking,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Csize_t}),ncid,varid,storagep,chunksizes))

    return NC_SYMBOLS[storagep[]],Int.(chunksizes)
end


"""
no_fill is a boolean and fill_value the value
"""
function nc_def_var_fill(ncid::Integer,varid::Integer,no_fill::Bool,fill_value)
    check_status!(ccall((:nc_def_var_fill,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Nothing}),
                ncid,
                varid,
                Cint(no_fill),
                [fill_value]))
end

function nc_def_var_fill(ncid::Integer,varid::Integer,no_fill::Bool,fill_value::String)
    check_status!(ccall((:nc_def_var_fill,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Nothing}),
                ncid,
                varid,
                Cint(no_fill),
                [pointer(fill_value)]))
end

"""
no_fill,fill_value = nc_inq_var_fill(ncid::Integer,varid::Integer)
no_fill is a boolean and fill_value the fill value (in the appropriate type)
"""
function nc_inq_var_fill(ncid::Integer,varid::Integer)
    T = JL_TYPES[nc_inq_vartype(ncid,varid)]
    no_fillp = Ref(Cint(0))

    if T == String
        fill_valuep = Vector{Ptr{UInt8}}(undef,1)
        #fill_valuep = Ptr{UInt8}()
        check_status!(ccall((:nc_inq_var_fill,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),unsafe_string(fill_valuep[1])
    elseif T == Char
        fill_valuep = Ref(UInt8(0))
        check_status!(ccall((:nc_inq_var_fill,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),Char(fill_valuep[])
    else
        fill_valuep = Ref{T}()
        check_status!(ccall((:nc_inq_var_fill,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),fill_valuep[]
    end
end


"""
    nc_set_chunk_cache(size::Integer,nelems::Integer,preemption::Number)

Sets the default chunk cache settins.

See netcdf C library documentation for `nc_set_chunk_cache` for details.

https://www.unidata.ucar.edu/software/netcdf/workshops/most-recent/nc4chunking/Cache.html
"""
function nc_set_chunk_cache(size::Integer,nelems::Integer,preemption::Number)
    check_status!(ccall((:nc_set_chunk_cache,libnetcdf),Cint,(Csize_t,Csize_t,Cfloat),size,nelems,preemption))
end

function nc_get_chunk_cache()
    sizep = Ref{Csize_t}()
    nelemsp = Ref{Csize_t}()
    preemptionp = Ref{Cfloat}()
    check_status!(ccall((:nc_get_chunk_cache,libnetcdf),Cint,(Ptr{Csize_t},Ptr{Csize_t},Ptr{Cfloat}),sizep,nelemsp,preemptionp))
    return Int(sizep[]),Int(nelemsp[]),preemptionp[]
end


function nc_redef(ncid::Integer)
    check_status!(ccall((:nc_redef,libnetcdf),Cint,(Cint,),ncid))
end


function nc_enddef(ncid::Integer)
    check_status!(ccall((:nc_enddef,libnetcdf),Cint,(Cint,),ncid))
end

function nc_sync(ncid::Integer)
    check_status!(ccall((:nc_sync,libnetcdf),Cint,(Cint,),ncid))
end


function nc_close(ncid::Integer)
    @debug("closing $ncid")
    check_status!(ccall((:nc_close,libnetcdf),Cint,(Cint,),ncid))
    @debug("end close $ncid")
end


function nc_inq_ndims(ncid::Integer)
    ndimsp = Ref(Cint(0))
    check_status!(ccall((:nc_inq_ndims,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,ndimsp))
    return ndimsp[]
end


"""
Returns the identifiers of unlimited dimensions
"""
function nc_inq_unlimdims(ncid::Integer)
    nunlimdimsp = Ref(Cint(0))
    check_status!(ccall((:nc_inq_unlimdims,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nunlimdimsp,C_NULL))

    unlimdimids = Vector{Cint}(undef,nunlimdimsp[])
    check_status!(ccall((:nc_inq_unlimdims,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nunlimdimsp,unlimdimids))
    return unlimdimids
end


"""
Define the dimension with the name NAME and the length LEN in the
dataset NCID. The id of the dimension is returned.
"""
function nc_def_dim(ncid::Integer,name,len::Integer)
    idp = Ref(Cint(0))

    check_status!(ccall((:nc_def_dim,libnetcdf),Cint,(Cint,Cstring,Cint,Ptr{Cint}),ncid,name,len,idp))
    return idp[]
end

"""Return the id of a NetCDF dimension."""
function nc_inq_dimid(ncid::Integer,name)
    dimidp = Ref(Cint(0))
    check_status!(ccall((:nc_inq_dimid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,name,dimidp))
    return dimidp[]
end


function nc_inq_dimname(ncid::Integer,dimid::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_dimname,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,dimid,cname))

    return unsafe_string(pointer(cname))
end

function nc_inq_dimlen(ncid::Integer,dimid::Integer)
    lengthp = Ref(Csize_t(0))
    check_status!(ccall((:nc_inq_dimlen,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t}),ncid,dimid,lengthp))
    return Int(lengthp[])
end

function nc_rename_dim(ncid::Integer,dimid::Integer,name)
    check_status!(ccall((:nc_rename_dim,libnetcdf),Cint,(Cint,Cint,Cstring),ncid,dimid,name))
end

# check presence of attribute without raising an error
function _nc_has_att(ncid::Integer,varid::Integer,name)
    xtypep = Ref(NC_TYPE(0))
    lenp = Ref(Csize_t(0))
    code = ccall((:nc_inq_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{NC_TYPE},Ptr{Csize_t}),ncid,varid,name,xtypep,lenp)
    return code == NC_NOERR
end


function nc_inq_att(ncid::Integer,varid::Integer,name)
    xtypep = Ref(NC_TYPE(0))
    lenp = Ref(Csize_t(0))

    check_status!(ccall((:nc_inq_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{NC_TYPE},Ptr{Csize_t}),ncid,varid,name,xtypep,lenp))

    return xtypep[],lenp[]
end


function nc_inq_attname(ncid::Integer,varid::Integer,attnum::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1)

    check_status!(ccall((:nc_inq_attname,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{UInt8}),ncid,varid,attnum,cname))
    # really necessary?
    cname[end]=0

   return unsafe_string(pointer(cname))
end


function nc_del_att(ncid::Integer,varid::Integer,name)
     check_status!(ccall((:nc_del_att,libnetcdf),Cint,(Cint,Cint,Cstring),ncid,varid,name))
end


function nc_put_att_string(ncid::Integer,varid::Integer,name,data)
    len = length(data)
    op = pointer(pointer.(data))

    check_status!(ccall((:nc_put_att_string,libnetcdf),Cint,(Cint,Cint,Cstring,Cint,Ptr{Cstring}),ncid,varid,name,len,op))
end


function nc_def_var(ncid::Integer,name,xtype::Integer,dimids::Vector{Cint})
    varidp = Ref(Cint(0))

    check_status!(ccall((:nc_def_var,libnetcdf),Cint,(Cint,Cstring,NC_TYPE,Cint,Ptr{Cint},Ptr{Cint}),ncid,name,xtype,length(dimids),dimids,varidp))

    return varidp[]
end

# get matching julia type
function _jltype(ncid,xtype)
    jltype =
        if xtype >= NC_FIRSTUSERTYPEID
            name,size,base_nc_type,nfields,class = nc_inq_user_type(ncid,xtype)
            # assume here variable-length type
            if class == NC_VLEN
                Vector{JL_TYPES[base_nc_type]}
            else
                @warn "unsupported type: class=$(class)"
                Nothing
            end
        else
            JL_TYPES[xtype]
        end

    return jltype
end


function nc_inq_var(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims(ncid,varid)

    ndimsp = Ref(Cint(0))
    cname = zeros(UInt8,NC_MAX_NAME+1)
    dimids = zeros(Cint,ndims)
    nattsp = Ref(Cint(0))
    xtypep = Ref(NC_TYPE(0))

    check_status!(ccall((:nc_inq_var,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8},Ptr{NC_TYPE},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,cname,xtypep,ndimsp,dimids,nattsp))

    name = unsafe_string(pointer(cname))

    xtype = xtypep[]
    jltype = _jltype(ncid,xtype)

    return name,jltype,dimids,nattsp[]
end

function nc_inq_varid(ncid::Integer,name)
    varidp = Ref(Cint(0))

    code = ccall((:nc_inq_varid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,name,varidp);
    if code == NC_NOERR
        return varidp[]
    else
        # return a more helpful error message (i.e. with the path)
        path =
            try
                nc_inq_path(ncid)
            catch
                "<unknown>"
            end

        throw(NetCDFError(code, "Variable '$name' not found in file $path"))
    end
end

function nc_inq_varname(ncid::Integer,varid::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1)
    check_status!(ccall((:nc_inq_varname,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,varid,cname))
    return unsafe_string(pointer(cname))
end

function nc_inq_vartype(ncid::Integer,varid::Integer)
    xtypep = Ref(NC_TYPE(0))
    check_status!(ccall((:nc_inq_vartype,libnetcdf),Cint,(Cint,Cint,Ptr{NC_TYPE}),ncid,varid,xtypep))
    return xtypep[]
end

function nc_inq_varndims(ncid::Integer,varid::Integer)
    ndimsp = Ref(Cint(0))
    check_status!(ccall((:nc_inq_varndims,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,ndimsp))
    return ndimsp[]
end

function nc_inq_vardimid(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims(ncid,varid)
    dimids = zeros(Cint,ndims)
    check_status!(ccall((:nc_inq_vardimid,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,dimids))
    return dimids
end

function nc_inq_varnatts(ncid::Integer,varid::Integer)
    nattsp = Ref(Cint(0))

    check_status!(ccall((:nc_inq_varnatts,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,nattsp))

    return nattsp[]
end

function nc_rename_var(ncid::Integer,varid::Integer,name)
    check_status!(ccall((:nc_rename_var,libnetcdf),Cint,(Cint,Cint,Cstring),ncid,varid,name))
end


function nc_rc_set(key,value)
    #nc_rc_set(const char* key, const char* value);
    check_status!(ccall((:nc_rc_set,libnetcdf),Cint,(Cstring,Cstring),key,value))
end

function nc_rc_get(key)
    p = ccall((:nc_rc_get,libnetcdf),Cstring,(Cstring,),key)
    if p !== C_NULL
        unsafe_string(p)
    else
        error("NetCDF: nc_rc_get: unable to get key $key")
    end
end
