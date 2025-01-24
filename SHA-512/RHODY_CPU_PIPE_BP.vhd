library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Rhody_CPU_pipe_BP is 
  port (	clk		: in	std_logic;
			rst		: in	std_logic;
			MEM_ADR	: out	std_logic_vector(31 downto 0);
			MEM_IN	: in  std_logic_vector(31 downto 0);
			MEM_OUT	: out std_logic_vector(31 downto 0);
	      mem_wr	: out std_logic;
			mem_rd	: out std_logic;
			key 		: in	std_logic;
			LEDR 		: out std_logic_vector(3 downto 0)
		);
end;

architecture Structural of Rhody_CPU_pipe_BP is
-- state machine: CPU_state
type State_type is (S1, S2);
signal update, stage1, stage2, stage3, stage4: State_type;
-- Register File: 8x32
type reg_file_type is array (0 to 7) of std_logic_vector(31 downto 0);
signal register_file : reg_file_type;
signal Bit64 : std_logic_vector(63 downto 0);
-- Internal registers
signal MDR_in, MDR_out, MAR, PSW: std_logic_vector(31 downto 0);
signal PC, SP: unsigned(31 downto 0);  --unsigned for arithemtic operations
-- Internal control signals
signal operand0, operand1, ALU_out : std_logic_vector(31 downto 0);
signal carry, overflow, zero : std_logic;	
-- Pipeline Istruction registers
signal stall: Boolean;
signal IR2, IR3, IR4: std_logic_vector(31 downto 0);
--working variables
signal wva, wvb, wvc, wvd, wve, wvf, wvg, wvh : std_logic_vector(63 downto 0);
--Rhody Instruction Format
alias Opcode2: std_logic_vector(5 downto 0) is IR2(31 downto 26);
alias Opcode3: std_logic_vector(5 downto 0) is IR3(31 downto 26);
alias Opcode4: std_logic_vector(5 downto 0) is IR4(31 downto 26);
alias	RX2	: std_logic_vector(2 downto 0) is IR2(25 downto 23); 
alias	RX3	: std_logic_vector(2 downto 0) is IR3(25 downto 23); 
alias	RX4	: std_logic_vector(2 downto 0) is IR4(25 downto 23);
alias	RY2	: std_logic_vector(2 downto 0) is IR2(22 downto 20);
alias	RY3	: std_logic_vector(2 downto 0) is IR3(22 downto 20);
alias	RY4	: std_logic_vector(2 downto 0) is IR4(22 downto 20);
alias RZ2	: std_logic_vector(2 downto 0) is IR2(19 downto 17);
alias I2		: std_logic_vector(15 downto 0) is IR2(15 downto 0);
alias M2		: std_logic_vector(19 downto 0) is IR2(19 downto 0);
alias M3		: std_logic_vector(19 downto 0) is IR3(19 downto 0);
--Condition Codes
alias Z: std_logic is PSW(0);
alias C: std_logic is PSW(1);
alias S: std_logic is PSW(2);
alias V: std_logic is PSW(3);
--Instruction Opcodes can take some of these out to free up room for more opcodes
constant NOP  : std_logic_vector(5 downto 0) := "000000";
constant LDM  : std_logic_vector(5 downto 0) := "000100";
constant LDR  : std_logic_vector(5 downto 0) := "000101";
constant LDH  : std_logic_vector(5 downto 0) := "001000";
constant LDL  : std_logic_vector(5 downto 0) := "001001";
constant LDI  : std_logic_vector(5 downto 0) := "001010";
constant MOV  : std_logic_vector(5 downto 0) := "001011";
constant STM  : std_logic_vector(5 downto 0) := "001100";
constant STR  : std_logic_vector(5 downto 0) := "001101";
constant ADD  : std_logic_vector(5 downto 0) := "010000";
constant ADI  : std_logic_vector(5 downto 0) := "010001";
constant SUB  : std_logic_vector(5 downto 0) := "010010";
constant MUL  : std_logic_vector(5 downto 0) := "010011";
constant IAND : std_logic_vector(5 downto 0) := "010100"; --avoid keyword
constant IOR  : std_logic_vector(5 downto 0) := "010101"; --avoid keyword
constant IXOR : std_logic_vector(5 downto 0) := "010110"; --avoid keyword
constant IROR : std_logic_vector(5 downto 0) := "010111"; --avoid keyword
constant CMP  : std_logic_vector(5 downto 0) := "101010";
constant CMPI : std_logic_vector(5 downto 0) := "110010";
constant JNZ  : std_logic_vector(5 downto 0) := "100000";
constant JNS  : std_logic_vector(5 downto 0) := "100001";
constant JNC  : std_logic_vector(5 downto 0) := "100011";
constant JNV  : std_logic_vector(5 downto 0) := "100010";
constant JZ   : std_logic_vector(5 downto 0) := "100100";
constant JS   : std_logic_vector(5 downto 0) := "100101";
constant JC   : std_logic_vector(5 downto 0) := "100111";
constant JV   : std_logic_vector(5 downto 0) := "100110";
constant JMP  : std_logic_vector(5 downto 0) := "101000";
constant CALL : std_logic_vector(5 downto 0) := "110000";
constant RET  : std_logic_vector(5 downto 0) := "110100";
constant RETI : std_logic_vector(5 downto 0) := "110101";
constant PUSH : std_logic_vector(5 downto 0) := "111000";
constant POP  : std_logic_vector(5 downto 0) := "111001";
constant SYS  : std_logic_vector(5 downto 0) := "111100";
constant LDIX : std_logic_vector(5 downto 0) := "000110";
constant STIX : std_logic_vector(5 downto 0) := "000111";
constant MTX  : std_logic_vector(5 downto 0) := "011010";
constant CH   : std_logic_vector(5 downto 0) := "101001";
constant MAJ  : std_logic_vector(5 downto 0) := "101011";
constant SUM0 : std_logic_vector(5 downto 0) := "011011";
constant SUM1 : std_logic_vector(5 downto 0) := "111101";
constant SIG0 : std_logic_vector(5 downto 0) := "111110";
constant SIG1 : std_logic_vector(5 downto 0) := "111111";
constant ADD64: std_logic_vector(5 downto 0) :=	"000010";
constant SCH3 : std_logic_vector(5 downto 0) := "011000"; --sch3 loop as instruction
constant SCH4 : std_logic_vector(5 downto 0) := "011001"; --sch4 loop as instruction
constant SCH50: std_logic_vector(5 downto 0) := "011100"; --sch5 part 1 
constant SCH51: std_logic_vector(5 downto 0) := "011101"; --sch5 part 2
constant S64  : std_logic_vector(5 downto 0) := "000011"; --64 bit store to memory instruction
--declare Hinit values for sch3 instruction
constant Hinit0 : std_logic_vector(63 downto 0) := x"6a09e667f3bcc908"; -- 64 bit hex number from sha512 asm
constant Hinit1 : std_logic_vector(63 downto 0) := x"bb67ae8584caa73b";
constant Hinit2 : std_logic_vector(63 downto 0) := x"3c6ef372fe94f82b";
constant Hinit3 : std_logic_vector(63 downto 0) := x"a54ff53a5f1d36f1";
constant Hinit4 : std_logic_vector(63 downto 0) := x"510e527fade682d1";
constant Hinit5 : std_logic_vector(63 downto 0) := x"9b05688c2b3e6c1f";
constant Hinit6 : std_logic_vector(63 downto 0) := x"1f83d9abfb41bd6b";
constant Hinit7 : std_logic_vector(63 downto 0) := x"5be0cd19137e2179";

