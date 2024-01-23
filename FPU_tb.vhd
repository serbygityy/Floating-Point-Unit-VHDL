library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FPU_tb is
--  Port ( );
end FPU_tb;

architecture Behavioral of FPU_tb is

component FPU is
        port( a : in std_logic_vector(31 downto 0);
              b : in std_logic_vector(31 downto 0);
              op : in std_logic;
              done: out std_logic;
              -- 0 => adunare
              -- 1 => scadere
              result : out std_logic_vector(31 downto 0));
    end component;

signal a, b, result : std_logic_vector(31 downto 0);
signal op, done : std_logic;

begin

gen_test : FPU port map (a => a, b => b, op => op, done => done, result => result);

    process is
    begin
    
        a <= "10111111100110110000001000001100"; 
        b <= "01000100101001010000001110010110"; 
        op <= '0';
        wait for 500 ns;
        a <= "10111111100110110000001000001100"; 
        b <= "01000100101001010000001110010110"; 
        op <= '1';
        wait for 500 ns;
        
 
        
    end process;

end Behavioral;
