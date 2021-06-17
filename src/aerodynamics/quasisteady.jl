"""
    QuasiSteady{Order} <: NoStateModel

2D quasi-steady aerodynamic model with parameters ``p_a = \\begin{bmatrix} a & b
& a_0 & \alpha_0 \\end{bmatrix}^T``.
"""
struct QuasiSteady{Order} <: NoStateModel end

# --- Constructors --- #

"""
    Steady()

Initialize an object of type [`QuasiSteady`](@ref) which represents a 2D
steady aerodynamic model.
"""
Steady() = QuasiSteady{0}()

"""
    QuasiSteady()

Initialize an object of type [`QuasiSteady`](@ref) which represents a 2D
quasi-steady aerodynamic model.
"""
QuasiSteady() = QuasiSteady{2}()

# --- Traits --- #

number_of_parameters(::Type{<:QuasiSteady}) = 4

# --- Typical Section Coupling --- #

"""
    couple_models(aero::QuasiSteady, stru::TypicalSection)

Create an aerostructural model using a quasi-steady aerodynamics model and a
two-degree of freedom typical section model.  This model introduces the
freestream velocity ``U`` and air density ``\\rho`` as additional parameters.
"""
couple_models(aero::QuasiSteady, stru::TypicalSection)

# --- traits --- #
inplaceness(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = OutOfPlace()
mass_matrix_type(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = Zeros()
state_jacobian_type(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = Nonlinear()
number_of_parameters(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = 2

inplaceness(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = OutOfPlace()
mass_matrix_type(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = Zeros()
state_jacobian_type(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = Nonlinear()
number_of_parameters(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = 2

inplaceness(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = OutOfPlace()
mass_matrix_type(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = Linear()
state_jacobian_type(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = Nonlinear()
number_of_parameters(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = 2

# --- methods --- #

function get_inputs(aero::QuasiSteady{0}, stru::TypicalSection, q, p, t)
    # extract state variables
    h, θ, hdot, θdot = q
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u = U
    v = U*θ
    # calculate aerodynamic loads
    L, M = quasisteady0_loads(a, b, ρ, a0, α0, u, v)
    # return inputs
    return SVector(L, M)
end

function get_inputs(aero::QuasiSteady{1}, stru::TypicalSection, q, p, t)
    # extract state variables
    h, θ, hdot, θdot = q
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u = U
    v = U*θ + hdot
    ω = θdot
    # calculate aerodynamic loads
    L, M = quasisteady1_loads(a, b, ρ, a0, α0, u, v, ω)
    # return inputs
    return SVector(L, M)
end

function get_inputs(aero::QuasiSteady{2}, stru::TypicalSection, q, p, t)
    # extract state variables
    h, θ, hdot, θdot = q
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u = U
    v = U*θ + hdot
    ω = θdot
    # calculate aerodynamic loads
    L, M = quasisteady2_state_loads(a, b, ρ, a0, α0, u, v, ω)
    # return inputs
    return SVector(L, M)
end

function get_input_mass_matrix(aero::QuasiSteady{2}, stru::TypicalSection, q, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady2_mass_matrix(a, b, ρ)
end

# --- performance overloads --- #

function get_input_state_jacobian(aero::QuasiSteady{0}, stru::TypicalSection, q, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady0_jacobian(a, b, ρ, a0, U)
end

function get_input_state_jacobian(aero::QuasiSteady{1}, stru::TypicalSection, q, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady1_jacobian(a, b, ρ, a0, U)
end

function get_input_state_jacobian(aero::QuasiSteady{2}, stru::TypicalSection, q, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady2_jacobian(a, b, ρ, a0, U)
end

# --- unit testing methods --- #

function get_inputs_from_state_rates(aero::QuasiSteady{0}, stru::TypicalSection,
    dq, q, p, t)

    return @SVector zeros(2)
end

function get_inputs_from_state_rates(aero::QuasiSteady{1}, stru::TypicalSection,
    dq, q, p, t)

    return @SVector zeros(2)
end

function get_inputs_from_state_rates(aero::QuasiSteady{2}, stru::TypicalSection,
    dq, q, p, t)
    # extract state rates
    dh, dθ, dhdot, dθdot = dq
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    udot = 0
    vdot = dhdot
    ωdot = dθdot
    # calculate aerodynamic loads
    L, M = quasisteady2_rate_loads(a, b, ρ, vdot, ωdot)
    # return inputs
    return SVector(L, M)
end

# --- Lifting Line Section Coupling --- #

"""
    couple_models(aero::QuasiSteady, stru::LiftingLineSection)

Create an aerostructural model using a quasi-steady aerodynamics model and a
lifting line section model.  The existence of this coupling allows
[`QuasiSteady`](@ref) to be used with [`LiftingLine`](@ref). This model
introduces the freestream air density ``\\rho`` as an additional parameter.
"""
couple_models(aero::QuasiSteady, stru::LiftingLineSection)

# --- traits --- #

inplaceness(::Type{QuasiSteady{0}}, ::Type{LiftingLineSection}) = OutOfPlace()
mass_matrix_type(::Type{QuasiSteady{0}}, ::Type{LiftingLineSection}) = Zeros()
state_jacobian_type(::Type{QuasiSteady{0}}, ::Type{LiftingLineSection}) = Nonlinear()
number_of_parameters(::Type{QuasiSteady{0}}, ::Type{LiftingLineSection}) = 1

inplaceness(::Type{QuasiSteady{1}}, ::Type{LiftingLineSection}) = OutOfPlace()
mass_matrix_type(::Type{QuasiSteady{1}}, ::Type{LiftingLineSection}) = Zeros()
state_jacobian_type(::Type{QuasiSteady{1}}, ::Type{LiftingLineSection}) = Nonlinear()
number_of_parameters(::Type{QuasiSteady{1}}, ::Type{LiftingLineSection}) = 1

inplaceness(::Type{QuasiSteady{2}}, ::Type{LiftingLineSection}) = OutOfPlace()
mass_matrix_type(::Type{QuasiSteady{2}}, ::Type{LiftingLineSection}) = Linear()
state_jacobian_type(::Type{QuasiSteady{2}}, ::Type{LiftingLineSection}) = Nonlinear()
number_of_parameters(::Type{QuasiSteady{2}}, ::Type{LiftingLineSection}) = 1

# --- methods --- #

function get_inputs(aero::QuasiSteady{0}, stru::LiftingLineSection, s, p, t)
    # extract state variables
    vx, vy, vz, ωx, ωy, ωz = s
    # extract parameters
    a, b, a0, α0, ρ = p
    # local freestream velocity components
    u = vx
    v = vz
    # calculate loads
    L, M = quasisteady0_loads(a, b, ρ, a0, α0, u, v)
    # forces and moments per unit span
    f = SVector(0, 0, L)
    m = SVector(0, M, 0)
    # return inputs
    return vcat(f, m)
end

function get_inputs(aero::QuasiSteady{1}, stru::LiftingLineSection, s, p, t)
    # extract state variables
    vx, vy, vz, ωx, ωy, ωz = s
    # extract parameters
    a, b, a0, α0, ρ = p
    # local freestream velocity components
    u = vx
    v = vz
    ω = ωy
    # calculate aerodynamic loads
    L, M = quasisteady1_loads(a, b, ρ, a0, α0, u, v, ω)
    # forces and moments per unit span
    f = SVector(0, 0, L)
    m = SVector(0, M, 0)
    # return inputs
    return vcat(f, m)
end

function get_inputs(aero::QuasiSteady{2}, stru::LiftingLineSection, s, p, t)
    # extract state variables
    vx, vy, vz, ωx, ωy, ωz = s
    # extract parameters
    a, b, a0, α0, ρ = p
    # local freestream velocity components
    u = vx
    v = vz
    ω = ωy
    # calculate aerodynamic loads
    L, M = quasisteady2_state_loads(a, b, ρ, a0, α0, u, v, ω)
    # forces and moments per unit span
    f = SVector(0, 0, L)
    m = SVector(0, M, 0)
    # return inputs
    return vcat(f, m)
end

function get_input_mass_matrix(aero::QuasiSteady{2}, stru::LiftingLineSection,
    s, p, t)
    # extract parameters
    a, b, a0, α0, ρ = p
    # calculate loads
    L_vx, M_vx = quasisteady2_udot()
    L_vz, M_vz = quasisteady2_vdot(a, b, ρ)
    L_ωy, M_ωy = quasisteady2_ωdot(a, b, ρ)
    # return input mass matrix
    return @SMatrix [0 0 0 0 0 0; 0 0 0 0 0 0; -L_vx 0 -L_vz 0 -L_ωy 0; 0 0 0 0 0 0;
        -M_vx 0 -M_vz 0 -M_ωy 0; 0 0 0 0 0 0]
end

# --- performance overloads --- #

function get_input_state_jacobian(aero::QuasiSteady{0}, stru::LiftingLineSection, s, p, t)
    # extract state variables
    vx, vy, vz, ωx, ωy, ωz = s
    # extract parameters
    a, b, a0, α0, ρ = p
    # local freestream velocity components
    u = vx
    v = vz
    # calculate loads
    L_u, M_u = quasisteady0_u(a, b, ρ, a0, v)
    L_v, M_v = quasisteady0_v(a, b, ρ, a0, u)
    # return inputs
    return @SMatrix [0 0 0 0 0 0; 0 0 0 0 0 0; L_u 0 L_v 0 0 0; 0 0 0 0 0 0;
        M_u 0 M_v 0 0 0; 0 0 0 0 0 0]
end

function get_input_state_jacobian(aero::QuasiSteady{1}, stru::LiftingLineSection,
    s, p, t)
    # extract state variables
    vx, vy, vz, ωx, ωy, ωz = s
    # extract parameters
    a, b, a0, α0, ρ = p
    # local freestream velocity components
    u = vx
    v = vz
    ω = ωy
    # calculate loads
    L_u, M_u = quasisteady1_u(a, b, ρ, a0, α0, u, v, ω)
    L_v, M_v = quasisteady1_v(a, b, ρ, a0, α0, u)
    L_ω, M_ω = quasisteady1_ω(a, b, ρ, a0, u)
    # return inputs
    return @SMatrix [0 0 0 0 0 0; 0 0 0 0 0 0; L_u 0 L_v 0 L_ω 0;
        0 0 0 0 0 0; M_u 0 M_v 0 M_ω 0; 0 0 0 0 0 0]
end

function get_input_state_jacobian(aero::QuasiSteady{2}, stru::LiftingLineSection,
    s, p, t)
    # extract state variables
    vx, vy, vz, ωx, ωy, ωz = s
    # extract parameters
    a, b, a0, α0, ρ = p
    # local freestream velocity components
    u = vx
    v = vz
    ω = ωy
    # calculate loads
    L_u, M_u = quasisteady2_u(a, b, ρ, a0, α0, u, v, ω)
    L_v, M_v = quasisteady2_v(a, b, ρ, a0, α0, u)
    L_ω, M_ω = quasisteady2_ω(a, b, ρ, a0, u)
    # return inputs
    return @SMatrix [0 0 0 0 0 0; 0 0 0 0 0 0; L_u 0 L_v 0 L_ω 0; 0 0 0 0 0 0;
        M_u 0 M_v 0 M_ω 0; 0 0 0 0 0 0]
end

# --- unit testing methods --- #

function get_inputs_from_state_rates(aero::QuasiSteady{0}, stru::LiftingLineSection,
    ds, s, p, t)

    return @SVector zeros(6)
end

function get_inputs_from_state_rates(aero::QuasiSteady{1}, stru::LiftingLineSection,
    ds, s, p, t)

    return @SVector zeros(6)
end

function get_inputs_from_state_rates(aero::QuasiSteady{2}, stru::LiftingLineSection,
    ds, s, p, t)
    # extract state rates
    dvx, dvy, dvz, dωx, dωy, dωz = ds
    # extract parameters
    a, b, a0, α0, ρ = p
    # local freestream velocity components
    du = dvx
    dv = dvz
    dω = dωy
    # calculate aerodynamic loads
    L, M = quasisteady2_rate_loads(a, b, ρ, dv, dω)
    # forces and moments per unit span
    f = SVector(0, 0, L)
    m = SVector(0, M, 0)
    # return inputs
    return vcat(f, m)
end

# --- Internal Methods --- #

# steady state loads
function quasisteady0_loads(a, b, ρ, a0, α0, u, v)
    # lift at reference point
    L = a0*ρ*b*u*v
    # moment at reference point
    M = (b/2 + a*b)*L

    return SVector(L, M)
end

# circulatory loads + added mass effects, neglecting accelerations
function quasisteady1_loads(a, b, ρ, a0, α0, u, v, ω)
    # circulatory load factor
    tmp1 = a0*ρ*u*b
    # non-circulatory load factor
    tmp2 = pi*ρ*b^3
    # constant based on geometry
    d = b/2 - a*b
    # lift at reference point
    L = tmp1*(v + d*ω - u*α0) + tmp2*u/b*ω
    # moment at reference point
    M = -tmp2*u*ω + (b/2 + a*b)*L

    return SVector(L, M)
end

# quasi-steady loads + added mass effects
function quasisteady2_loads(a, b, ρ, a0, α0, u, v, ω, vdot, ωdot)
    # circulatory load factor
    tmp1 = a0*ρ*u*b
    # non-circulatory load factor
    tmp2 = pi*ρ*b^3
    # constant based on geometry
    d = b/2 - a*b
    # lift at reference point
    L = tmp1*(v + d*ω - u*α0) + tmp2*(dv/b + u/b*ω - a*dω)
    # moment at reference point
    M = -tmp2*(dv/2 + u*ω + (b/8 - a*b/2)*dω) + (b/2 + a*b)*L

    return SVector(L, M)
end

function quasisteady2_state_loads(a, b, ρ, a0, α0, u, v, ω)

    return quasisteady1_loads(a, b, ρ, a0, α0, u, v, ω)
end

# quasi-steady loads from acceleration terms
function quasisteady2_rate_loads(a, b, ρ, vdot, ωdot)
    # non-circulatory load factor
    tmp = pi*ρ*b^3
    # lift at reference point
    L = tmp*(vdot/b - a*ωdot)
    # moment at reference point
    M = -tmp*(vdot/2 + b*(1/8 - a/2)*ωdot) + (b/2 + a*b)*L

    return SVector(L, M)
end

function quasisteady0_u(a, b, ρ, a0, v)
    L_u = a0*ρ*b*v
    M_u = (b/2 + a*b)*L_u
    return SVector(L_u, M_u)
end

function quasisteady0_v(a, b, ρ, a0, u)
    L_v = a0*ρ*b*u
    M_v = (b/2 + a*b)*L_v
    return SVector(L_v, M_v)
end

function quasisteady1_u(a, b, ρ, a0, α0, u, v, ω)
    # circulatory load factor
    tmp1 = a0*ρ*u*b
    tmp1_u = a0*ρ*b
    # non-circulatory load factor
    tmp2 = pi*ρ*b^3
    # constant based on geometry
    d = b/2 - a*b
    # lift at reference point
    L_u = tmp1_u*(v + d*ω - u*α0) - tmp1*α0 + tmp2/b*ω
    # moment at reference point
    M_u = -tmp2*ω + (b/2 + a*b)*L_u

    return SVector(L_u, M_u)
end

function quasisteady1_v(a, b, ρ, a0, α0, u)
    # lift at reference point
    L_v = a0*ρ*u*b
    # moment at reference point
    M_v = (b/2 + a*b)*L_v

    return SVector(L_v, M_v)
end

function quasisteady1_ω(a, b, ρ, a0, u)
    # circulatory load factor
    tmp1 = a0*ρ*u*b
    # non-circulatory load factor
    tmp2 = pi*ρ*b^3
    # constant based on geometry
    d = b/2 - a*b
    # lift at reference point
    L_ω = tmp1*d + tmp2*u/b
    # moment at reference point
    M_ω = -tmp2*u + (b/2 + a*b)*L_ω

    return SVector(L_ω, M_ω)
end

quasisteady2_u(a, b, ρ, a0, α0, u, v, ω) = quasisteady1_u(a, b, ρ, a0, α0, u, v, ω)

quasisteady2_v(a, b, ρ, a0, α0, u) = quasisteady1_v(a, b, ρ, a0, α0, u)

quasisteady2_ω(a, b, ρ, a0, u) = quasisteady1_ω(a, b, ρ, a0, u)

quasisteady2_udot() = SVector(0, 0)

function quasisteady2_vdot(a, b, ρ)
    # non-circulatory load factor
    tmp = pi*ρ*b^3
    # lift at reference point
    L_vdot = tmp/b
    # moment at reference point
    M_vdot = -tmp/2 + (b/2 + a*b)*L_vdot

    return SVector(L_vdot, M_vdot)
end

function quasisteady2_ωdot(a, b, ρ)
    tmp = pi*ρ*b^3
    L_ωdot = -tmp*a
    M_ωdot = -tmp*(b/8 - a*b/2) + (b/2 + a*b)*L_ωdot
    return SVector(L_ωdot, M_ωdot)
end

function quasisteady0_jacobian(a, b, ρ, a0, U)
    L_θ = a0*ρ*U^2*b
    M_θ = (b/2 + a*b)*L_θ
    return @SMatrix [0 L_θ 0 0; 0 M_θ 0 0]
end

function quasisteady1_jacobian(a, b, ρ, a0, U)
    tmp1 = a0*ρ*U*b
    tmp2 = pi*ρ*b^3
    d1 = b/2 - a*b
    d2 = b/2 + a*b
    L_θ = tmp1*U
    L_hdot = tmp1
    L_θdot = tmp1*d1 + tmp2*U/b
    M_θ = d2*L_θ
    M_hdot = d2*L_hdot
    M_θdot = -tmp2*U + d2*L_θdot
    return @SMatrix [0 L_θ L_hdot L_θdot; 0 M_θ M_hdot M_θdot]
end

quasisteady2_jacobian(a, b, ρ, a0, U) = quasisteady1_jacobian(a, b, ρ, a0, U)

function quasisteady2_mass_matrix(a, b, ρ)
    # calculate derivatives
    tmp1 = pi*ρ*b^3
    tmp2 = b/2 + a*b
    L_hddot = -tmp1/b
    L_θddot = tmp1*a
    M_hddot = tmp1/2 + tmp2*L_hddot
    M_θddot = tmp1*(b/8 - a*b/2) + tmp2*L_θddot
    # return jacobian
    return @SMatrix [0 0 L_hddot L_θddot; 0 0 M_hddot M_θddot]
end