begin
--Display condition code on LEDR for debugging purpose
LEDR(3) <= Z when key='0' else '0';
LEDR(2) <= C when key='0' else '0';
LEDR(1) <= S when key='0' else '0';
LEDR(0) <= V when key='0' else '0';
--CPU bus interface
MEM_OUT <= MDR_out;	--Outgoing data bus
MEM_ADR <= MAR;		--Address bus
--One clock cycle delay in obtaining CPU_state, e.g. S1->S2
mem_rd	<=	'1' when ((Opcode2=LDM or Opcode2=LDR or Opcode2=LDIX) and stage2=S2) else
				'1' when (stage1=S2 and not stall) else
				'1' when ((Opcode2=POP or Opcode2=RET) and stage2=S2) else
				'1' when (Opcode2=RETI and stage2=S2) else
				'1' when (Opcode3=RETI and stage3=S2) else
				'0';		--Memory read control signal
mem_wr	<=	'1' when ((Opcode3=STM or Opcode3=STR or Opcode3=STIX) and stage3=S1) else
				'1' when ((Opcode3=PUSH or Opcode3=CALL) and stage3=S2) else
				'1' when (Opcode3=SYS and stage3=S2) else	
				'1' when (Opcode4=SYS and stage4=S2) else
				'1' when (Opcode3=S64 and stage3=S1) else
				'1' when	(Opcode4=S64 and stage4=S1) else
				'0';		--Memory write control signal
