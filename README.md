# temp-clima-statechecks
Temporary place to store state check code for simple regression testing

# Example usage

  - see example/Ocean/SplitExplicit/simple_box_sRate_cnh.jl
    1. add this package
    ```
       :
       :
    ## Add State statistics package
    Pkg.add(
     PackageSpec(url="https://github.com/christophernhill/temp-clima-statetools",rev="0.1.3")
    )
    using CLIMAStateCheck
       :
       :
    ```

    2. create call back referencing the MPIStateArrays to be tracked every ```ntFreq```
       timesteps. Include a string for labeling each state array statistics.
    ```
       :
       :
     ntFreq=1
     cbcs_dg=CLIMAStateCheck.StateCheck.sccreate(
            [(Q_3D,"dg Q_3D"),
             (dg.auxstate,"dg auxstate"),
             (dg.modeldata.tendency_dg.auxstate,"dg tdg.aux"),
             (dg.modeldata.conti3d_Q,"dg conti3d_Q"),
             (Q_2D,"baro Q_2D"),
             (barotropic_dg.auxstate ,"baro auxstate"),
             (barotropic_dg.diffstate,"baro diffstate"),
             (horizontal_dg.auxstate, "horz auxstate"),
             (horizontal_dg.diffstate,"horz diffstate")
            ],
            ntFreq);
       :
       :
    ```

    3. add call back to set passed to ODE solver.
    ```
      :
      :
    cbv=(cbvector...,cbcs_dg)
    solve!(Qvec, odesolver; timeend = timeend, callbacks = cbv)
      :
      :
    ```

