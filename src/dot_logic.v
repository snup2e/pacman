module dot_logic (
    input wire clk,           // 시스템 클럭
    input wire rst,           // 비동기 전체 리셋
    input wire soft_reset,    // 충돌 후 재초기화를 위한 소프트 리셋
    input wire frame_tick,    // 프레임 단위 동기화 신호
    input wire [9:0] player_x, // 플레이어 x 좌표
    input wire [9:0] player_y, // 플레이어 y 좌표
    input wire [10:0] h_cnt,   // 현재 VGA 수평 스캔 위치
    input wire [9:0]  v_cnt,   // 현재 VGA 수직 스캔 위치
    output reg dot_pixel      // 해당 픽셀 위치에 도트가 존재하는지 여부
);

parameter DOT_RADIUS = 6;
parameter SIZE = 16;
parameter NUM_DOTS = 8;

reg [9:0] dot_x [0:NUM_DOTS-1];      // 도트 x 좌표 배열
reg [9:0] dot_y [0:NUM_DOTS-1];      // 도트 y 좌표 배열
reg       dot_alive [0:NUM_DOTS-1];  // 도트 생존 상태 배열

reg [11:0] dx, dy;           // 거리 차이 (X, Y)
reg [23:0] dist_sq;          // 거리 제곱값
integer i;

// === 난수 시드를 위한 카운터 ===
reg [15:0] seed_counter = 16'd0;
always @(posedge clk) begin
    seed_counter <= seed_counter + 1;
end

// === LFSR 기반 의사 난수 생성기 ===
reg [15:0] rand_seed;
wire feedback = rand_seed[15] ^ rand_seed[13] ^ rand_seed[12] ^ rand_seed[10];

// === 리셋 시 랜덤 시드 초기화 ===
always @(posedge clk or negedge rst) begin
    if (!rst)
        rand_seed <= 16'hBEEF ^ seed_counter;  // 리셋 시 초기화
    else if (soft_reset)
        rand_seed <= 16'hC0DE ^ seed_counter;  // 소프트 리셋 시 초기화
    else if (frame_tick)
        rand_seed <= {rand_seed[14:0], feedback}; // 매 프레임마다 LFSR shift
end

// === 도트 초기화용 플래그 ===
reg dot_initialized;
reg rand_seed_shifted;

always @(posedge clk or negedge rst) begin
    if (!rst || soft_reset) begin
        dot_initialized <= 1'b0;
        rand_seed_shifted <= 1'b0;
    end else if (frame_tick && !rand_seed_shifted) begin
        rand_seed_shifted <= 1'b1;
    end else if (!dot_initialized && rand_seed_shifted && frame_tick) begin
        dot_initialized <= 1'b1;
    end
end

// === 팩맨 중심 위치 및 거리 기준 계산 ===
wire [11:0] px_center = player_x + SIZE / 2;
wire [11:0] py_center = player_y + SIZE / 2;
wire [15:0] COLLISION_RADIUS_SQ = (DOT_RADIUS + SIZE/2 + 2) * (DOT_RADIUS + SIZE/2 + 2);
wire [15:0] DOT_RADIUS_SQ = DOT_RADIUS * DOT_RADIUS;

// === 도트 초기화 및 충돌 판정 ===
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        for (i = 0; i < NUM_DOTS; i = i + 1)
            dot_alive[i] <= 1'b0;
    end else if (!dot_initialized && rand_seed_shifted && frame_tick) begin
        for (i = 0; i < NUM_DOTS; i = i + 1) begin
            // 위치를 난수 기반으로 배치
            dot_x[i] <= (rand_seed + i * 53) % 600 + 20;
            dot_y[i] <= (rand_seed + i * 91) % 400 + 20;
            dot_alive[i] <= 1'b1;
        end
    end else if (frame_tick) begin
        for (i = 0; i < NUM_DOTS; i = i + 1) begin
            if (dot_alive[i]) begin
                dx = (px_center > dot_x[i]) ? (px_center - dot_x[i]) : (dot_x[i] - px_center);
                dy = (py_center > dot_y[i]) ? (py_center - dot_y[i]) : (dot_y[i] - py_center);
                dist_sq = dx * dx + dy * dy;
                if (dist_sq <= COLLISION_RADIUS_SQ)
                    dot_alive[i] <= 1'b0; // 충돌 시 해당 도트 제거
            end
        end
    end
end

// === 도트 픽셀 렌더링 로직 ===
always @(*) begin
    dot_pixel = 1'b0;
    for (i = 0; i < NUM_DOTS; i = i + 1) begin
        if (dot_alive[i]) begin
            dx = (h_cnt > dot_x[i]) ? (h_cnt - dot_x[i]) : (dot_x[i] - h_cnt);
            dy = (v_cnt > dot_y[i]) ? (v_cnt - dot_y[i]) : (dot_y[i] - v_cnt);
            dist_sq = dx * dx + dy * dy;
            if (dist_sq <= DOT_RADIUS_SQ)
                dot_pixel = 1'b1;  // 현재 픽셀이 도트 내부에 있다면 1 출력
        end
    end
end

endmodule