shader_type canvas_item;

uniform sampler2D cutout;
uniform float tlx = 0.75;
uniform float tly = 0.25;
uniform float brx = 0.90;
uniform float bry = 0.50;

void fragment() {
	vec4 color = texture(cutout, UV);
	//float alpha = min(COLOR.a, color.a);
	float alpha = COLOR.a;
	if ((UV.x >= tlx) && (UV.x <= brx) && (UV.y >= tly)  && (UV.y <= bry)) {
		alpha = 0.0;
	}
	COLOR.a = alpha;
}
