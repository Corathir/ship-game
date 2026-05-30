// ============================================================================
// Gerstner wave reference — canonical formula documentation.
// NOT included by the shader (Godot does not support #include in .gdshader).
// Both water.gdshader and wave_calculator.gd MUST stay in sync with this file.
//
// When editing wave math, update ALL THREE files:
//   1. This file (reference)
//   2. ocean/water.gdshader (vertex shader loop)
//   3. ocean/wave_calculator.gd (physics queries)
// ============================================================================
//
// Packed wave_data layout (STRIDE = 6):
//   [dir_x, dir_y, amplitude, steepness, k, omega]
//   k     = 2π / wavelength   (wave number)
//   omega = sqrt(g · k)       (deep water dispersion)
//   steepness Q ∈ [0, 1]      (0 = sine, 1 = full Gerstner)

const int MAX_WAVES = 8;
const int STRIDE = 6;

// Result struct for gerstner_evaluate()
struct GerstnerResult {
	vec3 displacement;   // world-space offset to add to undisplaced position
	vec3 normal;         // analytical surface normal (unnormalized)
	float jacobian;      // ∂x'/∂x — horizontal compression (J < 0 = wave breaking)
	float max_amplitude; // sum of all amplitudes (for height normalization)
};

// Evaluate all Gerstner waves at world position (wx, wz) at time t.
// wave_count: number of active waves (≤ MAX_WAVES)
// wave_data:  packed uniform array [dir_x, dir_y, amp, steep, k, omega] per wave
GerstnerResult gerstner_evaluate(
	float wx, float wz, float t,
	int wave_count,
	float wave_data[48]
) {
	GerstnerResult r;
	r.displacement = vec3(0.0);
	r.normal = vec3(0.0, 1.0, 0.0);
	r.jacobian = 1.0;
	r.max_amplitude = 0.0;

	for (int i = 0; i < MAX_WAVES; i++) {
		if (i >= wave_count) break;

		int idx = i * STRIDE;
		vec2 dir = vec2(wave_data[idx], wave_data[idx + 1]);
		float amp = wave_data[idx + 2];
		float steep = wave_data[idx + 3];
		float k = wave_data[idx + 4];
		float omega = wave_data[idx + 5];

		// θ = k · dot(D, P.xz) + ω · t
		float phase = k * dot(dir, vec2(wx, wz)) + omega * t;
		float s = sin(phase);
		float c = cos(phase);

		// Gerstner displacement:
		//   Horizontal: shift toward crests → sharp peaks, flat troughs
		//   Vertical: standard A · cos(θ)
		r.displacement.x -= dir.x * steep * amp * s;
		r.displacement.z -= dir.y * steep * amp * s;
		r.displacement.y += amp * c;

		// Analytical normal partial derivatives:
		//   N.x = -Σ D.x · k · A · cos(θ)
		//   N.y =  1 - Σ Q · k · A · sin(θ)
		//   N.z = -Σ D.y · k · A · cos(θ)
		float ka = k * amp;
		r.normal.x -= dir.x * ka * c;
		r.normal.y -= steep * ka * s;
		r.normal.z -= dir.y * ka * c;

		// Jacobian: ∂x'/∂x — measures horizontal compression at crests
		r.jacobian -= steep * ka * c;

		r.max_amplitude += amp;
	}

	return r;
}
