"""
 StateCheck :: Module with a minimal set of functions for gettings statistics 
               and basic I/O from CLIMA DG state arrays (MPIStateArray type). 
               Created for regression testing and code change tracking and debugging.
               StateCheck functions iterate over named variables in an MPIStateArray,
               calculate and report their statistics and/or write values for all or
               some subset of points at a fixed frequency.
"""
module StateCheck

import CLIMA.GenericCallbacks:  EveryXSimulationSteps
import CLIMA.MPIStateArrays:    MPIStateArray
import CLIMA.VariableTemplates: flattenednames

####
# For testing put a new function signature here!
# Needs to go in CLIMA/src/Utilities/VariableTemplates/var_names.jl
# This handles SMatrix case
using Pkg
Pkg.add("StaticArrays");using StaticArrays
flattenednames(::Type{T}; prefix="") where {T<:SArray} = ntuple(i -> "$prefix[$i]", length(T))
####

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

             Example:
             julia> F1=@vars begin; ν∇u::SMatrix{3, 2, T, 6}; κ∇θ::SVector{3, T}; end
             julia> F2=@vars begin; u::SVector{2, T}; θ::SVector{1, T}; end
             julia> Q1=MPIStateArray{Float32,F1}(MPI.COMM_WORLD,CLIMA.array_type(),4,6,8);
             julia> Q2=MPIStateArray{Float64,F2}(MPI.COMM_WORLD,CLIMA.array_type(),4,6,8);
             julia> cb=StateCheck.sccreate([(Q1,"My gradients"),(Q2,"My fields")],1);
             julia> cb()
 ========================================================================================
"""
sccreate(fields::Array{ <:Tuple{<:MPIStateArray, String} },ntFreq::Int=ntFreqDef) = ( 

 println("# Start: creating state check callback"); 

 ####
 # Print fields that the call back create by this call will query
 ####
 for f in fields
  printHead=true
  Q=f[1];
  lab=f[2];
  slist=typeof(Q).parameters[2].names;
  l=length(slist);
  if l == 0
   println("#  MPIStateArray labeled \"$lab\" has no named symbols.");
  else
   for s in slist
    if printHead
     println("   Creating state check callback labeled \"$lab\" for symbols")
     printHead=false
    end
    println("    ",s)
   end
  end
 end;

 ###
 # Initialize total calls counter for the call back
 ###
 nCbCalls=0;

 ######
 # Create the callback
 ######
 cb=EveryXSimulationSteps(ntFreq) do (s=false); 
  # Track which timestep this is
  nCbCalls=nCbCalls+1;
  nStep=(nCbCalls-1)*ntFreq+1;

  ## Print header
  println("# SC +++++++++++CLIMA StateCheck call-back start+++++++++++++++++")
  println("# SC  Step      Label       Field                          Stats                       ")
  println("# SC ======= ============ ========= |== min() ===|=== max() ===|   mean()    std()     ")

  ## Iterate over the set of MPIStateArrays for this callback
  for f in fields

   olabel=f[2];
   mArray=f[1];

   # Get descriptor for MPIStateArray

   V=typeof(mArray).parameters[2];

   ## Iterate over fields in each MPIStateArray
   #  (use ivar to index individual arrays within the MPIStateArray)
   ivar=0
   for i in 1:length(V.names)
    for n in flattenednames(fieldtype(V,i),prefix=fieldname(V,i))
     ivar=ivar+1
     println("# SC step ",nStep,": ",olabel," ", n, " ", ivar)
    end
   end
  end
  println("# SC +++++++++++CLIMA StateCheck call-back end+++++++++++++++++++")
 end ;

 println("# Finish: creating state check callback"); 

 return cb;
)

# Anything else prints doc
sccreate(Any...) = ( 
 println("# ERROR: Function signature not matched");
 @doc sccreate;
)
sccreate()=sccreate(0)

end # module
