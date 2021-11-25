module labK;
    reg a, b, flag, c, d; // reg without size means 1-bit
    wire notOutput, lowerInput, tmp, z;
    // tmp is an output; b is an input
    not my_not(notOutput, b);
    //z output; a, tmp are inputs
    and my_and(z, a, lowerInput);
    assign lowerInput = notOutput;
    initial
    begin
    c = 0; d = 1;
    flag = $value$plusargs("a=%b", a);
    if (flag === 0)
        $display("Missing input for a");
    else
    begin
        flag = $value$plusargs("b=%b", b);
        if (flag === 0)
            $display("Missing input for b");
        else
        begin
            #1; // wait for z
            $display("a=%b b=%b z=%b", a, b, z);
        end
    end
    $finish;
    end
endmodule