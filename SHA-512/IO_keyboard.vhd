library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
	port(	clk		: in	std_logic;
			rst		: in	std_logic;
			kascii	: out	std_logic_vector(31 downto 0);
			cr_out	: out	std_logic_vector(31 downto 0);
			cr_in		: in	std_logic_vector(31 downto 0);
			wr			: in	std_logic;
			ps2clk	: in	std_logic;
			ps2data	: in	std_logic
		);
	end;

architecture keyboard of keyboard is
	signal rxbuf :  std_logic_vector(7 downto 0);
	signal scan_code :  std_logic_vector(7 downto 0);
	signal ascii :  std_logic_vector(15 downto 0);
	signal ps2clkd :  std_logic;
	signal rdy, ack, ext_ack, done  :  std_logic;

	-- Queue: 8x8
	type reg_file_type is array (0 to 7) of std_logic_vector(7 downto 0);
	signal Qascii : reg_file_type;
		
	-- SYMBOLIC ENCODED state machines: KEY, and QUE
	type State_type is (S1, S2, S3, S4, S5);
	signal KEY, QUE: State_type;

begin
	------------------------------------------------
	--Debounce circuit to filter PS2CLK
	------------------------------------------------
	clk_debounce : entity work.debounce generic map(
		CYCLES => 8   )
	port map(pin => ps2clk,
				output => ps2clkd,
				clock => clk
			);
	------------------------------------------------
	--Lookup table to convert scan_code to ASCII
	--This simplified version received only
	--seven bits of scna_code.
	--The output "ascii" is 16-bit. Upper byte for key
	--with shift and the lower byte for key with no shift.
	------------------------------------------------
	Scan_code_to_ASCII_table: entity work.KROM port map(
		clock => clk,
		address => scan_code(6 downto 0),
		q => ascii
	); 
	--Fill all 31 bits of control reg with 0's. 
	--For no INT version. 
	cr_out(31 downto 1) <= (others => '0');
	------------------------------------------------
	--CPU write operation to control register
	--Actually only bit 0 = ack, all others are ignored
	--For no INT version.
	------------------------------------------------
	control_write: process(rst, clk) is
	begin
		if(rst='1') then
			ext_ack<='0';
		elsif(clk'event and clk='1') then
			if(wr='1') then ext_ack <= cr_in(0);	end if;
		end if;
	end process control_write;
	-----------------------------------------------
	-- Internal Handshaking signal handling;
	-----------------------------------------------
	handshaking : process(rst, ack, done) is 
	begin
		if(rst='1' or ack = '1') then
			rdy <= '0';
		elsif(done'event and done = '1') then
			rdy <= '1';
		end if;
	end process handshaking;
	-----------------------------------------------
	-- The scan code to ASCII converter: KEY
	-- To Keyboard interface: rdy, ack, scan_code, ascii
	-- The Queue handling state machine: QUE
	-- cr_out(0) (ext. rdy), ext_ack, kascii
	-----------------------------------------------
	Queue_Handling: process (clk, rst)
		variable rec : integer range 0 to 7;
		variable xmt : integer range 0 to 7;
		variable break : Boolean;
		variable shift : Boolean;
	begin
		if rst='1' then
			KEY <= S1;	QUE <= S1;
			rec := 0;	xmt := 0;
			break := false;	shift := false;
			ack <= '0';	
			cr_out(0) <= '0'; --For no INT version
		elsif clk'event and clk = '1' then
			case KEY is
				when S1 =>
					if(rdy='1') then	KEY <= S2; end if;
				when S2 =>
					if(break) then		--break=true means prior byte=0xF0
						if(scan_code=x"12" or scan_code=x"59") then
							shift := false; 
						end if;	--left or right shift
						break := false; ack<= '1'; KEY <= S4;
					elsif(scan_code=x"F0") then
						break := true;  
						ack<= '1'; 
						KEY <= S4;
					elsif(scan_code=x"AA" or scan_code=x"E0") then
						ack <= '1';		--ignore self-test and multiple byte leader
						KEY <= S4;
					elsif(scan_code=x"12" or scan_code=x"59") then
						shift := true; 
						ack<= '1'; 
						KEY <= S4;
					else
						if(shift) then		--shift
							Qascii(rec) <= ascii(15 downto 8);
						else					--no shift
							Qascii(rec) <= ascii(7 downto 0);
						end if;
						KEY <= S3;
					end if;
				when S3 =>
					rec := rec + 1;	
					ack <= '1';	
					KEY <= S4;
				when S4 =>
					if(rdy='0') then 
						KEY<= S5; 
					end if;
				when S5 =>
					ack <= '0';	
					KEY <= S1;
				when others =>
					null;
			end case;
			----------------------------------------------
			--The 8x8 Queue handler
			--No warning or error signal when queue is overrun
			----------------------------------------------
			case QUE is
				when S1 =>
					if(rec /= xmt) then	
						QUE <= S2; 
					end if;
				when S2 =>
					kascii <= x"000000" & Qascii(xmt);
					cr_out(0) <= '1';		--external rdy=1
					QUE <= S3;
				when S3 =>
					if(ext_ack='1') then 
						QUE <= S4; 
					end if;
				when S4 =>
					cr_out(0) <= '0';		--external rdy=0
					if(ext_ack='0') then 
						QUE <= S5; 
					end if;
				when S5 =>
					xmt := xmt + 1;	
					QUE <= S1;
				when others =>
					null;
			end case;
		end if;
	end process;
	-----------------------------------------------
	-- The PS/2 receiver
	-----------------------------------------------
	receiver : process(ps2clkd, rst) is
      -- -1 => start bit, 0-7 => data bits, 
      -- 8 => parity bit, 9 => stop bit
      variable index : integer range -1 to 9;
	begin
      if(rst = '1') then
         index := -1;
         rxbuf <= (others => '0');
         scan_code <= (others => '0');
         done <= '0';
      elsif(ps2clkd'event and ps2clkd = '1') then
         if(index = -1) then 			-- idle condition
            if(ps2data = '0') then 	--start bit=0
               index := index + 1;
            end if;
            done <= '0';
         elsif(index >= 0 and index < 8) then
               rxbuf(index) <= ps2data;
               index := index + 1;
         elsif(index = 8) then
			index := index + 1;		--parity bit ignore
	    elsif(index = 9) then
			if(ps2data='1') then 	--stop bit=1
				done <= '1';
				scan_code <= rxbuf;	--update scan_code
				index := -1;
			end if;
         end if;
      end if;
	end process receiver;
end keyboard;
