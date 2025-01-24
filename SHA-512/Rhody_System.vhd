library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rhody_System is
	port(	CLOCK_50	: in std_logic;
			KEY		: in std_logic_vector(3 downto 0);
			SW			: in std_logic_vector(9 downto 0);
			LEDR		: out std_logic_vector(3 downto 0);
			HEX0, HEX1, HEX2, HEX3: out std_logic_vector(6 downto 0);
			PS2_CLK, PS2_DAT		: inout std_logic;
			PS2_CLK2, PS2_DAT2	: inout std_logic;
			GPIO_1	: out std_logic_vector(31 downto 0);
			MTL_TOUCH_INT_n : in std_logic;
			MTL_TOUCH_I2C_SCL : out std_logic;
			MTL_TOUCH_I2C_SDA : inout std_logic
		);
end;

architecture DE1_SoC of Rhody_System is
	alias  clk : std_logic is clock_50;
	signal rst, nclk : std_logic;
	signal mem_in, mem_out, mem_adr: std_logic_vector(31 downto 0);
	signal prog_out, data_out, stck_out, lib_out: std_logic_vector(31 downto 0);
	signal gpio_out, kscan, kascii, cr, vga_out, ext_out: std_logic_vector(31 downto 0);
	signal tout0, tout1, rand, buf_out: std_logic_vector(31 downto 0);
	signal mem_rd, mem_wr: std_logic;
	signal en_prog, en_data, en_stck, en_lib: std_logic;
	signal en_gpio, en_kbdc, en_kscan, en_kascii: std_logic;
	signal en_vga, en_tvga, en_gvga, en_time0, en_time1: std_logic;
	signal en_rand, en_ext, en_buf: std_logic;
	signal ready : std_logic;
	signal touch_count : std_logic_vector(3 downto 0);
	signal gesture : std_logic_vector(7 downto 0);
	signal regx1, regx2, regx3, regx4, regx5 : std_logic_vector(9 downto 0);
	signal regy1, regy2, regy3, regy4, regy5 : std_logic_vector(8 downto 0);
	signal en_tready, en_tcount, en_gesture, en_x1, en_y1 : std_logic;
	signal en_x2, en_y2, en_x3, en_y3, en_x4, en_y4, en_x5, en_y5 : std_logic;

	constant MASK_PROG  : std_logic_vector(20 downto 0) := x"00000" & '0';
	constant MASK_DATA  : std_logic_vector(22 downto 0) := x"00000" & "100";
	constant MASK_STCK  : std_logic_vector(22 downto 0) := x"000FF" & "100";
	constant MASK_LIB   : std_logic_vector(21 downto 0) := x"000FF" & "11";
	constant MASK_EXT   : std_logic_vector(15 downto 0) := x"0001";
	constant MASK_BUF   : std_logic_vector(18 downto 0) := x"0001" & "000";
	constant MASK_TVGA  : std_logic_vector(18 downto 0) := x"0000" & "001";
	constant MASK_GVGA  : std_logic_vector(12 downto 0) := x"001" & '0';
	constant MASK_KBDC  : std_logic_vector(31 downto 0) := X"000F0000";	
	constant MASK_ASCII : std_logic_vector(31 downto 0) := X"000F0001";
	constant MASK_VGA   : std_logic_vector(31 downto 0) := X"000F0002";
	constant MASK_TIME0 : std_logic_vector(31 downto 0) := X"000F0003";
	constant MASK_TIME1 : std_logic_vector(31 downto 0) := X"000F0004";
	constant MASK_GPIO  : std_logic_vector(31 downto 0) := X"000F0005";
	constant MASK_RAND  : std_logic_vector(31 downto 0) := X"000F0006";
	constant MASK_TRDY  : std_logic_vector(31 downto 0) := X"000F0010";	
	constant MASK_TCNT  : std_logic_vector(31 downto 0) := X"000F0011";
	constant MASK_TGEST : std_logic_vector(31 downto 0) := X"000F0012";	
	constant MASK_TX1   : std_logic_vector(31 downto 0) := X"000F0013";
	constant MASK_TY1   : std_logic_vector(31 downto 0) := X"000F0014";
	constant MASK_TX2   : std_logic_vector(31 downto 0) := X"000F0015";
	constant MASK_TY2   : std_logic_vector(31 downto 0) := X"000F0016";
	constant MASK_TX3   : std_logic_vector(31 downto 0) := X"000F0017";
	constant MASK_TY3   : std_logic_vector(31 downto 0) := X"000F0018";
	constant MASK_TX4   : std_logic_vector(31 downto 0) := X"000F0019";
	constant MASK_TY4   : std_logic_vector(31 downto 0) := X"000F001A";
	constant MASK_TX5   : std_logic_vector(31 downto 0) := X"000F001B";
	constant MASK_TY5   : std_logic_vector(31 downto 0) := X"000F001C";

	signal VGA_R, VGA_G, VGA_B : std_logic_vector(7 downto 0);
	alias VGA_HS : std_logic is GPIO_1(30); --HSD
	alias VGA_VS : std_logic is GPIO_1(31); --VSD
	alias DCLK : std_logic is GPIO_1(1);	--pixel clock = 33.333MHz

	----------------------------------------------------------------
	--This is the IP provided by Terasic for interfacing
	-- touch sensors on MTL2. The source codes are in Verilog
	----------------------------------------------------------------
	component i2c_touch_config is port(
        iCLK : in std_logic;
        iRSTN : in std_logic;
        oREADY : out std_logic;
        INT_n : in std_logic;
        oREG_X1 : out std_logic_vector(9 downto 0);
        oREG_Y1 : out std_logic_vector(8 downto 0);
        oREG_X2 : out std_logic_vector(9 downto 0);
        oREG_Y2 : out std_logic_vector(8 downto 0);
        oREG_X3 : out std_logic_vector(9 downto 0);
        oREG_Y3 : out std_logic_vector(8 downto 0);
        oREG_X4 : out std_logic_vector(9 downto 0);
        oREG_Y4 : out std_logic_vector(8 downto 0);
        oREG_X5 : out std_logic_vector(9 downto 0);
        oREG_Y5 : out std_logic_vector(8 downto 0);
        oREG_GESTURE : out std_logic_vector(7 downto 0);
        oREG_TOUCH_COUNT : out std_logic_vector(3 downto 0);
        I2C_SDAT : inout std_logic;
        I2C_SCLK : out std_logic
	); end component i2c_touch_config;
	
