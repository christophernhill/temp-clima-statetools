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
     PackageSpec(url="https://github.com/christophernhill/temp-clima-statetools",rev="0.1.1")
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
  # SC =======|============|==========|======== min() ========|======== max() ========|======== mean() =======|======== std() ========|
  # SC 0000002      dg Q_3D      u[1]  -4.2748549208261393e-08|  4.2748552102026711e-08 -1.4649342448738028e-17  4.4954875553396070e-09
  # SC 0000002      dg Q_3D      u[2]  -3.7024474345370500e-04| -1.3864366400218321e-09 -1.5544542455119917e-04  1.0859536210224357e-04
  # SC 0000002      dg Q_3D         η  -1.1649874970125573e-05|  1.1649877728909136e-05  3.0756360480665992e-13  8.1734989670746345e-06
  # SC 0000002      dg Q_3D         θ   4.7942103302030581e-06|  9.0055369750850645e+00  2.4999999479422290e+00  2.1805798690704465e+00
  # SC 0000002      dg Q_3D    η_diag  -1.1654385244197310e-05|  1.1654387245012019e-05  2.6083057313996962e-13  8.1517153239337149e-06
  # SC 0000002  dg auxstate         w  -1.0599732371347812e-04|  1.0599736573785307e-04  1.7827978302520365e-12  3.5161954692778274e-05
  # SC 0000002  dg auxstate      pkin  -9.0000549789456741e-01|  0.0000000000000000e+00 -1.6674109310971905e-01  1.9569272273260008e-01
  # SC 0000002  dg auxstate       wz0  -1.6973837925570250e-07|  1.6973844461765685e-07  7.3836359769374741e-15  1.1886164077321282e-07
  # SC 0000002  dg auxstate     ∫u[1]  -4.2702225526306030e-05|  4.2702227098402670e-05 -1.4308037532551056e-14  2.5963563705381634e-06
  # SC 0000002  dg auxstate     ∫u[2]  -2.4650267758059319e-01|  0.0000000000000000e+00 -9.7168749575850505e-02  7.1552230217719698e-02
  # SC 0000002  dg auxstate         y   0.0000000000000000e+00|  4.0000000000000005e+06  2.0000000000000000e+06  1.1557316390191570e+06
  # SC 0000002  dg auxstate        Δη  -2.5275895407911329e-06|  2.5276012662470163e-06  4.6733031347501178e-14  2.4908221214550732e-07
  # SC 0000002   dg tdg.aux    ∫du[1]  -8.8741903727730534e-07|  8.8741904226043215e-07 -1.1291291296053329e-16  5.4099737171681806e-08
  # SC 0000002   dg tdg.aux    ∫du[2]  -2.0538673034392867e-03|  0.0000000000000000e+00 -8.0579143696228529e-04  5.9757641890865630e-04
  # SC 0000002 dg conti3d_Q      u[1]   0.0000000000000000e+00|  0.0000000000000000e+00  0.0000000000000000e+00  0.0000000000000000e+00
  # SC 0000002 dg conti3d_Q      u[2]   0.0000000000000000e+00|  0.0000000000000000e+00  0.0000000000000000e+00  0.0000000000000000e+00
  # SC 0000002 dg conti3d_Q         η   0.0000000000000000e+00|  0.0000000000000000e+00  0.0000000000000000e+00  0.0000000000000000e+00
  # SC 0000002 dg conti3d_Q         θ  -2.5456341898000465e-10|  2.5456352341793807e-10  7.3823655013778665e-18  1.3016610239148211e-10
  # SC 0000002 dg conti3d_Q    η_diag   0.0000000000000000e+00|  0.0000000000000000e+00  0.0000000000000000e+00  0.0000000000000000e+00
  # SC 0000002    baro Q_2D      U[1]  -1.0918702560681338e-04|  1.0918702509103547e-04 -1.5503221362928032e-14  1.1588672570610670e-05
  # SC 0000002    baro Q_2D      U[2]  -2.4651507928243502e-01| -2.0636531147924156e-06 -1.5462746164817889e-01  7.6943811950208482e-02
  # SC 0000002    baro Q_2D         η  -1.1654385244197310e-05|  1.1654387245012019e-05  2.6083057241832462e-13  8.1521188642089038e-06
  # SC 0000002 baro auxstat     Gᵁ[1]  -8.8741903727730534e-07|  8.8741904226043215e-07 -1.1237100049836350e-16  9.3681447409756354e-08
  # SC 0000002 baro auxstat     Gᵁ[2]  -2.0538673034392867e-03| -4.7416310802969518e-08 -1.2897301884337020e-03  6.3952147015056712e-04
  # SC 0000002 baro auxstat      Ū[1]  -4.7391157421459052e-04|  4.7391158025809622e-04 -1.0753196146018329e-13  5.0064788495761068e-05
  # SC 0000002 baro auxstat      Ū[2]  -1.9333467328796567e+00| -1.4907926223107023e-05 -1.2159634081422788e+00  5.9992687102779718e-01
  # SC 0000002 baro auxstat         η̄  -1.1654385244197310e-05|  1.1654387245012019e-05  2.6083057241832462e-13  8.1521188642089038e-06
  # SC 0000002 baro auxstat     Δu[1]  -6.6491020180497218e-08|  6.6491020146064402e-08  9.3289074788683803e-20  7.0956828855840718e-09
  # SC 0000002 baro auxstat     Δu[2]  -1.2404340521937618e-08|  6.9453706300164257e-05  8.8656403955709262e-07  6.8889560086505544e-06
  # SC 0000002 baro diffsta    ν∇U[1]  -2.6228488341641993e-05|  2.6223145904822268e-05 -3.1067976237312848e-11  2.6721720904357631e-06
  # SC 0000002 baro diffsta    ν∇U[2]  -3.0930805704696215e-05|  3.0930805967042153e-05 -7.7515001565393001e-15  6.5833476517222670e-07
  # SC 0000002 baro diffsta    ν∇U[3]  -0.0000000000000000e+00|  0.0000000000000000e+00  0.0000000000000000e+00  0.0000000000000000e+00
  # SC 0000002 baro diffsta    ν∇U[4]  -7.2792601380054514e-02|  7.2792601380148647e-02 -8.6971319035455959e-15  7.3459619027967885e-03
  # SC 0000002 baro diffsta    ν∇U[5]  -8.4775189277835168e-04|  8.4775193519515449e-04  2.6956843424130737e-13  5.9267620954955923e-04
  # SC 0000002 baro diffsta    ν∇U[6]  -0.0000000000000000e+00|  0.0000000000000000e+00  0.0000000000000000e+00  0.0000000000000000e+00
  # SC 0000002 horz auxstat         w  -1.0599732371347812e-04|  1.0599736573785307e-04  1.7827978302520365e-12  3.5161954692778274e-05
  # SC 0000002 horz auxstat      pkin  -9.0000549789456741e-01|  0.0000000000000000e+00 -1.6674109310971905e-01  1.9569272273260008e-01
  # SC 0000002 horz auxstat       wz0  -1.6973837925570250e-07|  1.6973844461765685e-07  7.3836359769374741e-15  1.1886164077321282e-07
  # SC 0000002 horz auxstat     ∫u[1]  -4.2702225526306030e-05|  4.2702227098402670e-05 -1.4308037532551056e-14  2.5963563705381634e-06
  # SC 0000002 horz auxstat     ∫u[2]  -2.4650267758059319e-01|  0.0000000000000000e+00 -9.7168749575850505e-02  7.1552230217719698e-02
  # SC 0000002 horz auxstat         y   0.0000000000000000e+00|  4.0000000000000005e+06  2.0000000000000000e+06  1.1557316390191570e+06
  # SC 0000002 horz auxstat        Δη  -2.5275895407911329e-06|  2.5276012662470163e-06  4.6733031347501178e-14  2.4908221214550732e-07
  # SC 0000002 horz diffsta    ν∇u[1]  -8.0642629275642158e-20|  1.3429525833845796e-19 -3.2100377993118471e-25  2.5015154458969402e-22
  # SC 0000002 horz diffsta    ν∇u[2]  -3.8341397239295729e-20|  3.8304260319148865e-20  5.1219779611838382e-26  1.3876195475210204e-22
  # SC 0000002 horz diffsta    ν∇u[3]  -5.2507173388128619e-11|  5.2507181338226290e-11  3.7207886778643568e-21  5.5123725418489111e-13
  # SC 0000002 horz diffsta    ν∇u[4]  -9.8088323424507242e-16|  6.0752915527306439e-16 -1.1573066254726760e-20  1.1652360489139667e-17
  # SC 0000002 horz diffsta    ν∇u[5]  -1.4701357811525250e-15|  1.7173772449869952e-15  5.8064822859737406e-21  1.2798815432045983e-17
  # SC 0000002 horz diffsta    ν∇u[6]  -6.3815745484402399e-07|  3.2055602092627026e-09 -3.0251741202476868e-09  4.4765430111663707e-08
  # SC 0000002 horz diffsta     κ∇θ[1  -5.8805431246370784e-16|  6.8695089799121273e-16  2.1836008036495267e-21  5.1193658898220633e-18
  # SC 0000002 horz diffsta     κ∇θ[2  -5.8805431246370784e-16|  6.8695089799121273e-16  2.1836008036495267e-21  5.1193658898220633e-18
  # SC 0000002 horz diffsta     κ∇θ[3  -5.8805431246370784e-16|  6.8695089799121273e-16  2.1836008036495267e-21  5.1193658898220633e-18
  # SC +++++++++++CLIMA StateCheck call-back end+++++++++++++++++++

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
