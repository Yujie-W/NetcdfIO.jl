# NetcdfIO.jl

<!-- Links and shortcuts -->
[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://Yujie-W.github.io/NetcdfIO.jl/dev/

[rel-img]: https://img.shields.io/badge/docs-stable-blue.svg
[rel-url]: https://Yujie-W.github.io/NetcdfIO.jl/stable/

[st-img]: https://github.com/Yujie-W/NetcdfIO.jl/actions/workflows/JuliaStable.yml/badge.svg
[st-url]: https://github.com/Yujie-W/NetcdfIO.jl/actions/workflows/JuliaStable.yml

[cov-img]: https://codecov.io/gh/Yujie-W/NetcdfIO.jl/branch/main/graph/badge.svg
[cov-url]: https://codecov.io/gh/Yujie-W/NetcdfIO.jl

## About
NetcdfIO contains a number of functions for NCDatasets.jl. The use of these functions significantly reduce the number of code to read/write data from/to a netcdf file (may not be efficient though). Note that the libnetcdf shipped with NCDatasets does not have HDF4 support; if you need to open HDF4 files, we have implemented a function `switch_netcdf_lib!` to allow the users to switch between libnetcdf library. What works on my case if I installed libnetcdf through Conda.jl (4.8.1 in my case, located at `~/.julia/conda/3/lib/libnetcdf.so`), and double checked that HDF4 support is enabled. Then I ran `switch_netcdf_lib!(use_default = false)` to enable it. You can also run `switch_netcdf_lib!()` to switch back to the default library shipped with NetCDF_jll.

| Documentation                                   | CI Status             | Code Coverage           |
|:------------------------------------------------|:----------------------|:------------------------|
| [![][dev-img]][dev-url] [![][rel-img]][rel-url] | [![][st-img]][st-url] | [![][cov-img]][cov-url] |


## Installation
```
using Pkg;
Pkg.add("NetcdfIO");
```


## API
See [`API`][ju-api] for more detailed information about how to use [`NetcdfIO.jl`][ju-url].


## Test local coverage
```
using Pkg
Pkg.test("NetcdfIO"; coverage=true);

using Coverage
coverage = process_folder();
LCOV.writefile("lcov.info", coverage);

Coverage.clean_folder(".");
```