begin
	rst <= not key(0);	--reverse polarity of pushbutton
	nclk <= not clk;		--CPU uses falling edge, memory uses rising edge
	GPIO_1(10 downto 3) <= VGA_R;		--MTL2 at GPIO_1 connector
	GPIO_1(21) <= VGA_G(7);
	GPIO_1(19 downto 18) <= VGA_G(6 downto 5);
	GPIO_1(15 downto 11) <= VGA_G(4 downto 0);
	GPIO_1(28 downto 22) <= VGA_B(7 downto 1);
	GPIO_1(20) <= VGA_B(0);
	
	--Basic Rhody CPU
--	the_cpu: entity work.Rhody_CPU port map(clk => nclk, rst => rst,  
--						mem_adr => mem_adr, mem_in => mem_in, mem_out => mem_out, 
--						mem_wr => mem_wr, mem_rd => mem_rd, key => key(2), LEDR => LEDR);
				
--	--Rhody CPU with instruction pipeline
--	the_cpu: entity work.Rhody_CPU_pipe port map(clk => nclk, rst => rst,  
--						mem_adr => mem_adr, mem_in => mem_in, mem_out => mem_out, 
--						mem_wr => mem_wr, mem_rd => mem_rd, key => key(2), LEDR => LEDR);

	--Rhody CPU with instruction pipeline and branch prediction
	the_cpu: entity work.Rhody_CPU_pipe_BP port map(clk => nclk, rst => rst,  
						mem_adr => mem_adr, mem_in => mem_in, mem_out => mem_out, 
						mem_wr => mem_wr, mem_rd => mem_rd, key => key(2), LEDR => LEDR);
						
	Memory_Address_Decode: process(clk)	--Enable signals for memory and I/O components
	begin
		if(clk'event AND clk = '1') then
			if(mem_adr(31 downto 11)=MASK_PROG) then en_prog<='1'; 	else en_prog<='0';	end if;
			if(mem_adr(31 downto 9)=MASK_DATA)	then en_data<='1'; 	else en_data<='0'; 	end if;
			if(mem_adr(31 downto 9)=MASK_STCK) 	then en_stck<='1'; 	else en_stck<='0'; 	end if;
			if(mem_adr(31 downto 10)=MASK_LIB) 	then en_lib<='1'; 	else en_lib<='0'; 	end if;	
			if(mem_adr(31 downto 16)=MASK_EXT) 	then en_ext<='1'; 	else en_ext<='0'; 	end if;
			if(mem_adr(31 downto 13)=MASK_BUF) 	then en_buf<='1'; 	else en_buf<='0'; 	end if;	
			if(mem_adr(31 downto 0)=MASK_KBDC) 	then en_kbdc<='1'; 	else en_kbdc<='0'; 	end if;
			if(mem_adr(31 downto 0)=MASK_ASCII) then en_kascii<='1';	else en_kascii<='0'; end if;
			if(mem_adr(31 downto 0)=MASK_VGA) 	then en_vga<='1'; 	else en_vga<='0'; 	end if;
			if(mem_adr(31 downto 0)=MASK_TIME0) then en_time0<='1'; 	else en_time0<='0'; 	end if;
			if(mem_adr(31 downto 0)=MASK_TIME1) then en_time1<='1'; 	else en_time1<='0'; 	end if;
			if(mem_adr(31 downto 0)=MASK_GPIO) 	then en_gpio<='1'; 	else en_gpio<='0'; 	end if;
			if(mem_adr(31 downto 0)=MASK_RAND) 	then en_rand<='1'; 	else en_rand<='0'; 	end if;
			if(mem_adr(31 downto 0)=MASK_TRDY) 	then en_tready<='1';	else en_tready<='0';	end if;
			if(mem_adr(31 downto 0)=MASK_TCNT) 	then en_tcount<='1';	else en_tcount<='0';	end if;
			if(mem_adr(31 downto 0)=MASK_TGEST)	then en_gesture<='1';else en_gesture<='0';end if;
			if(mem_adr(31 downto 0)=MASK_TX1) 	then en_x1<='1'; 		else en_x1<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TY1) 	then en_y1<='1'; 		else en_y1<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TX2) 	then en_x2<='1'; 		else en_x2<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TY2) 	then en_y2<='1'; 		else en_y2<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TX3) 	then en_x3<='1'; 		else en_x3<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TY3) 	then en_y3<='1'; 		else en_y3<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TX4) 	then en_x4<='1'; 		else en_x4<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TY4) 	then en_y4<='1'; 		else en_y4<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TX5) 	then en_x5<='1'; 		else en_x5<='0'; 		end if;
			if(mem_adr(31 downto 0)=MASK_TY5) 	then en_y5<='1'; 		else en_y5<='0'; 		end if;
			if(mem_adr(31 downto 13)=MASK_TVGA) then en_tvga<='1'; 	else en_tvga<='0'; 	end if;
			if(mem_adr(31 downto 19)=MASK_GVGA) then en_gvga<='1'; 	else en_gvga<='0'; 	end if;
		end if;
	end process;

   -- User Program ROM
	Program_ROM: entity work.prog_rom port map(
		clock => clk,
		address => mem_adr(10 downto 0),
		q => prog_out
		);
	MEM_IN <= prog_out when mem_rd='1' and en_prog='1' else (others => 'Z');
	
	-- User Data Memory
	Data_Memory: entity work.data_mem port map(
		clock => clk,
		address => mem_adr(8 downto 0),
		q => data_out,
		data => MEM_OUT,	
		wren => mem_wr and en_data
		);
	MEM_IN <= data_out when mem_rd='1' and en_data='1' else (others => 'Z');
	
	-- Extended Memory (Dual-Port) 64K words
	-- memory address: 0x10000 to 0x1FFFF
