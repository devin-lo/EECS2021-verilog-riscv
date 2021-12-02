module labM; reg [4:0] rs1, rs2, wn;
    reg clk, w, flag;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;
    integer i;

    rf myRF(rd1, rd2, rs1, rs2, wn, wd, clk, w);

    initial begin
        flag = $value$plusargs("w=%b", w);
        // set each register to the square of its reg #
        for (i = 0; i < 32; i = i + 1)
        begin
            clk = 0;
            wd = i * i;
            wn = i;
            clk = 1;
            #1;
        end

        // now test the rf instance by fetching rd1 and rd2 given random rs1 and rs2
        repeat (10)
        begin
            clk = 0;
            rs1 = $random % 32;
            rs2 = $random % 32;
            clk = 1;
            #1;
            if (rd1 == rs1 * rs1 && rd2 == rs2 * rs2)
                $display("PASS: rs1=%d value=%d | rs2=%d value=%d", rs1, rd1, rs2, rd2);
            else
                $display("FAIL: rs1=%d value=%d | rs2=%d value=%d", rs1, rd1, rs2, rd2);
        end
        
        $finish;
    end
endmodule
