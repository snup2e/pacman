module collision_pacman (
    input wire clk,                     // 시스템 클럭
    input wire rst,                     // 비동기 리셋
    input wire [9:0] player_x, player_y, // 팩맨 위치 입력
    input wire [9:0] ghost_x, ghost_y,   // 유령 위치 입력
    output reg hit_detected              // 충돌 여부 출력 (1이면 충돌)
);

    parameter PAC_SIZE = 16;            // 팩맨 크기
    parameter GHOST_SIZE = 16;          // 유령 크기

    always @(posedge clk or negedge rst) begin
        if (!rst)
            hit_detected <= 1'b0;       // 리셋 시 충돌 초기화
        else begin
            // 충돌 판정: 두 사각형 영역이 겹치는지 확인
            if ((player_x + PAC_SIZE > ghost_x) &&      // 오른쪽이 유령의 왼쪽보다 오른쪽에 있음
                (player_x < ghost_x + GHOST_SIZE) &&     // 왼쪽이 유령의 오른쪽보다 왼쪽에 있음
                (player_y + PAC_SIZE > ghost_y) &&       // 아래가 유령의 위보다 아래에 있음
                (player_y < ghost_y + GHOST_SIZE))       // 위가 유령의 아래보다 위에 있음
                hit_detected <= 1'b1;     // 충돌 발생
            else
                hit_detected <= 1'b0;     // 충돌 없음
        end
    end

endmodule