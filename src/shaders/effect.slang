#define SECTOR_COUNT 6
#define PI 3.1415926535897932384

struct PushConstants {
    float4 *src_img;
    float4 *dst_img;
    uint width;
    uint height;
    uint src_pitch;
    uint dst_pitch;
    uint kernel_size;
};
[[vk::push_constant]] ConstantBuffer<PushConstants> pc;

struct SectorInfo {
    float4 average;
    float variance;
}

inline int clamp_coord(int v, int maxv) { return (v < 0) ? 0 : (v > maxv ? maxv : v); }

float4 load_src(int x, int y)
{
    x = clamp_coord(x, int(pc.width) - 1);
    y = clamp_coord(y, int(pc.height) - 1);
    const uint idx = y * pc.src_pitch + x;
    return pc.src_img[idx];
}

void store_dst(uint x, uint y, float4 color)
{
    const uint idx = y * pc.dst_pitch + x;
    pc.dst_img[idx] = color;
}

// uv in [0, 1]; emulate hardware linear+clamp
float4 sample_bilinear(float2 uv)
{
    // GL/D3D-like sampler mapping: texel centers at i+0.5
    // float2 p = uv * (float2)(pc.width, pc.height) - 0.5;
    const float2 p = uv;

    const int2 i0 = (int2)floor(p);
    const int2 i1 = i0 + 1;
    const float2 f = frac(p);

    const float4 c00 = load_src(i0.x, i0.y);
    const float4 c10 = load_src(i1.x, i0.y);
    const float4 c01 = load_src(i0.x, i1.y);
    const float4 c11 = load_src(i1.x, i1.y);

    const float4 cx0 = lerp(c00, c10, f.x);
    const float4 cx1 = lerp(c01, c11, f.x);
    return lerp(cx0, cx1, f.y);
}

// Sobel kernels
static const float3x3 Gx = float3x3(-1, -2, -1, 0, 0, 0, 1, 2, 1); // x direction kernel
static const float3x3 Gy = float3x3(-1, 0, 1, -2, 0, 2, -1, 0, 1); // y direction kernel

float4 structure_tensor(float2 uv) {
    const float3 tx0y0 = sample_bilinear(uv + float2(-1, -1)).rgb;
    const float3 tx0y1 = sample_bilinear(uv + float2(-1, 0)).rgb;
    const float3 tx0y2 = sample_bilinear(uv + float2(-1, 1)).rgb;
    const float3 tx1y0 = sample_bilinear(uv + float2(0, -1)).rgb;
    const float3 tx1y1 = sample_bilinear(uv + float2(0, 0)).rgb;
    const float3 tx1y2 = sample_bilinear(uv + float2(0, 1)).rgb;
    const float3 tx2y0 = sample_bilinear(uv + float2(1, -1)).rgb;
    const float3 tx2y1 = sample_bilinear(uv + float2(1, 0)).rgb;
    const float3 tx2y2 = sample_bilinear(uv + float2(1, 1)).rgb;

    const float3 Sx = Gx[0][0] * tx0y0 + Gx[1][0] * tx1y0 + Gx[2][0] * tx2y0 +
                Gx[0][1] * tx0y1 + Gx[1][1] * tx1y1 + Gx[2][1] * tx2y1 +
                Gx[0][2] * tx0y2 + Gx[1][2] * tx1y2 + Gx[2][2] * tx2y2;

    const float3 Sy = Gy[0][0] * tx0y0 + Gy[1][0] * tx1y0 + Gy[2][0] * tx2y0 +
                Gy[0][1] * tx0y1 + Gy[1][1] * tx1y1 + Gy[2][1] * tx2y1 +
                Gy[0][2] * tx0y2 + Gy[1][2] * tx1y2 + Gy[2][2] * tx2y2;

    return float4(dot(Sx, Sx), dot(Sy, Sy), dot(Sx, Sy), 1.0);
}

