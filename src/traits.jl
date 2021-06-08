# --- Model Abstractions --- #

"""
    AbstractModel

Supertype for all models.
"""
abstract type AbstractModel end

"""
    NoStateModel <: AbstractModel

Supertype for all models which contain no state variables.
"""
abstract type NoStateModel <: AbstractModel end

# --- Trait Types --- #

abstract type InPlaceness end
struct InPlace <: InPlaceness end
struct OutOfPlace <: InPlaceness end

abstract type MatrixType end
struct Empty <: MatrixType end
struct Zeros <: MatrixType end
struct Identity <: MatrixType end
struct Constant <: MatrixType end
struct Varying <: MatrixType end

abstract type InputDependence end
struct Linear <: InputDependence end
struct Nonlinear <: InputDependence end

# --- Trait Functions --- #

"""
    inplaceness(::Type{T})

Return [`InPlace()`](@ref) if functions associated with model `T` are in-place
or [`OutOfPlace()`](@ref) if functions associated with model `T` are out-of-place.
"""
inplaceness(::Type{T}) where T

# models with no state variables use out-of-place definitions
inplaceness(::Type{T}) where T<:NoStateModel = OutOfPlace()

# definition for combinations of models
function inplaceness(::Type{T}) where T<:NTuple{N,AbstractModel} where N
    model_types = (T.parameters...,)
    if isinplace(inplaceness(model_types...)) || any(isinplace.(model_types))
        return InPlace()
    else
        return OutOfPlace()
    end
end

"""
    inplaceness(::Type{T1}, ::Type{T2}, ..., ::Type{TN})

Return [`InPlace()`](@ref) if the functions associated with the input function
for coupled models `T1`, `T2`, ... `TN` are in-place or [`OutOfPlace()`](@ref)
if the functions associated with the input function for coupled models `T1`,
`T2`, ... `TN` are out-of-place.
"""
inplaceness(::Vararg{Type,N}) where N

"""
   mass_matrix_type(::Type{T})

Return
 - [`Empty()`](@ref), if the mass matrix associated with model `T` is empty
 - [`Zeros()`](@ref), if the mass matrix associated with model `T` is filled
    with zeros
 - [`Identity()`](@ref), if the mass matrix associated with model `T` is the
    identity matrix
 - [`Constant()`](@ref), if the mass matrix associated with model `T` is
    constant with respect to time
 - [`Varying()`](@ref), if the mass matrix associated with model `T` may vary
    with respect to time

If no method is defined for the specified type, return [`Varying`](@ref).
"""
mass_matrix_type(::Type{T}) = Varying()

# models with no state variables have no mass matrix
mass_matrix_type(::Type{T}) where T<:NoStateModel = Empty()

# definition for combinations of models
function mass_matrix_type(::Type{T}) where T<:NTuple{N,AbstractModel} where N
    model_types = (T.parameters...,)
    if isempty(mass_matrix_type(model_types...)) &&
        all(isempty.(mass_matrix_type.(model_types)))
        return Empty()
    elseif iszero(mass_matrix_type(model_types...)) &&
        all(iszero.(mass_matrix_type.(model_types)))
        return Zeros()
    elseif iszero(mass_matrix_type(model_types...)) &&
        all(isidentity.(mass_matrix_type.(model_types)))
        return Identity()
    elseif isconstant(mass_matrix_type(model_types...)) &&
        all(isconstant.(input_jacobian_type.(model_types))) &&
        all(isconstant.(mass_matrix_type.(model_types)))
        return Constant()
    else
        return Varying()
    end
end

"""
   state_jacobian_type(::Type{T})

Return
 - [`Empty()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the state variables associated with model `T` is empty
 - [`Zeros()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the state variables associated with model `T` is filled
    with zeros
 - [`Identity()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the state variables associated with model `T` is the
    identity matrix
 - [`Constant()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the state variables associated with model `T` is
    constant with respect to time
 - [`Varying()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the state variables associated with model `T` may vary
    with respect to time

If no method is defined for the specified type, return [`Varying`](@ref).
"""
state_jacobian_type(::Type{T}) = Varying()

# models with no state variables have no state jacobian
state_jacobian_type(::Type{T}) where T<:NoStateModel = Empty()

# definition for combinations of models
function state_jacobian_type(::Type{T}) where T<:NTuple{N,AbstractModel} where N
    model_types = (T.parameters...,)
    if isempty(state_jacobian_type(model_types...)) &&
        all(isempty.(state_jacobian_type.(model_types)))
        return Empty()
    elseif iszero(state_jacobian_type(model_types...)) &&
        all(iszero.(state_jacobian_type.(model_types)))
        return Zeros()
    elseif iszero(state_jacobian_type(model_types...)) &&
        all(isidentity.(state_jacobian_type.(model_types)))
        return Identity()
    elseif isconstant(state_jacobian_type(model_types...)) &&
        all(isconstant.(input_jacobian_type.(model_types))) &&
        all(isconstant.(state_jacobian_type.(model_types)))
        return Constant()
    else
        return Varying()
    end
end

"""
   input_jacobian_type(::Type{T})

Return
 - [`Empty()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the inputs is empty for model `T`
 - [`Zeros()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the inputs is filled with zeros for model `T`
 - [`Identity()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the inputs is the identity matrix for model `T`
 - [`Constant()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the inputs is constant with respect to time for model `T`
 - [`Varying()`](@ref), if the jacobian of the mass matrix multiplied state rates
    with respect to the inputs may vary with respect to time for model `T`

If no method is defined for the specified type, return [`Varying`](@ref).
"""
input_jacobian_type(::Type{T}) = Varying()

# models with no state variables have no input jacobian
input_jacobian_type(::Type{T}) where T<:NoStateModel = Empty()

# definition for combinations of models
function input_jacobian_type(::Type{T}) where T<:NTuple{N,AbstractModel} where N
    model_types = (T.parameters...,)
    if all(isempty.(input_jacobian_type.(model_types)))
        return Empty()
    elseif all(iszero.(input_jacobian_type.(model_types)))
        return Zeros()
    elseif all(isidentity.(input_jacobian_type.(model_types)))
        return Identity()
    elseif all(isconstant.(input_jacobian_type.(model_types)))
        return Constant()
    else
        return Varying()
    end
end

"""
    input_dependence_type(::Type{T})

Return [`Linear()`](@ref) if the state rate function for model `T` is linearly
dependent on the associated inputs and [`Nonlinear()`](@ref) otherwise.

If no method is defined for the specified type, return [`Nonlinear`](@ref).
"""
input_dependence_type(::Type{T}) where T<:AbstractModel = Nonlinear()
input_dependence_type(::Type{T}) where T<:NoStateModel = Linear()

# --- dispatch functions --- #

isinplace(model::T) where T = isinplace(inplaceness(T))
isinplace(::Type{T}) where T = isinplace(inplaceness(T))
isinplace(::OutOfPlace) = false
isinplace(::InPlace) = true

isempty(::MatrixType) = false
isempty(::Empty) = true

iszero(::MatrixType) = false
iszero(::Zeros) = true

isidentity(::MatrixType) = false
isidentity(::Identity) = true

isconstant(::MatrixType) = false
isconstant(::Empty) = true
isconstant(::Zeros) = true
isconstant(::Constant) = true

function linear_input_dependence(model)
    return _linear_input_dependence(input_dependence_type(typeof(model)))
end
_linear_input_dependence(::Linear) = true
_linear_input_dependence(::Nonlinear) = false