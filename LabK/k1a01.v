module test;
    reg clk, reset;
    reg [31:0] instruction;
    initial begin
    $display("Time: ", $time);
    $display("Instruction: ", instruction);
    instruction = 10;
    $display("Time: ", $time);
    $display("Instruction: ", instruction);
    instruction = 20;
    $display("Time: ", $time);
    $display("Instruction: ", instruction);
    instruction = 30;
    $display("Time: ", $time);
    $display("Instruction: ", instruction);
    $finish;
    end
endmodule