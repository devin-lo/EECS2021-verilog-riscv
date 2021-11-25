module labM;
    reg [31:0] PCin;
    reg clk;
    wire [31:0] ins, PCp4;
    yIF myIF(ins, PCp4, PCin, clk);
    initial
    begin
        //------------------------------------Entry point
        PCin = 16'h28;
        //------------------------------------Run program
        repeat (11)
        begin
            //---------------------------------Fetch an ins
            clk = 1; #1;
            //---------------------------------Execute the ins
            clk = 0; #1;
            //---------------------------------View results
            $display("instruction = %h", ins);
            // Add a statement to prepare for the next instruction
            PCin = PCp4;
        end
    $finish;
    end
endmodule