# NetcdfIO.jl

<!-- Links and shortcuts -->
[ju-url]: https://github.com/Yujie-W/NetcdfIO.jl
[ju-api]: https://yujie-w.github.io/NetcdfIO.jl/stable/API/

[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://Yujie-W.github.io/NetcdfIO.jl/dev/

[rel-img]: https://img.shields.io/badge/docs-stable-blue.svg
[rel-url]: https://Yujie-W.github.io/NetcdfIO.jl/stable/

[st-img]: https://github.com/Yujie-W/NetcdfIO.jl/workflows/JuliaStable/badge.svg?branch=main
[st-url]: https://github.com/Yujie-W/NetcdfIO.jl/actions?query=branch%3A"main"++workflow%3A"JuliaStable"

[min-img]: https://github.com/Yujie-W/NetcdfIO.jl/workflows/Julia-1.6/badge.svg?branch=main
[min-url]: https://github.com/Yujie-W/NetcdfIO.jl/actions?query=branch%3A"main"++workflow%3A"Julia-1.6"

[cov-img]: https://codecov.io/gh/Yujie-W/NetcdfIO.jl/branch/main/graph/badge.svg
[cov-url]: https://codecov.io/gh/Yujie-W/NetcdfIO.jl

## About
NetcdfIO contains a number of wrapper functions for NCDatasets.jl. The use of these functions significantly reduce the number of code to read/write data from/to a netcdf file. Note that NetcdfIO does not have HDF4 support; if you need to open HDF4 files, use `NetCDF` v0.10 or `NCDatasets` v0.10 on a old system (for example, our server has a netcdf v4.3.3.1 installed, and it works; my desktop has a netcdf v4.8.1 installed, but it does not work).

| Documentation                                   | CI Status             | Compatibility           | Code Coverage           |
|:------------------------------------------------|:----------------------|:------------------------|:------------------------|
| [![][dev-img]][dev-url] [![][rel-img]][rel-url] | [![][st-img]][st-url] | [![][min-img]][min-url] | [![][cov-img]][cov-url] |


## Installation
```julia
julia> using Pkg;
julia> Pkg.add("NetcdfIO");
```


## API
See [`API`][ju-api] for more detailed information about how to use [`NetcdfIO.jl`][ju-url].
