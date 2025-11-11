#######################################################################################################################################################################################################
#
# Changes to the struct
# General:
#     2024-Feb-14: make the struct immutable
#     2025-Nov-15: add readblock! and writeblock! methods to use DiskArrays as used in CommonDataModel
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Struct to represent a NetCDF variable

# Fields

$(TYPEDFIELDS)

"""
struct Variable{T,N,TDS<:AbstractDataset} <: AbstractVariable{T,N}
    "Parent NetCDF dataset"
    ds::TDS
    "NetCDF variable id"
    varid::Cint
    "NetCDF dimension ids"
    dimids::NTuple{N,Cint}
    "Attributes of the variable"
    attrib::Attributes{TDS}
end;

readblock!(var::Variable, data, indexes...) = (
    data_mode!(var.ds);
    readblock_netcdf!(var, data, indexes...);

    return data
);

readblock_netcdf!(var::Variable, data, indexes::Int...) = (
    data .= nc_get_var1(eltype(var), var.ds.ncid, var.varid, [i-1 for i in indexes[ndims(var):-1:1]]);

    return nothing
);

readblock_netcdf!(var::Variable{T,N}, data, indexes::Colon...) where {T,N} = (
    nc_get_var!(var.ds.ncid, var.varid, data);

    return nothing
);

readblock_netcdf!(var::Variable{T,N}, data, indexes::TR...) where {T,N,TR<:Union{StepRange{Int,Int},UnitRange{Int}}} = (
    (start,count,stride,_) = ncsub(indexes[1:N]);
    nc_get_vars!(var.ds.ncid, var.varid, start, count, stride, data);

    return nothing
);

readblock_netcdf!(var::Variable{T,N}, data, indexes::Union{Int,Colon,AbstractRange{<:Integer}}...) where {T,N} = (
    (start,count,stride) = ncsub(size(var), indexes...);
    nc_get_vars!(var.ds.ncid, var.varid, start, count, stride, data);

    return nothing
);


writeblock!(var::Variable, data, indexes...) = (
    data_mode!(var.ds);
    writeblock_netcdf!(var, data, indexes...);

    return nothing
);

writeblock!(var::Variable, data, ci::CartesianIndices) = writeblock!(var, data, ci.indices...);

writeblock_netcdf!(var::Variable, data::AbstractArray, indexes::Union{Int,Colon,AbstractRange{<:Integer}}...) = (
    ind = normalized_indexes(size(var), indexes);

    # make arrays out of scalars (arrays can have zero dimensions)
    if (ndims(data) == 0) && !(data isa AbstractArray)
        data = fill(data, length.(ind));
    end;
    writeblock_netcdf!(var, data, ind...);

    return nothing
);

writeblock_netcdf!(var::Variable{T,N}, data, indexes::Int...) where {T,N} = (
    nc_put_var1(var.ds.ncid, var.varid, [i-1 for i in indexes[ndims(var):-1:1]], T(data));

    return nothing
);

writeblock_netcdf!(var::Variable{T,N}, data::AbstractArray{T,N}, indexes::Colon...) where {T,N} = (
    nc_put_var(var.ds.ncid, var.varid, data);

    return nothing
);

writeblock_netcdf!(var::Variable{T,N}, data::AbstractArray{T2,N}, indexes::Colon...) where {T,T2,N} = (
    tmp = T <: Integer ? round.(T,data) : convert(Array{T,N},data);
    nc_put_var(var.ds.ncid, var.varid, tmp);

    return nothing
);

writeblock_netcdf!(var::Variable{T,N}, data::T, indexes::StepRange{Int,Int}...) where {T,N} = (
    (start,count,stride,jlshape) = ncsub(indexes[1:ndims(var)]);
    tmp = fill(data, jlshape);
    nc_put_vars(var.ds.ncid, var.varid, start, count, stride, tmp);

    return nothing
);

writeblock_netcdf!(var::Variable{T,N}, data::Array{T,N}, indexes::StepRange{Int,Int}...) where {T,N} = (
    (start,count,stride,_) = ncsub(indexes[1:ndims(var)]);
    nc_put_vars(var.ds.ncid, var.varid, start, count, stride, data);

    return nothing
);

writeblock_netcdf!(var::Variable{T,N}, data::AbstractArray, indexes::StepRange{Int,Int}...) where {T,N} = (
    (start,count,stride,_) = ncsub(indexes[1:ndims(var)]);
    tmp = convert(Array{T,ndims(data)}, data);
    nc_put_vars(var.ds.ncid, var.varid, start, count, stride, tmp);

    return nothing
);


size(var::Variable{T,N}) where {T,N} = ntuple(i -> nc_inq_dimlen(var.ds.ncid, var.dimids[i]), Val(N));


#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2024-Feb-14: refine the types of the arguments
#
#######################################################################################################################################################################################################
"""

    normalized_index(sz::NTuple, index)

Normalize the index to a tuple of StepRange, given
- `sz` the size of the array
- `index` the index to be normalized

"""
function normalized_indexes end;

normalized_indexes(n::Int, ind::Base.OneTo) = 1:1:ind.stop;

normalized_indexes(n::Int, ind::Colon) = 1:1:n;

normalized_indexes(n::Int, ind::Int) = ind:1:ind;

normalized_indexes(n::Int, ind::UnitRange) = StepRange(ind);

normalized_indexes(n::Int, ind::StepRange) = ind;

normalized_indexes(sz::NTuple, index) = ntuple(i -> normalized_indexes(sz[i], index[i]), length(sz));


#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2024-Feb-14: combine ncsub and ncsub2 into one function
#
#######################################################################################################################################################################################################
"""

    ncsub(indexes::NTuple{N,T}) where {N,T}
    ncsub(sz::NTuple{N,T}, indexes...) where {N,T}

Return the start, count, stride, and shape of the slice, given
- `indexes` the indexes of the slice
- `sz` the size of the array

"""
function ncsub end;

ncsub(indexes::NTuple{N,T}) where {N,T} = (
    rindexes = reverse(indexes);
    count = Int[length(i) for i in rindexes];
    start = Int[first(i)-1 for i in rindexes]; # use zero-based indexes in netcdf_c
    stride = Int[step(i) for i in rindexes];
    jlshape = length.(indexes)::NTuple{N,Int};

    return start,count,stride,jlshape
);

ncsub(sz::NTuple{N,T}, indexes...) where {N,T} = (
    start = Vector{Int}(undef,N);
    count = Vector{Int}(undef,N);
    stride = Vector{Int}(undef,N);

    for i = 1:N
        ind = indexes[i];
        ri = N - i + 1;
        if ind isa AbstractRange
            start[ri],count[ri],stride[ri] = (first(ind)-1, length(ind), step(ind));
        elseif ind isa Integer
            start[ri],count[ri],stride[ri] = (ind-1, 1, 1);
        elseif ind isa Colon
            start[ri],count[ri],stride[ri] = (0, sz[i], 1);
        else
            error("Invalid index type: $(typeof(ind))");
        end;
    end;

    return start,count,stride
);
