float4x4 worldViewProj;
float4x4 world;

float4 ambientColor;

float4x4 worldInverseTranspose;

float shininess = 8;

sampler textureSampler : register(s0);

sampler bumpSampler : register(s1);

struct VertexShaderInput
{
    float4 position : POSITION0;
    float3 normal : NORMAL;
    float2 textureCoord : TEXCOORD0;
    float3 tangent : TANGENT;
};

struct VertexShaderOutput
{
float4 position : POSITION0;
    float3 normal : TEXCOORD0;
    float2 textureCoord : TEXCOORD1;
    float3 pixelPos : TEXCOORD2;
    float3 tangent : TEXCOORD3;
    float3 binormal : TEXCOORD4;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

    output.position = mul (worldViewProj,input.position);

    output.normal = normalize(mul(worldInverseTranspose, input.normal));
    output.tangent = normalize(mul(worldInverseTranspose,input.tangent));
    output.binormal = normalize(mul(worldInverseTranspose,cross(input.tangent.xyz,input.normal)));

    output.textureCoord = input.textureCoord;
    output.pixelPos = output.position.xyz;

    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input, uniform float3 cameraPos, uniform float4 diffLightPos, uniform float lightCorrection) : COLOR0
{

    //normal
    float3 bump = (tex2D(bumpSampler, input.textureCoord) - float3(0.5,0.5,0.5));
    float3 bumpNormal = normalize(input.normal + (bump.x * input.tangent + bump.y * input.binormal));

    //diffuse light
    float3 diffuseLightDirection = diffLightPos.xyz;
    float diffuseIntensity = dot(normalize(diffuseLightDirection), bumpNormal);
    if(diffuseIntensity < lightCorrection)
        diffuseIntensity = lightCorrection;

    //specular
    float3 viewVector = normalize(cameraPos - mul(input.pixelPos, world).xyz);
    float3 light = normalize(diffuseLightDirection);
    float3 r = normalize(2 * bumpNormal * diffuseIntensity - light);
    float3 v = normalize(viewVector);
    float dotProduct = dot(r,v);
    float4 specular = max(pow(dotProduct,shininess),0);

    //texture
    float4 textureColor = tex2D(textureSampler, input.textureCoord);
    //clip(textureColor.a - 0.3);
    textureColor.a = 1;

    return ambientColor * ambientColor.x + textureColor * diffuseIntensity + specular;
}
