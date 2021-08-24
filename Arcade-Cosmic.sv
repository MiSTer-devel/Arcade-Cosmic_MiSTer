//============================================================================
//  Arcade: Universal Cosmic series (Z80 version)
//
//  Mike Coates 
//
//  version 001 initial release - 08/07/2021
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);


///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;

assign AUDIO_S   = 1;
assign AUDIO_MIX = 0;

assign VGA_F1 = 0;
assign VGA_SCALER = 0;
assign HDMI_FREEZE = 0;
assign FB_FORCE_BLANK = 0;

assign LED_USER  = 0;

assign LED_DISK  = 0;
assign LED_POWER = 0;

assign BUTTONS = 0;

wire [1:0] ar = status[20:19];

assign VIDEO_ARX = (!ar) ? ((status[2])  ? 8'd4 : 8'd3) : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? ((status[2])  ? 8'd3 : 8'd4) : 12'd0;

`include "build_id.v" 
localparam CONF_STR = {
	"A.COSMIC;;",
   "OOR,CRT H adjust,0,+1,+2,+3,+4,+5,+6,+7,-8,-7,-6,-5,-4,-3,-2,-1;",
   "OSV,CRT V adjust,0,+1,+2,+3,+4,+5,+6,+7,-8,-7,-6,-5,-4,-3,-2,-1;",
	"H0OJK,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"H1H0O2,Orientation,Vert,Horz;",
	"O35,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"-;",
	"DIP;",
	"-;",
	"P1,Pause options;",
	"P1OL,Pause when OSD is open,On,Off;",
	"P1OM,Dim video after 10s,On,Off;",
	"-;",
	"R0,Reset;",
	"J1,Fire 1,Fire 2,Start 1P,Start 2P,Coin,Pause;",
	"jn,A,B,Start,Select,R,L;",
	"V,v",`BUILD_DATE
};

////////////////////   CLOCKS   ///////////////////

wire pll_locked;
wire clk_vid;
wire clk_sys;
    
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_vid),			// 43.264 Mhz
	.outclk_1(clk_sys),			// 10.816 Mhz
	.locked(pll_locked)
);


wire pix_clk = clk_div[0];		// Pixel clock = 5.408 Mhz

reg  [1:0] clk_div = 2'd0;		// Clock divider (for Pixel and CPU speed 2.7Mhz)
reg  [2:0] clk_div2 = 3'd0;	// Clock divider (for CPU speed 1.8 Mhz)
reg cpu_ena_27;					// 2.7 Mhz
reg cpu_ena_18;					// 1.8 Mhz


// Divider for other clocks (7474 and 74161 on PCB)
always @(posedge clk_sys) begin
	cpu_ena_27 <= 1'd0;
	cpu_ena_18 <= 1'd0;
	
	clk_div <= clk_div + 1'b1;
	clk_div2 <= clk_div2 + 1'b1;
	
	// cpu clocks
	if (clk_div == 3) cpu_ena_27 <= 1'd1;
	
	if (clk_div2 == 5) begin
		cpu_ena_18 <= 1'd1;
		clk_div2 <= 3'd0;
	end		
end


///////////////////////////////////////////////////

wire [31:0] status;
wire  [1:0] buttons;
wire        forced_scandoubler;
wire        direct_video;
wire [15:0] joy1, joy2;

wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire        ioctl_wait;

wire [21:0] gamma_bus;
wire [15:0] sdram_sz;

hps_io #(.CONF_STR(CONF_STR)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.buttons(buttons),
	.status(status),
	.status_menumask({1'd0,direct_video}),
	.forced_scandoubler(forced_scandoubler),
	.gamma_bus(gamma_bus),
	.direct_video(direct_video),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_index(ioctl_index),
	.ioctl_wait(ioctl_wait),

   .sdram_sz(sdram_sz),	
	
	.joystick_0(joy1),
	.joystick_1(joy2),
   .ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse)
);

// Game ID from MRA file

reg [7:0] GameMod = 255;
always @(posedge clk_sys) if (ioctl_wr & (ioctl_index==1)) GameMod <= ioctl_dout;

// Game ID - CPU Speed
// 01 = Space Panic - 1.8 Mhz
// 02 = Magic Spot  - 2.7 Mhz
// 03 = Cosmic Alien - 1.8 Mhz
// 04 = Devil Zone - 2.7 Mhz
// 05 = No Mans Land - 1.8Mhz

wire cpu_ena = (GameMod==2 || GameMod==4) ? cpu_ena_27 : cpu_ena_18;


// Dip switches from MRA file
reg [7:0] sw[8];
always @(posedge clk_sys) if (ioctl_wr && (ioctl_index==254) && !ioctl_addr[24:3]) sw[ioctl_addr[2:0]] <= ioctl_dout;

