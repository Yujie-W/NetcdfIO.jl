using Base


# computes the shape of the array of size `sz` after applying the indexes
# size(a[indexes...]) == _shape_after_slice(size(a),indexes...)

# the difficulty here is to make the size inferrable by the compiler
_shape_after_slice(sz,indexes...) = __sh(sz,(),1,indexes...)
__sh(sz,sh,n,i::Integer,indexes...) = __sh(sz,sh,               n+1,indexes...)
__sh(sz,sh,n,i::Colon,  indexes...) = __sh(sz,(sh...,sz[n]),    n+1,indexes...)
__sh(sz,sh,n,i,         indexes...) = __sh(sz,(sh...,length(i)),n+1,indexes...)
__sh(sz,sh,n) = sh


mutable struct CatArray{T,N,M,TA} <: AbstractArray{T,N} where TA <: AbstractArray
    # dimension over which the sub-arrays are concatenated
    dim::Int
    # tuple of all sub-arrays
    arrays::NTuple{M,TA}
    # offset indices of every subarrays in the combined array
    # (0-based, i.e. 0 = no offset)
    offset::NTuple{M,NTuple{N,Int}}
    # size of the combined array
    sz::NTuple{N,Int}
end
