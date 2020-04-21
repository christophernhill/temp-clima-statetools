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
