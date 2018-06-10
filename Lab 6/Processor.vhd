--------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port( clk : in  STD_LOGIC;
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
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     ALUCtrl: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;
	
	-- pc signals
	signal PCin: std_logic_vector(31 downto 0);
	signal PCout: std_logic_vector(31 downto 0);
	signal add4_result: std_logic_vector(31 downto 0);
	signal carryout: std_logic;

	-- output signal from instruction memory
	signal inst: std_logic_vector(31 downto 0);   -- instructions

	-- registers signals
	signal write_data: std_logic_vector(31 downto 0);
	signal read1: std_logic_vector(31 downto 0);
	signal read2: std_logic_vector(31 downto 0);
	signal read2_mux1: std_logic_vector(31 downto 0);
	

	-- control signals
	--signal clk: std_logic;
	signal opcode: 	 std_logic_vector(6 downto 0);
	signal funct7: 	 std_logic_vector (6 downto 0);	
	signal funct3: 	 std_logic_vector(2 downto 0);
	signal Branch: 	 std_logic_vector(1 downto 0);
	signal MemReg: 	 std_logic;
	signal MemRead:	 std_logic;
	signal ALUCtrl:  std_logic_vector (4 downto 0);
	signal MemWrite: std_logic;
	signal ALUSrc: 	 std_logic;
	signal RegWrite: std_logic;
	signal ImmGen: 	 std_logic_vector (1 downto 0);

	-- ImmGen signals
	signal ImmGen_out: std_logic_vector (31 downto 0);

	-- ALU 1 signals ( ALU under)
	signal ALU_result: std_logic_vector(31 downto 0);
	signal zero: std_logic;

	-- Data memory signals:
	signal read_data: std_logic_vector(31 downto 0);

	-- Branch signals:
	signal branchOut: std_logic;

	-- ADD2 signals:
	signal sum: std_logic_vector (31 downto 0);
	signal carryout_2: std_logic;
begin
	-- Add your code here
	
	
	
	--PC
	PC: ProgramCounter port map(reset, clock, PCin, PCout);

	-- PC add 4:
	add4: adder_subtracter port map(PCout, "00000000000000000000000000000100",'0',add4_result, carryout); -- add --> '0', sub --> '1'

	-- Intruction memory
	InstructionMem: InstructionRam port map(reset, clock, PCout(29 downto 0), Inst);

	opcode <= inst(6 downto 0);
	funct3 <= inst(14 downto 12);
	funct7 <= inst(31 downto 25);

	--branch off instructions
		-- Control
	ctrl: Control port map(clock, opcode, funct3, funct7, Branch, MemReg, MemRead, ALUCtrl, MemWrite, ALUSrc, RegWrite, ImmGen);
		-- Registers
	i_reg: Registers port map(inst(19 downto 15), inst(24 downto 20), inst(11 downto 7), write_data, RegWrite, read1, read2);
	
	-- ImmGen
	with ImmGen select
		ImmGen_out 	<= inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(30 downto 20) when "01", -- I-type
				inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(30 downto 25)&inst(11 downto 7) when "10", -- S-type
				inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(30 downto 12) when "11", -- U-type 
				inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(31)&inst(7)&inst(30 downto 25)&inst(11 downto 8)&'0' when others; --B type


	-- MUX 1
	mux_1: BusMux2to1 port map(ALUSrc, read2, ImmGen_out, read2_mux1);
	
	-- ALU
	alu1: ALU port map(read1, read2_mux1, ALUCtrl, zero, ALU_result);
	datamemory: RAM port map(reset, clock, MemRead, MemWrite, ALU_result(31 downto 2), read2, read_data);
	mux_2: BusMux2to1 port map(MemReg, ALU_result, read_data, write_data);
	mux_3: BusMux2to1 port map(branchOut, add4_result, Sum, PCin);

	-- Add2 (ADD --> SUM)
	addsum: adder_subtracter port map(PCout, ImmGen_out, '0', Sum, carryout_2);
	
	-- Branch 
	with zero&Branch select	
		branchOut <= '1' when "110",
				'1' when "101",
				'0' when others;


	

	

end architecture holistic;

