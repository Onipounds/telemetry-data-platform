# Ekf-sensor-fusion

A compact, well-tested **Extended Kalman Filter (EKF)** for 2-D target tracking
and sensor fusion. The numerical core is model-agnostic; a worked
range/bearing tracking example shows it fusing a noisy nonlinear sensor stream
into a clean state estimate.

![EKF tracking result](docs/trajectory.png)

On the demo scenario the filter cuts position error by **~62%** versus the raw
sensor fixes:

```
Filtered position RMSE: 0.254 m
Raw sensor RMSE:        0.666 m
Improvement:            61.9%
```

## What it demonstrates

- **State estimation under nonlinearity** — a range + bearing sensor is
  nonlinear in the state, so the filter linearises through analytic Jacobians
  (the "Extended" in EKF).
- **Numerical care** — the covariance update uses the **Joseph form**, which
  keeps the covariance symmetric and positive-definite even with imperfect
  gains, and the angular innovation is wrapped to avoid the ±π discontinuity.
- **A reusable core** — `ExtendedKalmanFilter` takes your transition and
  measurement functions plus their Jacobians; the application model lives
  separately, so the filter is trivial to repoint at a new problem.
- **Engineering hygiene** — typed, documented code, a focused test suite
  (including a finite-difference check of the analytic Jacobian), and CI across
  Python 3.10–3.12.

## The model

| Component | Choice |
|-----------|--------|
| State | `[px, py, vx, vy]` — position (m) and velocity (m/s) |
| Motion | Constant velocity (linear transition) |
| Process noise | Discrete white-noise acceleration |
| Sensor | Range + bearing from a fixed station (nonlinear) |

## Quick start

```bash
pip install -e ".[dev]"      # install with test/plot extras
pytest -v                    # run the test suite
python examples/run_tracking.py   # reproduce the figures above
```

Minimal use of the core filter:

```python
import numpy as np
from ekf_fusion import (
    ExtendedKalmanFilter, transition, measurement,
    process_noise, measurement_residual,
)

dt = 0.1
f, F_jac = transition(dt)
h, H_jac = measurement(sensor=np.array([0.0, 0.0]))

kf = ExtendedKalmanFilter(
    f=f, F_jac=F_jac, h=h, H_jac=H_jac,
    Q=process_noise(dt, sigma_a=0.3),
    R=np.diag([0.5**2, np.deg2rad(2.0)**2]),
    x=np.array([20.0, -10.0, -1.5, 1.0]),
    P=np.diag([25.0, 25.0, 4.0, 4.0]),
    residual=measurement_residual,   # wraps the bearing innovation
)

estimate = kf.step(measurement_vector)   # one predict + update cycle
```

## Error over time

The estimate converges within the first few updates and tracks the target
thereafter:

![Position error vs time](docs/error.png)

## Layout

```
src/ekf_fusion/
  ekf.py        # generic ExtendedKalmanFilter (predict / update / step)
  tracking.py   # CV motion + range/bearing measurement model
tests/          # unit tests + finite-difference Jacobian verification
examples/       # runnable demo that produces the figures
```

## License

MIT — see [LICENSE](LICENSE).