--	Extended_Memory: entity work.ext_mem port map(
--		clock => clk,
--		address_a => mem_adr(15 downto 0),
--		q_a => ext_out,
--		data_a => MEM_OUT,	
--		wren_a => mem_wr and en_ext,
--		address_b => "----------------",
--		--q_b => ,
--		data_b => x"00000000",	
--		wren_b => null
--		);
--	MEM_IN <= ext_out when mem_rd='1' and en_ext='1' else (others => 'Z');

	-- Buffer Memory (Dual-port) 8K words
	-- memory address: 0x10000 to 0x11FFF
--	Buffer_Memory: entity work.buf_mem port map(
--		clock => clk,
--		address_a => mem_adr(12 downto 0),
--		q_a => buf_out,
--		data_a => MEM_OUT,	
--		wren_a => mem_wr and en_buf,
--		address_b => "-------------",
--		--q_b => ,
--		data_b => x"00000000",	
--		wren_b => null
--		);
--	MEM_IN <= buf_out when mem_rd='1' and en_buf='1' else (others => 'Z');
--	
	-- Stack Memory
	Stack_Memory: entity work.stack_mem port map(
		clock => clk,
		address => mem_adr(8 downto 0),
		q => stck_out,
		data => MEM_OUT,	
		wren => mem_wr and en_stck
		);
	MEM_IN <= stck_out when mem_rd='1' and en_stck='1' else (others => 'Z');

   -- Library routines (System Functions) ROM
	SYS_ROM: entity work.sys_rom port map(
		clock => clk,
		address => mem_adr(9 downto 0),
		q => lib_out
		);
	MEM_IN <= lib_out when mem_rd='1' and en_lib='1' else (others => 'Z');
		
	-- Keyboard interface
	Keyboard_Interface : entity work.keyboard
	port map(
		clk => clk,
		rst => rst,
		kascii => kascii,
		cr_out => cr,
		cr_in => MEM_OUT,
		wr => mem_wr and en_kbdc,
		ps2clk => ps2_clk,
		ps2data => ps2_dat
	);
	MEM_IN <= 	cr when mem_rd='1' and en_kbdc='1' else  
					kascii when mem_rd='1' and en_kascii='1' else 
					(others => 'Z'); 

	--VGA1 interfaces for MTL2
	--Text video: 50x30 monochrome ASCII text
	--Graphic video : 800x480 6-bit (emulating 8-bit) colors
	Video_VGA1 : entity work.vga1 
	port map(
		clk => clk,			--system clock
		clock_50 => clk,	--50MHz clock for PLL to generate VGA pixel clock
		rst => rst,
		mem_adr => mem_adr,
		vga_out => vga_out,
		vga_in => mem_out,
		wr => mem_wr,
		en_vga => en_vga,		--VGA control
		en_text => en_tvga,	--Text video
		en_graph => en_gvga,	--Graphic video
		vga_hs => vga_hs,
		vga_vs => vga_vs,
		r => vga_r,
		g => vga_g,
		b => vga_b,
		pclk => dclk,
		SW => SW(9 downto 8)
	);
	MEM_IN <= 	vga_out when mem_rd='1' and (en_tvga='1' or en_gvga='1') else
					x"00000001" when mem_rd='1' and en_vga='1'	--VGA ID
					else (others => 'Z');       

	--VGA2 interfaces for MTL2 (text only)
	--Text video: 100x60 monochrome ASCII text
