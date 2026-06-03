/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     | Website:  https://openfoam.org
    \\  /    A nd           | Copyright (C) YEAR OpenFOAM Foundation
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

\*---------------------------------------------------------------------------*/

#include "codedFixedValueFvPatchFieldTemplate.H"
#include "addToRunTimeSelectionTable.H"
#include "fieldMapper.H"
#include "volFields.H"
#include "surfaceFields.H"
#include "read.H"

//{{{ begin codeInclude

//}}} end codeInclude


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{

// * * * * * * * * * * * * * * * Local Functions * * * * * * * * * * * * * * //

//{{{ begin localCode

//}}} end localCode


// * * * * * * * * * * * * * * * Global Functions  * * * * * * * * * * * * * //

extern "C"
{
    // dynamicCode:
    // SHA1 = ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03
    //
    // unique function name that can be checked if the correct library version
    // has been loaded
    void parabolicInlet_ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03(bool load)
    {
        if (load)
        {
            // code that can be explicitly executed after loading
        }
        else
        {
            // code that can be explicitly executed before unloading
        }
    }
}

// * * * * * * * * * * * * * * Static Data Members * * * * * * * * * * * * * //

makeRemovablePatchTypeField
(
    fvPatchVectorField,
    parabolicInletFixedValueFvPatchVectorField
);


const char* const parabolicInletFixedValueFvPatchVectorField::SHA1sum =
    "ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03";


// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

parabolicInletFixedValueFvPatchVectorField::
parabolicInletFixedValueFvPatchVectorField
(
    const fvPatch& p,
    const DimensionedField<vector, volMesh>& iF,
    const dictionary& dict
)
:
    fixedValueFvPatchField<vector>(p, iF, dict)
{
    if (false)
    {
        Info<<"construct parabolicInlet sha1: ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03"
            " from patch/dictionary\n";
    }
}


parabolicInletFixedValueFvPatchVectorField::
parabolicInletFixedValueFvPatchVectorField
(
    const parabolicInletFixedValueFvPatchVectorField& ptf,
    const fvPatch& p,
    const DimensionedField<vector, volMesh>& iF,
    const fieldMapper& mapper
)
:
    fixedValueFvPatchField<vector>(ptf, p, iF, mapper)
{
    if (false)
    {
        Info<<"construct parabolicInlet sha1: ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03"
            " from patch/DimensionedField/mapper\n";
    }
}


parabolicInletFixedValueFvPatchVectorField::
parabolicInletFixedValueFvPatchVectorField
(
    const parabolicInletFixedValueFvPatchVectorField& ptf,
    const DimensionedField<vector, volMesh>& iF
)
:
    fixedValueFvPatchField<vector>(ptf, iF)
{
    if (false)
    {
        Info<<"construct parabolicInlet sha1: ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03 "
            "as copy/DimensionedField\n";
    }
}


// * * * * * * * * * * * * * * * * Destructor  * * * * * * * * * * * * * * * //

parabolicInletFixedValueFvPatchVectorField::
~parabolicInletFixedValueFvPatchVectorField()
{
    if (false)
    {
        Info<<"destroy parabolicInlet sha1: ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03\n";
    }
}


// * * * * * * * * * * * * * * * Member Functions  * * * * * * * * * * * * * //

void parabolicInletFixedValueFvPatchVectorField::updateCoeffs()
{
    if (this->updated())
    {
        return;
    }

    if (false)
    {
        Info<<"updateCoeffs parabolicInlet sha1: ca2eaad859c15e22ea60d404e8ad4f98ee5cfe03\n";
    }

//{{{ begin code
    #line 22 "/home/lenovo/CFD-Portfolio/projects/03_OpenFOAM_Schaefer_Turek_2D2_Benchmark/case/runs/run_003_refined_cylinder_wake/0/U/boundaryField/inlet"
const scalar H = 0.41;
            const scalar Um = 1.5;

            const fvPatch& boundaryPatch = patch();
            vectorField& field = *this;

            forAll(field, i)
            {
                const scalar y = boundaryPatch.Cf()[i].y();
                const scalar ux = 4.0*Um*y*(H - y)/(H*H);
                field[i] = vector(ux, 0, 0);
            }
//}}} end code

    this->fixedValueFvPatchField<vector>::updateCoeffs();
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace Foam

// ************************************************************************* //

