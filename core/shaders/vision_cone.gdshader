shader_type canvas_item;

uniform float fov_angle : hint_range(0.0, 360.0) = 60.0;

void fragment() {
    vec2 dir = UV - vec2(0.5);   // assuming center of texture is 0.5,0.5
    float angle = atan(dir.y, dir.x);    
    float half_angle = radians(fov_angle) / 2.0;
    
    if(abs(angle) > half_angle){
        COLOR.a = 0.0; // make outside the cone transparent
    }
}