// Keyboard Reader

wire [10:0] ps2_key;
wire [24:0] ps2_mouse;
wire        pressed = ps2_key[9];
wire [8:0]  code    = ps2_key[8:0];

always @(posedge clk_sys) begin
	reg old_state;
	old_state <= ps2_key[10];
	
	if(old_state != ps2_key[10]) begin
		casex(code)
			'h75: btn_up            <= pressed; // up
			'h72: btn_down          <= pressed; // down
			'h6B: btn_left          <= pressed; // left
			'h74: btn_right         <= pressed; // right
			'h76: btn_coin1         <= pressed; // ESC
			'h05: btn_start1        <= pressed; // F1
			'h06: btn_start2        <= pressed; // F2
			'h14: btn_fireA         <= pressed; // lctrl
			'h11: btn_fireB         <= pressed; // lalt
			'h29: btn_fireC         <= pressed; // Space
			'h12: btn_fireD         <= pressed; // l-shift

			// JPAC/IPAC/MAME Style Codes
			'h16: btn_start1        <= pressed; // 1
			'h1E: btn_start2        <= pressed; // 2
			'h2E: btn_coin1         <= pressed; // 5
			'h36: btn_coin2         <= pressed; // 6
			'h2D: btn_up2           <= pressed; // R
			'h2B: btn_down2         <= pressed; // F
			'h23: btn_left2         <= pressed; // D
			'h34: btn_right2        <= pressed; // G
			'h1C: btn_fire2A        <= pressed; // A
			'h1B: btn_fire2B        <= pressed; // S
			'h21: btn_fire2C        <= pressed; // Q
			'h1D: btn_fire2D        <= pressed; // W
		endcase
	end
end

reg btn_left   = 0;
reg btn_right  = 0;
reg btn_down   = 0;
reg btn_up     = 0;
reg btn_fireA  = 0;
reg btn_fireB  = 0;
reg btn_fireC  = 0;
reg btn_fireD  = 0;
reg btn_coin1  = 0;
reg btn_coin2  = 0;
reg btn_start1 = 0;
reg btn_start2 = 0;
reg btn_start3 = 0;
reg btn_start4 = 0;
reg btn_up2    = 0;
reg btn_down2  = 0;
reg btn_left2  = 0;
reg btn_right2 = 0;
reg btn_fire2A = 0;
reg btn_fire2B = 0;
reg btn_fire2C = 0;
reg btn_fire2D = 0;

// Combined buttons
wire B1_S = joy1[6] | btn_start1;
wire B2_S = joy1[7] | btn_start2;
wire B1_C = joy1[8] | btn_coin1;

wire B1_B2 = joy1[5] | btn_fireB;
wire B1_B1 = joy1[4] | btn_fireA;
wire B1_U = joy1[3] | btn_up;
wire B1_D = joy1[2] | btn_down;
wire B1_L = joy1[1] | btn_left;
wire B1_R = joy1[0] | btn_right;

wire B2_B2 = joy2[5] | btn_fire2B;
wire B2_B1 = joy2[4] | btn_fire2A;
wire B2_U = joy2[3] | btn_up2;
wire B2_D = joy2[2] | btn_down2;
wire B2_L = joy2[1] | btn_left2;
wire B2_R = joy2[0] | btn_right2;

wire m_pause = joy1[9] | joy2[9];

