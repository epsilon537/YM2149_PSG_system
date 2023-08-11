//A Wishbone slave port wrapper around YM2149_PSG_system.

module YM2149_PSG_system_wb #(

    parameter      CLK_IN_HZ        = 100000000, // Input clock frequency
    parameter      CLK_I2S_IN_HZ    = 200000000, // Input clock frequency
    parameter      CLK_PSG_HZ       = 1789000,   // PSG clock frequency
    parameter      I2S_DAC_HZ       = 48000,     // I2S audio dac frequency
    parameter      YM2149_DAC_BITS  = 8,         // PSG DAC bit precision, 8 through 14 bits, the higher the bits, the higher the dynamic range.
                                                 // 10 bits almost perfectly replicates the YM2149 DA converter's Normalized voltage.
                                                 // With 8 bits, the lowest volumes settings will be slightly louder than normal.
                                                 // With 12 bits, the lowest volume settings will be too quiet.

    parameter      MIXER_DAC_BITS   = 16         // The number of DAC bits for the BHG_jt49_filter_mixer output.

)(

    input wire                                clk,
    input wire                                clk_i2s,
    input wire                                rst,

    //32-bit pipelined Wishbone interface.
    input wire [7:0]                          wb_adr,
	input wire [31:0]                         wb_dat_w,
	output wire [31:0]                        wb_dat_r,
	input wire [3:0]                          wb_sel,
    output wire                               wb_stall,
	input wire                                wb_cyc,
	input wire                                wb_stb,
	output wire                               wb_ack,
	input wire                                wb_we,
	output wire                               wb_err,

    output wire                               i2s_sclk,    // I2S serial bit clock output
    output wire                               i2s_lrclk,   // I2S L/R output
    output wire                               i2s_data,    // I2S serial audio out
    output wire  signed  [MIXER_DAC_BITS-1:0] sound,       // parallel   audio out, mono or left channel
    output wire  signed  [MIXER_DAC_BITS-1:0] sound_right  // parallel   audio out, right channel
);

    logic [ 7:0] ym_sys_addr;      // register address
    logic [ 7:0] ym_sys_data;      // data IN to PSG
    logic ym_sys_wr_n;             // data/addr valid
    logic [ 7:0] ym_sys_dout;      // PSG data output

    logic do_ack;

    assign ym_sys_addr = wb_adr;
    assign ym_sys_data = wb_dat_w[7:0];
    assign wb_dat_r = {24'b0, ym_sys_dout};
    assign wb_err = 1'b0;
    assign ym_sys_wr_n = ~(wb_cyc && wb_stb && wb_we);

    always_ff @(posedge clk) begin
        do_ack <= 1'b0;
        if (wb_stb) begin
            do_ack <= 1'b1;
        end
    end

    assign wb_ack = do_ack & wb_cyc;
    assign wb_stall = !wb_cyc ? 1'b0 : !wb_ack;

    YM2149_PSG_system #(
        .CLK_IN_HZ(CLK_IN_HZ),
        .CLK_I2S_IN_HZ(CLK_I2S_IN_HZ),
        .CLK_PSG_HZ(CLK_PSG_HZ),
        .I2S_DAC_HZ(I2S_DAC_HZ),
        .YM2149_DAC_BITS(YM2149_DAC_BITS),
        .MIXER_DAC_BITS(MIXER_DAC_BITS)) ym2149_psg_sys_inst(
        .clk(clk),
        .clk_i2s(clk_i2s),
        .reset_n(~rst),
        .addr(ym_sys_addr),      // register address
        .data(ym_sys_data),      // data IN to PSG
        .wr_n(ym_sys_wr_n),      // data/addr valid
        .dout(ym_sys_dout),      // PSG data output
        .i2s_sclk(i2s_sclk),    // I2S serial bit clock output
        .i2s_lrclk(i2s_lrclk),   // I2S L/R output
        .i2s_data(i2s_data),    // I2S serial audio out
        .sound(sound),          // parallel   audio out, mono or left channel
        .sound_right(sound_right)  // parallel   audio out, right channel
    );

endmodule