# Example output
  
  ```
  # SC +++++++++++CLIMA StateCheck call-back start+++++++++++++++++
  # SC  Step  |   Label    |  Field   |                                       Stats                       
  # SC =======|============|==========|======== min() =========|======== max() =========|======== mean() ========|======== std() =========|
  # SC 0000004|     dg Q_3D|     u[1] | -1.3870397605921040e-06|  1.3870397612717859e-06| -4.3312697178832238e-18|  1.5454998413550212e-07|
  # SC 0000004|     dg Q_3D|     u[2] | -1.1143419288212615e-03|  1.0793170406438532e-08| -4.6299994088385050e-04|  3.2682369107239930e-04|
  # SC 0000004|     dg Q_3D|        η | -1.0558486285585805e-04|  1.0558508799992146e-04|  3.6549379796468885e-11|  7.3336698542006984e-05|
  # SC 0000004|     dg Q_3D|        θ |  1.1976152338679291e-05|  9.0139220648162031e+00|  2.4999996872695087e+00|  2.1805848030189483e+00|
  # SC 0000004|     dg Q_3D|   η_diag | -1.0562733704707952e-04|  1.0562743588754802e-04|  2.5966857791104303e-11|  7.3291864286729858e-05|
  # SC 0000004| dg auxstate|        w | -3.5166709388449757e-04|  3.5166843244587281e-04|  9.0339706275699434e-11|  1.1527325797083953e-04|
  # SC 0000004| dg auxstate|     pkin | -9.0001637827252623e-01|  0.0000000000000000e+00| -1.6674112529114454e-01|  1.9569270861021520e-01|
  # SC 0000004| dg auxstate|      wz0 | -5.6451204942540772e-07|  5.6451396820416619e-07|  3.5614057750099625e-13|  3.8986568001241240e-07|
  # SC 0000004| dg auxstate|    ∫u[1] | -1.3841977626235043e-03|  1.3841977617253714e-03| -2.4268389964277049e-14|  8.9264796606844878e-05|
  # SC 0000004| dg auxstate|    ∫u[2] | -7.3915554229593172e-01|  0.0000000000000000e+00| -2.8948856927299521e-01|  2.1540028791028809e-01|
  # SC 0000004| dg auxstate|        y |  0.0000000000000000e+00|  4.0000000000000005e+06|  2.0000000000000000e+06|  1.1557316390191570e+06|
  # SC 0000004| dg auxstate|       Δη | -5.7004460597896329e-06|  5.7023064107161094e-06|  1.0582522001520433e-11|  3.8780106232410298e-07|
  # SC 0000004|  dg tdg.aux|   ∫du[1] | -9.7103623108143986e-06|  9.7103622970808232e-06|  2.0369091829897102e-17|  6.5070231672358097e-07|
  # SC 0000004|  dg tdg.aux|   ∫du[2] | -2.0517442702863071e-03|  1.1345631113842749e-07| -7.9949478695344424e-04|  6.0195994456789742e-04|
  # SC 0000004|dg conti3d_Q|     u[1] |  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|
  # SC 0000004|dg conti3d_Q|     u[2] |  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|
  # SC 0000004|dg conti3d_Q|        η |  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|
  # SC 0000004|dg conti3d_Q|        θ | -8.4658613956926538e-10|  8.4658966069105119e-10|  3.5600825770438356e-16|  4.2665464969611959e-10|
  # SC 0000004|dg conti3d_Q|   η_diag |  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|
  # SC 0000004|   baro Q_2D|     U[1] | -2.0249185144035177e-03|  2.0249185121703497e-03|  1.5638114414517901e-14|  2.3664336272192040e-04|
  # SC 0000004|   baro Q_2D|     U[2] | -7.3914400501453570e-01|  2.4865162650359117e-05| -4.6160140022315138e-01|  2.3375885196268084e-01|
  # SC 0000004|   baro Q_2D|        η | -1.0562733704707952e-04|  1.0562743588754802e-04|  2.5966857786219320e-11|  7.3295492507037847e-05|
  # SC 0000004|baro auxstat|    Gᵁ[1] | -9.7103623108143986e-06|  9.7103622970808232e-06|  1.6170626578222713e-16|  1.1268334017815426e-06|
  # SC 0000004|baro auxstat|    Gᵁ[2] | -2.0517442702863071e-03|  1.1345631113842749e-07| -1.2800970638851346e-03|  6.5142670908175922e-04|
  # SC 0000004|baro auxstat|     Ū[1] | -1.7936702353527258e-02|  1.7936702338220024e-02| -4.7246540013645702e-14|  2.0381169311781103e-03|
  # SC 0000004|baro auxstat|     Ū[2] | -8.8318771940589205e+00|  9.0256281871645583e-05| -5.5254038160420142e+00|  2.7771612232299745e+00|
  # SC 0000004|baro auxstat|        η̄ | -1.0562733704707952e-04|  1.0562743588754802e-04|  2.5966857786219320e-11|  7.3295492507037847e-05|
  # SC 0000004|baro auxstat|    Δu[1] | -6.4122027109817392e-07|  6.4122027038345398e-07|  2.2935804324568723e-17|  8.3584771363137616e-08|
  # SC 0000004|baro auxstat|    Δu[2] | -2.7823530563314584e-08|  1.3765604443980196e-04|  1.7974381788321389e-06|  1.3649039335502098e-05|
  # SC 0000004|baro diffsta|   ν∇U[1] | -8.4526512048234371e-04|  8.4508467857756194e-04| -9.7755324507883825e-10|  8.5771172012570030e-05|
  # SC 0000004|baro diffsta|   ν∇U[2] | -7.3706947801322549e-04|  7.3706947682050433e-04|  1.3255515088350656e-14|  1.6891089848249851e-05|
  # SC 0000004|baro diffsta|   ν∇U[3] | -0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|
  # SC 0000004|baro diffsta|   ν∇U[4] | -1.9518370368113852e-01|  1.9518370368155452e-01|  1.1533174415490067e-14|  2.0028376409351907e-02|
  # SC 0000004|baro diffsta|   ν∇U[5] | -2.7937788239733169e-03|  2.7937803242906495e-03|  9.9035014855530786e-12|  1.9466070878585049e-03|
  # SC 0000004|baro diffsta|   ν∇U[6] | -0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|  0.0000000000000000e+00|
  # SC 0000004|horz auxstat|        w | -3.5166709388449757e-04|  3.5166843244587281e-04|  9.0339706275699434e-11|  1.1527325797083953e-04|
  # SC 0000004|horz auxstat|     pkin | -9.0001637827252623e-01|  0.0000000000000000e+00| -1.6674112529114454e-01|  1.9569270861021520e-01|
  # SC 0000004|horz auxstat|      wz0 | -5.6451204942540772e-07|  5.6451396820416619e-07|  3.5614057750099625e-13|  3.8986568001241240e-07|
  # SC 0000004|horz auxstat|    ∫u[1] | -1.3841977626235043e-03|  1.3841977617253714e-03| -2.4268389964277049e-14|  8.9264796606844878e-05|
  # SC 0000004|horz auxstat|    ∫u[2] | -7.3915554229593172e-01|  0.0000000000000000e+00| -2.8948856927299521e-01|  2.1540028791028809e-01|
  # SC 0000004|horz auxstat|        y |  0.0000000000000000e+00|  4.0000000000000005e+06|  2.0000000000000000e+06|  1.1557316390191570e+06|
  # SC 0000004|horz auxstat|       Δη | -5.7004460597896329e-06|  5.7023064107161094e-06|  1.0582522001520433e-11|  3.8780106232410298e-07|
  # SC 0000004|horz diffsta|   ν∇u[1] | -3.7390620858674584e-18|  6.2267901992689480e-18| -1.4646244490490248e-23|  1.1624325937040046e-20|
  # SC 0000004|horz diffsta|   ν∇u[2] | -1.7778654805673991e-18|  1.7757157635428737e-18|  2.0206389992973165e-24|  6.4534345749055148e-21|
  # SC 0000004|horz diffsta|   ν∇u[3] | -2.4368342061460535e-09|  2.4368342115207311e-09|  1.2202956112478981e-20|  2.7037668033957821e-11|
  # SC 0000004|horz diffsta|   ν∇u[4] | -3.1383045013765849e-15|  1.9437385597010846e-15| -3.3670769922671319e-20|  3.7008306410494330e-17|
  # SC 0000004|horz diffsta|   ν∇u[5] | -4.7035635059319544e-15|  5.4945897145592374e-15|  1.0553883303286423e-20|  4.0844782124210845e-17|
  # SC 0000004|horz diffsta|   ν∇u[6] | -2.0417274411973877e-06|  1.0363512454553365e-08| -9.6359156075871394e-09|  1.4279090613335345e-07|
  # SC 0000004|horz diffsta|    κ∇θ[1 | -1.8814254023814132e-15|  2.1978358858122240e-15|  3.4921212458811655e-21|  1.6336952019543006e-17|
  # SC 0000004|horz diffsta|    κ∇θ[2 | -1.8814254023814132e-15|  2.1978358858122240e-15|  3.4921212458811655e-21|  1.6336952019543006e-17|
  # SC 0000004|horz diffsta|    κ∇θ[3 | -1.8814254023814132e-15|  2.1978358858122240e-15|  3.4921212458811655e-21|  1.6336952019543006e-17|
  # SC +++++++++++CLIMA StateCheck call-back end+++++++++++++++++++
  ```
  
