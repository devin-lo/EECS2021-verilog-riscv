module yAdder(z, cout, a, b, cin);
    // outputs
    output [31:0] z;
    output cout;

    // inputs
    input [31:0] a, b;
    input cin;

    // interconnects
    wire[31:0] in, out;

    // yAdder1 is defined in yAdder1.v
    yAdder1 mine[31:0](z, out, a, b, in);
    
    assign in[0] = cin;
    assign in[31:1] = out[30:0];
endmodule