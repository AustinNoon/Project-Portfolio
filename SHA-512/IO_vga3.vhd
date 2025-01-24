library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga3 is
   port(	clk		: in		std_logic;
			clock_50	: in		std_logic;
			rst		: in		std_logic;
			mem_adr	: in		std_logic_vector(31 downto 0);
			vga_out	: out		std_logic_vector(31 downto 0);
			vga_in	: in		std_logic_vector(31 downto 0);
			wr			: in		std_logic;
			en_vga	: in		std_logic;
			en_graph	: in		std_logic;
			vga_hs	: out		std_logic;
			vga_vs	: out		std_logic;
			r, g, b	: out		std_logic_vector(7 downto 0);
			pclk		: buffer	std_logic
		);
end;

architecture vga of vga3 is
   
   signal p1				:  std_logic_vector(18 downto 0);
	signal px				:	std_logic_vector(9 downto 0);
	signal py				:	std_logic_vector(8 downto 0);
   signal char_out		:  std_logic_vector(0 to 7);
   signal Q1, Q2, D1, D2:  std_logic_vector(7 downto 0);
   signal hsync, vsync	:  std_logic;
	signal blank			:  std_logic;
	signal h1, v1, b0, b1, b2	:  std_logic;
	signal pdata, text_out 	:  std_logic_vector(6 downto 0);
   signal tr, tg, tb, gr, gg, gb :  std_logic_vector(7 downto 0);
	
	component VGAPLL is
		port (
			refclk   : in  std_logic; 
			rst      : in  std_logic; 
			outclk_0 : out std_logic 
		);
	end component VGAPLL;

begin
	-----------------------------------------------------------
	--Graphic video memory for MTL2: 640x480 @ 8-bit color
	-----------------------------------------------------------
	VRAM_graphics_512x512: ENTITY work.vramg1 PORT MAP (
      clock_a => pclk,
		address_a => py & px(8 downto 0),
		data_a => x"00",
		wren_a => '0',
		q_a => Q1,
		clock_b => clk,
      address_b => mem_adr(18 downto 10) & mem_adr(8 downto 0),
      data_b => vga_in(7 downto 0),
      wren_b => wr and en_graph and not mem_adr(9),
		q_b => D1
	);
	VRAM_graphics_128x512: ENTITY work.vramg2 PORT MAP (
      clock_a => pclk,
		address_a => py & px(6 downto 0),
		data_a => x"00",
		wren_a => '0',
		q_a => Q2,
		clock_b => clk,
      address_b => mem_adr(18 downto 10) & mem_adr(6 downto 0),
      data_b => vga_in(7 downto 0),
      wren_b => wr and en_graph and mem_adr(9) and not mem_adr(8) and not mem_adr(7),
		q_b => D2
	);

	--Interface to CPU mem/io bus	
	vga_out <=	x"000000" & D1 when en_graph='1' and mem_adr(9) = '0' else
					x"000000" & D2 when en_graph='1' and mem_adr(9 downto 7) = "100" else
					(others => '0');
	--RGB video signal generations; merging text abd graphic video signals						  
	r <= 	x"00" when blank='0' else
			gr;
	g <= 	x"00" when blank='0' else
			gg;
	b <= 	x"00" when blank='0' else
			gb;
	-----------------------------------------------------------
	--VGA Timing circuit and signal delay buffers
	-----------------------------------------------------------
	process(pclk, rst) is
		variable hcount : integer range 0 to 1056;
		variable vcount : integer range 0 to 525;
	begin
		if(rst = '1') then
			hcount := 0;
			vcount := 0;
			hsync <= '1';
			vsync <= '1';
		elsif(pclk'event and pclk = '1') then
			if(hcount >= 0 and hcount <= 799 and vcount >= 0 and vcount <= 479) then
				px <=	std_logic_vector(to_unsigned(hcount, 10));
				py <= std_logic_vector(to_unsigned(vcount, 9));
				b0 <= '1';	-- don't blank the screen when in the zone
			else
				b0 <= '0';	-- blank the screen when not in range
			end if;
				
			if(hcount = 1055) then
				hcount := 0;
				if(vcount = 524) then	
					vcount := 0;
				else
					vcount := vcount + 1;
				end if;
			else
				hcount := hcount + 1;
			end if;
		
			if(hcount = 1010) then		hsync <= '0';
			elsif(hcount = 1050) then	hsync <= '1';
			end if;

			if(vcount = 502) then		vsync <= '0';
			elsif(vcount = 522) then	vsync <= '1';
			end if;
				
			h1 <= hsync;		-- hsync, vsync and blank signals
			v1 <= vsync;		-- are delayed by two clock cycles
			b1 <= b0;			-- to compensate for delays
			b2 <= b1;
			vga_hs <= h1;		
			vga_vs <= v1;
			blank <= b2;
			p1 <= py & px;
			--Generating RGB signals for the graphic video
			if(p1(9) = '0') then 
				gR <= Q1(7 downto 5) & Q1(7 downto 5) & Q1(7 downto 6); 
				gG <= Q1(4 downto 2) & Q1(4 downto 2) & Q1(4 downto 3); 
				gB <= Q1(1 downto 0) & Q1(1 downto 0) & Q1(1 downto 0) & Q1(1 downto 0);       
			elsif(p1(9 downto 7) = "100") then 
				gR <= Q2(7 downto 5) & Q2(7 downto 5) & Q2(7 downto 6); 
				gG <= Q2(4 downto 2) & Q2(4 downto 2) & Q2(4 downto 3); 
				gB <= Q2(1 downto 0) & Q2(1 downto 0) & Q2(1 downto 0) & Q2(1 downto 0); 
			else
				gR <= (7 downto 0 => '0');
				gG <= (7 downto 0 => '0');
				gB <= (7 downto 0 => '0');
			end if;
		end if;
	end process;
--------------------------------------------
  pll: vgapll port map(
      refclk => clock_50,
		rst => rst,
      outclk_0 => pclk		--MTL2 pixel clock = 33.3MHz
   ); 
end vga;
