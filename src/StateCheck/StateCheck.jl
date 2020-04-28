"""
 StateCheck :: Module with a minimal set of functions for gettings statistics 
               and basic I/O from CLIMA DG state arrays (MPIStateArray type). 
               Created for regression testing and code change tracking and debugging.
               StateCheck functions iterate over named variables in an MPIStateArray,
               calculate and report their statistics and/or write values for all or
               some subset of points at a fixed frequency.
"""
module StateCheck

# Imports from standard Julia packages
using MPI
using Printf
using Statistics
using Formatting

# Imports from CLIMA core
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

# Global functions to expose
# sccreate - Create a state checker call back
export sccreate

# ntFreqDef:: default frequency (in time steps) for output.
ntFreqDef=10;
precDef=15;

"""
 sccreate :: Create a a "state check" call-back for one or more MPIStateArrays  \n
             that will report basic statistics for the fields in the array.

             Input:
                fields: A required first argument that is an array of one or more
                        MPIStateArrays and label string pair tuples.
                        State array statistics will be reported for the named symbols
                        in each MPIStateArray labeled with the label string.
                ntFreq: An optional second argument with default value of 
                        $ntFreqDef that sets how freuently (in time-step counts) the
                        statistics are reported.
             Named:
                  prec: A named argument that sets number of decimal places to print for
                        statistics, defaults to $precDef.

             Return: 
                sccb: A state checker that can be used in a callback().

             Example:
             julia> F1=@vars begin; ν∇u::SMatrix{3, 2, T, 6}; κ∇θ::SVector{3, T}; end
             julia> F2=@vars begin; u::SVector{2, T}; θ::SVector{1, T}; end
             julia> Q1=MPIStateArray{Float32,F1}(MPI.COMM_WORLD,CLIMA.array_type(),4,9,8);
             julia> Q2=MPIStateArray{Float64,F2}(MPI.COMM_WORLD,CLIMA.array_type(),4,6,8);
             julia> cb=StateCheck.sccreate([(Q1,"My gradients"),(Q2,"My fields")],1; prec=$precDef);
             julia> cb()
 ========================================================================================
"""
sccreate(fields::Array{ <:Tuple{<:MPIStateArray, String} },ntFreq::Int=ntFreqDef; prec=precDef) = ( 

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
  nSStr=@sprintf("%7.7d",nStep-1)

  ## Print header
  nprec=min(max(1,prec),20)
  println("# SC +++++++++++CLIMA StateCheck call-back start+++++++++++++++++")
  println("# SC  Step  |   Label    |  Field   |                            Stats                       ")
  hVarFmt="%" * sprintf1("%d",nprec+8) * "s"
  minStr=sprintf1(hVarFmt," min() ")
  maxStr=sprintf1(hVarFmt," max() ")
  aveStr=sprintf1(hVarFmt," mean() ")
  stdStr=sprintf1(hVarFmt," std() ")
  println("# SC =======|============|==========|",minStr,"|",maxStr,"|",aveStr,"|",stdStr,"|")

  ## Iterate over the set of MPIStateArrays for this callback
  for f in fields

   olabel=f[2];
   olStr=@sprintf("%12.12s",olabel)
   mArray=f[1];

   # Get descriptor for MPIStateArray

   V=typeof(mArray).parameters[2];

   ## Iterate over fields in each MPIStateArray
   #  (use ivar to index individual arrays within the MPIStateArray)
   ivar=0
   for i in 1:length(V.names)
    for n in flattenednames(fieldtype(V,i),prefix=fieldname(V,i))
     ivar=ivar+1
     nStr=@sprintf("%9.9s",n)
     print("# SC ",nSStr,"|",olStr,"|", nStr, " |")
     statsString=scstats(mArray,ivar,nprec)
     println(statsString[1],"|",statsString[2],"|",statsString[3],"|",statsString[4],"|")
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

function scstats(V,ivar,nprec)
  # Get number of MPI procs
  nproc = MPI.Comm_size(V.mpicomm)

  npr=nprec;fmt=@sprintf("%%%d.%de",npr+8,npr)

  # Min
  phiLoc=minimum(V.data[:,ivar,:])
  phiMin=MPI.Reduce(phiLoc,MPI.MIN,0,V.mpicomm)
  phi=phiMin
  # minVstr=@sprintf("%23.15e",phi)
  minVstr=sprintf1(fmt,phi)
  

  # Max
  phiLoc=maximum(V.data[:,ivar,:])
  phiMax=MPI.Reduce(phiLoc,MPI.MAX,0,V.mpicomm)
  phi=phiMax
  # maxVstr=@sprintf("%23.15e",phi)
  maxVstr=sprintf1(fmt,phi)

  # Ave
  phiLoc=mean(V.data[:,ivar,:])
  phiSum=MPI.Reduce(phiLoc,+,0,V.mpicomm)
  phiMean=phiSum/(nproc*1.)
  phi=phiMean
  # aveVstr=@sprintf("%23.15e",phi)
  aveVstr=sprintf1(fmt,phi)

  # Std
  phiLoc=(V.data[:,ivar,:].-phiMean).^2
  nVal=length(phiLoc)*1.
  phiSum=MPI.Reduce(phiLoc,+,0,V.mpicomm)
  nValSum=MPI.Reduce(nVal,+,0,V.mpicomm)
  phiStd=(sum(phiSum)/(nValSum-1))^0.5
  phi=phiStd
  # stdVstr=@sprintf("%23.15e",phi)
  stdVstr=sprintf1(fmt,phi)

  return minVstr, maxVstr, aveVstr, stdVstr
end

end # module