stall <= true when(Opcode2=LDM or Opcode2=LDR or Opcode2=STM or Opcode2=STR or Opcode2=LDIX or Opcode2=STIX) else
			true when(Opcode2=CALL or Opcode2=PUSH or Opcode2=POP or Opcode2=RET or Opcode2=S64
							or Opcode2=SYS or Opcode2=RETI) else
			true when(Opcode3=CALL  or Opcode3=RET	or Opcode3=PUSH or Opcode3=S64
							or Opcode3=SYS or Opcode3=RETI) else
			true when(Opcode4=SYS or Opcode4=RETI) else
			false;

CPU_State_Machine: process (clk, rst)
begin
if rst='1' then
	update <= S1;
	stage1 <= S1;
	stage2 <= S1;
	stage3 <= S1;
	stage4 <= S1;
	PC <= x"00000000";	--initialize PC
	SP <= x"000FF7FF";	--initialize SP
	IR2 <= x"00000000";
	IR3 <= x"00000000";
	IR4 <= x"00000000";
	Bit64 <= x"0000000000000000"; --initialize bit64 (temp) 

elsif clk'event and clk = '1' then

	case update is
		when S1 =>
			update <= S2;
		when S2 =>
			if (stall or --insert NOP if jump fails
				(Opcode2=JNZ and Z='1') or (Opcode2=JZ and Z='0') or
				(Opcode2=JNS and S='1') or (Opcode2=JS and S='0') or
				(Opcode2=JNV and V='1') or (Opcode2=JV and V='0') or
				(Opcode2=JNC and C='1') or (Opcode2=JC and C='0')) then
				IR2 <= x"00000000";	--insert NOP
			else
				IR2 <= MEM_in;
			end if;
			IR3 <= IR2;
			IR4 <= IR3;
			update <= S1;
		when others =>
			null;
	end case;

	case stage1 is
		when S1 =>
			if (not stall) then
				if (Opcode2=JMP or Opcode2=JNZ or Opcode2=JZ or Opcode2=JNS or
					Opcode2=JS or Opcode2=JNV or Opcode2=JV or
					Opcode2=JNC or Opcode2=JC) then
					MAR <= x"000" & M2; --inst. fetch from the jump destination
				else	
					MAR <= std_logic_vector(PC);
				end if;
			end if;
			stage1 <= S2;
		when S2 =>
			if (not stall) then
				if (Opcode2=JMP or --jump condition is true, change PC
					 (Opcode2=JNZ and Z='0') or (Opcode2=JZ and Z='1') or
					 (Opcode2=JNS and S='0') or (Opcode2=JS and S='1') or
					 (Opcode2=JNV and V='0') or (Opcode2=JV and V='1') or
					 (Opcode2=JNC and C='0') or (Opcode2=JC and C='1') ) then
					PC  <= (x"000" & unsigned(M2)) + 1;
				elsif ((Opcode2=JNZ and Z='1') or (Opcode2=JZ and Z='0') or
					 (Opcode2=JNS and S='1') or (Opcode2=JS and S='0') or
					 (Opcode2=JNV and V='1') or (Opcode2=JV and V='0') or
					 (Opcode2=JNC and C='1') or (Opcode2=JC and C='0') ) then
					null;		--Do not change PC if jump condition is false
				else	
					PC <= PC + 1;
				end if;
			end if;
			stage1 <= S1;
		when others =>
			null;
	end case;

	case stage2 is
		when S1 =>
			if (Opcode2=LDI) then
				register_file(to_integer(unsigned(RX2)))<=(31 downto 16=>I2(15)) & I2;
			elsif (Opcode2=LDH) then
				register_file(to_integer(unsigned(RX2)))
					<= I2 & register_file(to_integer(unsigned(RX2)))(15 downto 0);
					--(31 downto 16)<= I2;
			elsif (Opcode2=LDL) then
				register_file(to_integer(unsigned(RX2)))
					<= register_file(to_integer(unsigned(RX2)))(31 downto 16) & I2;
					--(15 downto 0)<= I2;
			elsif (Opcode2=MOV) then
				register_file(to_integer(unsigned(RX2)))<=register_file(to_integer(unsigned(RY2)));	
			elsif (Opcode2=ADD or Opcode2=SUB or Opcode2=MUL or Opcode2=CMP or
					 Opcode2=IAND or Opcode2=IOR or Opcode2=IXOR) then
				operand1 <= register_file(to_integer(unsigned(RY2)));
			elsif (Opcode2=IROR) then
				null;
			elsif (Opcode2=ADI or Opcode2=CMPI) then
				operand1 <= (31 downto 16=>I2(15)) & I2;
			elsif (Opcode2=LDM) then
				MAR <= x"000" & M2;
			elsif (Opcode2=LDR) then
				MAR <= register_file(to_integer(unsigned(RY2)));
			elsif (Opcode2=STM or Opcode2=S64) then
				MAR <= x"000" & M2;	MDR_out <= register_file(to_integer(unsigned(RX2)));
			elsif (Opcode2=STR) then
				MAR <= register_file(to_integer(unsigned(RX2)));	
				MDR_out <= register_file(to_integer(unsigned(RY2)));
			elsif (Opcode2=CALL or Opcode2=PUSH or Opcode2=SYS) then
				SP <= SP + 1;
			elsif (Opcode2=RET or Opcode2=RETI or Opcode2=POP) then
				MAR <= std_logic_vector(SP);
			elsif(Opcode2=MTX) then
				register_file(to_integer(unsigned(RX2)))<= std_logic_vector(
					signed (I2) * signed(register_file(to_integer(unsigned(RZ2)))(15 downto 0)) 
					+ signed(register_file(to_integer(unsigned(RY2)))));
			elsif(Opcode2=LDIX) then
				MAR <= std_logic_vector(unsigned(register_file(to_integer(unsigned(RY2)))) + unsigned(M2));
			elsif(Opcode2=STIX) then
				MAR <= std_logic_vector(unsigned(register_file(to_integer(unsigned(RX2)))) + unsigned(M2));
				MDR_out <= register_file(to_integer(unsigned(RY2)));
				
			elsif(Opcode2=ADD64) then
				Bit64<=
					std_logic_vector((unsigned(register_file(0)) & unsigned(register_file(1)))
					+ (unsigned(register_file(4)) & unsigned(register_file(5))));
				
			elsif (Opcode2=CH) then
				register_file(0)<=
					(std_logic_vector(register_file(0)) and std_logic_vector(register_file(2))) xor
					(not std_logic_vector(register_file(0)) and std_logic_vector(register_file(4)));
					
				register_file(1)<=
					(std_logic_vector(register_file(1)) and std_logic_vector(register_file(3))) xor
					(not std_logic_vector(register_file(1)) and std_logic_vector(register_file(5)));
			
			elsif (Opcode2=MAJ) then
				register_file(0) <=
						(std_logic_vector(register_file(0)) and std_logic_vector(register_file(2)))xor
						(std_logic_vector(register_file(0)) and std_logic_vector(register_file(4)))xor
						(std_logic_vector(register_file(2)) and std_logic_vector(register_file(4)));
						
				register_file(1) <=
						(std_logic_vector(register_file(1)) and std_logic_vector(register_file(3)))xor
						(std_logic_vector(register_file(1)) and std_logic_vector(register_file(5)))xor
						(std_logic_vector(register_file(3)) and std_logic_vector(register_file(5)));

			elsif (Opcode2=SUM1) then
				Bit64 <= 
					std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 14)) xor
					std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 18)) xor
					std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 41));
			
			elsif (Opcode2=SIG0) then
				Bit64<=
					std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 1)) xor
					std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 8)) xor
					std_logic_vector(shift_right((unsigned(register_file(0)) & unsigned(register_file(1))), 7));
			
			elsif (Opcode2=SIG1) then
				Bit64 <= 
					std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 19)) xor
					std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 61)) xor
					std_logic_vector(shift_right((unsigned(register_file(0)) & unsigned(register_file(1))), 6));
			
			elsif(Opcode2=SUM0) then
				Bit64 <=
				std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 28)) xor
				std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 34)) xor
				std_logic_vector(rotate_right((unsigned(register_file(0)) & unsigned(register_file(1))), 39));
				
			elsif(Opcode2=SCH3) then
				wva <= Hinit0;
				wvb <= Hinit1;
				wvc <= Hinit2;
				wvd <= Hinit3;
				wve <= Hinit4;
				wvf <= Hinit5;
				wvg <= Hinit6;
				wvh <= Hinit7;
	
			elsif(Opcode2=SCH4) then
				wvh <= wvg;
				wvg <= wvf;
				wvf <= wve;
				wve <= std_logic_vector(
					unsigned(wvd) + unsigned(wvh) + 
						unsigned(std_logic_vector(rotate_right(unsigned(wve), 14)) 
							xor std_logic_vector(rotate_right(unsigned(wve), 18)) 
							xor std_logic_vector(rotate_right(unsigned(wve), 41))) --sum1(wve)
							+ unsigned ((wve and wvf) xor (not wve and wvg)) --Ch(wve, wvf, wvg)
							+ (unsigned(register_file(0)) & unsigned(register_file(1)))--k
							+ (unsigned(register_file(2)) & unsigned(register_file(3))));--w
							--wve <= wvd + T1
				wvd <= wvc;
				wvc <= wvb;
				wvb <= wva;
				wva <= std_logic_vector(unsigned(wvh)
					+ unsigned(std_logic_vector(rotate_right(unsigned(wve), 14)) 
					xor std_logic_vector(rotate_right(unsigned(wve), 18))
					xor std_logic_vector(rotate_right(unsigned(wve), 41))) --sum1(wve)
					+ unsigned((wve and wvf) xor (not wve and wvg)) --CH(wve,wvf,wvg)
					+ (unsigned(register_file(0)) & unsigned(register_file(1)))--K
					+ (unsigned(register_file(2)) & unsigned(register_file(3)))-- W
					--T1 = wvh + sum1(wve) +Ch(wve,wvf,wvg) + K + W
					--T2 = sum0(wva) + Maj(wva, wvb, wvc)
					+ unsigned(std_logic_vector(rotate_right(unsigned(wva), 28))
					xor std_logic_vector(rotate_right(unsigned(wva), 34))
					xor std_logic_vector(rotate_right(unsigned(wva), 39))) --sum0(wva)
					+ unsigned((wva and wvb) xor (wva and wvc) xor (wvb and wvc))); --Maj(wva,wvb,wvc)
					
			elsif(Opcode2=SCH50) then
				wva <= std_logic_vector(unsigned(wva) + unsigned(Hinit0));
				wvb <= std_logic_vector(unsigned(wvb) + unsigned(Hinit1));
				wvc <= std_logic_vector(unsigned(wvc) + unsigned(Hinit2));
				wvd <= std_logic_vector(unsigned(wvd) + unsigned(Hinit3));
				
			elsif(Opcode2=SCH51) then
				wve <= std_logic_vector(unsigned(wve) + unsigned(Hinit4));
				wvf <= std_logic_vector(unsigned(wvf) + unsigned(Hinit5));
				wvg <= std_logic_vector(unsigned(wvg) + unsigned(Hinit6));
				wvh <= std_logic_vector(unsigned(wvh) + unsigned(Hinit7));
			end if;
			stage2 <= S2;
		when S2 =>
			if (Opcode2=ADD or Opcode2=SUB or Opcode2=IROR or Opcode2=IAND or
					 Opcode2=MUL or Opcode2=IOR or Opcode2=IXOR or Opcode2=ADI) then
				register_file(to_integer(unsigned(RX2))) <= ALU_out;
				Z <= zero;	S <= ALU_out(31);	V <= overflow;	C <= carry; --update CC
				
			elsif (Opcode2=CMP or Opcode2=CMPI) then
				Z <= zero;	S <= ALU_out(31);	V <= overflow;	C <= carry; --update CC only
				
			elsif (Opcode2=LDM or Opcode2=LDR or Opcode2=LDIX) then
				MDR_in <= MEM_in;
				
			elsif (Opcode2=CALL or Opcode2=SYS) then
				MAR <= std_logic_vector(SP);	
				MDR_out <= std_logic_vector(PC);	
				
			elsif (Opcode2=RET or Opcode2=RETI or Opcode2=POP) then
				MDR_in <= MEM_IN;	SP <= SP - 1;
				
			elsif (Opcode2=PUSH) then
				MAR <= std_logic_vector(SP);
				MDR_out <= register_file(to_integer(unsigned(RX2)));
				
			elsif(Opcode2=STM or Opcode2=STR or Opcode2=STIX) then
				null;
				
			elsif(Opcode2=SIG0 or Opcode2=SIG1 or Opcode2=SUM0 or Opcode2=SUM1 or Opcode2=ADD64) then
				register_file(0) <= Bit64(63 downto 32);
				register_file(1) <= Bit64(31 downto 0);
			
			elsif(Opcode2=SCH50) then
				register_file(0) <= wva(63 downto 32);
				register_file(1) <= wva(31 downto 0);
				register_file(2) <= wvb(63 downto 32);
				register_file(3) <= wvb(31 downto 0);
				register_file(4) <= wvc(63 downto 32);
				register_file(5) <= wvc(31 downto 0);
				register_file(6) <= wvd(63 downto 32);
				register_file(7) <= wvd(31 downto 0);
				
			elsif(Opcode2=SCH51) then
				register_file(0) <= wve(63 downto 32);
				register_file(1) <= wve(31 downto 0);
				register_file(2) <= wvf(63 downto 32);
				register_file(3) <= wvf(31 downto 0);
				register_file(4) <= wvg(63 downto 32);
				register_file(5) <= wvg(31 downto 0);
				register_file(6) <= wvh(63 downto 32);
				register_file(7) <= wvh(31 downto 0);
				
			end if;
			stage2 <= S1;
		when others =>
			null;
	end case;
	
	case stage3 is
		when S1 =>
			if (Opcode3=LDM or Opcode3=LDR or Opcode3=LDIX) then
				register_file(to_integer(unsigned(RX3))) <= MDR_in;
			elsif (Opcode3=CALL) then
				PC <= x"000" & unsigned(M3);
			elsif (Opcode3=POP) then
				register_file(to_integer(unsigned(RX3))) <= MDR_in;
			elsif (Opcode3=RET) then
				PC <= unsigned(MDR_in);
			elsif (Opcode3=RETI) then
				PSW <= MDR_in;	MAR <= std_logic_vector(SP);	
			elsif (Opcode3=PUSH) then
				null;	
			elsif (Opcode3=SYS) then
				SP <= SP + 1;
			elsif(Opcode3=S64) then
				MAR <= x"000" & std_logic_vector(unsigned(M3) + 1);
				MDR_out <= register_file(to_integer(unsigned(RY3)));
			elsif(Opcode3=STM or Opcode3=STR or Opcode2=STIX) then
				null;
			end if;
			stage3 <= S2;
		when S2 =>
			if (Opcode3=RETI) then
				MDR_in <= MEM_IN;	sp <= sp - 1;
			elsif (Opcode3=SYS) then
				MAR <= std_logic_vector(SP);
				MDR_out <= PSW;
			end if;
			stage3 <= S1;
		when others =>
			null;
	end case;
	
	case stage4 is
		when S1 =>
			if (Opcode4=RETI) then
				PC <= unsigned(MDR_in);
			elsif (Opcode4=SYS) then
				PC <= X"000FFC0"&unsigned(IR4(3 downto 0));	
			end if;
			stage4 <= S2;
		when S2 =>
			stage4 <= S1;
		when others =>
			null;
	end case;
end if;
end process;
--------------------ALU----------------------------			
Rhody_ALU: entity work.alu port map(
		alu_op => IR2(28 downto 26), 
		operand0 => operand0, 
		operand1 => operand1,
		n => IR2(4 downto 0), 
		alu_out => ALU_out,
		carry => carry,
		overflow => overflow);	
zero <= '1' when alu_out = X"00000000" else '0';	
operand0 <= register_file(to_integer(unsigned(RX2)));
-----------------------------------------------------

end Structural;

