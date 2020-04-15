"""
 StateCheck :: Moduels with a minimal set of functions for gettings statistics 
               and basic I/O from CLIMA DG state st=rrays, intended for regression 
               testing and code change tracking.
"""
module StateCheck

import CLIMA.GenericCallbacks: EveryXSimulationSteps
import CLIMA.MPIStateArrays:   MPIStateArray

export sccreate

# ntFreqDef:: default frequency (in time steps) for output.
ntFreqDef=10;

"""
 sccreate :: Create a state checker \n
             Takes in a tuple of MPIStateArrays and label pairs.
             Creates a state checker that
             can be used in a callback().
"""
sccreate(fields::Array{ Tuple{UnionAll,String},1 },ntFreq::Int=10) = (
 println("Creating a state checker with Tuple...!");
 cbtest=EveryXSimulationSteps(10) do (s=false); end ;
 return cbtest;
)
sccreate(fields::Array{ <:Tuple{<:MPIStateArray, String} },ntFreq::Int=ntFreqDef) = ( 
 println("MPIStateArray in tuple, String"); 
)
sccreate(Any) = ( 
 println("# Creates state check call backs for an array of tuples, each tuple holding ");
 println("# CLIMA.MPIStateArrays.MPIStateArray and id label pairs, passed in as the   ");
 println("# first argument.");
 println("# The call back will be set to occur at a given number of timesteps in frequency.");
 println("# The default frequency of $ntFreqDef can be overridden by a second argument.");
 @doc sccreate;
)

end # module
