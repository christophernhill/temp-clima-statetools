"""
 ClimateMachineStateCheck :: Modules with a minimal set of functions for gettings statistics 
                    and basic I/O from CLIMA DG state arrays, intended for regression 
                    testing and code change tracking.
"""
module ClimateMachineStateCheck

export greet

"""
 A test greeting function
"""
greet() = print("Hello Hello World...!")

include("StateCheck/StateCheck.jl")

end # module
