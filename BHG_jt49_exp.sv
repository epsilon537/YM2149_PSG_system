/*  

This source code was written to replace jt49_exp.v which was part of the JT49 YM2149 PSG.

BHG_jt49_exp.v v1.0, Aug 6, 2022 by Brian Guralnick.

This code is free to use.  Just be fair and give credit where it is due.

******************************************************************
*** This code was written by BrianHG providing an optional     ***
*** volume decibel attenuation, or decibel volumetric power    ***
*** with optional DAC bit width parameter output.              ***
***                                                            ***
******************************************************************

10 bits almost perfectly replicates the YM2149 DA converter's Normalized voltage.
With 8 bits, the lowest volumes settings will be slightly louder than normal.
With 12 bits, the lowest volume settings will be too quiet.

*/


module BHG_jt49_exp #(

parameter [5:0] DAC_BITS   = 8        // The number of DAC bits for each channel of the YM2149 PSG.  Supports 8 thru 14.

)(
    input                     clk,
    input      [4:0]          din,
    output reg [DAC_BITS-1:0] dout
);

initial dout = 0;

generate
if ( (DAC_BITS<8) || (DAC_BITS>12) )  initial begin
$display("");
$display("");
$display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
$display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
$display("  XXXXXX                                              XXXXXX");
$display("  XXXXXX   BrianHG's BHG_jt49_exp.v PARAMETER ERROR   XXXXXX");
$display("  XXXXXX   https://github.com/BrianHGinc              XXXXXX");
$display("  XXXXXX                                              XXXXXX");
$display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
$display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
$display("  XXXXXX                                                             XXXXXX");
$display("  XXXXXX   BHG_jt49_exp parameter .DAC_BITS(%d) is not supported.    XXXXXX",DAC_BITS);
$display("  XXXXXX   Only numbers from 8 thru 12 are allowed.                  XXXXXX");
$display("  XXXXXX                                                             XXXXXX");
$display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
$display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
$error;
$stop;
end
endgenerate

`include "BHG_jt49_exp_lut.vh"
logic [15:0] dlut[0:31] = dlut_sel[DAC_BITS];

// generate
// initial begin
// $display("");
// $display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
// $display("  XXX  BrianHG's BHG_jt49_exp.v is using %d bit DAC LUT table.  XXX",DAC_BITS);
// $display("  XXX  https://github.com/BrianHGinc                            XXX");
// $display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
// $display("  XXX  dlut[0:31] = '{%d,%d,%d,%d,%d,%d,%d,%d,   XXX", dlut[ 0], dlut[ 1], dlut[ 2], dlut[ 3], dlut[ 4], dlut[ 5], dlut[ 6], dlut[ 7]);
// $display("  XXX                %d,%d,%d,%d,%d,%d,%d,%d,   XXX" , dlut[ 8], dlut[ 9], dlut[10], dlut[11], dlut[12], dlut[13], dlut[14], dlut[15]);
// $display("  XXX                %d,%d,%d,%d,%d,%d,%d,%d,   XXX" , dlut[16], dlut[17], dlut[18], dlut[19], dlut[20], dlut[21], dlut[22], dlut[23]);
// $display("  XXX                %d,%d,%d,%d,%d,%d,%d,%d}   XXX" , dlut[24], dlut[25], dlut[26], dlut[27], dlut[28], dlut[29], dlut[30], dlut[31]);
// $display("  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
// $display("");
// end
// endgenerate

// Clock the look-up table.
always @(posedge clk) dout <= dlut[din];

endmodule