--	Video_VGA2 : entity work.vga2 
--	port map(
--		clk => clk,			--system clock
--		clock_50 => clk,	--50MHz clock for PLL to generate VGA pixel clock
--		rst => rst,
--		mem_adr => mem_adr,
--		vga_out => vga_out,
--		vga_in => mem_out,
--		wr => mem_wr,
--		en_vga => en_vga,		--VGA control
--		en_text => en_tvga,	--Text video
--		vga_hs => vga_hs,
--		vga_vs => vga_vs,
--		r => vga_r,
--		g => vga_g,
--		b => vga_b,
--		pclk => dclk
--	);
--	MEM_IN <= 	vga_out when mem_rd='1' and en_tvga='1' else
--					x"00000002" when mem_rd='1' and en_vga='1'	--VGA ID
--					else (others => 'Z');       

	--VGA3 interfaces for MTL2 (graphic only)
	--Graphic video : 640x480 8-bit colors
--	Video_VGA3 : entity work.vga3 
--	port map(
--		clk => clk,			--system clock
--		clock_50 => clk,	--50MHz clock for PLL to generate VGA pixel clock
--		rst => rst,
--		mem_adr => mem_adr,
--		vga_out => vga_out,
--		vga_in => mem_out,
--		wr => mem_wr,
--		en_vga => en_vga,		--VGA control
--		en_graph => en_gvga,	--Graphic video
--		vga_hs => vga_hs,
--		vga_vs => vga_vs,
--		r => vga_r,
--		g => vga_g,
--		b => vga_b,
--		pclk => dclk
--	);
--	MEM_IN <= 	vga_out when mem_rd='1' and en_gvga='1' else
--					x"00000003" when mem_rd='1' and en_vga='1'	--VGA ID
--					else (others => 'Z');  
					
	-- GPIO (general purpose I/O) ports for switches and 7-segment displays
	GPIO_interface : entity work.gpio port map(
		clk => clk,
		rst => rst,
		gpio_in => MEM_out,
		gpio_out => gpio_out,
		wr => mem_wr and en_gpio, 
		KEY => KEY,
		SW => SW(7 downto 0),
		HEX0 => HEX0, 
		HEX1 => HEX1, 
		HEX2 => HEX2, 
		HEX3 => HEX3
		);
	MEM_IN <= gpio_out when mem_rd='1' and en_gpio='1' 
			else (others => 'Z');

	-- Timer #0
	System_Timer0: entity work.timer
	generic map(
		speed => 50   )	--speed=50MHz/50 = 1MHz
	port map(
		clk => clk,
		rst => rst,
		tin => MEM_OUT,
		tout => tout0,
		wr => mem_wr and en_time0
		);
	MEM_IN <= tout0 when mem_rd='1' and en_time0='1' 
			else (others => 'Z');       
	
	-- Timer #1
