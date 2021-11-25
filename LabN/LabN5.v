module labM;
    reg [31:0] entryPoint;
    reg clk, INT;
    wire [31:0] ins, rd2, wb;
    yChip myChip(ins, rd2, wb, entryPoint, INT, clk);
    
    initial
    begin
        //------------------------------------Entry point
        INT = 1;
        entryPoint = 16'h28; #1;
        //------------------------------------Run program
        repeat (43)
        begin
            //---------------------------------Fetch an ins
            clk = 1; #1;
            INT = 0;
            
            //---------------------------------Execute the ins
            clk = 0; #1;
            //---------------------------------View results
            // display the following signals ins, rd1, rd2, imm, jTarget, z, zero
            // #4 $display("%8h: rd1=%d rd2=%d imm=%d jTarget=%d z=%d zero=%b wb=%d ALUop=%b funct3=%b op=%b", ins, rd1, rd2, imm, jTarget, z, zero, wb, ALUop, funct3, op);\
            $display("%h: rd2=%2d wb=%2d", ins, rd2, wb);
            //---------------------------------Prepare for the next ins - no longer needed as it's in circuit
        end
        $finish;
    end
endmodule