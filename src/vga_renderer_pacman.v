module vga_renderer_pacman (
    input wire [10:0] h_cnt,       // 현재 VGA 수평 스캔 좌표
    input wire [9:0]  v_cnt,       // 현재 VGA 수직 스캔 좌표
    input wire [9:0]  player_x,    // 팩맨의 왼쪽 위 X좌표
    input wire [9:0]  player_y,    // 팩맨의 왼쪽 위 Y좌표
    input wire [9:0]  ghost_x,     // 유령 1의 좌표
    input wire [9:0]  ghost_y,
    input wire [9:0]  ghost2_x,    // 유령 2의 좌표
    input wire [9:0]  ghost2_y,
    input wire [9:0]  ghost3_x,    // 유령 3의 좌표
    input wire [9:0]  ghost3_y,
    input wire        dot_pixel,   // 도트 위치일 경우 HIGH
    output reg [3:0]  vga_r,       // VGA RED 채널 (4비트)
    output reg [3:0]  vga_g,       // VGA GREEN 채널 (4비트)
    output reg [3:0]  vga_b        // VGA BLUE 채널 (4비트)
);

parameter SIZE = 16;
parameter RADIUS = SIZE / 2;

// === 팩맨 중심 좌표 계산 ===
wire [10:0] player_center_x = player_x + RADIUS;
wire [9:0]  player_center_y = player_y + RADIUS;

// === 팩맨 원형 범위 계산 ===
wire player_visible = 
    ((h_cnt - player_center_x) * (h_cnt - player_center_x) + 
     (v_cnt - player_center_y) * (v_cnt - player_center_y)) <= (RADIUS * RADIUS);

// === 유령 1 사각형 범위 내 여부 확인 ===
wire ghost_visible = 
    (h_cnt >= ghost_x) && (h_cnt < ghost_x + SIZE) &&
    (v_cnt >= ghost_y) && (v_cnt < ghost_y + SIZE);

// === 유령 2 범위 확인 ===
wire ghost_visible2 = 
    (h_cnt >= ghost2_x) && (h_cnt < ghost2_x + SIZE) &&
    (v_cnt >= ghost2_y) && (v_cnt < ghost2_y + SIZE);

// === 유령 3 범위 확인 ===
wire ghost_visible3 = 
    (h_cnt >= ghost3_x) && (h_cnt < ghost3_x + SIZE) &&
    (v_cnt >= ghost3_y) && (v_cnt < ghost3_y + SIZE);

// === 도트 픽셀 여부 ===
wire dot_visible = dot_pixel;

// === 출력 색상 결정 ===
always @(*) begin
    if (player_visible) begin
        vga_r = 4'hF; vga_g = 4'hF; vga_b = 4'h0;  // 노란색 (팩맨)
    end else if (ghost_visible) begin
        vga_r = 4'hF; vga_g = 4'h0; vga_b = 4'h0;  // 빨간색 (고스트1)
    end else if (ghost_visible2) begin
        vga_r = 4'h5; vga_g = 4'hF; vga_b = 4'hA;  // 초록색 (고스트2)
    end else if (ghost_visible3) begin
        vga_r = 4'hF; vga_g = 4'h6; vga_b = 4'h0;  // 주황색 (고스트3)
    end else if (dot_visible) begin
        vga_r = 4'hF; vga_g = 4'hF; vga_b = 4'hF;  // 흰색 (도트)
    end else begin
        vga_r = 4'h0; vga_g = 4'h0; vga_b = 4'h0;  // 검정색 배경
    end
end

endmodule