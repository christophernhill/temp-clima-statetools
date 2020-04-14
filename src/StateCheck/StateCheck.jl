"""
 StateCheck :: Moduels with a minimal set of functions for gettings statistics 
               and basic I/O from CLIMA DG state st=rrays, intended for regression 
               testing and code change tracking.
"""
module StateCheck

import CLIMA.GenericCallbacks: EveryXSimulationSteps
import CLIMA.MPIStateArrays:   MPIStateArray

export sccreate

"""
 sccreate :: Create a state checker 
             Takes in a tuple of MPIStateArrays and label pairs.
             Creates a state checker that
             can be used in a callback().
"""
sccreate(fields::Tuple{ Tuple{Any,Any,}, },ntFreq::Int=10) = (
 println("Creating a state checker with Tuple...!");
 cbtest=EveryXSimulationSteps(10) do (s=false); end ;
 return cbtest;
)

end # module
