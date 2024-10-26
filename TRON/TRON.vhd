library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------------------------
--entity
entity TRON is
	port(	CLOCK_50 : in std_logic;
			KEY 		: in std_logic_vector(3 downto 0);
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0);
			GPIO_1 	: out std_logic_vector(31 downto 0);
			MTL_TOUCH_INT_n : in std_logic;
			MTL_TOUCH_I2C_SCL : out std_logic;
			MTL_TOUCH_I2C_SDA : inout std_logic
			);
end entity;
------------------------------------------------------------------------------------------------------------------------------------------------------
--architecture----------------------------------------------------------------------------------------------------------------------------------------
architecture DE1_SoC_MTL2 of TRON is
	alias clock : std_logic is Clock_50;
	alias reset : std_logic is KEY(0);
	
	constant background : std_logic_vector(3 downto 0) := "0000"; --black background (done)
	constant border_color : std_logic_vector(3 downto 0) := "0001"; -- borders for game, depicted by orange "X's" (done)
------------------------------------------------------------------------------------------------------------------------------------------------------
	constant speed_sprite : std_logic_vector(3 downto 0) := "0010"; --sprite that appears for speed mode, stay puff marshmallow man (done)
	constant sprite_select: std_logic_vector(3 downto 0) := "0011"; --speed select sprite, differently colored stay puff marshmallow man (done) 
------------------------------------------------------------------------------------------------------------------------------------------------------
	constant ai_lives : std_logic_vector(3 downto 0)  := "0100"; -- sprite that represents the amount of AI lives, "blue hearts" (done)
	constant user_lives : std_logic_vector(3 downto 0) := "0101"; -- sprite that represents the amount of player lives, "red hearts" (done)
------------------------------------------------------------------------------------------------------------------------------------------------------
	constant trail_1 : std_logic_vector(3 downto 0) := "0110";-- sprite that represents the player's trail, "blue/red/purple plasma trail" (done)
	constant user_sprite : std_logic_vector(3 downto 0) := "0111";-- sprite that represents player one, "ghostbusters character" (done)
------------------------------------------------------------------------------------------------------------------------------------------------------
	constant trail_2 : std_logic_vector(3 downto 0) := "1000"; --sprite for AI character's trail, "slime" (done)
	constant AI_sprite : std_logic_vector(3 downto 0) := "1001"; --sprite that represents the AI character, "slimer" (done)
------------------------------------------------------------------------------------------------------------------------------------------------------
	constant game_over : std_logic_vector(3 downto 0) := "1110"; -- TODO "ghostbusters logo" (temped)
------------------------------------------------------------------------------------------------------------------------------------------------------
	constant AI_button : std_logic_vector(3 downto 0) := "1111"; --TODO, sprite that represents AI select button, "fire" (not done)(temped)
------------------------------------------------------------------------------------------------------------------------------------------------------
	--title (T,R,O,N)
	constant title_1 : std_logic_vector(3 downto 0) := "1010";--done
	constant title_2 : std_logic_vector(3 downto 0) := "1011";--done
	constant title_3 : std_logic_vector(3 downto 0) := "1100";--done
	constant title_4 : std_logic_vector(3 downto 0) := "1101";--done
------------------------------------------------------------------------------------------------------------------------------------------------------
	--50x30 screen dimensions
	constant screen_width:  integer := 50; --x 
	constant screen_height: integer := 30; --y
------------------------------------------------------------------------------------------------------------------------------------------------------	
	signal mem_in, mem_out, vdata: std_logic_vector(3 downto 0);
	signal mem_adr: std_logic_vector(10 downto 0);
	signal mem_wr: std_logic;
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal slow_clock: std_logic; 
------------------------------------------------------------------------------------------------------------------------------------------------------	
	signal old_x : unsigned(5 downto 0); --old x position
	signal old_y : unsigned(4 downto 0); --old y position
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal x,user_x, AI_x  : unsigned (5 downto 0); --positions in x direction
	signal y,user_y, AI_y  : unsigned (4 downto 0); --positions in y direction
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal go : Boolean; --moving
	signal collide : Boolean; --collision
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal top_val, bottom_val, left_val, right_val: unsigned(3 downto 0); --directional values 
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal X1: std_logic_vector(9 downto 0);
	signal Y1: std_logic_vector(8 downto 0);
	signal TX: unsigned(9 downto 0);
	signal TY: unsigned(8 downto 0);
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal speed, AI, old_speed, AI_old: unsigned(3 downto 0);
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal queue: std_logic_vector(1 downto 0);
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal move_clock: std_logic;
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal rand : std_logic_vector(3 downto 0); --random number generator
------------------------------------------------------------------------------------------------------------------------------------------------------
--	signal op_num : integer range 0 to 2;
--	type display is array (0 to 2) of std_logic_vector(15 downto 0);
--	constant OP: display :=
--            (x"5102", -- "StOP"
--             x"304C", -- "gO=L"
--             x"3046"  -- "gO=r"
--             );

