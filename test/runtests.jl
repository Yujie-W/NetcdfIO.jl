using DataFrames
using NetcdfIO
using Test


@testset verbose = true "NetcdfIO Test" begin
    @testset "Grow" begin
        growable_nc!("growable.nc", ["ind"]);
        @test true;
    end;

    @testset "Save" begin
        data2 = rand(36,18) .+ 273.15;
        data3 = rand(36,18,5) .+ 273.15;
        attrn = Dict("description" => "Random temperature", "unit" => "K");
        notes = Dict("description" => "This is a file generated using PkgUtility.jl", "notes" => "PkgUtility.jl uses NCDatasets.jl to create NC files");
        save_nc!("data2.nc", "data2", attrn, data2);
        save_nc!("data3.nc", "data3", attrn, data3; notes=notes);
        save_nc!("data3_grow.nc", "data3", attrn, data3; notes=notes, growable=true);
        @test true;

        df = DataFrame();
        df[!,"A"] = rand(5);
        df[!,"B"] = rand(5);
        df[!,"C"] = rand(5);
        save_nc!("dataf.nc", df);
        save_nc!("dataf_grow.nc", df; growable=true);
        @test true;
    end;

    @testset "Append" begin
        # generate data to write into NC file
        lats = collect(Float64, -85:10:85);
        lons = collect(Float64, -175:10:175);
        inds = collect(Int, 1:5);
        data1 = rand(36) .+ 273.15;
        data2 = rand(36,18) .+ 273.15;
        data3 = rand(36,18,5) .+ 273.15;

        # define the attributes of the dimensions and data
        attrn = Dict("description" => "Random temperature", "unit" => "K");
        latat = Dict("description" => "Latitude", "unit" => "°");
        lonat = Dict("description" => "Longitude", "unit" => "°");
        indat = Dict("description" => "Cycle index", "unit" => "-");

        # define attributes names, information, and data
        atts_name1 = ["lon"];
        atts_name2 = ["lon", "lat"];
        atts_name3 = ["lon", "lat", "ind"];
        atts_attr1 = [lonat];
        atts_attr2 = [lonat, latat];
        atts_attr3 = [lonat, latat, indat];
        atts_data1 = Any[lons];
        atts_data2 = Any[lons, lats];
        atts_data3 = Any[lons, lats, inds];

        # save data as NC files (1D, 2D, and 3D)
        append_nc!("dataf.nc", "data1", attrn, data1, atts_name1, atts_attr1, atts_data1);
        @test true;
        append_nc!("dataf.nc", "data2", attrn, data2, atts_name2, atts_attr2, atts_data2);
        @test true;
        append_nc!("dataf.nc", "data3", attrn, data3, atts_name3, atts_attr3, atts_data3);
        @test true;
        append_nc!("dataf_grow.nc", "data3", attrn, data3, atts_name3, atts_attr3, atts_data3);
        @test true;
    end;

    @testset "Info" begin
        @test dimname_nc("data2.nc") == ["lon", "lat"];
        @test dimname_nc("data3.nc") == ["lon", "lat", "ind"];
        @test varname_nc("data2.nc") == ["data2"];
        @test varname_nc("data3.nc") == ["data3"];
        @test varname_nc("dataf.nc") == ["A", "B", "C", "data1", "data2", "data3"];
    end;

    @testset "Read" begin
        read_nc(Float32, "data2.nc", "data2");
        @test true;
        read_nc(Float32, "data3.nc", "data3", 1);
        @test true;
        read_nc(Float32, "data2.nc", "data2", 1, 1);
        @test true;
        read_nc(Float32, "data3.nc", "data3", 1, 1, 1);
        @test true;
        read_nc("dataf.nc", ["A", "B", "C"]);
        @test true;
    end;

    @testset "Size" begin
        @test size_nc("data2.nc", "data2") == (2, (36,18));
        @test size_nc("data3.nc", "data3") == (3, (36,18,5));
        @test size_nc("dataf.nc", "A"    ) == (1, (5,));
    end;
end;


# remove the generated nc files
rm("data2.nc"     ; force = true);
rm("data3.nc"     ; force = true);
rm("data3_grow.nc"; force = true);
rm("dataf.nc"     ; force = true);
rm("dataf_grow.nc"; force = true);
rm("growable.nc"  ; force = true);
