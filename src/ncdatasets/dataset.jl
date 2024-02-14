

const NCIterable = Union{NCDataset}


############################################################
# Mappings
############################################################

# Mapping between NetCDF types and Julia types
const jlType = Dict(
    NC_BYTE   => Int8,
    NC_UBYTE  => UInt8,
    NC_SHORT  => Int16,
    NC_USHORT => UInt16,
    NC_INT    => Int32,
    NC_UINT   => UInt32,
    NC_INT64  => Int64,
    NC_UINT64 => UInt64,
    NC_FLOAT  => Float32,
    NC_DOUBLE => Float64,
    NC_CHAR   => Char,
    NC_STRING => String
)

# Inverse mapping
const ncType = Dict(value => key for (key, value) in jlType)


"Make sure that a dataset is in data mode"
function datamode(ds)
    if ds.isdefmode[]
        nc_enddef(ds.ncid)
        ds.isdefmode[] = false
    end
end

"Make sure that a dataset is in define mode"
function defmode(ds)
    if !ds.isdefmode[]
        nc_redef(ds.ncid)
        ds.isdefmode[] = true
    end
end

"Initialize the ds._boundsmap variable"
function initboundsmap!(ds)
    ds._boundsmap = Dict{String,String}()
    for vname in keys(ds)
        v = variable(ds,vname)
        bounds = get(v.attrib, "bounds", nothing)

        if !isnothing(bounds)
            ds._boundsmap[bounds] = vname
        end
    end
end

############################################################
# High-level
############################################################

"""
    NCDataset(filename::AbstractString, mode = "r";
              format::Symbol = :netcdf4,
              share::Bool = false,
              diskless::Bool = false,
              persist::Bool = false,
              memory::Union{Vector{UInt8},Nothing} = nothing,
              attrib = [])

Load, create, or even overwrite a NetCDF file at `filename`, depending on `mode`

* `"r"` (default) : open an existing netCDF file or OPeNDAP URL
   in read-only mode.
* `"c"` : create a new NetCDF file at `filename` (an existing file with the same
  name will be overwritten).
* `"a"` : open `filename` into append mode (i.e. existing data in the netCDF
  file is not overwritten and a variable can be added).


If `share` is true, the `NC_SHARE` flag is set allowing to have multiple
processes to read the file and one writer process. Likewise setting `diskless`
or `persist` to `true` will enable the flags `NC_DISKLESS` or `NC_PERSIST` flag.
More information is available in the [NetCDF C-API](https://www.unidata.ucar.edu/software/netcdf/docs/).

Notice that this does not close the dataset, use `close` on the
result (or see below the `do`-block).

The optional parameter `attrib` is an iterable of attribute name and attribute
value pairs, for example a `Dict`, `DataStructures.OrderedDict` or simply a
vector of pairs (see example below).

# Supported `format` values:

* `:netcdf4` (default): HDF5-based NetCDF format.
* `:netcdf4_classic`: Only netCDF 3 compatible API features will be used.
* `:netcdf3_classic`: classic netCDF format supporting only files smaller than 2GB.
* `:netcdf3_64bit_offset`: improved netCDF format supporting files larger than 2GB.
* `:netcdf5_64bit_data`: improved netCDF format supporting 64-bit integer data types.


Files can also be open and automatically closed with a `do` block.

```julia
NCDataset("file.nc") do ds
    data = ds["temperature"][:,:]
end
```

Here is an attribute example:
```julia
using DataStructures
NCDataset("file.nc", "c", attrib = OrderedDict("title" => "my first netCDF file")) do ds
   defVar(ds,"temp",[10.,20.,30.],("time",))
end;
```

The NetCDF dataset can also be a `memory` as a vector of bytes. A non-empty string
a `filename` is still required, for example:

```julia
using NCDataset, HTTP
resp = HTTP.get("https://www.unidata.ucar.edu/software/netcdf/examples/ECMWF_ERA-40_subset.nc")
ds = NCDataset("some_string","r",memory = resp.body)
total_precipitation = ds["tp"][:,:,:]
close(ds)
```

`Dataset` is an alias of `NCDataset`.
"""
function NCDataset(filename::AbstractString,
                   mode::AbstractString = "r";
                   format::Symbol = :netcdf4,
                   share::Bool = false,
                   diskless::Bool = false,
                   persist::Bool = false,
                   memory::Union{Vector{UInt8},Nothing} = nothing,
                   attrib = [])

    ncid = -1
    isdefmode = Ref(false)

    ncmode =
        if mode == "r"
            NC_NOWRITE
        elseif mode == "a"
            NC_WRITE
        elseif mode == "c"
            NC_CLOBBER
        else
            throw(NetCDFError(-1, "Unsupported mode '$(mode)' for filename '$(filename)'"))
        end

    if diskless
        ncmode = ncmode | NC_DISKLESS

        if persist
            ncmode = ncmode | NC_PERSIST
        end
    end

    if share
        @debug "share mode"
        ncmode = ncmode | NC_SHARE
    end

    @debug "ncmode: $ncmode"

    if (mode == "r") || (mode == "a")
        if isnothing(memory)
            ncid = nc_open(filename,ncmode)
        else
            ncid = nc_open_mem(filename,ncmode,memory)
        end
    elseif mode == "c"
        if format == :netcdf5_64bit_data
            ncmode = ncmode | NC_64BIT_DATA
        elseif format == :netcdf3_64bit_offset
            ncmode = ncmode | NC_64BIT_OFFSET
        elseif format == :netcdf4_classic
            ncmode = ncmode | NC_NETCDF4 | NC_CLASSIC_MODEL
        elseif format == :netcdf4
            ncmode = ncmode | NC_NETCDF4
        elseif format == :netcdf3_classic
            # do nothing
        else
            throw(NetCDFError(-1, "Unkown format '$(format)' for filename '$(filename)'"))
        end

        ncid = nc_create(filename,ncmode)
        isdefmode[] = true
    end

    iswritable = mode != "r"
    ds = NCDataset(ncid,iswritable,isdefmode)

    # set global attributes
    for (attname,attval) in attrib
        ds.attrib[attname] = attval
    end

    return ds
end


############################################################
# High-level: user convenience
############################################################
"""
    keys(ds::NCDataset)

Return a list of all variables names in NCDataset `ds`.
"""
keys(ds::NCDataset) = listVar(ds.ncid)


"""
    close(ds::NCDataset)

Close the NCDataset `ds`. All pending changes will be written
to the disk.
"""
function close(ds::NCDataset)
    try
        nc_close(ds.ncid)
    catch err
        # like Base, allow close on closed file
        if isa(err,NetCDFError)
            if err.code == NC_EBADID
                return ds
            end
        end
        rethrow()
    end
    # prevent finalize to close file as ncid can reused for future files
    ds.ncid = -1
    return ds
end


"""
    haskey(ds::NCDataset,name)

Return true if the NCDataset `ds` (or dimension/attribute list) has a variable (dimension/attribute) with the name `name`.
For example:

```julia
ds = NCDataset("/tmp/test.nc","r")
if haskey(ds,"temperature")
    println("The file has a variable 'temperature'")
end

if haskey(ds.dim,"lon")
    println("The file has a dimension 'lon'")
end
```

This example checks if the file `/tmp/test.nc` has a variable with the
name `temperature` and a dimension with the name `lon`.
"""
haskey(a::NCIterable,name::Union{AbstractString,Symbol}) = name in keys(a)
