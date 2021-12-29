using DataFrames
using NetcdfIO
using Test


@testset "NetcdfIO - save variable" begin
    data2 = rand(36,18) .+ 273.15;
    data3 = rand(36,18,12) .+ 273.15;
    attrn = Dict("description" => "Random temperature", "unit" => "K");
    notes = Dict("description" => "This is a file generated using PkgUtility.jl", "notes" => "PkgUtility.jl uses NCDatasets.jl to create NC files");
    save_nc!("data2.nc", "data2", attrn, data2);
    save_nc!("data3.nc", "data3", attrn, data3; notes=notes);
    @test true;

    df = DataFrame();
    df[!,"A"] = rand(5);
    df[!,"B"] = rand(5);
    df[!,"C"] = rand(5);
    save_nc!("dataf.nc", df);
    @test true;
end


# remove the generated nc files
rm("data2.nc"; force = true);
rm("data3.nc"; force = true);
rm("dataf.nc"; force = true);
