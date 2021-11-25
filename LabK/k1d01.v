// Testbench
module testbench;
    reg [31:0] instruction;
    integer i;
    initial begin
    $monitor("Time: %5d Instruction: %d (decimal)", $time, instruction);
    #5
    for (i = 0; i< 20; i= i + 1)
    #10 instruction = 1000+i;
    $finish;
    end
endmodule