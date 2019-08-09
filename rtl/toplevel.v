////////////////////////////////////////////////////////////////////////////////
//
// Filename:	./toplevel.v
//
// Project:	ZipVersa, Versa Brd implementation using ZipCPU infrastructure
//
// DO NOT EDIT THIS FILE!
// Computer Generated: This file is computer generated by AUTOFPGA. DO NOT EDIT.
// DO NOT EDIT THIS FILE!
//
// CmdLine:	autofpga autofpga -d -o . allclocks.txt global.txt dlyarbiter.txt version.txt buserr.txt pwrcount.txt wbfft.txt spio.txt gpio.txt wbuconsole.txt bkram.txt flash.txt picorv.txt pic.txt mdio1.txt enet.txt enetscope.txt flashscope.txt mem_flash_bkram.txt mem_bkram_only.txt
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2019, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none


//
// Here we declare our toplevel.v (toplevel) design module.
// All design logic must take place beneath this top level.
//
// The port declarations just copy data from the @TOP.PORTLIST
// key, or equivalently from the @MAIN.PORTLIST key if
// @TOP.PORTLIST is absent.  For those peripherals that don't need
// any top level logic, the @MAIN.PORTLIST should be sufficent,
// so the @TOP.PORTLIST key may be left undefined.
//
// The only exception is that any clocks with CLOCK.TOP tags will
// also appear in this list
//
module	toplevel(i_clk, i_clk_125mhz,
		// Ethernet control (packets) lines
		o_net1_reset_n,
		// eth_int_b	// Interrupt, leave floating
		// eth_pme_b	// Power management event, leave floating
		i_net1_rx_clk, i_net1_rx_ctl, i_net1_rxd,
		o_net1_tx_clk, o_net1_tx_ctl, o_net1_txd,
		o_net1_config,
		// Toplevel ethernet MDIO1 ports
		o_net1_mdc, io_net1_mdio,
		// Top level Quad-SPI I/O ports
		o_qspi_cs_n, io_qspi_dat,
		// SPIO interface
		i_sw, i_btn, o_led,
		// UART/host to wishbone interface
		i_wbu_uart_rx, o_wbu_uart_tx,
		// GPIO ports
		// i_gpio, o_gpio
		o_gpio_clk_reset_n,
		// i_gpio_clk_locked,
		io_gpio_clk_scl,
		io_gpio_clk_sda);
	//
	// Declaring our input and output ports.  We listed these above,
	// now we are declaring them here.
	//
	// These declarations just copy data from the @TOP.IODECLS key,
	// or from the @MAIN.IODECL key if @TOP.IODECL is absent.  For
	// those peripherals that don't do anything at the top level,
	// the @MAIN.IODECL key should be sufficient, so the @TOP.IODECL
	// key may be left undefined.
	//
	// We start with any @CLOCK.TOP keys
	//
	input	wire		i_clk;
	input	wire		i_clk_125mhz;
	// Ethernet (RGMII) port wires
	output	wire		o_net1_reset_n;
	input	wire		i_net1_rx_clk, i_net1_rx_ctl;
	input	wire	[3:0]	i_net1_rxd;
	output	wire		o_net1_tx_clk, o_net1_tx_ctl;
	output	wire	[3:0]	o_net1_txd;
	output	wire		o_net1_config;
	// Ethernet control (MDIO1)
	output	wire		o_net1_mdc;
	inout	wire		io_net1_mdio;
	// Quad SPI flash
	output	wire		o_qspi_cs_n;
	inout	wire	[3:0]	io_qspi_dat;
	// SPIO interface
	input	wire	[8-1:0]	i_sw;
	input	wire	[1-1:0]	i_btn;
	output	wire	[8-1:0]	o_led;
	input	wire		i_wbu_uart_rx;
	output	wire		o_wbu_uart_tx;
	// GPIO wires
	localparam	NGPI = 2, NGPO=4;
	// GPIO ports
	// GSRN clk_reset_n (R1), FPGA_WRITEN
	output	wire	o_gpio_clk_reset_n;
	//
	// There doesn't appear to be any true clock locked input.
	// The CLK_LOCK1 pin from the ispCLOCK doesn't go to any pins
	// on the FPGA.  Not quite sure where my info came from to
	// suggest that it would.
	// input	wire	i_gpio_clk_locked;
	inout	wire	io_gpio_clk_scl, io_gpio_clk_sda;


	//
	// Declaring component data, internal wires and registers
	//
	// These declarations just copy data from the @TOP.DEFNS key
	// within the component data files.
	//
	// Ethernet (RGMII) port wires
	wire	[7:0]		w_net1_rxd,  w_net1_txd;
	wire			w_net1_rxdv, w_net1_rxerr,
				w_net1_txctl;
	wire	[1:0]		w_net1_tx_clk;
	// Ethernet control (MDIO1)
	wire		w_mdio1_dat, w_mdio1_we;
	wire		i_mdio1;
	wire		w_qspi_sck, w_qspi_cs_n;
	wire	[3:0]	qspi_dat, i_qspi_dat;
	wire	[1:0]	qspi_bmod;
	// Master clock input and reset
	wire	s_clk;
	reg	s_reset;
	// Network clock at 125MHz
	wire		s_clk_125mhz, s_clk_125d;
	wire	w_gpio_clk_reset;
	wire	w_gpio_clk_scl, w_gpio_clk_sda,
		w_gpio_halt_sim;


	//
	// Time to call the main module within main.v.  Remember, the purpose
	// of the main.v module is to contain all of our portable logic.
	// Things that are Xilinx (or even Altera) specific, or for that
	// matter anything that requires something other than on-off logic,
	// such as the high impedence states required by many wires, is
	// kept in this (toplevel.v) module.  Everything else goes in
	// main.v.
	//
	// We automatically place s_clk, and s_reset here.  You may need
	// to define those above.  (You did, didn't you?)  Other
	// component descriptions come from the keys @TOP.MAIN (if it
	// exists), or @MAIN.PORTLIST if it does not.
	//

	main	thedesign(s_clk, s_reset,
		// Ethernet (RGMII) connections
		o_net1_reset_n,
		i_net1_rx_clk, w_net1_rxdv,  w_net1_rxdv ^ w_net1_rxerr, w_net1_rxd,
		w_net1_tx_clk, w_net1_txctl, w_net1_txd,
		o_net1_mdc, w_mdio1_dat, w_mdio1_we, i_mdio1,
		// Quad SPI flash
		w_qspi_cs_n, w_qspi_sck, qspi_dat, i_qspi_dat, qspi_bmod,
		// SPIO interface
		i_sw, i_btn, o_led,
		// Network clock at 125MHz
		s_clk_125mhz,
		// UART/host to wishbone interface
		i_wbu_uart_rx, o_wbu_uart_tx,
		// GPIO wires
		// 2 Inputs first
		{ io_gpio_clk_scl, io_gpio_clk_sda },
		// Then the 4 outputs
		{ w_gpio_halt_sim, w_gpio_clk_reset,
			w_gpio_clk_scl, w_gpio_clk_sda });


	//
	// Our final section to the toplevel is used to provide all of
	// that special logic that couldnt fit in main.  This logic is
	// given by the @TOP.INSERT tag in our data files.
	//


	ecpiddr	rx0(i_net1_rx_clk, i_net1_rxd[0], { w_net1_rxd[4], w_net1_rxd[0] });
	ecpiddr	rx1(i_net1_rx_clk, i_net1_rxd[1], { w_net1_rxd[5], w_net1_rxd[1] });
	ecpiddr	rx2(i_net1_rx_clk, i_net1_rxd[2], { w_net1_rxd[6], w_net1_rxd[2] });
	ecpiddr	rx3(i_net1_rx_clk, i_net1_rxd[3], { w_net1_rxd[7], w_net1_rxd[3] });
	ecpiddr	rxc(i_net1_rx_clk, i_net1_rx_ctl, { w_net1_rxdv,   w_net1_rxerr });

	ecpoddr	tx0(s_clk_125mhz, { w_net1_txd[0], w_net1_txd[4] }, o_net1_txd[0]);
	ecpoddr	tx1(s_clk_125mhz, { w_net1_txd[1], w_net1_txd[5] }, o_net1_txd[1]);
	ecpoddr	tx2(s_clk_125mhz, { w_net1_txd[2], w_net1_txd[6] }, o_net1_txd[2]);
	ecpoddr	tx3(s_clk_125mhz, { w_net1_txd[3], w_net1_txd[7] }, o_net1_txd[3]);
	ecpoddr	txc(s_clk_125mhz, { w_net1_txctl,  w_net1_txctl  }, o_net1_tx_ctl);
	ecpoddr	txck(s_clk_125d,{w_net1_tx_clk[1],w_net1_tx_clk[0]},o_net1_tx_clk);

	assign	o_net1_config = 1'b0;

	// What I want ...
	// assign	io_net1_mdio = (w_mdio1_we) ? w_mdio1_dat : 1'bz;
	// assign	i_mdio1 = io_net1_mdio
	//
	// Trellis bi-directional I/O primitive: BB
	BB mdio1dati(.I(w_mdio1_dat), .T(!w_mdio1_we),
			.O(i_mdio1), .B(io_net1_mdio));

	//
	//
	// Wires for setting up the QSPI flash wishbone peripheral
	//
	//
	// QSPI)BMOD, Quad SPI bus mode, Bus modes are:
	//	0?	Normal serial mode, one bit in one bit out
	//	10	Quad SPI mode, going out
	//	11	Quad SPI mode coming from the device (read mode)
	USRMCLK
	mclk(.USRMCLKI(w_qspi_sck), .USRMCLKTS(1'b0), .USRMCLKO());

	assign	o_qspi_cs_n = w_qspi_cs_n;
	BB // TRELLIS_IO #(.DIR("BIDIR"))
	QSPID0 (.I(qspi_dat[0]), .O(i_qspi_dat[0]), .T(qspi_bmod==2'b11),
		.B(io_qspi_dat[0]));

	BB // TRELLIS_IO #(.DIR("BIDIR"))
	QSPID1 (.I(qspi_dat[1]), .O(i_qspi_dat[1]), .T(qspi_bmod!=2'b10),
		.B(io_qspi_dat[1]));

	BB // TRELLIS_IO #(.DIR("BIDIR"))
	QSPID2 (.I(qspi_bmod[1] ? qspi_dat[2] : 1'b1), .O(i_qspi_dat[2]),
		.T(qspi_bmod==2'b11), .B(io_qspi_dat[2]));

	BB // TRELLIS_IO #(.DIR("BIDIR"))
	QSPID3 (.I(qspi_bmod[1] ? qspi_dat[3] : 1'b1), .O(i_qspi_dat[3]),
		.T(qspi_bmod==2'b11), .B(io_qspi_dat[3]));


	//
	// Master clock input and reset
	CLKDIVF	clock_divider(.CLKI(i_clk),
		.RST(0), .ALIGNWD(1'b0), .CDIVX(s_clk));

	initial	s_reset = 1;
	always @(posedge s_clk)
		s_reset <= 0;

	assign	s_clk_125mhz = i_clk_125mhz;
	assign	s_clk_125d   = i_clk_125mhz;

	assign	o_gpio_clk_reset_n= !w_gpio_clk_reset;
	// assign	io_gpio_clk_scl = w_gpio_clk_scl ? 1'bz : 1'b0;
	// assign	io_gpio_clk_sda = w_gpio_clk_sda ? 1'bz : 1'b0;
	BB gpio_clk_scli(.I(1'b0), .T(w_gpio_clk_scl),
		.O(io_gpio_clk_scl));
	BB gpio_clk_sdai(.I(1'b0), .T(w_gpio_clk_sda),
		.O(io_gpio_clk_sda));




endmodule // end of toplevel.v module definition