-----states-------------------------------------------------------------------------------------------------------------------------------------------
	type state is (clean0, clean1, clean2, clean3, sync1, sync2,
						perase1, perase2, pupdate, pdraw1, pdraw2,
                  update1, update2, update3, update4, update5, update6, update7,    
                  update8, update9, update10, update11, erase1, erase2,
                  update, sdraw0, sdraw1, sdraw2, sdraw3, adraw0, adraw1, adraw2, adraw3, 
                  draw1, draw2, 
                  AIupdate1, AIupdate2, AIupdate3, AIupdate4, AIupdate5, AIupdate6, AIupdate7, AIupdate8,
						AIupdate9, AIupdate10,
                  AIerase1,AIerase2,AIbupdate, AIdraw1, AIdraw2,AIDir,
                  endround,endgame,endgame2,endgame3, wait4gesture, gameover);
						
	signal SV : state;
------------------------------------------------------------------------------------------------------------------------------------------------------	
	type direction is (move_up, move_down, move_left, move_right);
	signal dir_1, dir_2: direction;
------------------------------------------------------------------------------------------------------------------------------------------------------
	function AI_func (AI                                    : unsigned;
							rand0                                 : std_logic_vector;
							dir                                   : direction;
							up_val, down_val, left_val, right_val : unsigned)
	return direction is
	begin
		case AI is
			when x"0" => --AI 0
				return move_left;
				
			when x"1" => --AI1
				if(rand0 = "00") then
					return move_left;
				elsif(rand0 = "01") then
					return move_right;
				elsif(rand0 = "10") then
					return move_up;
				else
					return move_down;
				end if;
				
			
			when x"2" => --AI 2
				if (randO = "00") then 
                    if (up_val = "00000") then --check for background, if background then move into background
                        return move_up;
                    elsif (left_val = "00000") then 
                        return move_left;
                    elsif (down_val = "00000") then
                        return mopve_down;
                    elsif(right_val = "00000") then
                        return move_right;
							elsif(up_val = "00110") then --check for player 1 trail, if player1 trail then move opposite of detected sprite
								return move_down;
							elsif(left_val = "00110") then
								return move_right;
							elsif(down_val = "00110") then
								return move_up;
							else 
								return move_left;
                    end if;
                elsif (randO = "01") then 
                    if (down_val = "00000") then 
                        return move_down;
                    elsif (left_val = "00000") then
                        return move_left;
                    elsif (up_val = "00000") then
                        return move_up;
                    elsif(right_val = "00000") then
                        return move_right;
						  elsif(down_val = "00110") then
								return move_up;
						  elsif(left_val = "00110") then
								return move_right;
						  elsif(up_val = "00110") then
								return move_down;
						  else 
								return move_left;
                    end if;
                elsif (randO = "10") then 
                    if (left_val = "00000") then 
                        return move_left;
                    elsif (up_val = "00000") then
                        return move_up;
                    elsif (down_val = "00000") then
                        return move_down;
                    elsif(right_val = "00000") then
                        return move_right;
						  elsif(left_val = "00110") then
								return move_right;
						  elsif(up_val = "00110") then
								return move_down;
						  elsif(down_val = "00110") then
								return move_up;
						  else 
								return move_left;
                    end if;
                else
                    if (right_val = "00000") then 
                        return move_right;
                    elsif (left_val = "00000") then
                        return move_left;
                    elsif (down_val = "00000") then
                        return move_down;
                    elsif(up_val = "00000") then
                        return move_up;
						  elsif(right_val = "00110") then
								return move_left;
						  elsif(left_val = "00110") then
								return move_right;
						  elsif(down_val = "00110") then
								return move_up;
						  else
								return move_down;
                    end if;
                end if;
					 
            when x"3" => -- AI 3
                
						if(right_val = "00000" or right_val = "00110") then
							return move_right;
						elsif(down_val = "00000" or down_val = "00110") then
							return move_down;
						elsif(up_val = "00000" or up_val = "00110") then
							return move_up;
						elsif(left_val = "00000" or left_val = "00110") then
							return move_left;
						else
							return move_up;
						end if;
					when others =>
							return move_left;
            end case;
    end function;    
					
