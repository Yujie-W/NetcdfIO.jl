############################################################
# Types and subtypes
############################################################

# List of attributes (for a single NetCDF file)
# all ids should be Cint








mutable struct NCDataset{TDS} <: AbstractDataset where TDS<:AbstractDataset
    # parent_dataset is nothing for the root dataset
    parentdataset::TDS
    ncid::Cint
    iswritable::Bool
    # true of the NetCDF is in define mode (i.e. metadata can be added, but not data)
    # need to be a reference, so that remains syncronised when copied
    isdefmode::Ref{Bool}
    attrib::Attributes{NCDataset{TDS}}
    dim::Dimensions{NCDataset{TDS}}
    group::Groups{NCDataset{TDS}}
    # mapping between variables related via the bounds attribute
    # It is only used for read-only datasets to improve performance
    _boundsmap::Dict{String,String}
    function NCDataset(ncid::Integer,
                       iswritable::Bool,
                       isdefmode::Ref{Bool};
                       parentdataset = nothing,
                       )
        ds = new{typeof(parentdataset)}()
        ds.parentdataset = parentdataset
        ds.ncid = ncid
        ds.iswritable = iswritable
        ds.isdefmode = isdefmode
        ds.attrib = Attributes(ds,NC_GLOBAL)
        ds.dim = Dimensions(ds)
        ds.group = Groups(ds)
        ds._boundsmap = Dict{String,String}()
        if !iswritable
            initboundsmap!(ds)
        end
        timeid = now()
        @debug "add finalizer $ncid $(timeid)"

        function _finalize(ds)
            @debug begin
                ccall(:jl_, Cvoid, (Any,), "finalize $ncid $timeid \n")
            end
            # only close open root group
            if (ds.ncid != -1) && isnothing(ds.parentdataset)
                close(ds)
            end
        end

        finalizer(_finalize, ds)
        return ds
    end
end

"Alias to `NCDataset`"
const Dataset = NCDataset
