module labK;
    reg a, b; // reg without size means 1-bit
    wire tmp, z;
    // tmp is an output; b is an input
    not my_not(tmp, b);
    //z output; a, tmp are inputs
    and my_and(z, a, tmp);
    initial
    begin
    a = 1; b = 1;
    $display("a=%b b=%b z=%b", a, b, z);
    $finish;
    end
endmodule