// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32843,y:32699,varname:node_3138,prsc:2|emission-2115-RGB,alpha-2115-A;n:type:ShaderForge.SFN_Tex2d,id:2115,x:32422,y:32599,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7dc0c73abe2a171489860ce1a4fd7823,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:713,x:32423,y:32860,ptovrint:False,ptlb:Noise,ptin:_Noise,varname:_Noise,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;proporder:2115;pass:END;sub:END;*/

Shader "Shader Forge/ball" {
    Properties {
        _Diffuse ("MainTex", 2D) = "black" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        _Noise("Noise",2D)="white"{}
        _GlowColor ("Glow Color", Color) = (1,0.2391481,0.1102941,1)
        _BulgeScale ("Bulge Scale", Float ) = 0.2
        _BulgeShape ("Bulge Shape", Float ) = 5
        _GlowIntensity ("Glow Intensity", Float ) = 1.2
        _tendency("tendency",Float)=10
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        pass{
        	Cull Front
        	ZWrite Off
        	Blend SrcAlpha OneMinusSrcAlpha
        	CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma geometry geom
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            
            uniform float _BulgeScale;
            uniform sampler2D _Diffuse; uniform float4 _Diffuse_ST;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            uniform float4 _GlowColor;
            uniform float _BulgeShape;
            uniform float _GlowIntensity;
			uniform float _tendency;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float3 normal:NORMAL;
                
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 posWorld : TEXCOORD1;
                float3 normal : NORMAL;
				
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                float temp = pow((abs((frac((o.uv0+_Time.g*float2(0.25,0)).r)-0.5))*2.0),_BulgeShape); // Panning gradient
                v.vertex.xyz += (temp*_BulgeScale*v.normal);
                o.posWorld=v.vertex.xyz;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.normal=v.normal;
				
                return o;
            }
            [maxvertexcount(3)]
            void geom(inout TriangleStream<VertexOutput> OutputStream,triangle VertexOutput input[3]){
            		 
            		
            		VertexOutput p=input[0];
            		float r=tex2Dlod(_Noise,float4(p.uv0,0,1)).r;
            		float tendency=sin(_Time*25)*_tendency*r;
            		if(tendency<0)tendency=-tendency;
            		float tempd = pow((abs((frac((p.uv0+_Time.g*float2(0.25,0)).r)-0.5))*2.0),_BulgeShape); // Panning gradient
					if((tempd*_BulgeScale)>0.1){
						tendency=0;
					}
                	tendency = tendency;//-(tempd*_BulgeScale*p.normal)*10;
            		float3 dir1=input[1].posWorld-input[0].posWorld;
            		float3 dir2=input[2].posWorld-input[0].posWorld;
            		float3 dir=cross(dir1,dir2);
            		float3 temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
            		p.normal=mul(p.normal,unity_WorldToObject);
					
            		OutputStream.Append(p);
            		p=input[1];
            		temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
					p.normal=mul(p.normal,unity_WorldToObject);
					
            		OutputStream.Append(p);
            		p=input[2];
            		temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
					p.normal=mul(p.normal,unity_WorldToObject);
					
            		OutputStream.Append(p);
            		OutputStream.RestartStrip();
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
				
            	float tempd = pow((abs((frac((i.uv0+_Time.g*float2(0.25,0)).r)-0.5))*2.0),_BulgeShape); 
                float tendency = (tempd*_BulgeScale);
                
                float4 _MainTex_var = tex2D(_Diffuse,TRANSFORM_TEX(i.uv0, _Diffuse));
                float3 emissive = _MainTex_var.rgb;
                float3 finalColor = emissive*2+tendency*_GlowColor*_GlowIntensity;
                return fixed4(finalColor,0.5);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma geometry geom
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            
            uniform float _BulgeScale;
            uniform sampler2D _Diffuse; uniform float4 _Diffuse_ST;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            uniform float4 _GlowColor;
            uniform float _BulgeShape;
            uniform float _GlowIntensity;
			uniform float _tendency;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float3 normal:NORMAL;
                
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 posWorld : TEXCOORD1;
                float3 normal : NORMAL;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                float temp = pow((abs((frac((o.uv0+_Time.g*float2(0.25,0)).r)-0.5))*2.0),_BulgeShape); // Panning gradient
                v.vertex.xyz += (temp*_BulgeScale*v.normal);
                o.posWorld=v.vertex.xyz;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.normal=v.normal;
                return o;
            }
            [maxvertexcount(3)]
            void geom(inout TriangleStream<VertexOutput> OutputStream,triangle VertexOutput input[3]){
            		 
            		
            		VertexOutput p=input[0];
            		float r=tex2Dlod(_Noise,float4(p.uv0,0,1)).r;
            		float tendency=sin(_Time*25)*_tendency*r;
            		//if(tendency<0)tendency=-tendency;
            		float tempd = pow((abs((frac((p.uv0+_Time.g*float2(0.25,0)).r)-0.5))*2.0),_BulgeShape); // Panning gradient
					if((tempd*_BulgeScale)>0.1){
						tendency=0;
					}
                	tendency = tendency;//-(tempd*_BulgeScale*p.normal)*10;
            		float3 dir1=input[1].posWorld-input[0].posWorld;
            		float3 dir2=input[2].posWorld-input[0].posWorld;
            		float3 dir=cross(dir1,dir2);
            		float3 temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
            		p.normal=mul(p.normal,unity_WorldToObject);
            		OutputStream.Append(p);
            		p=input[1];
            		temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
					p.normal=mul(p.normal,unity_WorldToObject);
            		OutputStream.Append(p);
            		p=input[2];
            		temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
					p.normal=mul(p.normal,unity_WorldToObject);
            		OutputStream.Append(p);
            		OutputStream.RestartStrip();
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
            	float tempd = pow((abs((frac((i.uv0+_Time.g*float2(0.25,0)).r)-0.5))*2.0),_BulgeShape); 
                float tendency = (tempd*_BulgeScale);
                
                float4 _MainTex_var = tex2D(_Diffuse,TRANSFORM_TEX(i.uv0, _Diffuse));
                float3 emissive = _MainTex_var.rgb;
                float3 finalColor = emissive*2+tendency*_GlowColor*_GlowIntensity;
               // return fixed4(1,1,0,1);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
