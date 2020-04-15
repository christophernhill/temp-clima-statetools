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
 sccreate :: Create a "state check" call-back for one or more MPIStateArrays. \n
              Input:
                fields: A required first argument that is an array of one or more
                        MPIStateArrays and label string pair tuples.
                        State array statistics will be reported for the named symbols
                        in each MPIStateArray labeled with the label string.
                ntFreq: An optional second argument with default value of 
                        $ntFreqDef that sets how freuently (in time-step counts) the
                        statistics are reported.
             Return: 
                  sccb: A state checker that can be used in a callback().
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
 @doc sccreate;
)
sccreate()=sccreate(0)

end # module