--	System_Timer1: entity work.timer
--	generic map(
--		speed => 50   )	--speed=50MHz/50 = 1MHz
--	port map(
--		clk => clk,
--		rst => rst,
--		tin => MEM_OUT,
--		tout => tout1,
--		wr => mem_wr and en_time1
--		);
--	MEM_IN <= tout1 when mem_rd='1' and en_time1='1' 
--			else (others => 'Z');   
	
	--Pseudo-random number generator based on LFSR 
	Pseudo_Random: entity work.random
	port map(
		clk => clk,
		rst => rst,
		rand => rand,
		rin => MEM_OUT,
		wr => mem_wr and en_rand,
		rd => mem_rd and en_rand
		);
	MEM_IN <= rand when mem_rd='1' and en_rand='1' else (others => 'Z');  

	--Terasic's IP for touch sensor interface
	Terasic_Touch_IP: i2c_touch_config port map(
		iclk => clock_50,
		iRSTN => key(0),
		oready => ready,
		int_n => MTL_TOUCH_INT_n,
		oreg_x1 => regx1,
		oreg_y1 => regy1,
		oreg_x2 => regx2,
		oreg_y2 => regy2,
		oreg_x3 => regx3,
		oreg_y3 => regy3,
		oreg_x4 => regx4,
		oreg_y4 => regy4,
		oreg_x5 => regx5,
		oreg_y5 => regy5,
		oreg_gesture => gesture,
		oreg_touch_count => touch_count,
		i2c_sclk => MTL_TOUCH_I2C_SCL,
		i2c_sdat =>	MTL_TOUCH_I2C_SDA
		);
	MEM_IN <= 	x"0000000" & "000" & ready when mem_rd='1' and en_tready='1' else 
					x"0000000" & touch_count when mem_rd='1' and en_tcount='1' else 
					x"000000" & gesture when mem_rd='1' and en_gesture='1' else 
					x"00000" & "00"  & regx1 when mem_rd='1' and en_x1 ='1' else  
					x"00000" & "000" & regy1 when mem_rd='1' and en_y1 ='1' else 
					x"00000" & "00"  & regx2 when mem_rd='1' and en_x2 ='1' else  
					x"00000" & "000" & regy2 when mem_rd='1' and en_y2 ='1' else 
					x"00000" & "00"  & regx3 when mem_rd='1' and en_x3 ='1' else  
					x"00000" & "000" & regy3 when mem_rd='1' and en_y3 ='1' else 
					x"00000" & "00"  & regx4 when mem_rd='1' and en_x4 ='1' else  
					x"00000" & "000" & regy4 when mem_rd='1' and en_y4 ='1' else 
					x"00000" & "00"  & regx5 when mem_rd='1' and en_x5 ='1' else  
					x"00000" & "000" & regy5 when mem_rd='1' and en_y5 ='1' else 
					(others => 'Z'); 
					
end DE1_SoC;