------------------------------------------------------------------------------------------------------------------------------------------------------
	signal VGA_R, VGA_G, VGA_B : std_logic_vector(7 downto 0); --vga RGB
------------------------------------------------------------------------------------------------------------------------------------------------------
	alias  VGA_HS : std_logic is GPIO_1(30); --HSD
	alias  VGA_VS : std_logic is GPIO_1(31); --VSD
	alias  DCLK : std_logic is GPIO_1(1);	--pixel clock = 33.3MHz
------------------------------------------------------------------------------------------------------------------------------------------------------
	TYPE Touch_state IS (wait_for_ready, get_code, examine);
	SIGNAL TS : Touch_state;	
	signal gesture : std_logic_vector(7 downto 0);
	signal ready: std_logic;
------------------------------------------------------------------------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------------------------------------------------------------------------

begin
	GPIO_1(10 downto 3) <= VGA_R;
	GPIO_1(21) <= VGA_G(7);
	GPIO_1(19 downto 18) <= VGA_G(6 downto 5);
	GPIO_1(15 downto 11) <= VGA_G(4 downto 0);
	GPIO_1(28 downto 22) <= VGA_B(7 downto 1);
	GPIO_1(20) <= VGA_B(0);
------------------------------------------------------------------------------------------------------------------------------------------------------	
  vga_interface : entity work.vga_sprite2 port map(
      clock => clock,	
      reset => not reset,	
      mem_adr => mem_adr,
      mem_out => mem_out,
      mem_in => mem_in,
      mem_wr => mem_wr,   
      vga_hs => vga_hs,
      vga_vs => vga_vs,
		pclock => DCLK,
      r => vga_r,
      g => vga_g,
      b => vga_b
   );
   mem_adr <= std_logic_vector(y) & std_logic_vector(x);
-----------------------------------------------------------------------------------------------------------------------------------------------------
	Terasic_Touch_IP: i2c_touch_config port map(
		iclk => clock_50,
		iRSTN => key(0),
		int_n => MTL_TOUCH_INT_n,
		oready => ready,
		oreg_gesture => gesture,
		i2c_sclk => MTL_TOUCH_I2C_SCL,
		i2c_sdat =>	MTL_TOUCH_I2C_SDA,
		oREG_X1 => X1,
		oREG_Y1 => Y1
	);
-----------------------------------------------------------------------------------------------------------------------------------------------------
	HEX0 <= "1111111";
	HEX1 <= "1111111";
	HEX2 <= "1111111";
	HEX3 <= "1111111";
	HEX4 <= "1111111";
	HEX5 <= "1111111";
	LEDR <= "0000000000";
