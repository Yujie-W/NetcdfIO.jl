############################################################
# Creating variables
############################################################

"""
    defVar(ds::NCDataset,name,vtype,dimnames; kwargs...)
    defVar(ds::NCDataset,name,data,dimnames; kwargs...)

Define a variable with the name `name` in the dataset `ds`.  `vtype` can be
Julia types in the table below (with the corresponding NetCDF type). The
parameter `dimnames` is a tuple with the names of the dimension.  For scalar
this parameter is the empty tuple `()`.
The variable is returned (of the type `CFVariable`).

Instead of providing the variable type one can directly give also the data `data` which
will be used to fill the NetCDF variable. In this case, the dimensions with
the appropriate size will be created as required using the names in `dimnames`.

If `data` is a vector or array of `DateTime` objects, then the dates
are saved as double-precision floats and units
"CFTime.DEFAULT_TIME_UNITS" (unless a time unit
is specifed with the `attrib` keyword as described below). Dates are
converted to the default calendar in the CF conversion which is the
mixed Julian/Gregorian calendar.

## Keyword arguments

* `fillvalue`: A value filled in the NetCDF file to indicate missing data.
   It will be stored in the _FillValue attribute.
* `chunksizes`: Vector integers setting the chunk size. The total size of a chunk must be less than 4 GiB.
* `deflatelevel`: Compression level: 0 (default) means no compression and 9 means maximum compression. Each chunk will be compressed individually.
* `shuffle`: If true, the shuffle filter is activated which can improve the compression ratio.
* `checksum`: The checksum method can be `:fletcher32` or `:nochecksum` (checksumming is disabled, which is the default)
* `attrib`: An iterable of attribute name and attribute value pairs, for example a `Dict`, `DataStructures.OrderedDict` or simply a vector of pairs (see example below)
* `typename` (string): The name of the NetCDF type required for [vlen arrays](https://web.archive.org/save/https://www.unidata.ucar.edu/software/netcdf/netcdf-4/newdocs/netcdf-c/nc_005fdef_005fvlen.html)

`chunksizes`, `deflatelevel`, `shuffle` and `checksum` can only be
set on NetCDF 4 files. Compression of strings and variable-length arrays is not
supported by the underlying NetCDF library.

## NetCDF data types

| NetCDF Type | Julia Type |
|-------------|------------|
| NC_BYTE     | Int8 |
| NC_UBYTE    | UInt8 |
| NC_SHORT    | Int16 |
| NC_INT      | Int32 |
| NC_INT64    | Int64 |
| NC_FLOAT    | Float32 |
| NC_DOUBLE   | Float64 |
| NC_CHAR     | Char |
| NC_STRING   | String |


## Dimension ordering

The data is stored in the NetCDF file in the same order as they are stored in
memory. As julia uses the
[Column-major ordering](https://en.wikipedia.org/wiki/Row-_and_column-major_order)
for arrays, the order of dimensions will appear reversed when the data is loaded
in languages or programs using
[Row-major ordering](https://en.wikipedia.org/wiki/Row-_and_column-major_order)
such as C/C++, Python/NumPy or the tools `ncdump`/`ncgen`
([NetCDF CDL](https://web.archive.org/web/20220513091844/https://docs.unidata.ucar.edu/nug/current/_c_d_l.html)).
NumPy can also use Column-major ordering but Row-major order is the default. For the column-major
interpretation of the dimensions (as in Julia), the
[CF Convention recommends](https://web.archive.org/web/20220328110810/http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html#dimensions) the
order  "longitude" (X), "latitude" (Y), "height or depth" (Z) and
"date or time" (T) (if applicable). All other dimensions should, whenever
possible, be placed to the right of the spatiotemporal dimensions.

## Example:

In this example, `scale_factor` and `add_offset` are applied when the `data`
is saved.

```julia-repl
julia> using DataStructures
julia> data = randn(3,5)
julia> NCDataset("test_file.nc","c") do ds
          defVar(ds,"temp",data,("lon","lat"), attrib = OrderedDict(
             "units" => "degree_Celsius",
             "add_offset" => -273.15,
             "scale_factor" => 0.1,
             "long_name" => "Temperature"
          ))
       end;
```

!!! note

    If the attributes `_FillValue`, `missing_value`, `add_offset`, `scale_factor`,
    `units` and `calendar` are used, they should be defined when calling `defVar`
    by using the parameter `attrib` as shown in the example above.


"""
function defVar(ds::NCDataset,name::Union{Symbol, AbstractString},vtype::DataType,dimnames;
                chunksizes = nothing,
                shuffle = false,
                deflatelevel = nothing,
                checksum = nothing,
                fillvalue = nothing,
                nofill = false,
                typename = nothing,
                attrib = ())
    defmode(ds) # make sure that the file is in define mode
    dimids = Cint[nc_inq_dimid(ds.ncid,dimname) for dimname in dimnames[end:-1:1]]

    typeid =
        if vtype <: Vector
            # variable-length type
            typeid = nc_def_vlen(ds.ncid, typename, ncType[eltype(vtype)])
        else
            # base-type
            ncType[vtype]
        end

    varid = nc_def_var(ds.ncid,name,typeid,dimids)

    if !isnothing(chunksizes)
        storage = :chunked
        # this will fail on NetCDF-3 files
        nc_def_var_chunking(ds.ncid,varid,storage,reverse(chunksizes))
    end

    if shuffle || !isnothing(deflatelevel)
        deflate = !isnothing(deflatelevel)

        # this will fail on NetCDF-3 files
        nc_def_var_deflate(ds.ncid,varid,shuffle,deflate,deflatelevel)
    end

    if !isnothing(checksum)
        nc_def_var_fletcher32(ds.ncid,varid,checksum)
    end

    if !isnothing(fillvalue)
        nc_def_var_fill(ds.ncid, varid, nofill, vtype(fillvalue))
    end

    v = ds[name]
    for (attname,attval) in attrib
        v.attrib[attname] = attval
    end

    # note: element type of ds[name] potentially changed
    # we cannot return v here
    return ds[name]
end
