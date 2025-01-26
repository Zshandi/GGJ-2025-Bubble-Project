shader_type canvas_item;

bool is_in_corner(float corner_radius, vec2 local_pos, vec2 uv, out vec2 corner_offset) {
	float max_x = local_pos.x * (1.0 / uv.x);
	float max_y = local_pos.y * (1.0 / uv.y);
	float min_x = 0.0, min_y = 0.0;
	
	// Each vec4 holds both the corners position, as 
	vec4 corners[] = {
		vec4(min_x, min_y, 1, 1),
		vec4(min_x, max_y, 1, -1),
		vec4(max_x, min_y, -1, 1),
		vec4(max_x, max_y, -1, -1)
	};
	
	vec4 closest_corner = corners[0];
	float closest_dist = distance(local_pos, corners[0].xy);
	
	for (int i = 1; i < corners.length();  i++) {
		float dist = distance(local_pos, corners[i].xy);
		if (dist < closest_dist) {
			closest_corner = corners[i];
			closest_dist = dist;
		}
	}
	
	vec2 closest_corner_pos = closest_corner.xy + (closest_corner.zw * corner_radius);
	vec2 closest_corner_direction = -closest_corner.zw;
	
	corner_offset = (local_pos - closest_corner_pos) * closest_corner_direction;
	return corner_offset.x >= 0.0 && corner_offset.y >= 0.0;
}

void vertex() {
	vec2 corner_offset = vec2(0);
	if (is_in_corner(50, VERTEX, UV, corner_offset)) {
		bool is_within_circle = (corner_offset.x*corner_offset.x + corner_offset.y*corner_offset.y) <= 50.0*50.0;
		
		if (!is_within_circle) {
			COLOR.a = 0.0;
		}
	}
	COLOR = vec4(corner_offset.x / (VERTEX.x * (1.0 / UV.x)), corner_offset.y / (VERTEX.y * (1.0 / UV.y)), 0, 1);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
