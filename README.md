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
NetcdfIO contains a number of wrapper functions for NCDatasets.jl. The use of these functions significantly reduce the number of code to read/write data from/to a netcdf file (may not be efficient though). Note that the libnetcdf shipped with NCDatasets does not have HDF4 support; if you need to open HDF4 files, we have implemented a function `switch_netcdf_lib!` to allow the users to switch between libnetcdf library. What works on my case if I installed libnetcdf through Conda.jl (4.8.1 in my case, located at `~/.julia/conda/3/lib/libnetcdf.so`), and double checked that HDF4 support is enabled. Then I ran `switch_netcdf_lib!(use_default = false)` to enable it. You can also run `switch_netcdf_lib!()` to switch back to the default library shipped with NCDatasets.

| Documentation                                   | CI Status             | Compatibility           | Code Coverage           |
|:------------------------------------------------|:----------------------|:------------------------|:------------------------|
| [![][dev-img]][dev-url] [![][rel-img]][rel-url] | [![][st-img]][st-url] | [![][min-img]][min-url] | [![][cov-img]][cov-url] |


## Installation
```julia
using Pkg;
Pkg.add("NetcdfIO");
```


## API
See [`API`][ju-api] for more detailed information about how to use [`NetcdfIO.jl`][ju-url].
