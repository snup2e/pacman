module vga_timing (
    input wire clk,        // 25MHz 픽셀 클럭 입력
    input wire rst,        // 비동기 리셋 입력
    output reg [10:0] h_cnt, // 현재 수평 위치 카운터 (0~799)
    output reg [9:0]  v_cnt, // 현재 수직 위치 카운터 (0~524)
    output wire hsync,     // 수평 동기화 신호
    output wire vsync      // 수직 동기화 신호
);

parameter H_ACTIVE = 640;                    // 실제 픽셀 표시 구간 (수평)
parameter H_FP     = 16;                     // 프론트 포치 (수평)
parameter H_SYNC   = 96;                     // 수평 동기 신호 길이
parameter H_BP     = 48;                     // 백 포치 (수평)
parameter H_TOTAL  = H_ACTIVE + H_FP + H_SYNC + H_BP; // 총 수평 주기: 800

parameter V_ACTIVE = 480;                    // 실제 픽셀 표시 구간 (수직)
parameter V_FP     = 10;                     // 프론트 포치 (수직)
parameter V_SYNC   = 2;                      // 수직 동기 신호 길이
parameter V_BP     = 33;                     // 백 포치 (수직)
parameter V_TOTAL  = V_ACTIVE + V_FP + V_SYNC + V_BP; // 총 수직 주기: 525

// 수평 카운터: 한 줄 끝나면 초기화
always @(posedge clk or negedge rst) begin
    if (!rst)
        h_cnt <= 0;
    else if (h_cnt == H_TOTAL - 1)
        h_cnt <= 0;
    else
        h_cnt <= h_cnt + 1;
end

// 수직 카운터: 수평 한 줄 끝나면 증가
always @(posedge clk or negedge rst) begin
    if (!rst)
        v_cnt <= 0;
    else if (h_cnt == H_TOTAL - 1) begin
        if (v_cnt == V_TOTAL - 1)
            v_cnt <= 0;
        else
            v_cnt <= v_cnt + 1;
    end
end

// 수평 동기 신호: Active LOW
assign hsync = ~((h_cnt >= (H_ACTIVE + H_FP)) && (h_cnt < (H_ACTIVE + H_FP + H_SYNC)));

// 수직 동기 신호: Active LOW
assign vsync = ~((v_cnt >= (V_ACTIVE + V_FP)) && (v_cnt < (V_ACTIVE + V_FP + V_SYNC)));

endmodule