`timescale 1ns / 1ps

module Mix_columns(
    input  [127:0] state_in,
    output [127:0] state_out
);

    
    function [7:0] xtime;
        input [7:0] x;
        begin
            xtime = (x << 1) ^ (8'h1b & {8{x[7]}});
        end
    endfunction

    
    function [7:0] mul3;
        input [7:0] x;
        begin
            mul3 = xtime(x) ^ x;
        end
    endfunction

    
    wire [7:0] b [0:15];

    assign {b[0],  b[1],  b[2],  b[3],
            b[4],  b[5],  b[6],  b[7],
            b[8],  b[9],  b[10], b[11],
            b[12], b[13], b[14], b[15]} = state_in;

   
    wire [7:0] out [0:15];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : mix_col

           
            wire [7:0] s0 = b[i*4 + 0];
            wire [7:0] s1 = b[i*4 + 1];
            wire [7:0] s2 = b[i*4 + 2];
            wire [7:0] s3 = b[i*4 + 3];

            assign out[i*4 + 0] = xtime(s0) ^ mul3(s1) ^ s2 ^ s3;
            assign out[i*4 + 1] = s0 ^ xtime(s1) ^ mul3(s2) ^ s3;
            assign out[i*4 + 2] = s0 ^ s1 ^ xtime(s2) ^ mul3(s3);
            assign out[i*4 + 3] = mul3(s0) ^ s1 ^ s2 ^ xtime(s3);

        end
    endgenerate

    
    assign state_out = {
        out[0],  out[1],  out[2],  out[3],
        out[4],  out[5],  out[6],  out[7],
        out[8],  out[9],  out[10], out[11],
        out[12], out[13], out[14], out[15]
    };

endmodule