-----------------------------------------------------------------------------------------------------------------------------------------------------
	random : process(clock, reset)--done
	begin
		if(reset = "0") then
			rand <= x"DEADDEAD";
		elsif(clock'event and clock = "1") then
			rand <= rand(30 downto 0) & (rand(31) xor rand(24) xor rand(27) xor rand(0));
		end if;
	end process;
-----------------------------------------------------------------------------------------------------------------------------------------------------
	Touch_gesture_handler: process(CLOCK, reset)--done
   begin
		if(reset = '0') then	
			go <= false;		
			speed <= x"8";
			AI <= x"0";
			TS <= wait_for_ready;
--			OP_num <= 0;
		elsif(clock'event AND clock = '1') then
			CASE TS IS
				WHEN wait_for_ready =>
					if(ready='1') then
						TS <= get_code;
					end if;
				WHEN get_code =>
						TX <= unsigned(X1); -- convert x1 and y1 to unsigned
						TY <= unsigned(Y1);
						TS <= examine;
				WHEN examine =>	
					if(gesture = x"10") then	--Move Up
						go <= true;
						dir <= move_up;
					elsif(gesture = x"18") then	--Move Down
						go <= false;
						dir <= move_down;
					elsif(gesture = x"14") then	--Move Left
						go <= true;
						dir <= move_left;		
					elsif(gesture = x"1C") then	--Move Right
						go <= true;
						dir <= move_right;
					elsif(gesture = x"48" or x"49") then
						go <= false;					
					end if;
					
                    if(TX >= 0 and TX <= 45 and TY >= 0 and TY <= 80) then speed <= x"8";
                        elsif(TX >= 0 and TX <= 45 and TY >= 81 and TY <= 144) then speed <= x"4";
                            elsif(TX >= 0 and TX <= 45 and TY >= 145 and TY <= 208) then speed <= x"2";
                                elsif(TX >= 0 and TX <= 45 and TY >= 209 and TY <= 287) then speed <= x"1";
                    end if;
                    
                    if(TX >= 760 and TX <= 791 and TY >= 0 and TY <= 80) then AI <= x"0";
                        elsif(TX >= 760 and TX <= 791 and TY >= 81 and TY <= 144) then AI <= x"1";
                            elsif(TX >= 760 and TX <= 791 and TY >= 145 and TY <= 208) then AI <= x"2";
                                elsif(TX >= 760 and TX <= 791 and TY >= 209 and TY <= 287) then AI <= x"3";
                    end if;
					TS <= wait_for_ready;
				WHEN OTHERS =>
					TS <= wait_for_ready;
			END CASE;
		end if;		
   end process;
-----------------------------------------------------------------------------------------------------------------------------------------------------
   display_clock: process(clock, reset) --done
		variable loopcount : integer range 0 to 500000;
		variable switchcount : integer range 0 to 15;
   begin
		if(reset = '0') then	
			loopcount := 0;
			switchcount := 0;
			slow_clock <= '0';
		elsif(clock'event AND clock = '1') then
			if(loopcount >= 199999) then
				loopcount := 0;
				if(switchcount >= speed) then
					slow_clock <= not slow_clock;
					switchcount := 0;
				else
					switchcount := switchcount + 1;
				end if;
			else
				loopcount := loopcount + 1;
			end if;
		end if;		
		end process;
------------------------------------------------------------------------------------------------------------------------------------------------------
		main: process(clock, reset) --almost done
		
		variable userLives : integer range 0 to 3; --user lives 
		variable aiLives   : integer range 0 to 3; --ai lives 
		variable counter   : integer range 0 to 4; -- counter
		variable collision : std_logic;
		begin
		
		if(reset = '0') then			-- if reset then...
			x <= "000000";-- x = 0
			y <= "00000"; -- y = 0
			mem_wr <= '0';--init VRAM 
			SV <= clean0;
			user_x <= to_unsigned(12,6); --starting position for user
			user_y <= to_unsigned(14,5); --starting position for user
			ai_x <= to_unsigned((screen_width - 12),6); --ai starting position
			ai_y <= to_unsigned(14,5); -- ai starting position
			collision := '0'; --collision set to false initially
			userLives := 3;-- init user lives 
			aiLives := 3; --init ai lives 
			old_speed <= x"0";
			AI_old <= x"5";
			
			
		elsif(clock'event AND clock = '1') then
			case SV is
				when gameover => -- redraw everything after game ends
					mem_wr <= '0'; -- re init vram
					x <= "000000"; -- x = 0 & y = 0
					y <= "00000";
					SV <= clean0; --next state <= clean0
					user_x <= to_unsigned(12,6); --init user & ai positions
					user_y <= to_unsigned(14,5);
					ai_x <= to_unsigned((screen_width - 12), 6);
					ai_y <= to_unsigned(14,5);
					collision := '0'; --collision = false
					userLives := 3; --re init user & ai lives
					aiLives := 3;
-----------------------------------------------------------------------------------------------------------------------------------------------------				
				when clean0 =>	--TODO 
					mem_wr <= '1';
						if((x = 3 and 0 < y and y < screen_height - 1) or (x = 46 and 0 < y and y < screen_height - 1) 
							or (y = 1 and 3 < x and x < screen_width - 4) or (y = 28 and 3 < x and x < screen_width - 4)) then
								mem_in <= border_color; --border color
						elsif(x = 3 and y = 0 and lives >= 1) then
							mem_in <= l_color;
						elsif(x = 4 and y = 0 and lives >= 2) then
							mem_in <= l_color;
						elsif(x = 5 and y = 0 and lives = 3) then
							mem_in <= l_color;
						elsif(x = 1 and (y = 5 or y = 10 or y = 15 or y = 20)) then
							mem_in <= speed_sprite;
						elsif(x = 1 and y = 5) then
							mem_in <= speed_select;
						else 
							mem_in <= background;
						end if;
					SV <= clean1;
-----------------------------------------------------------------------------------------------------------------------------------------------------	
				when clean1 => --done
					mem_wr <= '0'; --disable write enable
					x <= x + 1;
					SV <= clean2;
-----------------------------------------------------------------------------------------------------------------------------------------------------						
				when clean2 => --done
					if(x > screen_width - 1) then 
						x<= "000000";
						y <= y + 1;
						SV <= clean3;
					else
						SV <= clean0;
					end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------						
				when clean3 => --done
					if(y > screen_height - 1) then
						SV <= sync1;
					else
						SV <= clean0;
					end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------	
				when sync1 =>--done	
					queue <= queue(0) & slow_clock;
					SV <= sync2;
-----------------------------------------------------------------------------------------------------------------------------------------------------						
				when sync2 =>-- done
						if(speed /= old_speed) then 
							old_speed <= speed;
							SV <= sdraw0;
						elsif(AI /= AI_old) then
							AI_old <= AI;
							SV <= adraw0;
						elsif(queue = "01" and go) then
							SV <= update1;
						else 
							SV <= sync1;
						end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------	
				when sdraw0 => --done
					count := 0;
					old_x <= x;
					old_y <= y;
					SV <= sdraw1;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when sdraw1 => --TODO (dot?)
					case count is
						when 0 =>
							x <= to_unsigned(1 ,6);
							y <= to_unsigned(3,5);
--------------------------------------------------------------------------------------------------------------------------------------------------
				when sdraw2=> --done
					mem_wr <= '0';
					count := count + 1;
					SV <= sdraw3;
---------------------------------------------------------------------------------------------------------------------------------------------------
				when sdraw3=> --done
					if(count <= 3) then
						SV <= sdraw1;
					else
						x <= old_x;
						y <= old_y;
						SV <= sync2;
					end if;
---------------------------------------------------------------------------------------------------------------------------------------------------
				when adraw0 => --done
					count := 0;
					old_x <= x;
					old_y <= y;
					SV <= adraw1;
---------------------------------------------------------------------------------------------------------------------------------------------------
				when adraw1 => --TODO (dot?)
					
---------------------------------------------------------------------------------------------------------------------------------------------------
				when adraw2 => --done
					mem_wr <= '0';
					count := count + 1;
					SV <= adraw3;
---------------------------------------------------------------------------------------------------------------------------------------------------
				when adraw3 => --done 
					if(count <= 3) then
						SV <= adraw1;
					else 
						x <= old_x;
						y <= old_y;
						SV <= sync2;
					end if;				
---------------------------------------------------------------------------------------------------------------------------------------------------					
				when update1 => --done
					x <= user_x;
					y <= user_y - 1;
					mem_wr <= '0';
					SV <= update2;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update2 => --done
					SV <= update3;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update3 => --done
					top_val <= unsigned(mem_out);
					y <= y + 2;
					SV <= update4;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update4 =>  --done
					SV <= update5;
---------------------------------------------------------------------------------------------------------------------------------------------------			
				when update5 => --done
					bottom_val <= unsigned(mem_out);
					y <= y - 1; 
					x <= x - 1;
					SV <= update6;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update6 => --done
					SV <= update7;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update7 => --done
					left_val <= unsigned(mem_out);
					x <= x + 2;
					SV <= update8;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update8 => --done
					SV <= update9;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update9 => --done
					right_val <= unsigned(mem_out);
					x <= x - 1;
					SV <= update10;
---------------------------------------------------------------------------------------------------------------------------------------------------				
				when update10 => --done
					case dir1 is
						when move_up =>
							if(top_val /= unsigned(background)) then
								userLives := '1';
								SV <= draw1;
							else 
								SV <= erase1;
							end if;
						when move_down =>
							if(bottom_val/= unsigned(background)) then
								userLives := userLives - 1;
								collision := '1';
								SV <= draw1;
							else
								SV <= erase1;
							end if;
						when move_left =>
							if(left_val /= unsigned(background)) then
								userLives := userLives - 1;
								collision := '1';
								SV <= draw1;
							else 
								SV <= erase1;
							end if;
						when move_right =>
							if(right_val /= unsigned(background)) then
								userLives := userLives - 1;
								collision := '1';
								SV <= draw1;
							else
								SV <= erase1;
							end if;
						when others =>
							SV <= erase1;
					end case;
					SV <= erase1;
----------------------------------------------------------------------------------------------------------------------------------------------------					
				when erase1 => --done 
					x <= user_x;
					y <= user_y;
					mem_wr <= '1';
					mem_in <= trail_1;
					SV <= erase2;
----------------------------------------------------------------------------------------------------------------------------------------------------								
				when erase2 => --done
					mem_wr <= '0';
					SV <= bupdate;
----------------------------------------------------------------------------------------------------------------------------------------------------				
				when bupdate => --done 
					case dir1 is
						when move_up =>
							user_y <= user_y - 1;
						when move_down =>
							user_y <= user_y + 1;
						when move_left =>
							user_x <= user_x - 1;
						when move_right =>
							user_x <= user_x + 1;
					end case;
					SV <= draw1;
----------------------------------------------------------------------------------------------------------------------------------------------------
				when draw1 => --done
					mem_wr <= '1';
						if(collision = '1') then
							if(userLives < 1) then
								x <= to_unsigned(4,6);
								y <= to_unsigned(0,5);
								mem_in <= background;
							elsif(userLives < 2) then 
								x <= to_unsigned(8,6);
								y <= to_unsigned(0,5);
							elsif(userLives < 3) then
								x <= to_unsigned(12,6);
								y <= to_unsigned(0,5);
								mem_in <= background;
							end if;
						collision := 0;
						SV <= endround;
						else
							x <= user_x;
							y <= user_y;
							SV <= draw1;
							mem_in <= user_sprite;
							SV <= draw2;
						end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------
				when draw2 => --done
					mem_wr <= '0';
					SV <= AIupdate1;
-----------------------------------------------------------------------------------------------------------------------------------------------------				
				when AIupdate1 => --done
					x <= AI_x;
					y <= AI_y - 1;
					SV <= AIupdate2;
-----------------------------------------------------------------------------------------------------------------------------------------------------
				when AIupdate2 => --done
					SV <= AIupdate3;
-----------------------------------------------------------------------------------------------------------------------------------------------------
				when AIupdate3 => --done
					top_val <= unsigned(mem_out);
					y <= y + 2;
					SV <= AIupdate4;
-----------------------------------------------------------------------------------------------------------------------------------------------------
				when AIupdate4 => --done
					SV <= AIupdate5;
-----------------------------------------------------------------------------------------------------------------------------------------------------				
				when AIupdate5 => --done
					bottom_val <= unsigned(mem_out);
					y <= y - 1;
					x <= x - 1;
					SV <= AIupdate6;
-----------------------------------------------------------------------------------------------------------------------------------------------------			
				when AIupdate6 => -- done
					SV <= AIupdate7;
-----------------------------------------------------------------------------------------------------------------------------------------------------				
				when AIupdate7 => --done
					left_val <= unsigned(mem_out);
					x <= x + 2;
					SV <= AIupdate8;
-----------------------------------------------------------------------------------------------------------------------------------------------------				
				when AIupdate8 => --done
					SV <= AIupdate9;
-----------------------------------------------------------------------------------------------------------------------------------------------------				
				when AIupdate9 => --done
					right_val <= unsigned(mem_out);
					SV <= AIdirectiondecision;
					x <= x - 1;
-----------------------------------------------------------------------------------------------------------------------------------------------------				
				when AIupdate10 => --done 
					case dir2 is 
						when move_up =>
							if(top_val /= unsigned(background)) then
								aiLives := aiLives - 1;
								collision := '1';
								SV <= AIdraw1;
							else
								SV <= AIerase1;
							end if;
						when move_down =>
							if(bottom_val /= unsigned(background)) then
								aiLives := aiLives - 1;
								collision := '1';
								SV <= AIdraw1;
							else 
								SV <= AIerase1;
							end if;
						when move_left =>
							if(left_val /= unsigned(background)) then
								aiLives := aiLives - 1;
								collision := '1';
								SV <= AIdraw1;
							else 
								SV <= AIerase1;
							end if;
						when move_right =>
							if(right_val /= unsigned(background)) then
								aiLives := aiLives - 1;
								collision := '1';
								SV <= AIdraw1;
							else 
								SV <= AIerase2;
							end if;
						when others =>
							SV <= AIerase1;
					end case;
					SV <= AIerase1;
-----------------------------------------------------------------------------------------------------------------------------------------------------					
				when AIerase1 => --done
					x <= AI_x;
					y <= AI_y;
					mem_wr <= '1';
					mem_in <= trail_2;
					SV <= AIerase2;
-----------------------------------------------------------------------------------------------------------------------------------------------------
				when AIerase2 => --done
					mem_wr <= '0';
					SV <= AIbupdate;
-----------------------------------------------------------------------------------------------------------------------------------------------------	
				when AIbupdate => --done
					case dir2 is
						when move_up =>
							AI_y <= AI_y - 1;
						when move_down =>
							AI_y <= AI_y + 1;
						when move_left =>
							AI_x <= AI_x - 1;
						when move_right =>
							AI_x <= AI_x + 1;
					end case;
					SV <= AIdraw1;
-----------------------------------------------------------------------------------------------------------------------------------------------------					
				when AIdraw1 => --done
					mem_wr <= '1';
						if(collision = '1') then 
							if(aiLives < 1) then 
                            x<=to_unsigned(screen_width-4,6); 
                            y<=to_unsigned(0,5);
                            mem_in<=background;
                        elsif(aiLives < 2) then 
                            x<=to_unsigned(screen_width-8,6); 
                            y<=to_unsigned(0,5);
                            mem_in<=background;
                        elsif(aiLives < 3) then 
                            x<=to_unsigned(screen_width-12,6);
                            y<=to_unsigned(0,5);
                            mem_in<=background; 
                        end if;
                        collision := '0';
                        SV<=endround;
                    else 
                        x <= AI_x;
                        y <= AI_y;                   
                        mem_in <= AI_sprite;
                        SV <= AIdraw2;
                    end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------					
				when AIdraw2 => --done
					mem_wr <= '0';
					SV <= sync1;
-----------------------------------------------------------------------------------------------------------------------------------------------------						
				when AIDir => --done
					dir2 <= AI_func(AI, rand(25 downto 24), dir2, top_val, bottom_val, left_val, right_val);
					SV <= AIupdate10;
-----------------------------------------------------------------------------------------------------------------------------------------------------						
				when endround => --done
					mem_wr <= '1';
					x <= "000000";
					y <= "00000";
					user_x <= to_unsigned(12,6);
					user_y <= to_unsigned(14,5);
					AI_x <= to_unsigned((screen_width - 12), 6);
					AI_y <= to_unsigned(14,5);
					if(userLives = 0 or aiLives = 0) then
						SV <= endgame;
					else
						SV <= wait4gesture;
					end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------						
				when wait4gesture => --done 
					mem_wr <= '0';
					if(KEY(3) = '0' or gesture = x"48" or gesture = x"49") then
						if(userLives = 0 or aiLives = 0) then
							SV <= gameover;
						else 
							SV <= clean0;
						end if;
					else 
						if(userLives = 0 or aiLives = 0) then
							SV <= endgame;
						else 
							SV <= endround;
						end if;
					end if;
-----------------------------------------------------------------------------------------------------------------------------------------------------	
				when endgame => --done
					mem_wr <= '1';
					x <= to_unsigned(25,6);
					y <= to_unsigned(15,5);
					mem_in <= game_over;
					SV <= wait4gesture;
-----------------------------------------------------------------------------------------------------------------------------------------------------	
				when others => --done
					SV <= clean0;
				
			end case;
		end if;
	end process;
end architecture;
-----------------------------------------------------------------------------------------------------------------------------------------------------									
					
					
					
					
				
				
							
					
						
					
				
