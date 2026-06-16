# Source Code Trace: van Albada Limiter in OpenFOAM

## From fvSchemes to source code

The baseline shock tube case uses the `vanAlbada` limited interpolation scheme for several convective terms:

```cpp
div(phid,p)         Gauss vanAlbada;
div(phi,e)          Gauss vanAlbada;
div(phi,K)          Gauss vanAlbada;
div(phi,(p|rho))    Gauss vanAlbada;

