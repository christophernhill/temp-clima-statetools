"""
 CLIMAStateCheck :: Moduels with a minimal set of functions for gettings statistics 
                    and basic I/O from CLIMA DG state st=rrays, intended for regression 
                    testing and code change tracking.
"""
module CLIMAStateCheck

export greet

"""
 A test greeting function
"""
greet() = print("Hello World...!")

end # module
