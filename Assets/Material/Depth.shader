Shader "ShapeOutline/Depth"
{
   Properties {        
        _Noise("Noise",2D)="white"{}        
        _BulgeScale ("Bulge Scale", Float ) = 0.2
        _BulgeShape ("Bulge Shape", Float ) = 5
        _tendency("tendency",Float)=10
    }
    SubShader {
        Tags {
            "RenderType"="Opaque" 
            
        }
        pass{
        	
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
           
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
			
            uniform float _BulgeShape;
			
			uniform float _tendency;
			uniform sampler2D _CameraDepthTexture;
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
				float4 screenPos:TEXCOORD2;
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
					p.screenPos=ComputeScreenPos(p.pos);
            		OutputStream.Append(p);
            		p=input[1];
            		temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
					p.normal=mul(p.normal,unity_WorldToObject);
					p.screenPos=ComputeScreenPos(p.pos);
            		OutputStream.Append(p);
            		p=input[2];
            		temp=dir*tendency+p.posWorld;
            		p.posWorld=mul(unity_ObjectToWorld,temp);
            		p.pos=UnityObjectToClipPos(float4(temp,1));
					p.normal=mul(p.normal,unity_WorldToObject);
					p.screenPos=ComputeScreenPos(p.pos);
            		OutputStream.Append(p);
            		OutputStream.RestartStrip();
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
				
				

            	return fixed4(0.2,0.2,0.2,0);
            }
            ENDCG
        }
    }
}