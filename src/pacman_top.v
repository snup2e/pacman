module pacman_top (
    input wire clk,                  // 메인 입력 클럭 (100MHz)
    input wire rst,                  // 비동기 리셋
    input wire btn_left,            // 왼쪽 버튼 입력
    input wire btn_right,           // 오른쪽 버튼 입력
    input wire btn_up,              // 위 버튼 입력
    input wire btn_down,            // 아래 버튼 입력
    output wire hsync,              // VGA 수평 동기화 신호
    output wire vsync,              // VGA 수직 동기화 신호
    output wire [3:0] vga_r,        // VGA 빨강색 출력 (4비트)
    output wire [3:0] vga_g,        // VGA 초록색 출력 (4비트)
    output wire [3:0] vga_b         // VGA 파랑색 출력 (4비트)
);

    // === 25MHz 클럭 생성 ===
    wire clk_25;
    clk_wiz_0 clkgen (              // Clock Wizard IP로 25MHz 분주
        .clk_in1(clk),
        .clk_out1(clk_25)
    );

    // === VGA 타이밍 모듈: 현재 픽셀 위치 및 hsync/vsync 생성 ===
    wire [10:0] h_cnt;
    wire [9:0] v_cnt;
    vga_timing vga(
        .clk(clk_25),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .hsync(hsync),
        .vsync(vsync)
    );

    // === 프레임 틱 생성 (화면 좌상단 도달 시 1클럭 HIGH)
    wire frame_tick = (h_cnt == 0 && v_cnt == 0);

    // === 팩맨 좌표
    wire [9:0] pac_x, pac_y;

    // === 유령들 좌표
    wire [9:0] ghost_x, ghost_y, ghost2_x, ghost2_y, ghost3_x, ghost3_y;

    // === 유령과 충돌 감지
    wire collision, collision2, collision3;
    collision_pacman check1 (
        .clk(clk_25), .rst(rst),
        .player_x(pac_x), .player_y(pac_y),
        .ghost_x(ghost_x), .ghost_y(ghost_y),
        .hit_detected(collision)
    );
    collision_pacman check2 (
        .clk(clk_25), .rst(rst),
        .player_x(pac_x), .player_y(pac_y),
        .ghost_x(ghost2_x), .ghost_y(ghost2_y),
        .hit_detected(collision2)
    );
    collision_pacman check3 (
        .clk(clk_25), .rst(rst),
        .player_x(pac_x), .player_y(pac_y),
        .ghost_x(ghost3_x), .ghost_y(ghost3_y),
        .hit_detected(collision3)
    );

    // === soft_reset: 충돌 발생 시 약 10프레임 동안 리셋 신호 생성
    reg soft_reset = 0;
    reg [7:0] soft_reset_cnt = 0;

    always @(posedge clk_25 or negedge rst) begin
        if (!rst) begin
            soft_reset <= 0;
            soft_reset_cnt <= 0;
        end else if (collision || collision2 || collision3) begin
            soft_reset <= 1;
            soft_reset_cnt <= 8'd10;
        end else if (soft_reset_cnt > 0) begin
            soft_reset_cnt <= soft_reset_cnt - 1;
            if (soft_reset_cnt == 1)
                soft_reset <= 0;
        end else begin
            soft_reset <= 0;
        end
    end

    // === 팩맨 컨트롤 모듈
    player_pacman player (
        .clk(clk_25),
        .rst(rst),
        .soft_reset(soft_reset),
        .frame_tick(frame_tick),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .pac_x(pac_x),
        .pac_y(pac_y)
    );

    // === 유령 3마리 모듈 (위치와 랜덤 seed 다르게 설정)
    ghost_logic #(.INIT_X(300), .INIT_Y(100), .INIT_LFSR(8'hA5)) ghost1 (
        .clk(clk_25), .rst(rst),
        .soft_reset(soft_reset),
        .ghost_x(ghost_x), .ghost_y(ghost_y)
    );
    ghost_logic #(.INIT_X(100), .INIT_Y(300), .INIT_LFSR(8'hB3)) ghost2 (
        .clk(clk_25), .rst(rst),
        .soft_reset(soft_reset),
        .ghost_x(ghost2_x), .ghost_y(ghost2_y)
    );
    ghost_logic #(.INIT_X(500), .INIT_Y(200), .INIT_LFSR(8'h79)) ghost3 (
        .clk(clk_25), .rst(rst),
        .soft_reset(soft_reset),
        .ghost_x(ghost3_x), .ghost_y(ghost3_y)
    );

    // === 도트 (먹이) 모듈
    wire dot_pixel;
    dot_logic dots (
        .clk(clk_25),
        .rst(rst),
        .soft_reset(soft_reset),
        .frame_tick(frame_tick),
        .player_x(pac_x),
        .player_y(pac_y),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .dot_pixel(dot_pixel)
    );

    // === VGA 출력 렌더링 모듈
    vga_renderer_pacman renderer (
        .h_cnt(h_cnt), .v_cnt(v_cnt),
        .player_x(pac_x), .player_y(pac_y),
        .ghost_x(ghost_x), .ghost_y(ghost_y),
        .ghost2_x(ghost2_x), .ghost2_y(ghost2_y),
        .ghost3_x(ghost3_x), .ghost3_y(ghost3_y),
        .dot_pixel(dot_pixel),
        .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b)
    );

endmodule