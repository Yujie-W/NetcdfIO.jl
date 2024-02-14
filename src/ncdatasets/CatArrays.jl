# computes the shape of the array of size `sz` after applying the indexes
# size(a[indexes...]) == _shape_after_slice(size(a),indexes...)

# the difficulty here is to make the size inferrable by the compiler
_shape_after_slice(sz,indexes...) = __sh(sz,(),1,indexes...)
__sh(sz,sh,n,i::Integer,indexes...) = __sh(sz,sh,               n+1,indexes...)
__sh(sz,sh,n,i::Colon,  indexes...) = __sh(sz,(sh...,sz[n]),    n+1,indexes...)
__sh(sz,sh,n,i,         indexes...) = __sh(sz,(sh...,length(i)),n+1,indexes...)
__sh(sz,sh,n) = sh
