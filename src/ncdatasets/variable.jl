#=
Functionality and definitions
related with the `Variables` types/subtypes
=#



############################################################
# Helper functions (internal)
############################################################
"Return all variable names"
listVar(ncid) = String[nc_inq_varname(ncid,varid)
                       for varid in nc_inq_varids(ncid)]


"""
    sz = size(var::Variable)

Return a tuple of integers with the size of the variable `var`.

!!! note

    Note that the size of a variable can change, i.e. for a variable with an
    unlimited dimension.
"""
size(v::Variable{T,N}) where {T,N} = ntuple(i -> nc_inq_dimlen(v.ds.ncid,v.dimids[i]),Val(N))


############################################################
# Obtaining variables
############################################################

function variable(ds::NCDataset,varid::Integer)
    dimids = nc_inq_vardimid(ds.ncid,varid)
    nctype = _jltype(ds.ncid,nc_inq_vartype(ds.ncid,varid))
    ndims = length(dimids)
    attrib = Attributes(ds,varid)

    # reverse dimids to have the dimension order in Fortran style
    return Variable{nctype,ndims,typeof(ds)}(ds,varid, (reverse(dimids)...,), attrib)
end


function _variable(ds::NCDataset,varname)
    varid = nc_inq_varid(ds.ncid,varname)
    return variable(ds,varid)
end

"""
    v = variable(ds::NCDataset,varname::String)

Return the NetCDF variable `varname` in the dataset `ds` as a
`NCDataset.Variable`. No scaling or other transformations are applied when the
variable `v` is indexed.
"""
variable(ds::NCDataset,varname::AbstractString) = _variable(ds,varname)


function getindex(v::Variable,indexes::Int...)
    datamode(v.ds)
    return nc_get_var1(eltype(v),v.ds.ncid,v.varid,[i-1 for i in indexes[ndims(v):-1:1]])
end

function setindex!(v::Variable{T,N},data,indexes::Int...) where N where T
    @debug "$(@__LINE__)"
    datamode(v.ds)
    # use zero-based indexes and reversed order
    nc_put_var1(v.ds.ncid,v.varid,[i-1 for i in indexes[ndims(v):-1:1]],T(data))
    return data
end

function getindex(v::Variable{T,N},indexes::Colon...) where {T,N}
    datamode(v.ds)
    data = Array{T,N}(undef,size(v))
    nc_get_var!(v.ds.ncid,v.varid,data)

    # special case for scalar NetCDF variable
    if N == 0
        return data[]
    else
        return data
    end
end

function setindex!(v::Variable{T,N},data::AbstractArray{T,N},indexes::Colon...) where {T,N}
    datamode(v.ds) # make sure that the file is in data mode

    nc_put_var(v.ds.ncid,v.varid,data)
    return data
end

function setindex!(v::Variable{T,N},data::AbstractArray{T2,N},indexes::Colon...) where {T,T2,N}
    datamode(v.ds) # make sure that the file is in data mode
    tmp =
        if T <: Integer
            round.(T,data)
        else
            convert(Array{T,N},data)
        end

    nc_put_var(v.ds.ncid,v.varid,tmp)
    return data
end

_normalizeindex(n,ind::Base.OneTo) = 1:1:ind.stop
_normalizeindex(n,ind::Colon) = 1:1:n
_normalizeindex(n,ind::Int) = ind:1:ind
_normalizeindex(n,ind::UnitRange) = StepRange(ind)
_normalizeindex(n,ind::StepRange) = ind
_normalizeindex(n,ind) = error("unsupported index")

# indexes can be longer than sz
function normalizeindexes(sz,indexes)
    return ntuple(i -> _normalizeindex(sz[i],indexes[i]), length(sz))
end


function ncsub(indexes::NTuple{N,T}) where N where T
    rindexes = reverse(indexes)
    count  = Int[length(i)  for i in rindexes]
    start  = Int[first(i)-1 for i in rindexes]     # use zero-based indexes
    stride = Int[step(i)    for i in rindexes]
    jlshape = length.(indexes)::NTuple{N,Int}
    return start,count,stride,jlshape
end

@inline start_count_stride(n,ind::AbstractRange) = (first(ind)-1,length(ind),step(ind))
@inline start_count_stride(n,ind::Integer) = (ind-1,1,1)
@inline start_count_stride(n,ind::Colon) = (0,n,1)

@inline function ncsub2(sz,indexes...)
    N = length(sz)

    start = Vector{Int}(undef,N)
    count = Vector{Int}(undef,N)
    stride = Vector{Int}(undef,N)

    for i = 1:N
        ind = indexes[i]
        ri = N-i+1
        @inbounds start[ri],count[ri],stride[ri] = start_count_stride(sz[i],ind)
    end

    return start,count,stride
end

function getindex(v::Variable{T,N},indexes::TR...) where {T,N} where TR <: Union{StepRange{Int,Int},UnitRange{Int}}
    start,count,stride,jlshape = ncsub(indexes[1:N])
    data = Array{T,N}(undef,jlshape)

    datamode(v.ds)
    nc_get_vars!(v.ds.ncid,v.varid,start,count,stride,data)
    return data
end

function setindex!(v::Variable{T,N},data::T,indexes::StepRange{Int,Int}...) where {T,N}
    datamode(v.ds) # make sure that the file is in data mode
    start,count,stride,jlshape = ncsub(indexes[1:ndims(v)])
    tmp = fill(data,jlshape)
    nc_put_vars(v.ds.ncid,v.varid,start,count,stride,tmp)
    return data
end

function setindex!(v::Variable{T,N},data::Array{T,N},indexes::StepRange{Int,Int}...) where {T,N}
    datamode(v.ds) # make sure that the file is in data mode
    start,count,stride,jlshape = ncsub(indexes[1:ndims(v)])
    nc_put_vars(v.ds.ncid,v.varid,start,count,stride,data)
    return data
end

# data can be Array{T2,N} or BitArray{N}
function setindex!(v::Variable{T,N},data::AbstractArray,indexes::StepRange{Int,Int}...) where {T,N}
    datamode(v.ds) # make sure that the file is in data mode
    start,count,stride,jlshape = ncsub(indexes[1:ndims(v)])

    tmp = convert(Array{T,ndims(data)},data)
    nc_put_vars(v.ds.ncid,v.varid,start,count,stride,tmp)

    return data
end




function getindex(v::Variable{T,N},indexes::Union{Int,Colon,AbstractRange{<:Integer}}...) where {T,N}
    sz = size(v)
    start,count,stride = ncsub2(sz,indexes...)
    jlshape = _shape_after_slice(sz,indexes...)
    data = Array{T}(undef,jlshape)

    datamode(v.ds)
    nc_get_vars!(v.ds.ncid,v.varid,start,count,stride,data)

    return data
end

# NetCDF scalars indexed as []
getindex(v::Variable{T, 0}) where T = v[1]



function setindex!(v::Variable,data,indexes::Union{Int,Colon,AbstractRange{<:Integer}}...)
    ind = normalizeindexes(size(v),indexes)

    # make arrays out of scalars (arrays can have zero dimensions)
    if (ndims(data) == 0) && !(data isa AbstractArray)
        data = fill(data,length.(ind))
    end

    return v[ind...] = data
end


getindex(v::Union{MFVariable,DeferVariable,Variable},ci::CartesianIndices) = v[ci.indices...]
setindex!(v::Union{MFVariable,DeferVariable,Variable},data,ci::CartesianIndices) = setindex!(v,data,ci.indices...)
