shader_type spatial;
render_mode specular_schlick_ggx;

// ============================================================================
// WAVE DATA — fed from WaveCalculator singleton
// ============================================================================
// Packed array: [dir_x, dir_y, amplitude, steepness, k, omega] per wave
// k = 2π / wavelength (wave number)
// omega = sqrt(g * k) (angular frequency, deep water dispersion relation)
// steepness Q ∈ [0, 1] — horizontal displacement (0 = sine, 1 = full Gerstner)
const int MAX_WAVES = 8;
const int STRIDE = 6;

uniform int wave_count : hint_range(1, 8) = 6;
uniform float wave_data[48]; // MAX_WAVES * STRIDE

// ============================================================================
// SURFACE COLORS
// ============================================================================
uniform vec3 color_deep : source_color = vec3(0.01, 0.06, 0.12);
uniform vec3 color_surface : source_color = vec3(0.02, 0.25, 0.35);
uniform vec3 color_sss : source_color = vec3(0.05, 0.55, 0.45);
uniform float sss_strength : hint_range(0.0, 1.0) = 0.25;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float base_roughness : hint_range(0.0, 1.0) = 0.05;

// ============================================================================
// FOAM — appears where Jacobian indicates wave breaking
// ============================================================================
uniform vec3 foam_color : source_color = vec3(0.85, 0.92, 0.97);
uniform float foam_roughness : hint_range(0.0, 1.0) = 0.8;
uniform float foam_threshold : hint_range(-1.0, 1.0) = 0.0;

// ============================================================================
// NORMAL MAP — two scrolling layers for capillary wave detail
// ============================================================================
uniform bool use_normal_maps = false;
uniform sampler2D normal_map_1 : hint_normal;
uniform sampler2D normal_map_2 : hint_normal;
uniform float normal_scale_1 : hint_range(0.001, 0.2) = 0.04;
uniform float normal_scale_2 : hint_range(0.001, 0.2) = 0.018;
uniform vec2 normal_dir_1 = vec2(1.0, 0.3);
uniform vec2 normal_dir_2 = vec2(-0.4, 1.0);
uniform float normal_speed_1 : hint_range(0.0, 0.1) = 0.02;
uniform float normal_speed_2 : hint_range(0.0, 0.1) = 0.013;
uniform float normal_strength : hint_range(0.0, 1.0) = 0.3;

// ============================================================================
// REFRACTION (optional — enable when ready)
// ============================================================================
uniform bool use_refraction = false;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture;
uniform float refraction_strength : hint_range(0.0, 0.3) = 0.06;
uniform float depth_fade_distance : hint_range(0.1, 50.0) = 8.0;

// ============================================================================
// VARYINGS — vertex → fragment
// ============================================================================
varying float v_foam_factor;
varying float v_wave_height_norm;
varying vec3 v_world_pos;

// ============================================================================
// VERTEX SHADER
// ============================================================================
void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vec3 displacement = vec3(0.0);

	// Gerstner analytical normal accumulator:
	//   N.x = -Σ D.x · k · A · cos(θ)
	//   N.y =  1 - Σ Q · k · A · sin(θ)
	//   N.z = -Σ D.y · k · A · cos(θ)
	float nx = 0.0;
	float ny = 1.0;
	float nz = 0.0;

	// Jacobian for foam: J = 1 - Σ Q·k·A·cos(θ)
	// J < 0 → surface folding → wave breaking → foam zone
	float jacobian = 1.0;

	float max_height = 0.0;

	for (int i = 0; i < MAX_WAVES; i++) {
		if (i >= wave_count) break;

		int idx = i * STRIDE;
		vec2 dir = vec2(wave_data[idx], wave_data[idx + 1]);
		float amp = wave_data[idx + 2];
		float steep = wave_data[idx + 3];
		float k = wave_data[idx + 4];
		float omega = wave_data[idx + 5];

		// θ = k · dot(D, P.xz) + ω · t
		float phase = k * dot(dir, world_pos.xz) + omega * TIME;
		float s = sin(phase);
		float c = cos(phase);

		// Gerstner displacement:
		//   Horizontal: shift toward crests → sharp peaks, flat troughs
		//   Vertical: standard A · cos(θ)
		displacement.x -= dir.x * steep * amp * s;
		displacement.z -= dir.y * steep * amp * s;
		displacement.y += amp * c;

		// Partial derivatives of Gerstner surface for analytical normal
		float ka = k * amp;
		nx -= dir.x * ka * c;
		ny -= steep * ka * s;
		nz -= dir.y * ka * c;

		// Jacobian: ∂x'/∂x — measures horizontal compression at crests
		jacobian -= steep * ka * c;

		max_height += amp;
	}

	// Apply displacement in world space, convert back to local
	vec3 displaced_world = world_pos + displacement;
	VERTEX = (inverse(MODEL_MATRIX) * vec4(displaced_world, 1.0)).xyz;

	// Transform normal world → local via normal matrix
	// transpose(inverse(M)) handles non-uniform scale and rotation
	mat3 normal_matrix = transpose(inverse(mat3(MODEL_MATRIX)));
	NORMAL = normalize(normal_matrix * vec3(nx, ny, nz));

	// Foam intensity: positive where surface folds (J < 0)
	v_foam_factor = clamp(-jacobian + foam_threshold, 0.0, 1.0);

	// Normalized wave height [0..1] for SSS: 0 = trough, 1 = crest
	v_wave_height_norm = (max_height > 0.0)
		? clamp((displacement.y + max_height) / (2.0 * max_height), 0.0, 1.0)
		: 0.5;

	v_world_pos = displaced_world;
}

