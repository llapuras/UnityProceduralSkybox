Shader "Lapu/LapuSky_step1"
{
	Properties
	{
		//debug
		[Header(Debug)]
		_Test("test",  Range(0, 1000)) = 0.15
		[MaterialToggle] addSunandMoon("Add Sun And Moon", Float) = 0
		[MaterialToggle] _addGradient("Add Gradient", Float) = 0
		[Toggle(ADDCLOUD)] _addCloud("Add Cloud", Float) = 0
		[MaterialToggle] _addStar("Add Star", Float) = 0
		[MaterialToggle] _addHorizon("Add Horizon", Float) = 0
		[Toggle(MIRROR)] _MirrorMode("Mirror Mode", Float) = 0

		[Header(Sun Settings)]
		_SunColor("Sun Color", Color) = (1,1,1,1)
		_SunRadius("Sun Radius",  Range(0, 2)) = 0.1

		[Header(Moon Settings)]
		_MoonColor("Moon Color", Color) = (1,1,1,1)
		_MoonRadius("Moon Radius",  Range(0, 2)) = 0.15
		_MoonOffset("Moon Crescent",  Range(-1, 1)) = -0.1

	    [Header(Cloud Settings)]
		_Cloud("Cloud Texture", 2D) = "black" {}
		_CloudCutoff("Cloud Cutoff",  Range(0, 3)) = 0.08
		_CloudSpeed("Cloud Move Speed",  Range(-10, 10)) = 0.3
		_CloudScale("Cloud Scale",  Range(0, 10)) = 0.3

		[Space()]
		_CloudNoise("Cloud Noise", 2D) = "black" {}
		_CloudNoiseScale("Cloud Noise Scale",  Range(0, 1)) = 0.2
		_CloudNoiseSpeed("Cloud Noise Speed",  Range(-1, 1)) = 0.1

		[Space()]
		_DistortTex("Distort Tex", 2D) = "black" {}
		_DistortScale("Distort Noise Scale",  Range(0, 1)) = 0.06
		_DistortionSpeed("Distortion Speed",  Range(-1, 1)) = 0.1

		[Space()]
		_Fuzziness("Cloud Fuzziness",  Range(-5, 5)) = 0.04
		_FuzzinessSec("Cloud Fuzziness Sec",  Range(-5, 5)) = 0.04

		[Header(Cloud Color Settings)]
		_CloudColorDayMain("Cloud Day Color Main", Color) = (0.0,0.2,0.1,1)
		_CloudColorDaySec("Clouds Day Color Sec", Color) = (0.6,0.7,0.6,1)

		[Space()]
		_CloudColorNightMain("Clouds Night Color Main", Color) = (1,1,1,1)
		_CloudColorNightSec("Cloud Night Color Sec", Color) = (0.0,0.2,0.1,1)

		[Space()]
		_CloudBrightnessDay("Cloud Brightness Day",  Range(0, 2)) = 1
		_CloudBrightnessNight("Cloud Brightness Night",  Range(0, 2)) = 1
		
		[Header(Star Settings)]
		_Stars("Stars Texture", 2D) = "black" {}
		_StarsCutoff("Stars Cutoff",  Range(0, 1)) = 0.08
		_StarsSpeed("Stars Move Speed",  Range(-10, 10)) = 0.3
		_StarScale("Star Scale",  Range(-10, 10)) = 0.3
	    _StarsSkyColor("Stars Sky Color", Color) = (0.0,0.2,0.1,1)
			
		[Header(Day Sky Settings)]
		_DayTopColor("Day Top Color", Color) = (0.4,1,1,1)
		_DayBottomColor("Day Bottom Color", Color) = (0,0.8,1,1)

		[Header(Night Sky Settings)]
		_NightTopColor("Night Top Color", Color) = (0.4,1,1,1)
		_NightBottomColor("Night Bottom Color", Color) = (0,0.8,1,1)

		[Header(Horizon Settings)]
		_HorizonHeight("Horizon Height", Range(-10,10)) = 10
		_HorizonIntensity("Horizon Intensity",  Range(0, 100)) = 3.3
	    _MidLightIntensity("Mid Light Intensity",  Range(0, 100)) = 3.3
		_HorizonColorDay("Day Horizon Color", Color) = (0,0.8,1,1)
		_HorizonColorNight("Night Horizon Color", Color) = (0,0.8,1,1)
		_HorizonLightDay("Day Horizon Light", Color) = (0,0.8,1,1)
		_HorizonLightNight("Night Horizon Light", Color) = (0,0.8,1,1)
		_HorizonBrightness("Horizon Brightness", Range(-10,10)) = 10

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
				#include "UnityCG.cginc"

				#pragma shader_feature MIRROR
				#pragma shader_feature ADDCLOUD

				struct appdata
				{
					float4 vertex : POSITION;
					float3 uv : TEXCOORD0;
				};

				struct v2f
				{
					float3 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 worldPos : TEXCOORD1;
				};

				void scaleTex() {
				
				}

				//debug
				float _Test, addSunandMoon, _addHorizon, _addGradient, _addCloud, _addStar, _MirrorMode;

				float _SunRadius, _MoonRadius, _MoonOffset;
				float4 _DayTopColor, _DayBottomColor, _NightBottomColor, _NightTopColor, _StarsSkyColor;
				float4 _HorizonLightNight, _HorizonLightDay, _HorizonColorDay, _HorizonColorNight, _SunSet, _SunColor, _MoonColor;
				float4 _CloudColorDayMain, _CloudColorDaySec, _CloudColorNightMain, _CloudColorNightSec;
				float _HorizonBrightness, _MidLightIntensity, _CloudBrightnessDay, _CloudBrightnessNight, _Fuzziness, _FuzzinessSec, _DistortionSpeed, _CloudNoiseSpeed, _CloudNoiseScale, _DistortScale, _StarsCutoff, _StarsSpeed, _CloudCutoff, _CloudSpeed, _HorizonHeight, _HorizonIntensity, _CloudScale, _StarScale;
				sampler2D _Stars, _CloudNoise, _Cloud, _DistortTex;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{

				// sun
				float sun = distance(i.uv.xyz, _WorldSpaceLightPos0);
				float sunDisc = 1 - (sun / _SunRadius);
				sunDisc = saturate(sunDisc * 50);
				
				// moon
				float moon = distance(i.uv.xyz, -_WorldSpaceLightPos0);
				float moonDisc = 1 - (moon / _MoonRadius);
				moonDisc = saturate(moonDisc * 50);
				float crescentMoon = distance(float3(i.uv.x + _MoonOffset, i.uv.yz), -_WorldSpaceLightPos0);
				float crescentMoonDisc = 1 - (crescentMoon / _MoonRadius);
				crescentMoonDisc = saturate(crescentMoonDisc * 50);
				moonDisc = saturate(moonDisc - crescentMoonDisc);

				float3 SunAndMoon = (sunDisc * _SunColor) + (moonDisc * _MoonColor);

				float2 skyuv = (i.worldPos.xz) / (clamp(i.worldPos.y, 0, 10000));

				//cloud
				float cloud = tex2D(_Cloud, (skyuv + (_Time.x * _CloudSpeed)) * _CloudScale);
				float distort = tex2D(_DistortTex, (skyuv + (_Time.x * _DistortionSpeed)) * _DistortScale);
				float noise = tex2D(_CloudNoise, ((skyuv + distort) - (_Time.x * _CloudSpeed)) * _CloudNoiseScale);
				float finalNoise = saturate(noise) * 3 * saturate(i.worldPos.y);
				cloud = saturate(smoothstep(_CloudCutoff * cloud, _CloudCutoff * cloud + _Fuzziness, finalNoise));
				float cloudSec = saturate(smoothstep(_CloudCutoff * cloud, _CloudCutoff * cloud + _Fuzziness + _FuzzinessSec, finalNoise));
				
				float3 cloudColoredDay = cloud *  _CloudColorDayMain * _CloudBrightnessDay;
				float3 cloudSecColoredDay = cloudSec * _CloudColorDaySec * _CloudBrightnessDay;
				cloudColoredDay += cloudSecColoredDay;

				float3 cloudColoredNight = cloud * _CloudColorNightMain * _CloudBrightnessNight;
				float3 cloudSecColoredNight = cloudSec * _CloudColorNightSec * _CloudBrightnessNight;
				cloudColoredNight += cloudSecColoredNight;

				float3 finalcloud = lerp(cloudColoredNight, cloudColoredDay, saturate(_WorldSpaceLightPos0.y));

				float3 stars = tex2D(_Stars, (skyuv + float2(_StarsSpeed, _StarsSpeed) * _Time.x) * _StarScale);
				stars = step(_StarsCutoff, stars) * saturate(-_WorldSpaceLightPos0.y);
				#if ADDCLOUD
					stars *= (1 - cloud);
				#endif

				//gradient day sky
				#if MIRROR
					float ypos = saturate(abs(i.uv.y));
				#else
					float ypos = saturate(i.uv.y);
				#endif
				float3 gradientDay = lerp(_DayBottomColor, _DayTopColor, ypos);
				float3 gradientNight = lerp(_NightBottomColor, _NightTopColor, ypos);
				float3 skyGradients = lerp(gradientNight, gradientDay,saturate(_WorldSpaceLightPos0.y));

				//horizon
				float3 horizon = abs((i.uv.y * _HorizonIntensity) - _HorizonHeight);
				float midline = saturate((1 - horizon * _MidLightIntensity));
				horizon = saturate((1 - horizon)) * ((_HorizonColorDay + midline * _HorizonLightDay) * saturate(_WorldSpaceLightPos0.y*10)
					+ (_HorizonColorNight + midline * _HorizonLightNight) * saturate(-_WorldSpaceLightPos0.y * 10)) * _HorizonBrightness;

				//combine all effects
				float3 combined = horizon * _addHorizon 
					+ stars * _addStar * _StarsSkyColor 
					+ skyGradients * _addGradient 
					+ SunAndMoon * addSunandMoon
					+ finalcloud * _addCloud;

			    return float4(combined,1);
		    }
		    ENDCG
	    }
	}
}
