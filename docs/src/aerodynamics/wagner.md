# Wagner's Function

## Theory

Wagner's function models the indicial response of aerodynamic loads under a sudden change in downwash ``w`` at the three-quarter's chord. The exact expression for Wagner's function is
```math
\phi(t) = \frac{2}{\pi} \int_0^\infty \frac{Re(C) \sin ( \omega (u/b) t  )}{\omega} d\omega
```
where ``C(\omega)`` is Theodorsen's function.  In many cases, approximate versions of Wagner's function are used rather than the exact expression,  of which one of the most common is the approximation of Wagner's function provided by R. T. Jones
```math
\phi(t) = 1 - C_1 e^{-\varepsilon_1 (u/b) t} - C_2 e^{-\varepsilon_2 (u/b) t}
```
where ``C_1 = 0.165``, ``C_2 = 0.335``, ``\varepsilon_1 = 0.455``, and ``\varepsilon_2 = 0.3``.

Wagner's function may be used to model arbitrary airfoil motion using Duhamel's integral.  We start by modeling the increment in circulatory lift ``d L_c(t)`` at time ``t`` due to an increment in downwash ``d w(t)`` at earlier time ``\tau`` as
```math
\frac{d L_c'(t)}{a_0 \rho_\infty u b} =  \phi(t - \tau) d w(\tau)
```
where ``\phi(t)`` is the impulse response function, which in this case is R. T. Jones' approximation of Wagner's function.  Superimposing all previous impulse responses using Duhamel's integral yields the following expression for the instantaneous circulatory lift.
```math
\frac{L_c'}{a_0 \rho_\infty u b} = \int_{-\infty}^t d w(\tau) \phi(t - \tau) d\tau = w(0) \phi(t) + \int_{0}^t  d w(\tau) \phi(t - \tau) d \tau
```
We can transform this equation using integration by parts, yielding
```math
\frac{L_c'}{a_0 \rho_\infty u b} = w(t) \phi(0) - \int_{0}^t w(\tau) d\phi(t - \tau) d\tau
```
The integral in this expression may be expressed as a function of the aerodynamic states ``\lambda_1`` and ``\lambda_2``.
```math
\lambda_1 = C_1 \varepsilon_1 \frac{u}{b} \int_0^t w(\tau) e^{-\varepsilon_1 (u/b) (t - \tau)} d \tau
```
```math
\lambda_2 = C_2 \varepsilon_2 \frac{u}{b} \int_0^t w(\tau) e^{-\varepsilon_2 (u/b) (t - \tau)} d \tau
```
```math
\lambda_1 + \lambda_2 = - \int_0^t w(\tau) d\phi(t-\tau) d\tau
```
The expression for circulatory lift then reduces to
```math
\frac{L_c'}{a_0 \rho_\infty u b} = w(t) \phi(0) + \lambda_1 + \lambda_2
```
where the downwash at the three quarter's chord is given by
```math
w(t) = -v + b \left( \frac{1}{2} - a \right) \dot{\theta} - u\alpha_0
```
and the aerodynamic states variables ``\lambda_1`` and ``\lambda_2`` are described by the ordinary differential equations
```math
\dot{\lambda_1} = -\varepsilon_1 \frac{u}{b} \lambda_1 + C_1 \varepsilon_1 \frac{u}{b} w(t) \\
\dot{\lambda_2} = -\varepsilon_2 \frac{u}{b} \lambda_2 + C_2 \varepsilon_2 \frac{u}{b} w(t)
```

The same lift and moment expressions are used as in the quasi-steady model, but with the new effective angle of attack
```math
\alpha_\text{eff} = \left(-\frac{v}{u} + \frac{b}{u} \left( \frac{1}{2} - a \right) \dot{\theta} - \alpha_0 \right) \phi(0) + \frac{\lambda_1}{u} + \frac{\lambda_2}{u}
```

## Documentation

```@docs
Wagner()
```