# Try it in the REPL

```
% mkdir foo
% cd foo
% git clone https://github.com/christophernhill/temp-clima-statetools
% cd temp-clima-statetools
julia> using Pkg
julia> Pkg.add( PackageSpec(url="https://github.com/jm-c/CLIMA.git",rev="jmc/split_explicit_dvlp") )
julia> using CLIMA
julia> Pkg.add("MPI"); Pkg.add("StaticArrays"); Pkg.add("GPUifyLoops");
julia> include("example/Ocean/SplitExplicit/simple_box_sRate_cnh.jl")
```

# Some possibly useful ~/startup.jl functions
 (1) Set where CLIMA packages come from - sometimes its nice to take from local clones
     sometimes taking from git is preferred.

```
using Pkg

my_set_clima_packages(s="loc")=
(
 if     s=="loc"

  my_local_gh_root="/Users/chrishill/projects/github.com/";

  clloc =string(my_local_gh_root, "climate-machine/CLIMA"                 );
  clploc=string(my_local_gh_root, "climate-machine/CLIMAParameters.jl"    );
  stloc =string(my_local_gh_root, "christophernhill/temp-clima-statetools");

  Pkg.add( PackageSpec(path=clloc)  );
  Pkg.add( PackageSpec(path=clploc) );
  Pkg.add( PackageSpec(path=stloc)  );

 elseif s=="git"

  Pkg.add( PackageSpec(url="https://github.com/climate-machine/CLIMA")                   );
  Pkg.add( PackageSpec(url="https://github.com/climate-machine/CLIMAParameters.jl")      );
  Pkg.add( PackageSpec(url="https://github.com/christophernhill/temp-clima-statetools")  );

 else

  println("AGHHHHH")

 end
)

my_set_clima_packages()
using CLIMA
```
