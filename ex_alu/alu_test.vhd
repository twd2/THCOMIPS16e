--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:33:52 10/17/2017
-- Design Name:   
-- Module Name:   C:/Users/twd2/Desktop/ex_alu/ex_alu/alu_test.vhd
-- Project Name:  ex_alu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.constants.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY alu_test IS
END alu_test;
 
ARCHITECTURE behavior OF alu_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         OP : IN  std_logic_vector(3 downto 0);
         OPERAND_0 : IN  std_logic_vector(15 downto 0);
         OPERAND_1 : IN  std_logic_vector(15 downto 0);
         RESULT : OUT  std_logic_vector(15 downto 0);
         OVERFLOW : OUT  std_logic;
         ZERO : OUT  std_logic;
         SIGN : OUT  std_logic;
         CARRY : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal OP : std_logic_vector(3 downto 0) := (others => '0');
   signal OPERAND_0 : std_logic_vector(15 downto 0) := (others => '0');
   signal OPERAND_1 : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal RESULT : std_logic_vector(15 downto 0);
   signal OVERFLOW : std_logic;
   signal ZERO : std_logic;
   signal SIGN : std_logic;
   signal CARRY : std_logic;
   -- No clock
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          OP => OP,
          OPERAND_0 => OPERAND_0,
          OPERAND_1 => OPERAND_1,
          RESULT => RESULT,
          OVERFLOW => OVERFLOW,
          ZERO => ZERO,
          SIGN => SIGN,
          CARRY => CARRY
        );

   -- Stimulus process
   stim_proc:
   process
   begin
      -- hold reset state for 100 ns.
      wait for 5 ns;

      OPERAND_0 <= x"0000";
      OPERAND_1 <= x"0000";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"FFFD";
      OPERAND_1 <= x"0003";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"FFFF";
      OPERAND_1 <= x"FFFF";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"0001";
      OPERAND_1 <= x"0002";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"0006";
      OPERAND_1 <= x"FFFF";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"FFFE";
      OPERAND_1 <= x"FFFF";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"FFFF";
      OPERAND_1 <= x"FFFE";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"7FFF";
      OPERAND_1 <= x"0005";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"8000";
      OPERAND_1 <= x"FFFF";
      OP <= alu_add;
      wait for 10 ns;

      OPERAND_0 <= x"0003";
      OPERAND_1 <= x"0003";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"0001";
      OPERAND_1 <= x"0002";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"0009";
      OPERAND_1 <= x"0002";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"0006";
      OPERAND_1 <= x"FFFF";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"FFFE";
      OPERAND_1 <= x"FFFF";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"FFFF";
      OPERAND_1 <= x"FFFE";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"7FFF";
      OPERAND_1 <= x"0005";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"8000";
      OPERAND_1 <= x"FFFF";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"FFFF";
      OPERAND_1 <= x"8000";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"8000";
      OPERAND_1 <= x"0001";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"7FFF";
      OPERAND_1 <= x"FFFF";
      OP <= alu_sub;
      wait for 10 ns;

      OPERAND_0 <= x"0005";
      OPERAND_1 <= x"000C";
      OP <= alu_and;
      wait for 10 ns;

      OPERAND_0 <= x"0005";
      OPERAND_1 <= x"000C";
      OP <= alu_or;
      wait for 10 ns;

      OPERAND_0 <= x"0005";
      OPERAND_1 <= x"000C";
      OP <= alu_xor;
      wait for 10 ns;

      OPERAND_0 <= x"05AF";
      OPERAND_1 <= x"000C";
      OP <= alu_not;
      wait for 10 ns;

      OPERAND_0 <= x"05AF";
      OPERAND_1 <= x"0003";
      OP <= alu_sll;
      wait for 10 ns;

      OPERAND_0 <= x"05AF";
      OPERAND_1 <= x"0003";
      OP <= alu_srl;
      wait for 10 ns;

      OPERAND_0 <= x"85AF";
      OPERAND_1 <= x"0003";
      OP <= alu_srl;
      wait for 10 ns;

      OPERAND_0 <= x"05AF";
      OPERAND_1 <= x"0003";
      OP <= alu_sra;
      wait for 10 ns;

      OPERAND_0 <= x"85AF";
      OPERAND_1 <= x"0003";
      OP <= alu_sra;
      wait for 10 ns;

      OPERAND_0 <= x"85AF";
      OPERAND_1 <= x"0003";
      OP <= alu_rol;
      wait for 10 ns;
      wait;
   end process;

END;
