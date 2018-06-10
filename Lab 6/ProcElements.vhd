--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
-- Add your code here
	WITH selector SELECT Result <= In0 when '0',
					In1 when OTHERS;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (6 downto 0);
           funct3  : in  STD_LOGIC_VECTOR (2 downto 0);
           funct7  : in  STD_LOGIC_VECTOR (6 downto 0);
           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0);
           MemWrite : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC;
           ImmGen : out STD_LOGIC_VECTOR(1 downto 0));
end Control;

architecture Boss of Control is
begin
-- Add your code here
	WITH opcode & funct3 SELECT Branch <= "01" when "1100011000", --BEQ
						"10" when "1100011001", --BNE
						"--" when others;
	
	WITH opcode & funct3 SELECT MemRead <= '1' when "0000011010", --LW
						'0' when others;
	
	WITH opcode & funct3 SELECT MemtoReg <= '1' when "0000011010", --LW
						'0' when others;

	WITH opcode & funct3 & funct7 SELECT ALUCtrl <= "0-000" when "01100110000000000", -- ADD
							"0-100" when "01100110000100000", -- SUB
							"0--10" when "01100111110000000", --AND
							"0--11" when "01100111100000000", -- OR
							"00-01" when "00100110010000000", --SLLI
							"01-01" when "00100111010000000", --SRLI
							"01-10" when "0000011010-------", --LW
							"0-000" when "0010011000-------", --ADDI
							"0--11" when "0010011110-------", --ORI
							"0--10" when "0010011111-------", --ANDI
							"10-01" when "0100011010-------", --SW
							"1--00" when "1100011000-------", --BEQ
							"0--00" when "1100011001-------", --BNE
							"01-11" when "0110111----------", --LUI
							"11111" when others;
	
	WITH opcode & funct3 SELECT MemWrite <= '1' when "0100011010", -- SW
						'0' when others;

	WITH opcode & funct3 & funct7 SELECT ALUSrc <= '0' when "01100110000000000", --ADD
							'0' when "01100110001000000", --SUB
							'0' when "01100111110000000", --AND
							'0' when "01100111100000000", --OR
							'0' when "1100011000-------", --BEQ
							'0' when "1100011001-------", --BNE
							'1' when others;

	WITH opcode & funct3 SELECT RegWrite <= '0' when "0100011010", -- SW
						'0' when "1100011000", -- BEQ
						'0' when "1100011001", --BNE
						'1' when others;

	WITH opcode & funct3 SELECT ImmGen <= "00" when "0010011001", --SLLI
						"00" when "0010011101", --SRLI
						"00" when "0000011010", --LW
						"00" when "0010011000", --ADDI
						"00" when "0010011110", --ORI
						"00" when "0010011111", --ANDI
						"01" when "0100011010", --SW
						"10" when "1100011000", --BEQ
						"10" when "1100011001", --BNE
						"11" when "0110111---", --LUI
						"--" when others;
end Boss;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is

	signal new_address: std_logic_vector(31 downto 0);
begin
-- Add your code here
ProgramCounter: Process(Reset, Clock)
begin
	if (Reset = '1') then
		new_address <= "00000000010000000000000000000000";
	end if;
	if (falling_edge(Clock)) then
		new_address <= PCin;
	end if;
	if (rising_edge(Clock)) then
		PCOut <= new_address;
	end if;
end process;	
end executive;
--------------------------------------------------------------------------------
