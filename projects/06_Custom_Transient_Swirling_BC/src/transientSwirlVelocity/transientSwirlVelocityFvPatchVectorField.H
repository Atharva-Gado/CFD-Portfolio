#ifndef transientSwirlVelocityFvPatchVectorField_H
#define transientSwirlVelocityFvPatchVectorField_H

#include "fixedValueFvPatchFields.H"

namespace Foam
{

class transientSwirlVelocityFvPatchVectorField
:
    public fixedValueFvPatchVectorField
{
    // Private data

        // Mean axial velocity
        vector meanVelocity_;

        // Axial pulsation amplitude
        vector amplitude_;

        // Pulsation frequency [Hz]
        scalar frequency_;

        // Angular swirl strength [1/s]
        scalar omega_;

        // Swirl center
        vector origin_;

        // Axis direction
        vector axis_;


public:

    TypeName("transientSwirlVelocity");


    // Constructors

        transientSwirlVelocityFvPatchVectorField
        (
            const fvPatch&,
            const DimensionedField<vector, volMesh>&
        );

        transientSwirlVelocityFvPatchVectorField
        (
            const transientSwirlVelocityFvPatchVectorField&,
            const fvPatch&,
            const DimensionedField<vector, volMesh>&,
            const fvPatchFieldMapper&
        );

        transientSwirlVelocityFvPatchVectorField
        (
            const fvPatch&,
            const DimensionedField<vector, volMesh>&,
            const dictionary&
        );

        transientSwirlVelocityFvPatchVectorField
        (
            const transientSwirlVelocityFvPatchVectorField&,
            const DimensionedField<vector, volMesh>&
        );


    // Member functions

    virtual tmp<fvPatchVectorField> clone() const
    {
    NotImplemented;
    return tmp<fvPatchVectorField>();
    }

        virtual tmp<fvPatchVectorField> clone
        (
            const DimensionedField<vector, volMesh>& iF
        ) const
        {
            return tmp<fvPatchVectorField>
            (
                new transientSwirlVelocityFvPatchVectorField(*this, iF)
            );
        }

        virtual void updateCoeffs();

        virtual void write(Ostream&) const;
};

} // End namespace Foam

#endif