using Documenter
using NetcdfIO


# define default docs pages
pages = Pair{Any,Any}[
    "Home"       => "index.md",
    "libnetcdf"  => "libnetcdf.md",
    "ncdatasets" => "ncdatasets.md",
];


# format the docs
mathengine = MathJax(
    Dict(
        :TeX => Dict(
            :equationNumbers => Dict(:autoNumber => "AMS"),
            :Macros => Dict(),
        )
    )
);

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = mathengine,
    collapselevel = 1
);


# build the docs
makedocs(
    sitename = "NetcdfIO.jl",
    format = format,
    clean = false,
    modules = [NetcdfIO],
    pages = pages,
    warnonly = [:cross_references, :missing_docs],
);


# deploy the docs to Github gh-pages
deploydocs(repo = "github.com/Yujie-W/NetcdfIO.jl.git", devbranch = "main");
