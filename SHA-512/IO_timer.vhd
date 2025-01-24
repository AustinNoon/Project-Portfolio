library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity timer is
   generic(
      speed: natural := 50		--micro-second (1MHz) timer
   );
   port(
		clk	:  in    std_logic;
		rst	:  in    std_logic;
		tin	:  in    std_logic_vector(31 downto 0);
		tout	:  out   std_logic_vector(31 downto 0);
		wr		:  in    std_logic
		);
	end;

architecture repeat of timer is
	signal count :  unsigned(31 downto 0);
begin
	tout <= std_logic_vector(count);		--allow program to read the "count"
	
	slow_clock_generator: process(clk, rst)
		variable loopcount : integer range 0 to speed;
	begin
		if(rst = '1') then
			count <= X"00000000";	
			loopcount := 0;
		elsif(clk'event AND clk = '1') then
			--CPU write handle
			if(wr='1') then count <= unsigned(tin);	end if;
			--Generating internal clock according to speed parameter
			if(loopcount = speed - 1) then
				loopcount := 0;
				count <= count + 1;
			else
				loopcount := loopcount + 1;
			end if;
		end if;
	end process;  
end repeat;
