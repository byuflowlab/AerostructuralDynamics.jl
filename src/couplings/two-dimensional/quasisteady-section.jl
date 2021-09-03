"""
    couple_models(aero::Steady, stru::TypicalSection)

Create an aerostructural model using a steady aerodynamics model and a
two-degree of freedom typical section model.  This model introduces the
freestream velocity ``U`` and air density ``\\rho`` as additional parameters.
"""
couple_models(aero::Steady, stru::TypicalSection) = (aero, stru)

"""
    couple_models(aero::QuasiSteady, stru::TypicalSection)

Create an aerostructural model using a quasi-steady aerodynamics model and a
two-degree of freedom typical section model.  This model introduces the
freestream velocity ``U`` and air density ``\\rho`` as additional parameters.
"""
couple_models(aero::QuasiSteady, stru::TypicalSection) = (aero, stru)

# --- traits --- #

number_of_additional_parameters(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = 2
coupling_inplaceness(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = OutOfPlace()
coupling_rate_jacobian_type(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = Zeros()
coupling_state_jacobian_type(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = Nonlinear()
coupling_parameter_jacobian_type(::Type{QuasiSteady{0}}, ::Type{TypicalSection}) = Nonlinear()

number_of_additional_parameters(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = 2
coupling_inplaceness(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = OutOfPlace()
coupling_rate_jacobian_type(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = Zeros()
coupling_state_jacobian_type(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = Nonlinear()
coupling_parameter_jacobian_type(::Type{QuasiSteady{1}}, ::Type{TypicalSection}) = Nonlinear()

number_of_additional_parameters(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = 2
coupling_inplaceness(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = OutOfPlace()
coupling_rate_jacobian_type(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = Linear()
coupling_state_jacobian_type(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = Nonlinear()
coupling_parameter_jacobian_type(::Type{QuasiSteady{2}}, ::Type{TypicalSection}) = Nonlinear()

# --- methods --- #

function get_coupling_inputs(aero::QuasiSteady{0}, stru::TypicalSection, dx, x, p, t)
    # extract state variables
    h, θ, hdot, θdot = x
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u, v = section_steady_velocities(U, θ)
    # calculate aerodynamic loads
    L, M = quasisteady0_loads(a, b, ρ, a0, α0, u, v)
    # return inputs
    return SVector(L, M)
end

function get_coupling_inputs(aero::QuasiSteady{1}, stru::TypicalSection, dx, x, p, t)
    # extract state variables
    h, θ, hdot, θdot = x
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u, v, ω = section_velocities(U, θ, hdot, θdot)
    # calculate aerodynamic loads
    L, M = quasisteady1_loads(a, b, ρ, a0, α0, u, v, ω)
    # return inputs
    return SVector(L, M)
end

function get_coupling_inputs(aero::QuasiSteady{2}, stru::TypicalSection, dx, x, p, t)
    # extract state variables
    dh, dθ, dhdot, dθdot = dx
    # extract state variables
    h, θ, hdot, θdot = x
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u, v, ω = section_velocities(U, θ, hdot, θdot)
    # local freestream accelerations
    udot, vdot, ωdot = section_accelerations(U, dhdot, dθdot)
    # calculate aerodynamic loads
    L, M = quasisteady2_state_loads(a, b, ρ, a0, α0, u, v, ω, vdot, ωdot)
    # return inputs
    return SVector(L, M)
end

# --- performance overloads --- #

function get_coupling_rate_jacobian(aero::QuasiSteady{2}, stru::TypicalSection, dx, x, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady2_section_rate_jacobian(a, b, ρ)
end

function get_coupling_state_jacobian(aero::QuasiSteady{0}, stru::TypicalSection, x, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady0_section_state_jacobian(a, b, ρ, a0, U)
end

function get_coupling_state_jacobian(aero::QuasiSteady{1}, stru::TypicalSection, x, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady1_section_state_jacobian(a, b, ρ, a0, U)
end

function get_coupling_state_jacobian(aero::QuasiSteady{2}, stru::TypicalSection, x, p, t)
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # return jacobian
    return quasisteady2_section_state_jacobian(a, b, ρ, a0, U)
end

function get_coupling_parameter_jacobian(aero::QuasiSteady{0}, stru::TypicalSection, x, p, t)
    # extract state variables
    h, θ, hdot, θdot = x
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u, v, ω = section_steady_velocities(U, θ, hdot, θdot)
    # calculate loads
    L_a, M_a = quasisteady0_loads_a(a, b, ρ, a0, α0, u, v, ω)
    L_b, M_b = quasisteady0_loads_b(a, b, ρ, a0, α0, u, v, ω)
    L_a0, M_a0 = quasisteady0_loads_a0(a, b, ρ, α0, u, v, ω)
    L_α0, M_a0 = quasisteady0_loads_α0(a, b, ρ, a0, u)
    L_U, M_U = quasisteady0_loads_u(a, b, ρ, a0, α0, u, v)
    L_ρ, M_ρ = quasisteady0_loads_ρ(a, b, a0, α0, u, v, ω)
    # return jacobian
    return quasisteady0_section_parameter_jacobian(a, b, ρ, a0, U)
end

function get_coupling_parameter_jacobian(aero::QuasiSteady{1}, stru::TypicalSection, dx, x, p, t)
    # extract state variables
    h, θ, hdot, θdot = x
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u, v, ω = section_velocities(U, θ, hdot, θdot)
    # calculate loads
    L_a, M_a = quasisteady1_loads_a(a, b, ρ, a0, α0, u, v, ω)
    L_b, M_b = quasisteady1_loads_b(a, b, ρ, a0, α0, u, v, ω)
    L_a0, M_a0 = quasisteady1_loads_a0(a, b, ρ, α0, u, v, ω)
    L_α0, M_a0 = quasisteady1_loads_α0(a, b, ρ, a0, u)
    L_U, M_U = quasisteady1_loads_u(a, b, ρ, a0, α0, u, v)
    L_ρ, M_ρ = quasisteady1_loads_ρ(a, b, a0, α0, u, v, ω)
    # return jacobian
    return @SMatrix [L_a L_b L_a0 L_α0 L_U L_ρ; M_a M_b M_a0 M_α0 M_U M_ρ]
end

function get_coupling_parameter_jacobian(aero::QuasiSteady{2}, stru::TypicalSection, dx, x, p, t)
    # extract state variables
    dh, dθ, dhdot, dθdot = dx
    # extract state variables
    h, θ, hdot, θdot = x
    # extract aerodynamic, structural, and aerostructural parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p
    # local freestream velocity components
    u, v, ω = section_velocities(U, θ, hdot, θdot)
    # local freestream accelerations
    udot, vdot, ωdot = section_accelerations(U, dhdot, dθdot)
    # calculate loads
    L_a, M_a = quasisteady2_loads_a(a, b, ρ, a0, α0, u, v, ω, vdot, ωdot)
    L_b, M_b = quasisteady2_loads_b(a, b, ρ, a0, α0, u, v, ω, vdot, ωdot)
    L_a0, M_a0 = quasisteady2_loads_a0(a, b, ρ, α0, u, v, ω)
    L_α0, M_a0 = quasisteady2_loads_α0(a, b, ρ, a0, u)
    L_U, M_U = quasisteady2_loads_u(a, b, ρ, a0, α0, u, v, ωdot)
    L_ρ, M_ρ = quasisteady2_loads_ρ(a, b, a0, α0, u, v, ω, vdot, ωdot)
    # return jacobian
    return @SMatrix [L_a L_b L_a0 L_α0 L_U L_ρ; M_a M_b M_a0 M_α0 M_U M_ρ]
end

# --- Convenience Methods --- #

function set_additional_parameters!(padd, aero::QuasiSteady, stru::TypicalSection; U, rho)

    padd[1] = U
    padd[2] = rho

    return padd
end

function separate_additional_parameters(aero::QuasiSteady, stru::TypicalSection, padd)

    return (U = padd[1], rho = padd[2])
end

# --- Plotting --- #

@recipe function f(aero::QuasiSteady, stru::TypicalSection, x, y, p, t)

    framestyle --> :origin
    grid --> false
    xlims --> (-1.0, 1.0)
    ylims --> (-1.5, 1.5)
    label --> @sprintf("t = %6.3f", t)

    # extract state variables
    h, θ, hdot, θdot = x

    # extract parameters
    a, b, a0, α0, kh, kθ, m, Sθ, Iθ, U, ρ = p

    xplot = [-(0.5 + a*b)*cos(θ),    (0.5 - a*b)*cos(θ)]
    yplot = [ (0.5 + a*b)*sin(θ)-h, -(0.5 - a*b)*sin(θ)-h]

    return xplot, yplot
end

# --- Internal Methods --- #

function section_steady_velocities(U, θ)
    u = U
    v = U*θ
end

function quasisteady0_section_state_jacobian(a, b, ρ, a0, U)
    L_θ = a0*ρ*U^2*b
    M_θ = (b/2 + a*b)*L_θ
    return @SMatrix [0 L_θ 0 0; 0 M_θ 0 0]
end

function quasisteady1_section_state_jacobian(a, b, ρ, a0, U)
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

quasisteady2_section_state_jacobian(a, b, ρ, a0, U) = quasisteady1_jacobian(a, b, ρ, a0, U)

function quasisteady2_section_rate_jacobian(a, b, ρ)
    # calculate derivatives
    tmp1 = pi*ρ*b^3
    tmp2 = b/2 + a*b
    L_hddot = tmp1/b
    L_θddot = -tmp1*a
    M_hddot = tmp1/2 + tmp2*L_hddot
    M_θddot = tmp1*(b/8 - a*b/2) + tmp2*L_θddot
    # return jacobian
    return @SMatrix [0 0 L_hddot L_θddot; 0 0 M_hddot M_θddot]
end