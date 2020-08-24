Shader "Unlit/SkyboxProc"
{
	Properties
	{
		 [Header(Stars Settings)]
		_Stars("Stars Texture", 2D) = "black" {}
		_StarsCutoff("Stars Cutoff",  Range(0, 1)) = 0.08
		_StarsSpeed("Stars Move Speed",  Range(0, 1)) = 0.3 
		_StarsSkyColor("Stars Sky Color", Color) = (0.0,0.2,0.1,1)

		 [Header(Horizon Settings)]
		_OffsetHorizon("Horizon Offset",  Range(-1, 1)) = 0
		_HorizonIntensity("Horizon Intensity",  Range(0, 10)) = 3.3
		_SunSet("Sunset/Rise Color", Color) = (1,0.8,1,1)
		_HorizonColorDay("Day Horizon Color", Color) = (0,0.8,1,1)
		_HorizonColorNight("Night Horizon Color", Color) = (0,0.8,1,1)

		 [Header(Sun Settings)]
		 _SunColor("Sun Color", Color) = (1,1,1,1)
		_SunRadius("Sun Radius",  Range(0, 2)) = 0.1

		[Header(Moon Settings)]
		_MoonColor("Moon Color", Color) = (1,1,1,1)
		_MoonRadius("Moon Radius",  Range(0, 2)) = 0.15
		_MoonOffset("Moon Crescent",  Range(-1, 1)) = -0.1

		[Header(Day Sky Settings)]
		_DayTopColor("Day Sky Color Top", Color) = (0.4,1,1,1)
		_DayBottomColor("Day Sky Color Bottom", Color) = (0,0.8,1,1)

		[Header(Main Cloud Settings)]
		_BaseNoise("Base Noise", 2D) = "black" {}
		_Distort("Distort", 2D) = "black" {}
		_SecNoise("Secondary Noise", 2D) = "black" {}
		_BaseNoiseScale("Base Noise Scale",  Range(0, 1)) = 0.2
		_DistortScale("Distort Noise Scale",  Range(0, 1)) = 0.06
		_SecNoiseScale("Secondary Noise Scale",  Range(0, 1)) = 0.05
		_Distortion("Extra Distortion",  Range(0, 1)) = 0.1
		_Speed("Movement Speed",  Range(0, 10)) = 1.4
		_CloudCutoff("Cloud Cutoff",  Range(0, 1)) = 0.3
		_Fuzziness("Cloud Fuzziness",  Range(0, 5)) = 0.04
		_FuzzinessUnder("Cloud Fuzziness Under",  Range(0, 1)) = 0.01
		[Toggle(FUZZY)] _FUZZY("Extra Fuzzy clouds", Float) = 1

		[Header(Day Clouds Settings)]
		_CloudColorDayEdge("Clouds Edge Day", Color) = (1,1,1,1)
		_CloudColorDayMain("Clouds Main Day", Color) = (0.8,0.9,0.8,1)
		_CloudColorDayUnder("Clouds Under Day", Color) = (0.6,0.7,0.6,1)
		_Brightness("Cloud Brightness",  Range(1, 10)) = 2.5
		[Header(Night Sky Settings)]
		_NightTopColor("Night Sky Color Top", Color) = (0,0,0,1)
		_NightBottomColor("Night Sky Color Bottom", Color) = (0,0,0.2,1)

		[Header(Night Clouds Settings)]
		_CloudColorNightEdge("Clouds Edge Night", Color) = (0,1,1,1)
		_CloudColorNightMain("Clouds Main Night", Color) = (0,0.2,0.8,1)
		_CloudColorNightUnder("Clouds Under Night", Color) = (0,0.2,0.6,1)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog
				#pragma shader_feature FUZZY
				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float3 uv : TEXCOORD0;
				};

				struct v2f
				{
					float3 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
					float3 worldPos : TEXCOORD1;
				};

				sampler2D _Stars, _BaseNoise, _Distort, _SecNoise;

				float _SunRadius, _MoonRadius, _MoonOffset, _OffsetHorizon;
				float4 _SunColor, _MoonColor;
				float4 _DayTopColor, _DayBottomColor, _NightBottomColor, _NightTopColor;
				float4 _HorizonColorDay, _HorizonColorNight, _SunSet;
				float _StarsCutoff, _StarsSpeed, _HorizonIntensity;
				float _BaseNoiseScale, _DistortScale, _SecNoiseScale, _Distortion;
				float _Speed, _CloudCutoff, _Fuzziness, _FuzzinessUnder, _Brightness;
				float4 _CloudColorDayEdge, _CloudColorDayMain, _CloudColorDayUnder;
				float4 _CloudColorNightEdge, _CloudColorNightMain, _CloudColorNightUnder, _StarsSkyColor;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{

					float horizon = abs((i.uv.y * _HorizonIntensity) - _OffsetHorizon);

				// uv for the sky
				float2 skyUV = i.worldPos.xz / i.worldPos.y;

				// moving clouds
				float baseNoise = tex2D(_BaseNoise, (skyUV - _Time.x) * _BaseNoiseScale).x;

				float noise1 = tex2D(_Distort, ((skyUV + baseNoise) - (_Time.x * _Speed)) * _DistortScale);

				float noise2 = tex2D(_SecNoise, ((skyUV + (noise1 * _Distortion)) - (_Time.x * (_Speed * 0.5))) * _SecNoiseScale);

				float finalNoise = saturate(noise1 * noise2) * 3 * saturate(i.worldPos.y);

#if FUZZY
				float clouds = saturate(smoothstep(_CloudCutoff * baseNoise, _CloudCutoff * baseNoise + _Fuzziness, finalNoise));
				float cloudsunder = saturate(smoothstep(_CloudCutoff* baseNoise, _CloudCutoff * baseNoise + _FuzzinessUnder + _Fuzziness, noise2) * clouds);

#else
				float clouds = saturate(smoothstep(_CloudCutoff, _CloudCutoff + _Fuzziness, finalNoise));
				float cloudsunder = saturate(smoothstep(_CloudCutoff, _CloudCutoff + _Fuzziness + _FuzzinessUnder , noise2) * clouds);

#endif
				float3 cloudsColored = lerp(_CloudColorDayEdge, lerp(_CloudColorDayUnder, _CloudColorDayMain, cloudsunder), clouds) * clouds;
				float3 cloudsColoredNight = lerp(_CloudColorNightEdge, lerp(_CloudColorNightUnder,_CloudColorNightMain , cloudsunder), clouds) * clouds;
				cloudsColoredNight *= horizon;


				cloudsColored = lerp(cloudsColoredNight, cloudsColored, saturate(_WorldSpaceLightPos0.y)); // lerp the night and day clouds over the light direction
				cloudsColored += (_Brightness * cloudsColored * horizon); // add some extra brightness


				float cloudsNegative = (1 - clouds) * horizon;
				// sun
				float sun = distance(i.uv.xyz, _WorldSpaceLightPos0);
				float sunDisc = 1 - (sun / _SunRadius);
				sunDisc = saturate(sunDisc * 50);

				// (crescent) moon
				float moon = distance(i.uv.xyz, -_WorldSpaceLightPos0);
				float crescentMoon = distance(float3(i.uv.x + _MoonOffset, i.uv.yz), -_WorldSpaceLightPos0);
				float crescentMoonDisc = 1 - (crescentMoon / _MoonRadius);
				crescentMoonDisc = saturate(crescentMoonDisc * 50);
				float moonDisc = 1 - (moon / _MoonRadius);
				moonDisc = saturate(moonDisc * 50);
				moonDisc = saturate(moonDisc - crescentMoonDisc);

				float3 sunAndMoon = (sunDisc * _SunColor) + (moonDisc * _MoonColor);
				sunAndMoon *= cloudsNegative;

				//stars
				float3 stars = tex2D(_Stars, skyUV + (_StarsSpeed * _Time.x));
				stars *= saturate(-_WorldSpaceLightPos0.y);
				stars = step(_StarsCutoff, stars);
				stars += (baseNoise * _StarsSkyColor);
				stars *= cloudsNegative;

				// gradient day sky
				float3 gradientDay = lerp(_DayBottomColor, _DayTopColor, saturate(horizon));

				// gradient night sky
				float3 gradientNight = lerp(_NightBottomColor, _NightTopColor, saturate(horizon));

				float3 skyGradients = lerp(gradientNight, gradientDay, saturate(_WorldSpaceLightPos0.y)) * cloudsNegative;

				// horizon glow / sunset/rise
				float sunset = saturate((1 - horizon) * saturate(_WorldSpaceLightPos0.y * 5));

				float3 sunsetColoured = sunset * _SunSet;

				float3 horizonGlow = saturate((1 - horizon * 5) * saturate(_WorldSpaceLightPos0.y * 10)) * _HorizonColorDay;// 
				float3 horizonGlowNight = saturate((1 - horizon * 5) * saturate(-_WorldSpaceLightPos0.y * 10)) * _HorizonColorNight;//
				horizonGlow += horizonGlowNight;

			    float3 combined = skyGradients + sunAndMoon + sunsetColoured + stars + cloudsColored + horizonGlow;
			    UNITY_APPLY_FOG(i.fogCoord, combined);
			    return float4(combined,1);

		   }
		   ENDCG
	   }
		}
}
