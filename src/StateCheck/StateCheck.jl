"""
 StateCheck :: Moduels with a minimal set of functions for gettings statistics 
               and basic I/O from CLIMA DG state st=rrays, intended for regression 
               testing and code change tracking.
"""
module StateCheck

using CLIMA.GenericCallbacks

export sccreate

"""
 sccreate :: Create a state checker 
             Takes in a set of MPIStateArrays and creates a state checker that
             can be used in a callback().
"""
sccreate() = print("Creating a state checker...!")


end # module
