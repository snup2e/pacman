module player_pacman (
    input wire clk,           // 시스템 클럭
    input wire rst,           // 전체 리셋 (비동기)
    input wire soft_reset,    // 충돌 시 소프트 리셋
    input wire btn_left,      // 왼쪽 버튼
    input wire btn_right,     // 오른쪽 버튼
    input wire btn_up,        // 위쪽 버튼
    input wire btn_down,      // 아래쪽 버튼
    input wire frame_tick,    // 프레임 기준 1회 이동 제어
    output reg [9:0] pac_x,   // 팩맨의 x 좌표
    output reg [9:0] pac_y    // 팩맨의 y 좌표
);

parameter SIZE = 16;                 // 팩맨의 크기 (픽셀)
parameter INIT_X = 320;              // 초기 X 위치 (화면 중앙)
parameter INIT_Y = 400;              // 초기 Y 위치 (화면 아래쪽)
parameter SPEED = 2;                 // 이동 속도 (2픽셀씩)

parameter LEFT_BOUND = 0;
parameter RIGHT_BOUND = 640 - SIZE;  // 화면 우측 경계 제한
parameter TOP_BOUND = 0;
parameter BOTTOM_BOUND = 480 - SIZE; // 화면 하단 경계 제한

always @(posedge clk or negedge rst) begin
    if (!rst || soft_reset) begin    // 리셋 또는 소프트 리셋 시 초기 위치로 복귀
        pac_x <= INIT_X;
        pac_y <= INIT_Y;
    end else if (frame_tick) begin   // 매 프레임마다 1회만 이동 허용
        // X 방향 이동 제어
        if (btn_left && pac_x > LEFT_BOUND)
            pac_x <= pac_x - SPEED;
        else if (btn_right && pac_x < RIGHT_BOUND)
            pac_x <= pac_x + SPEED;

        // Y 방향 이동 제어
        if (btn_up && pac_y > TOP_BOUND)
            pac_y <= pac_y - SPEED;
        else if (btn_down && pac_y < BOTTOM_BOUND)
            pac_y <= pac_y + SPEED;
    end
end

endmodule