// ============================================================================
// FRAGMENT SHADER
// ============================================================================
void fragment() {
	vec3 N = NORMAL;

	// --- Normal map detail (capillary waves) ---
	if (use_normal_maps) {
		// Two layers scrolling in different directions for organic motion
		vec2 uv1 = v_world_pos.xz * normal_scale_1 + normal_dir_1 * TIME * normal_speed_1;
		vec2 uv2 = v_world_pos.xz * normal_scale_2 + normal_dir_2 * TIME * normal_speed_2;

		// Unpack [0,1] → [-1,1]
		vec3 n1 = texture(normal_map_1, uv1).rgb * 2.0 - 1.0;
		vec3 n2 = texture(normal_map_2, uv2).rgb * 2.0 - 1.0;

		// UDN blending: add detail XY to geometric normal
		N = normalize(vec3(
			N.x + (n1.x + n2.x) * normal_strength,
			N.y,
			N.z + (n1.y + n2.y) * normal_strength
		));
	}

	// --- Fresnel: Schlick approximation ---
	// F(θ) = F0 + (1 - F0) · (1 - cosθ)^5
	// Water IoR ≈ 1.33 → F0 = ((n-1)/(n+1))^2 ≈ 0.02
	float cos_theta = max(dot(N, VIEW), 0.0);
	float F0 = 0.02;
	float fresnel = F0 + (1.0 - F0) * pow(1.0 - cos_theta, 5.0);

	// --- Base water color ---
	vec3 water_color = mix(color_deep, color_surface, fresnel);

	// --- Subsurface scattering approximation ---
	// Thin water at crests transmits light → bright teal glow
	// Effect scales with: (1) crest height, (2) glancing view angle
	float sss = v_wave_height_norm * sss_strength * pow(1.0 - cos_theta, 2.0);
	water_color = mix(water_color, color_sss, sss);

	// --- Optional refraction ---
	vec3 color = water_color;
	if (use_refraction) {
		// Reconstruct scene depth behind water surface
		float depth_sample = texture(depth_texture, SCREEN_UV).r;
		vec4 ndc = vec4(SCREEN_UV * 2.0 - 1.0, depth_sample, 1.0);
		vec4 view_pos = INV_PROJECTION_MATRIX * ndc;
		view_pos.xyz /= view_pos.w;
		float scene_depth = -view_pos.z;
		float water_depth = -VERTEX.z;
		float depth_diff = scene_depth - water_depth;

		// Exponential falloff: shallow → transparent, deep → opaque
		float depth_factor = clamp(1.0 - exp(-depth_diff / depth_fade_distance), 0.0, 1.0);

		// Offset screen UV by surface normal to bend light through water
		vec2 refraction_uv = SCREEN_UV + N.xz * refraction_strength * depth_factor;
		vec3 refracted = texture(screen_texture, refraction_uv).rgb;

		color = mix(refracted, water_color, depth_factor);
	}

	// --- Foam: white, matte where surface folds ---
	float foam = v_foam_factor;
	color = mix(color, foam_color, foam);
	float final_roughness = mix(base_roughness, foam_roughness, foam);

	// --- Output ---
	ALBEDO = color;
	METALLIC = metallic;
	ROUGHNESS = final_roughness;
	SPECULAR = mix(0.5, 0.1, foam);
}
