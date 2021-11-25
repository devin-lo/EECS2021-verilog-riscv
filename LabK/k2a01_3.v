module labK;
    reg a, b, flag; // reg without size means 1-bit
    wire notOutput, lowerInput, tmp, z;
    // tmp is an output; b is an input
    not my_not(notOutput, b);
    //z output; a, tmp are inputs
    and my_and(z, a, lowerInput);
    assign lowerInput = notOutput;
    initial
    begin
    flag = $value$plusargs("a=%b", a);
    flag = $value$plusargs("b=%b", b);
    #1; // wait for z
    $display("a=%b b=%b z=%b", a, b, z);
    $finish;
    end
endmodule