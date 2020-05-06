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
using Formatting
using MPI
using Printf
using Statistics

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

struct vstat ; max; min; mean; std ; end

# Global functions to expose
# sccreate - Create a state checker call back
export sccreate
export scdocheck
export scprint

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
             julia> using CLIMA.VariableTemplates
             julia> using StaticArrays
             julia> using CLIMA.MPIStateArrays
             julia> using MPI
             julia> MPI.Init()
             julia> T=Float64
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

 ###
 # Create holder for most recent stats
 ###
 curStats_dict=Dict();
 curStats_flat=[];

 ######
 # Create the callback
 ######
 cb=EveryXSimulationSteps(ntFreq) do (s=false); 
  # Track which timestep this is
  nCbCalls=nCbCalls+1;
  nStep=(nCbCalls-1)*ntFreq+1;
  nSStr=@sprintf("%7.7d",nStep-1)

  ## Free previous curStats_flat if there is one 
  #  (interesting piece of code - it works, but I am not sure its very elegant!)
  for i in range(1,length=length(curStats_flat))
   pop!(curStats_flat)
  end


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
   statsVal_dict=Dict()
   for i in 1:length(V.names)
    for n in flattenednames(fieldtype(V,i),prefix=fieldname(V,i))
     ivar=ivar+1
     nStr=@sprintf("%9.9s",n)
     print("# SC ",nSStr,"|",olStr,"|", nStr, " |")
     statsString=scstats(mArray,ivar,nprec)
     println(statsString[1],"|",statsString[2],"|",statsString[3],"|",statsString[4],"|")
     statsVal_dict[n]=statsString[5];
     append!(curStats_flat, [ 
      [olabel,n,statsString[5].max,statsString[5].min,statsString[5].mean,statsString[5].std] 
     ] )
    end
   end
   curStats_dict[olabel]=statsVal_dict;
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

  vals=vstat(phiMin,phiMax,phiMean,phiStd)

  return minVstr, maxVstr, aveVstr, stdVstr, vals
end

"""
 scprintref :: Print out a "state check" call-back table of values in a format
               suitable for use as a set of reference numbers for CI comparison.

               Input:
                cb - callback variable of type CLIMA.GenericCallbacks.Every*
               Updates:
                Nothing
               Returns:
                Nothing - prints to REPL
"""
function scprintref( cb )
 # Get print format lengths for cols 1 and 2 so they are aligned
 # for readability.
 phi=cb.func.curStats_flat;
 f=1;
 a1l=maximum( length.(map(i->(phi[i])[f],range(1,length=length(phi)) )) )
 f=2;
 a2l=maximum( length.(String.((map(i->(phi[i])[f],range(1,length=length(phi)) )) ) ) )
 fmt1=@sprintf("%%%d.%ds",a1l,a1l) # Column 1
 fmt2=@sprintf("%%%d.%ds",a2l,a2l) # Column 2
 fmt3=@sprintf("%%28.20e")         # All numbers at full precision
 # Create an string of spaces to be used for fomatting
 sp="                                                                           "

 # Write header
 println("# BEGIN SCPRINT")
 println("# varr - reference values (from reference run)    ")
 println("# parr - digits match precision (hand edit as needed) ")
 println("#")
 println("# [")
 println("#  [ MPIStateArray Name, Field Name, Maximum, Minimum, Mean, Standard Deviation ],")
 println("#  [         :                :          :        :      :          :           ],")
 println("# ]")
 #
 # Write tables
 #  Reference value and precision match tables are separate since it is more
 #  common to update reference values occiasionally while precision values are
 #  typically changed rarely and the precision values are hand edited from experience.
 #
 # Write table of reference values
 println("varr = [")
 for lv in cb.func.curStats_flat
  s1=lv[1]
  l1=length(s1); s1=sp[1:a1l-l1] * "\"" * s1 * "\"";
  s2=lv[2]
  if typeof(s2) == String
    l2=length(s2); s2=sp[1:a2l-l2] * "\"" * s2 * "\"";
    s22="";
  end
  if typeof(s2) == Symbol
    s22=s2;
    l2=length(String(s2)); s2=sp[1:a2l-l2+1] * ":";
  end
  s3=sprintf1(fmt3,lv[3])
  s4=sprintf1(fmt3,lv[4])
  s5=sprintf1(fmt3,lv[5])
  s6=sprintf1(fmt3,lv[6])
  println( " [ ", s1,", ", s2,s22,"," ,s3,",", s4,",", s5,",", s6," ]," )
 end
 println("]")

 # Write table of reference match precisions using default precision that
 # can be hand upadated.
 println("parr = [")
 for lv in cb.func.curStats_flat
  s1=lv[1]
  l1=length(s1); s1=sp[1:a1l-l1] * "\"" * s1 * "\"";
  s2=lv[2]
  if typeof(s2) == String
    l2=length(s2); s2=sp[1:a2l-l2] * "\"" * s2 * "\"";
    s22="";
  end
  if typeof(s2) == Symbol
    s22=s2;
    l2=length(String(s2)); s2=sp[1:a2l-l2+1] * ":";
  end
  s3=sprintf1(fmt3,lv[3])
  s4=sprintf1(fmt3,lv[4])
  s5=sprintf1(fmt3,lv[5])
  s6=sprintf1(fmt3,lv[6])
  println( " [ ", s1,", ", s2,s22,"," ,"    16,    16,    16,    16 ]," )
 end
 println("]")
 println("# END SCPRINT")
end

"""
"""
function scdocheck( cb, refDat )

  irow=1
  for row in cb.func.curStats_flat
   println(row)
   println(refDat[1][irow])
   irow=irow+1
  end
end

end # module
