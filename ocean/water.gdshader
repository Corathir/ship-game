shader_type spatial;
render_mode specular_schlick_ggx;

uniform float amplitude1 : hint_range(0.0, 2.0) = 0.5;
uniform float amplitude2 : hint_range(0.0, 2.0) = 0.3;
uniform float frequency1 : hint_range(0.1, 3.0) = 0.5;
uniform float frequency2 : hint_range(0.1, 3.0) = 0.8;
uniform float speed : hint_range(0.0, 5.0) = 1.0;

uniform vec3 color_deep : source_color = vec3(0.0, 0.1, 0.2);
uniform vec3 color_surface : source_color = vec3(0.0, 0.4, 0.5);
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.

    // Мировые координаты вершины
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    float wave1 = sin(world_pos.x * frequency1 + TIME * speed) * amplitude1;
    float wave2 = sin(world_pos.z * frequency2 + TIME * speed * 1.3) * amplitude2;

    // Дополнительные волны — мельче и быстрее
    float wave3 = sin(world_pos.x * 1.5 + world_pos.z * 0.8 + TIME * speed * 2.0) * 0.15;
    float wave4 = sin(world_pos.x * 0.6 - world_pos.z * 1.2 + TIME * speed * 1.7) * 0.1;

    VERTEX.y += wave1 + wave2 + wave3 + wave4;

    // Производные волн (наклон поверхности)
    float dx = cos(world_pos.x * frequency1 + TIME * speed) * frequency1 * amplitude1;
    dx += cos(world_pos.x * 1.5 + world_pos.z * 0.8 + TIME * speed * 2.0) * 1.5 * 0.15;
    dx += cos(world_pos.x * 0.6 - world_pos.z * 1.2 + TIME * speed * 1.7) * 0.6 * 0.1;

    float dz = cos(world_pos.z * frequency2 + TIME * speed * 1.3) * frequency2 * amplitude2;
    dz += cos(world_pos.x * 1.5 + world_pos.z * 0.8 + TIME * speed * 2.0) * 0.8 * 0.15;
    dz += cos(world_pos.x * 0.6 - world_pos.z * 1.2 + TIME * speed * 1.7) * -1.2 * 0.1;

    // Нормаль перпендикулярна наклону
    NORMAL = normalize(vec3(-dx, 1.0, -dz));
}

void fragment() {
	// Called for every pixel the material is visible on.
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);
    ALBEDO = mix(color_deep, color_surface, fresnel);
    METALLIC = metallic;
    ROUGHNESS = roughness;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}