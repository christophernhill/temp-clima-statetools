#            julia> F1=@vars begin; ν∇u::SMatrix{3, 2, T, 6}; κ∇θ::SVector{3, T}; end
#            julia> F2=@vars begin; u::SVector{2, T}; θ::SVector{1, T}; end
#            julia> Q1=MPIStateArray{Float32,F1}(MPI.COMM_WORLD,CLIMA.array_type(),4,9,8);
#            julia> Q2=MPIStateArray{Float64,F2}(MPI.COMM_WORLD,CLIMA.array_type(),4,6,8);
#            julia> cb=StateCheck.sccreate([(Q1,"My gradients"),(Q2,"My fields")],1);
#            julia> cb()

