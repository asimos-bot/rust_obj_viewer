// Vertex shader

[[block]]
struct CameraUniform {
    view_proj: mat4x4<f32>;
    view_pos: vec4<f32>;
};

struct VertexInput {
    [[location(0)]] position: vec3<f32>;
    [[location(1)]] normal: vec3<f32>;
};

struct InstanceInput {
    [[location(2)]] model_matrix_0: vec4<f32>;
    [[location(3)]] model_matrix_1: vec4<f32>;
    [[location(4)]] model_matrix_2: vec4<f32>;
    [[location(5)]] model_matrix_3: vec4<f32>;

    [[location(6)]] normal_matrix_0: vec3<f32>;
    [[location(7)]] normal_matrix_1: vec3<f32>;
    [[location(8)]] normal_matrix_2: vec3<f32>;
};

[[group(0), binding(0)]]
var<uniform> camera: CameraUniform;

[[block]]
struct LightUniform {
    position: vec3<f32>;
    color: vec3<f32>;
};

[[group(1), binding(0)]]
var<uniform> light: LightUniform;

struct VertexOutput {
    [[builtin(position)]] clip_position: vec4<f32>;
    [[location(0)]] color: vec3<f32>;
    [[location(1)]] world_normal: vec3<f32>;
    [[location(2)]] world_position: vec3<f32>;
};

[[stage(vertex)]]
fn vs_main(
    model: VertexInput,
    instance: InstanceInput
) -> VertexOutput {
    let model_matrix = mat4x4<f32>(
        instance.model_matrix_0,
        instance.model_matrix_1,
        instance.model_matrix_2,
        instance.model_matrix_3,
    );
    let normal_matrix = mat3x3<f32>(
        instance.normal_matrix_0,
        instance.normal_matrix_1,
        instance.normal_matrix_2,
    );
    var out: VertexOutput;

    out.world_normal = normal_matrix * model.normal;
    var world_position: vec4<f32> = model_matrix * vec4<f32>(model.position, 1.0);
    out.world_position = world_position.xyz;
    out.clip_position = camera.view_proj * world_position;

    return out;
}

[[stage(fragment)]]
fn fs_main(in: VertexOutput) -> [[location(0)]] vec4<f32> {

    let object_color: vec4<f32> = vec4<f32>(0.3, 0.2, 0.5, 0.1);
    let ambient_strenght = 0.1;
    let ambient_color = light.color * ambient_strenght;

    let light_dir = normalize(light.position - in.world_position);

    let diffuse_strength = max(dot(in.world_normal, light_dir), 0.0);
    let diffuse_color = light.color * diffuse_strength;

    let view_dir = normalize(camera.view_pos.xyz - in.world_position);
    let half_dir = normalize(view_dir + light_dir);
    let specular_strength = pow(max(dot(in.world_normal, half_dir), 0.0), 32.0);
    let specular_color = specular_strength * light.color;

    let result = (ambient_color + diffuse_color + specular_color) * object_color.xyz;
    return vec4<f32>(result, object_color.a);
}
