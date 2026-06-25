#include "transientSwirlVelocityFvPatchVectorField.H"
#include "addToRunTimeSelectionTable.H"
#include "volFields.H"
#include "surfaceFields.H"
#include "Time.H"
#include "mathematicalConstants.H"

namespace Foam
{

defineTypeNameAndDebug(transientSwirlVelocityFvPatchVectorField, 0);

addToRunTimeSelectionTable
(
    fvPatchVectorField,
    transientSwirlVelocityFvPatchVectorField,
    dictionary
);


// Constructors

transientSwirlVelocityFvPatchVectorField::
transientSwirlVelocityFvPatchVectorField
(
    const fvPatch& p,
    const DimensionedField<vector, volMesh>& iF
)
:
    fixedValueFvPatchVectorField(p, iF),
    meanVelocity_(vector::zero),
    amplitude_(vector::zero),
    frequency_(0.0),
    omega_(0.0),
    origin_(vector::zero),
    axis_(vector(1, 0, 0))
{}


transientSwirlVelocityFvPatchVectorField::
transientSwirlVelocityFvPatchVectorField
(
    const transientSwirlVelocityFvPatchVectorField& ptf,
    const fvPatch& p,
    const DimensionedField<vector, volMesh>& iF,
    const fvPatchFieldMapper& mapper
)
:
    fixedValueFvPatchVectorField(ptf, p, iF, mapper),
    meanVelocity_(ptf.meanVelocity_),
    amplitude_(ptf.amplitude_),
    frequency_(ptf.frequency_),
    omega_(ptf.omega_),
    origin_(ptf.origin_),
    axis_(ptf.axis_)
{}


transientSwirlVelocityFvPatchVectorField::
transientSwirlVelocityFvPatchVectorField
(
    const fvPatch& p,
    const DimensionedField<vector, volMesh>& iF,
    const dictionary& dict
)
:
    fixedValueFvPatchVectorField(p, iF, dict),
    meanVelocity_(dict.lookup("meanVelocity")),
    amplitude_(dict.lookup("amplitude")),
    frequency_(readScalar(dict.lookup("frequency"))),
    omega_(readScalar(dict.lookup("omega"))),
    origin_(dict.lookupOrDefault<vector>("origin", vector::zero)),
    axis_(dict.lookupOrDefault<vector>("axis", vector(1, 0, 0)))
{
    axis_ /= mag(axis_) + VSMALL;
    updateCoeffs();
}


transientSwirlVelocityFvPatchVectorField::
transientSwirlVelocityFvPatchVectorField
(
    const transientSwirlVelocityFvPatchVectorField& ptf,
    const DimensionedField<vector, volMesh>& iF
)
:
    fixedValueFvPatchVectorField(ptf, iF),
    meanVelocity_(ptf.meanVelocity_),
    amplitude_(ptf.amplitude_),
    frequency_(ptf.frequency_),
    omega_(ptf.omega_),
    origin_(ptf.origin_),
    axis_(ptf.axis_)
{}


// Member functions

void transientSwirlVelocityFvPatchVectorField::updateCoeffs()
{
    if (updated())
    {
        return;
    }

    const scalar t = this->db().time().value();

    const scalar sinTerm =
        sin(constant::mathematical::twoPi*frequency_*t);

    vector axialVelocity = meanVelocity_ + amplitude_*sinTerm;

    vectorField values(patch().size(), vector::zero);

    const vectorField& Cf = patch().Cf();

    forAll(values, faceI)
    {
        vector rVec = Cf[faceI] - origin_;

        // Remove axial component to get radial vector
        rVec -= (rVec & axis_)*axis_;

        // Tangential direction from axis cross radius
        vector tangentialDir = axis_ ^ rVec;

        scalar r = mag(rVec);

        if (r > VSMALL)
        {
            tangentialDir /= mag(tangentialDir) + VSMALL;
            values[faceI] = axialVelocity + omega_*r*tangentialDir;
        }
        else
        {
            values[faceI] = axialVelocity;
        }
    }

    operator==(values);

    fixedValueFvPatchVectorField::updateCoeffs();
}


void transientSwirlVelocityFvPatchVectorField::write(Ostream& os) const
{
    fvPatchVectorField::write(os);

    writeEntry(os, "meanVelocity", meanVelocity_);
    writeEntry(os, "amplitude", amplitude_);
    writeEntry(os, "frequency", frequency_);
    writeEntry(os, "omega", omega_);
    writeEntry(os, "origin", origin_);
    writeEntry(os, "axis", axis_);

    writeEntry(os, "value", *this);
}

} // End namespace Foam