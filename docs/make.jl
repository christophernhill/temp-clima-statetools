push!(LOAD_PATH,"../src/")
using Pkg
Pkg.add( PackageSpec(url="../../climatemachine.jl") )
Pkg.add("MPI")
Pkg.add("StaticArrays")

Pkg.add("Documenter")
Pkg.add("Literate")

using
 Documenter,
 Literate

const EXAMPLES_DIR = joinpath(@__DIR__,  "..", "tutorials" )
const OUTPUT_DIR   = joinpath(@__DIR__, "src", "generated" )

Literate.markdown( joinpath(EXAMPLES_DIR,"Diagnostics/Debug/StateCheck.jl") , OUTPUT_DIR, documenter=true )

makedocs(sitename="ClimateMachine/Diagnostics/Debug", pages = [ "Home" => "index.md", "Examples" => "generated/StateCheck.md" ] )
