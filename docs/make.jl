push!(LOAD_PATH,"../src/")
using
 Documenter,
 Literate

const EXAMPLES_DIR = joinpath(@__DIR__,  "..", "tutorials" )
const OUTPUT_DIR   = joinpath(@__DIR__, "src", "generated" )

# Diagnostics/Debug/statestats.jl 

Literate.markdown( joinpath(EXAMPLES_DIR,"Diagnostics/Debug/statestats.jl") , OUTPUT_DIR, documenter=true )

makedocs(sitename="ClimateMachine/Diagnostics/Debug", pages = [ "Home" => "index.md", "Examples" => "generated/statestats.md" ] )
