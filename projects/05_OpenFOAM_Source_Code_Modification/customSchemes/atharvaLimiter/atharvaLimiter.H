/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     | Website:  https://openfoam.org
    \\  /    A nd           | Copyright (C) 2011-2022 OpenFOAM Foundation
     \\/     M anipulation  |
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

    OpenFOAM is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    for more details.

    You should have received a copy of the GNU General Public License
    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.

Class
    Foam::atharvaLimiterLimiter

Description
    Class with limiter function which returns the limiter for the
    atharvaLimiter interpolation scheme based on r obtained from the LimiterFunc
    class.

    Used in conjunction with the template class LimitedScheme.

SourceFiles
    atharvaLimiter.C

\*---------------------------------------------------------------------------*/

#ifndef atharvaLimiter_H
#define atharvaLimiter_H

#include "vector.H"

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{

/*---------------------------------------------------------------------------*\
                      Class atharvaLimiterLimiter Declaration
\*---------------------------------------------------------------------------*/

template<class LimiterFunc>
class atharvaLimiterLimiter
:
    public LimiterFunc
{

public:

    atharvaLimiterLimiter(Istream&)
    {}

    scalar limiter
    (
        const scalar cdWeight,
        const scalar faceFlux,
        const typename LimiterFunc::phiType& phiP,
        const typename LimiterFunc::phiType& phiN,
        const typename LimiterFunc::gradPhiType& gradcP,
        const typename LimiterFunc::gradPhiType& gradcN,
        const vector& d
    ) const
    {
        const scalar r = max
        (
            LimiterFunc::r(faceFlux, phiP, phiN, gradcP, gradcN, d), 0
        );
// Custom limiter based on the van Albada formulation.
// This first version reproduces the baseline van Albada behavior.
        const scalar beta = 1.0;

// Generalized van Albada-type limiter.
// beta = 1 recovers the original van Albada formulation.
return r*(r + beta)/(sqr(r) + beta);
    }
};


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace Foam

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

#endif

// ************************************************************************* //
