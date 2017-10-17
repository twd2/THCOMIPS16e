--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:54:58 10/17/2017
-- Design Name:   
-- Module Name:   C:/Users/twd2/Desktop/ex_alu/ex_alu/test_controller.vhd
-- Project Name:  ex_alu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: controller
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_controller IS
END test_controller;
 
ARCHITECTURE behavior OF test_controller IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT controller
    PORT(
         nCLK : IN  std_logic;
         nRST : IN  std_logic;
         nInputSW : IN  std_logic_vector(15 downto 0);
         fout : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal nCLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal nInputSW : std_logic_vector(15 downto 0) := (others => '0');
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal InputSW : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal fout : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: controller PORT MAP (
          nCLK => nCLK,
          nRST => nRST,
          nInputSW => nInputSW,
          fout => fout
        );

    nCLK <= not CLK;
    nRST <= not RST;
    nInputSW <= not InputSW;

   -- Stimulus process
   stim_proc: process
   begin
      RST <= '1';
      CLK <= '0';
      wait for 20 ns;
      RST <= '0';
      wait for 10 ns;
      
      -- input A
      InputSW <= x"7003";
      wait for 5 ns;
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;
      
      -- input B
      InputSW <= x"1234";
      wait for 5 ns;
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;

      -- input OP
      InputSW <= x"0000";
      wait for 5 ns;
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;
      
      -- show flags
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;

      -- input A
      InputSW <= x"0003";
      wait for 5 ns;
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;
      
      -- input B
      InputSW <= x"1234";
      wait for 5 ns;
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;

      -- input OP
      InputSW <= x"0001";
      wait for 5 ns;
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;
      
      -- show flags
      CLK <= '1';
      wait for 5 ns;
      CLK <= '0';
      wait for 10 ns;
      wait;
   end process;

END;
