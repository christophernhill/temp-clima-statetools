# # State debug statistics
#
# This page shows how to use the ```Statestats``` functions to get basic
# statistics for nodal values of fields held in ClimateMachine ```MPIStateArray```
# data structures. The ```Statestats``` functions can be used to
#
# 1. Generate statistics on ```MPIStateArray``` holding the state #    of a ClimateMachine experiment.
# 
#    and to
#
# 2. Compare against saved reference statistics from ClimateMachine ```MPIStateArray```
#    variables. This can enable simple automated regression test checks for
#    detecting unexpected changes introduced into numerical experiments
#    by code updates.
#


# ## Generating statistics
#
# Here we create a callback that can generate statistics for an arbitrary
# set of the MPIStateArray type variables of the sort that hold persistent state for
# ClimateMachine models. We then invoke the call back to show the statistics.
#
# In regular use the ```MPIStateArray``` variables will come from model configurations.
# Here we create a dummy set of ```MPIStateArray``` variables for use in stand alone
# examples.

# ### Create a dummy set of MPIStateArrays
#
# First we set up two ```MPIStateArray``` variables. This need a few packages to be in placeT,
# and utilizes some utility functions to create the array and add named
# persistent state variables.
# This is usually handled automatically as part of model deefinition in regular
# ClimateMachine activity.

# Set up a basic environment
using ClimateMachine
using ClimateMachine.VariableTemplates
using ClimateMachine.MPIStateArrays
MPI.Init()
T=Float64

# Define some dummy vector and tensor abstract variables with associated types
# and dimensions
F1=@vars begin; ν∇u::SMatrix{3, 2, T, 6}; κ∇θ::SVector{3, T}; end
F2=@vars begin; u::SVector{2, T}; θ::SVector{1, T}; end

# Create ```MPIStateArray``` variables with arrays to hold elements of the 
# vectors and tensors
Q1=MPIStateArray{Float32,F1}(MPI.COMM_WORLD,CLIMA.array_type(),4,9,8)
Q2=MPIStateArray{Float64,F2}(MPI.COMM_WORLD,CLIMA.array_type(),4,6,8)

# ### Create a call-back
#
# Now we can create a ```Statestats``` call-back, _cb_, tied to the ```MPIStateArray```
# variables _Q1_ and _Q2_. Each ```MPIStateArray``` in the array
# of ```MPIStateArray``` variables tracked is paired with a label
# to identify it. The call-back is also given a frequency (in time step numbers) and
# precision for printing summary tables.
cb=StateCheck.sccreate([(Q1,"My gradients"),(Q2,"My fields")],1; prec=15)

# ### Invoke the call-back
#
# The call-back is of type ```ClimateMachine.GenericCallbacks.EveryXSimulationSteps```
# and in regular use is designed to be passed to a ClimateMachine timestepping 
# solver. Here, for demonstration purposes, we can invoke
# the call-back after simply initializing the ```MPIStateArray``` fields to a random
# set of values e.g.
Q1.data .= rand( Float32,  size(Q1.data) )
Q2.data .= rand( Float64,  size(Q2.data) )
cb()

# ## Comparing to reference values
