library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity FPU is
  Port ( a : in std_logic_vector(31 downto 0); 
         b : in std_logic_vector(31 downto 0);
         op : in std_logic;
         done: out std_logic; 
         result : out std_logic_vector(31 downto 0));
       
end FPU;

architecture Behavioral of FPU is

signal mantisa_a, mantisa_b, mantisa_res : std_logic_vector(24 downto 0) := "0" & x"000000";
signal exp_a, exp_b, exp_res : std_logic_vector(8 downto 0) := "0" & x"00";
signal sign_a, sign_b, sign_res : std_logic := '0';
signal exp_dif : signed(8 downto 0) := "000000000";
signal state : std_logic_vector(2 downto 0) := "000";
signal normalization: std_logic;
signal done_aux : std_logic := '0';
signal z: std_logic_vector(31 downto 0);


 
    
begin

    main: process(a, b, op, state, normalization) is
    variable x_mantissa : STD_LOGIC_VECTOR (22 downto 0);
		variable x_exponent : STD_LOGIC_VECTOR (7 downto 0);
		variable x_sign : STD_LOGIC;
		variable y_mantissa : STD_LOGIC_VECTOR (22 downto 0);
		variable y_exponent : STD_LOGIC_VECTOR (7 downto 0);
		variable y_sign : STD_LOGIC;
		variable z_mantissa : STD_LOGIC_VECTOR (22 downto 0);
		variable z_exponent : STD_LOGIC_VECTOR (7 downto 0);
		variable z_sign : STD_LOGIC;
		variable aux : STD_LOGIC;
		variable aux2 : STD_LOGIC_VECTOR (47 downto 0);
		variable exponent_sum : STD_LOGIC_VECTOR (8 downto 0);
    
    begin
     x_mantissa := a(22 downto 0);
		x_exponent := a(30 downto 23);
		x_sign := a(31);
		y_mantissa := b(22 downto 0);
		y_exponent := b(30 downto 23);
		y_sign := b(31);
   
        if(state = "000") then
            done_aux <= '0';
        end if;
        if (done_aux = '0') and (a(31) /= 'U') then
            if state = "000" then
                normalization <= '0'; 
                
                
                done <= '0';
                done_aux <= '0';
                result <= (others => '0'); 
                sign_a <= a(31); 
                exp_a <= '0' & a(30 downto 23); 
                mantisa_a <= "01" & a(22 downto 0); 
                

                sign_b <= b(31);
                exp_b <= '0' & b(30 downto 23); 
                mantisa_b <= "01" & b(22 downto 0); 

                state <= "101"; 
                
            elsif state = "101" then
            if (unsigned(exp_a) > unsigned(exp_b)) then
                    exp_dif <= signed(exp_a) - signed(exp_b);
            else
                  exp_dif <= signed(exp_b) - signed(exp_a);
            end if;
            
            state <= "001"; 
                            

            elsif state = "001" then
                if (unsigned(exp_a) > unsigned(exp_b)) then
                    exp_res <= exp_a;
                    mantisa_b(23 - to_integer(exp_dif) downto 0) <= mantisa_b(23 downto to_integer(exp_dif));
                    mantisa_b(23 downto 24 - to_integer(exp_dif)) <= (others => '0');
                    
                    state <= "010"; 
                else
                    
                    exp_res <= exp_b;
                    mantisa_a(24 - to_integer(exp_dif) downto 0)  <= mantisa_a(24 downto to_integer(exp_dif));
                    mantisa_a(24 downto 25 - to_integer(exp_dif)) <= (others => '0');
                    
                    state <= "010"; 
                end if;

            elsif state = "010" then
                if (op = '0') then
                   
                    if ((sign_a xor sign_b) = '0') then
                        mantisa_res <= std_logic_vector(unsigned(mantisa_a) + unsigned(mantisa_b));
                        sign_res <= sign_a;
                    
                    
                    elsif unsigned(mantisa_a) >= unsigned(mantisa_b) then
                        mantisa_res <= std_logic_vector(unsigned(mantisa_a) - unsigned(mantisa_b));
                        sign_res <= sign_a;
                    else
                        mantisa_res <= std_logic_vector(unsigned(mantisa_b) - unsigned(mantisa_a));
                        sign_res <= sign_b;
                       
                    end if;
              else
                 
       
	
		
		if (x_exponent=255 or y_exponent=255) then 
		
			z_exponent := "11111111";
			z_mantissa := (others => '0');
			z_sign := x_sign xor y_sign;
			
		elsif (x_exponent=0 or y_exponent=0) then 
		
			z_exponent := (others => '0');
			z_mantissa := (others => '0');
			z_sign := '0';
		else
			
			aux2 := ('1' & x_mantissa) * ('1' & y_mantissa);
		
			if (aux2(47)='1') then 
				
				z_mantissa := aux2(46 downto 24) + aux2(23); 
				aux := '1';
			else
				z_mantissa := aux2(45 downto 23) + aux2(22);
				aux := '0';
			end if;
			
			
			exponent_sum := ('0' & x_exponent) + ('0' & y_exponent) + aux - 127;
			
			if (exponent_sum(8)='1') then 
				if (exponent_sum(7)='0') then
					z_exponent := "11111111";
					z_mantissa := (others => '0');
					z_sign := x_sign xor y_sign;
				else 									
					z_exponent := (others => '0');
					z_mantissa := (others => '0');
					z_sign := '0';
				end if;
			else								  		 
				z_exponent := exponent_sum(7 downto 0);
				z_sign := x_sign xor y_sign;
			end if;
		end if;
		

		  result(31)<=z_sign;
          result(30 downto 23)<=z_exponent;
          result (22 downto 0)<=z_mantissa ;                
          
		  end if;                
 
          state <= "011";

         
            elsif state = "011" then
                
                if (mantisa_res(24) = '1') then
                    mantisa_res <= '0' & mantisa_res(24 downto 1);
                    exp_res <= std_logic_vector(unsigned(exp_res) + 1); 
                    state <= "100";
          
                elsif (mantisa_res(23) = '0') then
                    mantisa_res <= mantisa_res(23 downto 0) & '0';
                    exp_res <= std_logic_vector(unsigned(exp_res) - 1);
                    normalization <= not normalization; 
                else
                    state <= "100"; 
                end if;
                
                
            elsif state = "100" then
            if op='0' then
                result(31) <= sign_res;  
                result(30 downto 23) <= exp_res(7 downto 0);  
                result(22 downto 0) <= mantisa_res(22 downto 0);
                done <= '1';  
                done_aux <= '1'; 
                state <= "000";
               
                end if; 
            end if;
            
          end if;  
   
    end process;
    

end Behavioral;