// Panic
wire [7:0] Panic_P1 = {~B1_B2,2'd3,~B1_U,~B1_D,~B1_L,~B1_R,~B1_B1};
wire [7:0] Panic_P2 = {~B2_B2,2'd3,~B2_U,~B2_D,~B2_L,~B2_R,~B2_B1};
wire [7:0] Panic_P3 = {1'd1,~B1_C,4'D15,~B2_S,~B1_S};
// Magical Spot
wire [7:0] MagSpot_P1 = {sw[1][7:6],~B1_R,3'd7,~B1_L,1'd1}; // Includes bonus dips
wire [7:0] MagSpot_P2 = {2'd3,~B2_R,3'd7,~B2_L,1'd1};
wire [7:0] MagSpot_P3 = {~B1_B1,~B2_B1,5'D31,~vblank};
wire [7:0] MagSpot_P4 = {~B1_S,~B2_S,sw[0][5:0]};
// Cosmic Alien
wire [7:0] Alien_P1 = {5'd31,~B1_L,~B1_R,~B1_B1};
wire [7:0] Alien_P2 = {5'd31,~B2_L,~B2_R,~B2_B1};
wire [7:0] Alien_P3 = {2'd0,VCount[7:2]};

// Select correct inputs
wire [7:0] IN0 = (GameMod==1)? Panic_P1 : (GameMod==2 || GameMod==4 || GameMod==5)? MagSpot_P1 : Alien_P1;
wire [7:0] IN1 = (GameMod==1)? Panic_P2 : (GameMod==2 || GameMod==4 || GameMod==5)? MagSpot_P2 : Alien_P2;
wire [7:0] IN2 = (GameMod==1)? Panic_P3 : (GameMod==2 || GameMod==4 || GameMod==5)? MagSpot_P3 : Alien_P3;
wire [7:0] DIP = (GameMod==1)? sw[0] : MagSpot_P4; 

wire hblank, vblank;
wire hs, vs;
wire [3:0] r,g,b;
wire [8:0] VCount;

wire [ 3:0] hoffset, voffset;
assign { voffset, hoffset } = status[31:24];

wire no_rotate = status[2] | direct_video;
wire rotate_ccw = 1;
screen_rotate screen_rotate (.*);

arcade_video #(260,12) arcade_video
(
	.*,

	.clk_video(clk_vid),
	.ce_pix(pix_clk),

	.RGB_in(rgb_out),
	.HBlank(hblank),
	.VBlank(vblank),
	.HSync(hs),
	.VSync(vs),

	.fx(status[5:3])
);

// PAUSE SYSTEM
wire pause_cpu;

wire [11:0] rgb_out;

// Clock speed is either 1.7 or 2.8MHz. The speed of the clock for
// the pause system is just for how long to wait to dim the screen,
// so it's fine just to set it to 2 always.
pause #(4,4,4,2) pause (
  .*,
  .reset(Myreset),
  .user_button(m_pause),
  .pause_request(),
  .options(~status[22:21])
);


// reg [15:0] audio;
assign AUDIO_L = samples_left;
assign AUDIO_R = samples_right;
wire   Myreset = RESET | ioctl_download | status[0] | buttons[1];

COSMIC COSMIC
(
	.O_VIDEO_R(r),
	.O_VIDEO_G(g),
	.O_VIDEO_B(b),
	.O_HSYNC(hs),
	.O_VSYNC(vs),
	.O_HBLANK(hblank),
	.O_VBLANK(vblank),
	.I_H_OFFSET(hoffset),
	.I_V_OFFSET(voffset),
	.I_FLIP(sw[2][0]),
	.O_VCOUNT(VCount),

	.dn_addr(ioctl_addr[15:0]),
	.dn_data(ioctl_dout),
	.dn_wr(ioctl_wr && (ioctl_index == 0)),
	.dn_ld(ioctl_download),

	.O_SoundPort(SoundTrigger),
	.O_SoundStop(SoundStop),
	.O_AUDIO(audio),
	.O_Sound_EN(),

	.dipsw1(DIP),
	.dipsw2(sw[1]),
	.in0(IN0),
	.in1(IN1),
	.in2(IN2),
	.coin(B1_C),
	
	.RESET(Myreset),
	.PIX_CLK(pix_clk),
	.CPU_ENA(cpu_ena),
	.CLK(clk_sys),
	.GAME(GameMod),
  .PAUSED(pause_cpu) 
);

////////////////////////////  Samples   ///////////////////////////////////

//wire		wav_load = ioctl_download && (ioctl_index == 4);
reg  [24:0] wav_addr;
wire [15:0] wav_data;
reg         wav_want_byte;
wire [15:0] samples_left;
wire [15:0] samples_right;
reg 	      use_samples;
reg  [15:0] SoundTrigger; 
reg  [15:0] SoundStop; 
reg         Sound_Enable;

// 8 bit write, 16 bit read 

	sdram sdram
	(
		.*,
		.init(~pll_locked),
		.clk(clk_vid),

		.addr(ioctl_download ? ioctl_addr : {wav_addr[24:1],1'd0}),
		.we(ioctl_download && ioctl_wr && (ioctl_index==4)),
		.rd(~ioctl_download & wav_want_byte),
		.din(ioctl_dout),
		.dout(wav_data),

		.ready()
	);
	
// Link to Samples module

samples samples
(
	.audio_enabled(1'd1),
	.audio_port_0(SoundTrigger[7:0]),  
	.audio_port_1(SoundTrigger[15:8]),
	.audio_stop(SoundStop),

	.wave_addr(wav_addr),        
	.wave_read(wav_want_byte),   
	.wave_data(wav_data),        

	.samples_ok(use_samples),

	.dl_addr(ioctl_addr),
	.dl_wr(ioctl_wr),
	.dl_data(ioctl_dout),
	.dl_download(ioctl_download && (ioctl_index == 3)),
	
	.CLK_SYS(clk_sys),
	.clock(clk_vid & ~pause_cpu),
	.reset(Myreset),
	
	.audio_in(audio),
	.audio_out_L(samples_left),
	.audio_out_R(samples_right)
);

endmodule

