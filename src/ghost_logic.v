module ghost_logic #(
    parameter X_MIN = 0,               // 이동 가능한 최소 X값
    parameter X_MAX = 640 - 16,        // 최대 X값 (화면 오른쪽 경계)
    parameter Y_MIN = 0,               // 최소 Y값
    parameter Y_MAX = 480 - 16,        // 최대 Y값 (화면 아래 경계)
    parameter SPEED = 3,               // 유령 이동 속도 (픽셀 단위)
    parameter STEP_DELAY = 400_000,    // 이동 주기 (클럭 단위)
    parameter DIR_CHANGE_DELAY = 60,   // 방향 전환 주기 (step 단위)
    parameter INIT_X = 300,            // 초기 X 위치
    parameter INIT_Y = 100,            // 초기 Y 위치
    parameter INIT_LFSR = 8'hA5        // 초기 난수 시드 (LFSR)
) (
    input wire clk,                    // 시스템 클럭
    input wire rst,                    // 리셋
    input wire soft_reset,             // 충돌 시 초기화 신호
    output reg [9:0] ghost_x,          // 유령 X 좌표 출력
    output reg [9:0] ghost_y           // 유령 Y 좌표 출력
);

    reg [1:0] dir = 2'b01;             // 현재 이동 방향 (00=좌, 01=우, 10=위, 11=아래)
    reg [19:0] step_cnt = 0;           // 이동 간 간격 타이머
    reg [7:0] lfsr = INIT_LFSR;        // 난수 생성기 (LFSR)
    reg [7:0] dir_cnt = 0;             // 방향 유지 타이머

    // === 방향 제어: LFSR을 통한 난수 기반 방향 전환 ===
    always @(posedge clk or negedge rst) begin
        if (!rst || soft_reset) begin
            dir <= 2'b01;             // 초기 방향 오른쪽
            dir_cnt <= 0;             // 방향 유지 카운터 초기화
            lfsr <= INIT_LFSR;        // LFSR 시드 재설정
            step_cnt <= 0;            // 스텝 타이머 초기화
        end else begin
            // LFSR 시프트: 새로운 난수 생성
            lfsr <= {lfsr[6:0], lfsr[7]^lfsr[5]^lfsr[4]^lfsr[3]};

            // 일정 시간 지나면 한 스텝 이동
            if (step_cnt >= STEP_DELAY) begin
                step_cnt <= 0;
                dir_cnt <= dir_cnt + 1;

                // 방향 전환 조건 (60스텝마다)
                if (dir_cnt >= DIR_CHANGE_DELAY) begin
                    dir_cnt <= 0;
                    dir <= lfsr[1:0]; // 새로운 방향 설정 (난수 기반)
                end
            end else begin
                step_cnt <= step_cnt + 1;
            end
        end
    end

    // === 위치 업데이트: 방향에 따라 유령 이동 ===
    always @(posedge clk or negedge rst) begin
        if (!rst || soft_reset) begin
            ghost_x <= INIT_X;         // 초기 위치 설정
            ghost_y <= INIT_Y;
        end else if (step_cnt == 0) begin
            case (dir)
                2'b00: if (ghost_x > X_MIN + SPEED) ghost_x <= ghost_x - SPEED; // 좌
                2'b01: if (ghost_x < X_MAX - SPEED) ghost_x <= ghost_x + SPEED; // 우
                2'b10: if (ghost_y > Y_MIN + SPEED) ghost_y <= ghost_y - SPEED; // 상
                2'b11: if (ghost_y < Y_MAX - SPEED) ghost_y <= ghost_y + SPEED; // 하
            endcase
        end
    end

endmodule