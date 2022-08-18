var documenterSearchIndex = {"docs":
[{"location":"#NetcdfIO.jl","page":"Home","title":"NetcdfIO.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Utility functions to read and write netcdf files using NCDatasets","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"julia> using Pkg;\njulia> Pkg.add(\"NetcdfIO\");","category":"page"},{"location":"API/#API","page":"API","title":"API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"CurrentModule = NetcdfIO","category":"page"},{"location":"API/#Read-variable-size-from-netcdf","page":"API","title":"Read variable size from netcdf","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"size_nc","category":"page"},{"location":"API/#NetcdfIO.size_nc","page":"API","title":"NetcdfIO.size_nc","text":"size_nc(file::String, var::String)\n\nReturn the dimensions and size of a NetCDF dataset, given\n\nfile Dataset path\nvar Variable name\n\n\n\nExamples\n\nndims,sizes = read_nc(\"test.nc\", \"test\");\n\n\n\n\n\n","category":"function"},{"location":"API/#Read-variable-from-netcdf","page":"API","title":"Read variable from netcdf","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"read_nc\nread_nc(file::String, var::String)\nread_nc(T, file::String, var::String)\nread_nc(file::String, var::String, indz::Int)\nread_nc(T, file::String, var::String, indz::Int)\nread_nc(file::String, var::String, indx::Int, indy::Int)\nread_nc(T, file::String, var::String, indx::Int, indy::Int)\nread_nc(file::String, var::String, indx::Int, indy::Int, indz::Int)\nread_nc(T, file::String, var::String, indx::Int, indy::Int, indz::Int)","category":"page"},{"location":"API/#NetcdfIO.read_nc","page":"API","title":"NetcdfIO.read_nc","text":"NCDatasets.jl and NetCDF.jl both provide function to read data out from NC dataset. However, while NetCDF.jl is more convenient to use (less lines of code to read data), NCDatasets.jl is better to     read a subset from the dataset and is able to detect the scale factor and offset. Here, we used a wrapper function to read NC dataset using NCDatasets.jl:\n\nread_nc(file, var)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:29.\n\nread_nc(T, file, var)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:59.\n\nread_nc(file, var, indz)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:81.\n\nread_nc(T, file, var, indz)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:112.\n\nread_nc(file, var, indx, indy)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:132.\n\nread_nc(T, file, var, indx, indy)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:163.\n\nread_nc(file, var, indx, indy, indz)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:184.\n\nread_nc(T, file, var, indx, indy, indz)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/read.jl:212.\n\n\n\n\n\n","category":"function"},{"location":"API/#NetcdfIO.read_nc-Tuple{String, String}","page":"API","title":"NetcdfIO.read_nc","text":"When only file name and variable label are provided, read_nc function reads out all the data:\n\nread_nc(file::String, var::String)\n\nRead data from NC file, given\n\nfile Dataset path\nvar Variable to read\n\nNote that the missing data will be labeled as NaN.\n\n\n\nExamples\n\n# read data labeled as test from test.nc\ndata = read_nc(\"test.nc\", \"test\");\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.read_nc-Tuple{Any, String, String}","page":"API","title":"NetcdfIO.read_nc","text":"If a float type is given, the data will be converted to T, namely the output will be an array of T type numbers:\n\nread_nc(T, file::String, var::String)\n\nRead data from nc file, given\n\nT Number type\nfile Dataset path\nvar Variable name\n\n\n\nExamples\n\n# read data labeled as test from test.nc as Float32\ndata = read_nc(Float32, \"test.nc\", \"test\");\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.read_nc-Tuple{String, String, Int64}","page":"API","title":"NetcdfIO.read_nc","text":"In many cases, the NC dataset can be very huge, and reading all the data points into one array could be time and memory consuming. In this case, reading a subset of data would be the best option:\n\nread_nc(file::String, var::String, indz::Int)\n\nRead a subset from nc file, given\n\nfile Dataset path\nvar Variable name\nindz The 3rd index of subset data to read\n\nNote that the dataset must be a 3D array to use this method.\n\n\n\nExamples\n\n# read 1st layer data labeled as test from test.nc\ndata = read_nc(\"test.nc\", \"test\", 1);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.read_nc-Tuple{Any, String, String, Int64}","page":"API","title":"NetcdfIO.read_nc","text":"Similarly, one may want to read the subset as a certain type using\n\nread_nc(T, file::String, var::String, indz::Int)\n\nRead a subset from nc file, given\n\nT Number type\nfile Dataset path\nvar Variable name\nindz The 3rd index of subset data to read\n\n\n\nExamples\n\n# read 1st layer data labeled as test from test.nc as Float32\ndata = read_nc(Float32, \"test.nc\", \"test\", 1);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.read_nc-Tuple{String, String, Int64, Int64}","page":"API","title":"NetcdfIO.read_nc","text":"Another convenient wrapper is to read all the data for given index in x and y, for example, if one wants to read the time series of data at a given site:\n\nread_nc(file::String, var::String, indx::Int, indy::Int)\n\nRead the time series of data for a site, given\n\nfile Dataset path\nvar Variable name\nindx The 1st index of subset data to read, typically longitude\nindy The 2nd index of subset data to read, typically latitude\n\n\n\nExamples\n\ndata = read_nc(\"test.nc\", \"test\", 1, 1);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.read_nc-Tuple{Any, String, String, Int64, Int64}","page":"API","title":"NetcdfIO.read_nc","text":"Similarly, one may want to read the subset as a certain type using\n\nread_nc(T, file::String, var::String, indx::Int, indy::Int)\n\nRead the time series of data for a site, given\n\nT Number type\nfile Dataset path\nvar Variable name\nindx The 1st index of subset data to read, typically longitude\nindy The 2nd index of subset data to read, typically latitude\n\n\n\nExamples\n\ndata = read_nc(Float32, \"test.nc\", \"test\", 1, 1);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.read_nc-Tuple{String, String, Int64, Int64, Int64}","page":"API","title":"NetcdfIO.read_nc","text":"Another convenient wrapper is to read the data for given index in x, y, and z, for example, if one wants to read the time series of data at a given site:\n\nread_nc(file::String, var::String, indx::Int, indy::Int, indz::Int)\n\nRead the time series of data for a site, given\n\nfile Dataset path\nvar Variable name\nindx The 1st index of subset data to read, typically longitude\nindy The 2nd index of subset data to read, typically latitude\nindz The 3rd index of subset data to read, typically time\n\n\n\nExamples\n\ndata = read_nc(\"test.nc\", \"test\", 1, 1, 1);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.read_nc-Tuple{Any, String, String, Int64, Int64, Int64}","page":"API","title":"NetcdfIO.read_nc","text":"Similarly, one may want to read the data as a certain type using\n\nread_nc(T, file::String, var::String, indx::Int, indy::Int, indz::Int)\n\nRead the time series of data for a site, given\n\nT Number type\nfile Dataset path\nvar Variable name\nindx The 1st index of subset data to read, typically longitude\nindy The 2nd index of subset data to read, typically latitude\nindz The 3rd index of subset data to read, typically time\n\n\n\nExamples\n\ndata = read_nc(Float32, \"test.nc\", \"test\", 1, 1, 1);\n\n\n\n\n\n","category":"method"},{"location":"API/#Save-variable-to-netcdf","page":"API","title":"Save variable to netcdf","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"save_nc!\nsave_nc!(file::String, var_name::String, var_attr::Dict{String,String}, var_data::Array{T,N}, atts_name::Vector{String}, atts_attr::Vector{Dict{String,String}}, atts_data::Vector{Vector},\n    notes::Dict{String,String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}\nsave_nc!(file::String, var_name::String, var_attr::Dict{String,String}, var_data::Array{T,N}; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}\nsave_nc!(file::String, var_names::Vector{String}, var_attrs::Vector{Dict{String,String}}, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4)\nsave_nc!(file::String, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4)","category":"page"},{"location":"API/#NetcdfIO.save_nc!","page":"API","title":"NetcdfIO.save_nc!","text":"NCDatasets.jl does not have a convenient function (1 line command) to save dataset as a file. Thus, we provide a few methods as supplements:\n\nsave_nc!(file, var_name, var_attr, var_data, atts_name, atts_attr, atts_data, notes; compress)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/save.jl:79.\n\nsave_nc!(file, var_name, var_attr, var_data; notes, compress)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/save.jl:153.\n\nsave_nc!(file, var_names, var_attrs, df; notes, compress)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/save.jl:216.\n\nsave_nc!(file, df; notes, compress)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/save.jl:250.\n\n\n\n\n\n","category":"function"},{"location":"API/#NetcdfIO.save_nc!-Union{Tuple{N}, Tuple{T}, Tuple{String, String, Dict{String, String}, Array{T, N}, Vector{String}, Vector{Dict{String, String}}, Vector{Vector}, Dict{String, String}}} where {T<:Union{Int64, AbstractFloat, String}, N}","page":"API","title":"NetcdfIO.save_nc!","text":"This method is a case if one wants to save both variable and attributes into the target file. This method support saving multiple (N) dimension arrays:\n\nsave_nc!(file::String,\n         var_name::String,\n         var_attr::Dict{String,String},\n         var_data::Array{T,N},\n         atts_name::Vector{String},\n         atts_attr::Vector{Dict{String,String}},\n         atts_data::Vector{Vector},\n         notes::Dict{String,String};\n         compress::Int = 4\n) where {T<:Union{AbstractFloat,Int,String},N}\n\nSave dataset as NC file, given\n\nfile Path to save the dataset\nvar_name Variable name for the data in the NC file\nvar_attr Variable attributes for the data, such as unit and long name\nvar_data Data to save\natts_name vector of supporting attribute labels, such as lat and lon\natts_attr Vector of attributes for the supporting attributes, such as unit\natts_data Vector of attributes data, such as the latitude range\nnotes Global attributes (notes)\ncompress Compression level fro NetCDF, default is 4\n\n\n\nExamples\n\n# generate data to write into NC file\nlats = collect(Float64, -85:10:85);\nlons = collect(Float64, -175:10:175);\ninds = collect(Int, 1:12);\ndata1 = rand(18) .+ 273.15;\ndata2 = rand(36,18) .+ 273.15;\ndata3 = rand(36,18,12) .+ 273.15;\n\n# define the attributes of the dimensions and data\nattrn = Dict(\"description\" => \"Random temperature\", \"unit\" => \"K\");\nlatat = Dict(\"description\" => \"Latitude\", \"unit\" => \"°\");\nlonat = Dict(\"description\" => \"Longitude\", \"unit\" => \"°\");\nindat = Dict(\"description\" => \"Cycle index\", \"unit\" => \"-\");\n\n# define attributes names, information, and data\natts_name1 = [\"lat\"];\natts_name2 = [\"lon\", \"lat\"];\natts_name3 = [\"lon\", \"lat\", \"ind\"];\natts_attr1 = [latat];\natts_attr2 = [lonat, latat];\natts_attr3 = [lonat, latat, indat];\natts_data1 = Any[lats];\natts_data2 = Any[lons, lats];\natts_data3 = Any[lons, lats, inds];\nnotes = Dict(\"description\" => \"This is a file generated using PkgUtility.jl\", \"notes\" => \"PkgUtility.jl uses NCDatasets.jl to create NC files\");\n\n# save data as NC files (1D, 2D, and 3D)\nsave_nc!(\"data1.nc\", \"data1\", attrn, data1, atts_name1, atts_attr1, atts_data1, notes);\nsave_nc!(\"data2.nc\", \"data2\", attrn, data2, atts_name2, atts_attr2, atts_data2, notes);\nsave_nc!(\"data3.nc\", \"data3\", attrn, data3, atts_name3, atts_attr3, atts_data3, notes);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.save_nc!-Union{Tuple{N}, Tuple{T}, Tuple{String, String, Dict{String, String}, Array{T, N}}} where {T<:Union{Int64, AbstractFloat, String}, N}","page":"API","title":"NetcdfIO.save_nc!","text":"To save the code and effort to redefine the common attributes like latitude, longitude, and cycle index, we provide a shortcut method that handles these within the function:\n\nsave_nc!(file::String,\n         var_name::String,\n         var_attr::Dict{String,String},\n         var_data::Array{T,N};\n         notes::Dict{String,String} = ATTR_ABOUT,\n         compress::Int = 4\n) where {T<:Union{AbstractFloat,Int,String},N}\n\nSave the 2D or 3D data as NC file, given\n\nfile Path to save the dataset\nvar_name Variable name for the data in the NC file\nvar_attr Variable attributes for the data, such as unit and long name\nvar_data Data to save\nnotes Global attributes (notes)\ncompress Compression level fro NetCDF, default is 4\n\n\n\nExamples\n\n# generate data to write into NC file\ndata2 = rand(36,18) .+ 273.15;\ndata3 = rand(36,18,12) .+ 273.15;\n\n# define the attributes and notes\nattrn = Dict(\"description\" => \"Random temperature\", \"unit\" => \"K\");\nnotes = Dict(\"description\" => \"This is a file generated using PkgUtility.jl\", \"notes\" => \"PkgUtility.jl uses NCDatasets.jl to create NC files\");\n\n# save data as NC files (2D and 3D)\nsave_nc!(\"data2.nc\", \"data2\", attrn, data2);\nsave_nc!(\"data2.nc\", \"data2\", attrn, data2; notes=notes);\nsave_nc!(\"data3.nc\", \"data3\", attrn, data3);\nsave_nc!(\"data3.nc\", \"data3\", attrn, data3; notes=notes);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.save_nc!-Tuple{String, Vector{String}, Vector{Dict{String, String}}, DataFrames.DataFrame}","page":"API","title":"NetcdfIO.save_nc!","text":"This method saves DataFrame as a NetCDF file to save more space (compared to a CSV file).\n\nsave_nc!(file::String, var_names::Vector{String}, var_attrs::Vector{Dict{String,String}}, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4)\n\nSave DataFrame to NetCDF, given\n\nfile Path to save the data\nvar_names The label of data in DataFrame to save\nvar_attrs Variable attributes for the data to save\ndf DataFrame to save\nnotes Global attributes (notes)\ncompress Compression level fro NetCDF, default is 4\n\n\n\nExamples\n\ndf = DataFrame();\ndf[!,\"A\"] = rand(5);\ndf[!,\"B\"] = rand(5);\ndf[!,\"C\"] = rand(5);\nsave_nc!(\"test.nc\", [\"A\",\"B\"], [Dict(\"A\" => \"Attribute A\"), Dict(\"B\" => \"Attribute B\")], df);\n\n\n\n\n\n","category":"method"},{"location":"API/#NetcdfIO.save_nc!-Tuple{String, DataFrames.DataFrame}","page":"API","title":"NetcdfIO.save_nc!","text":"This method is a simplified version of the method above, namely when users do not want to define the attributes.\n\nsave_nc!(file::String, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4)\n\nSave DataFrame to NetCDF, given\n\nfile Path to save the data\ndf DataFrame to save\nnotes Global attributes (notes)\ncompress Compression level fro NetCDF, default is 4\n\n\n\nExamples\n\ndf = DataFrame();\ndf[!,\"A\"] = rand(5);\ndf[!,\"B\"] = rand(5);\ndf[!,\"C\"] = rand(5);\nsave_nc!(\"test.nc\", df);\n\n\n\n\n\n","category":"method"},{"location":"API/#Append-variable-to-netcdf","page":"API","title":"Append variable to netcdf","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"append_nc!\nappend_nc!(file::String, var_name::String, var_attr::Dict{String,String}, var_data::Array{FT,N}, atts_name::Vector{String}, atts_attr::Vector{Dict{String,String}}, atts_data::Vector; compress::Int =\n    4) where {FT<:AbstractFloat,N}","category":"page"},{"location":"API/#NetcdfIO.append_nc!","page":"API","title":"NetcdfIO.append_nc!","text":"NCDatasets.jl does not have a convenient function (1 line command) to append dataset into a file. Thus, we provide a few methods as supplements:\n\nappend_nc!(file, var_name, var_attr, var_data, atts_name, atts_attr, atts_data; compress)\n\ndefined at /home/runner/work/NetcdfIO.jl/NetcdfIO.jl/src/append.jl:76.\n\n\n\n\n\n","category":"function"},{"location":"API/#NetcdfIO.append_nc!-Union{Tuple{N}, Tuple{FT}, Tuple{String, String, Dict{String, String}, Array{FT, N}, Vector{String}, Vector{Dict{String, String}}, Vector}} where {FT<:AbstractFloat, N}","page":"API","title":"NetcdfIO.append_nc!","text":"This method append data to an exisiting NC file. If the attributes exist already, then only save the data:\n\nappend_nc!(file::String,\n           var_name::String,\n           var_attr::Dict{String,String},\n           var_data::Array{FT,N},\n           atts_name::Vector{String},\n           atts_attr::Vector{Dict{String,String}},\n           atts_data::Vector;\n           compress::Int = 4\n) where {FT<:AbstractFloat,N}\n\nAppend data to existing file, given\n\nfile Path to save the dataset\nvar_name Variable name for the data in the NC file\nvar_attr Variable attributes for the data, such as unit and long name\nvar_data Data to save\natts_name vector of supporting attribute labels, such as lat and lon\natts_attr Vector of attributes for the supporting attributes, such as unit\natts_data Vector of attributes data, such as the latitude range\ncompress Compression level fro NetCDF, default is 4\n\n\n\nExamples\n\n# generate data to write into NC file\nlats = collect(Float64, -85:10:85);\nlons = collect(Float64, -175:10:175);\ninds = collect(Int, 1:12);\ndata1 = rand(18) .+ 273.15;\ndata2 = rand(36,18) .+ 273.15;\ndata3 = rand(36,18,12) .+ 273.15;\n\n# define the attributes of the dimensions and data\nattrn = Dict(\"description\" => \"Random temperature\", \"unit\" => \"K\");\nlatat = Dict(\"description\" => \"Latitude\", \"unit\" => \"°\");\nlonat = Dict(\"description\" => \"Longitude\", \"unit\" => \"°\");\nindat = Dict(\"description\" => \"Cycle index\", \"unit\" => \"-\");\n\n# define attributes names, information, and data\natts_name1 = [\"lat\"];\natts_name2 = [\"lon\", \"lat\"];\natts_name3 = [\"lon\", \"lat\", \"ind\"];\natts_attr1 = [latat];\natts_attr2 = [lonat, latat];\natts_attr3 = [lonat, latat, indat];\natts_data1 = Any[lats];\natts_data2 = Any[lons, lats];\natts_data3 = Any[lons, lats, inds];\nnotes = Dict(\"description\" => \"This is a file generated using PkgUtility.jl\", \"notes\" => \"PkgUtility.jl uses NCDatasets.jl to create NC files\");\n\n# save data as NC files (1D, 2D, and 3D)\nappend_nc!(\"data1.nc\", \"datax\", attrn, data1, atts_name1, atts_attr1, atts_data1);\nappend_nc!(\"data2.nc\", \"datax\", attrn, data2, atts_name2, atts_attr2, atts_data2);\nappend_nc!(\"data3.nc\", \"datax\", attrn, data3, atts_name3, atts_attr3, atts_data3);\n\n\n\n\n\n","category":"method"}]
}