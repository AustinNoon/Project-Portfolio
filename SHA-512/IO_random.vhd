library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity random is
	port(	clk 	: in 	std_logic;
			rst 	: in 	std_logic;
			rand	: buffer std_logic_vector(31 downto 0);
			rin	: in	std_logic_vector(31 downto 0);
			wr, rd	: in	std_logic --;
		);
end;

--architecture LFSR of random is
--begin
--	-----------------------------------------------------------
--	-- The 32-bit Psuedo-Random Number Generator based on LFSR
--	-- X^32 + X^31 + X^29 + X + 1
--	-----------------------------------------------------------
--	Psuedo_random: process(clk, rst)
--	begin
--		if(rst = '1') then			
--			rand <= X"01020034"; --hardware initial seed
--		elsif(clk'event AND clk = '1') then
--			--CPU write handle
--			if(wr='1') then rand <= rin;
--			elsif(rd='1') then
--				rand <= rand(30 downto 0) & 
--					(rand(31) xor rand(30) xor rand(28) xor rand (0));
--			end if;
--		end if;		
--	end process;
--end LFSR;
architecture WELLRNG512 of random is
	alias clock: std_logic is clk;
	alias reset: std_logic is rst;
	alias seed: std_logic_vector(31 downto 0) is rin;
	
	
	signal index: unsigned(3 downto 0);
	signal a, b, c, d: unsigned(31 downto 0);
	type state_array is array (0 to 15) of unsigned(31 downto 0);
		signal state: state_array;

	TYPE state_type IS (s1, s2, s3, s4, s5, s6, s7, s8, s8a, s9, s10);
	SIGNAL SV : state_type;
	
begin
	WELL_RNG_512: process(clock, reset)
	begin
		if(reset = '1') then			
				index <= "0000";
				state(0) <= to_unsigned(5489, 32); --default seed
				SV <= s1;
		elsif(clock'event AND clock = '1') then
			CASE SV IS
-----------------------------------------------------------------------------	
--		/* initialize state to random bits */ 
--		static unsigned long state[16]; 
-----------------------------------------------------------------------------	
--Use the modified MT initial seed to produce state[16]		
--    for (index=1; index<16; index++) {
--        state[index] = (1812433253UL * (state[index-1] ^ (state[index-1] >> 30)) + index); 
--    }
-----------------------------------------------------------------------------	
				WHEN s1 =>
					state(1) <= state(0) xor x"12345678";
					state(2) <= state(0) xor x"12340000";
					state(3) <= state(0) xor x"12345000";
					state(4) <= state(0) xor x"12345600";
					state(5) <= state(0) xor x"12345670";
					state(6) <= state(0) xor x"00005678";
					state(7) <= state(0) xor x"00045678";
					state(8) <= state(0) xor x"00345678";
					state(9) <= state(0) xor x"02345678";
					state(10) <= state(0) xor x"02345670";
					state(11) <= state(0) xor x"10345608";
					state(12) <= state(0) xor x"12045078";
					state(13) <= state(0) xor x"12300678";
					state(14) <= state(0) xor x"02345600";
					state(15) <= state(0) xor x"10345008";
					SV <= s2;
-----------------------------------------------------------------------------	
--		/* init should also reset this to 0 */ 
--		static unsigned int index = 0; 
--		/* return 32 bit random number */ 
--		unsigned long WELLRNG512(void) 
--		{ 
--		unsigned long a, b, c, d; 
--		a = state[index]; 
--		c = state[(index+13)&15]; 
--		b = a^c^(a<<16)^(c<<15); 
--		c = state[(index+9)&15]; 
--		c ^= (c>>11); 
--		a = state[index] = b^c; 
--		d = a^((a<<5)&0xDA442D24UL); 
--		index = (index + 15)&15; 
--		a = state[index]; 
--		state[index] = a^b^d^(a<<2)^(b<<18)^(c<<28); 
--		return state[index]; 
--		} 
-----------------------------------------------------------------------------	
				WHEN s2 =>
					--		a = state[index]; 
					--		c = state[(index+13)&15]; 
					a <= state(to_integer(index));
					c <= state(to_integer(index + 13));
					SV <= s3;
				WHEN s3 =>
					--		b = a^c^(a<<16)^(c<<15); 
					b <= a xor c xor shift_left(a, 16) xor shift_left(c, 15);
					SV <= s4;
				WHEN s4 =>
					--		c = state[(index+9)&15]; 
					c <= state(to_integer(index + 9));
					SV <= s5;
				WHEN s5 =>
					--		c ^= (c>>11); 
					c <= c xor shift_right(c, 11);
					SV <= s6;
				WHEN s6 =>
					--		a = state[index] = b^c; 
					a <= b xor c;
					state(to_integer(index)) <= b xor c;
					SV <= s7;
				WHEN s7 =>
					--		d = a^((a<<5)&0xDA442D24UL); 
					--		index = (index + 15)&15; 
					d <= a xor (shift_left(a, 5) and x"DA442D24");
					index <= index + 15;
					SV <= s8;
				WHEN s8 =>			
					--		a = state[index]; 
					a <= state(to_integer(index));
					SV <= s9;
				WHEN s9 =>
					--		state[index] = a^b^d^(a<<2)^(b<<18)^(c<<28); 
					state(to_integer(index)) <= a xor b xor d xor shift_left(a, 2) xor shift_left(b, 18) xor shift_left(c, 28);
					SV <= s10;
				WHEN s10 =>
					--		return state[index];
					rand <= std_logic_vector(state(to_integer(index)));
					if(wr = '1') then 
						state(0) <= unsigned(seed);
						index <= "0001";
						SV <= S1;
					elsif(rd = '1') then
						SV <= S2;
					end if;
	 			WHEN OTHERS =>
					SV <= s1;
			END CASE;
		end if;
	end process;
end WELLRNG512;