float4 get_dominant_orientation(float4 tensor) {
    const float trace = tensor.x + tensor.y;
    const float determinant = tensor.x * tensor.y - tensor.z * tensor.z;

    const float half_trace = trace * 0.5;
    const float sq = sqrt(half_trace * half_trace - determinant);
    const float lambda1 = half_trace + sq;
    const float lambda2 = half_trace - sq;

    const float jxy_strength = abs(tensor.z) / (abs(tensor.x) + abs(tensor.y) + abs(tensor.z) + 1e-7);

    float2 v;
    if (jxy_strength > 0.0) {
        v = normalize(float2(-tensor.z, tensor.x - lambda1));
    } else {
        v = float2(0.0, 1.0);
    }

    // v = normalize(v);
    return float4(v.x, v.y, lambda1, lambda2);
}

float gaussian_weight(float distance, float sigma) {
    return exp(-(distance * distance) / (2.0 * sigma * sigma));
}

float polynomial_weight(float2 xy) {
    static const float ETA = 0.1;
    static const float LAMBDA = 0.5;

    float poly_value = (xy.x + ETA) - LAMBDA * (xy.y * xy.y);
    return poly_value * poly_value;
}

SectorInfo calculate_sector_info(float2 uv, float angle, float2x2 anisotropy_mat) {
    SectorInfo sector;
    sector.average = float4(0.0);

    float total_weight = 0.0;
    float4 weighted_square_sum = float4(0.0);

    const float radius = (float)pc.kernel_size;

    static const float ANGLE_VAL = PI / SECTOR_COUNT;
    for (float r = 1.0; r <= radius; r += 1.0) {
        for (float a = -ANGLE_VAL; a <= ANGLE_VAL; a += ANGLE_VAL * 0.5) {
            const float2 offset = mul(r * float2(cos(angle + a), sin(angle + a)), anisotropy_mat);

            const float2 pos = uv + offset;
            if (pos.x >= (float)pc.width || pos.x < 0 || pos.y >= (float)pc.height || pos.y < 0) {
                continue;
            }

            const float4 color = sample_bilinear(pos);
            // float weight = polynomial_weight(offset);
            const float weight = gaussian_weight(length(offset), radius / 3.0);

            const float4 cw = color * weight;
            sector.average += cw;
            weighted_square_sum += color * cw;

            total_weight += weight;
        }
    }

    sector.average /= total_weight;
    const float4 variance = weighted_square_sum / total_weight - sector.average * sector.average;
    sector.variance = dot(variance.xyz, float3(0.299, 0.587, 0.114));

    return sector;
}

[shader("compute")]
[numthreads(16, 16, 1)]
void main(uint3 thread_id: SV_DispatchThreadID) {
    if (thread_id.x >= pc.width || thread_id.y >= pc.height) {
        return;
    }

    const float2 uv = (float2)thread_id.xy + 0.5;

    const float4 tensor = structure_tensor(uv);
    const float4 orient_n_anis = get_dominant_orientation(tensor);
    const float2 orientation = orient_n_anis.xy;
    const float anisotropy = (orient_n_anis.z - orient_n_anis.w) / (orient_n_anis.z + orient_n_anis.w + 1e-7);

    static const float ALPHA = 25.0;
    const float an_a = anisotropy + ALPHA;
    const float scale_x = ALPHA / an_a;
    const float scale_y = an_a / ALPHA;

    const float2x2 anisotropy_mat = mul(float2x2(orientation.x, -orientation.y, orientation.y, orientation.x), float2x2(scale_x, 0.0, 0.0, scale_y));

    SectorInfo sectors[SECTOR_COUNT];
    for (uint i = 0; i < SECTOR_COUNT; i++) {
        const float angle = float(i) * (2.0 * PI) / float(SECTOR_COUNT);
        sectors[i] = calculate_sector_info(uv, angle, anisotropy_mat);
    }

    uint min_variance_sector = 0;
    for (uint i = 1; i < SECTOR_COUNT; i++) {
        if (sectors[min_variance_sector].variance > sectors[i].variance) {
            min_variance_sector = i;
        }
    }

    float4 col = sectors[min_variance_sector].average;
    if (isnan(col.r)) {
        col = float4(0.0);
    }
    store_dst(thread_id.x, thread_id.y, col);
}
