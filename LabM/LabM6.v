module labM;
    reg clk, read, write;
    reg [31:0] address, memIn;
    wire [31:0] memOut;

    mem data(memOut, address, memIn, clk, read, write);

    initial begin
        address = 16'h28; write = 0; read = 1;
        repeat (11)
        begin
            #1;

            if (memOut[6:0] == 7'h33) // R-type
                $display("%2h  %2h %2h %d  %2h %2h // R-Type", memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h6F) // UJ-type
                $display("%5h  %2h %2h       // UJ-Type", memOut[31:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h3 || memOut[6:0] == 7'h13) // I-Type
                $display("%3h %2h %d  %2h %2h    // I-Type", memOut[31:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h23) // S-Type
                $display("%2h  %2h %2h %d  %2h %2h // S-Type", memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            else if (memOut[6:0] == 7'h63) // SB-Type
                $display("%2h  %2h %2h %d  %2h %2h // SB-Type", memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);
            
            address = address + 4;
        end
        $finish;
    end
endmodule
