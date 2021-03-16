library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_SM is
    port (
      clk           : in std_logic;
      valid_input   : in std_logic;
      data_input    : in std_logic_vector(7 downto 0);
      valid_output  : out std_logic;
      data_output   : out std_logic_vector(7 downto 0)
    );
    end fir_filter_SM;

    architecture rtl of fir_filter_SM is

        -- coefficients
        signal coeff_0      : signed(7 downto 0) := to_signed(4, 8);
        signal coeff_1      : signed(7 downto 0) := to_signed(31, 8);
        signal coeff_2      : signed(7 downto 0) := to_signed(58, 8);
      
        -- sum1
        signal sum0        : signed(8 downto 0);
        signal sum1        : signed(8 downto 0);
        --signal sum2        : signed(7 downto 0);
      
        -- mul
        signal mul0        : signed(16 downto 0);
        signal mul1        : signed(16 downto 0);
        signal mul2        : signed(15 downto 0);
      
        --sum2
        signal sum_sf       : signed(17 downto 0);
        --signal sum_sf2      : signed(15 downto 0);
      
        --sum3
        signal sum_tot      : signed(18 downto 0);
      
        type data_type    is array (0 to 4) of signed(7  downto 0);
        signal proc_data               : data_type;

        type state_type is (IDLE, Input, Sum_1, Mul, Sum_2, Sum_3, Output);
        signal state : state_type := IDLE;
    
    begin
        main : process (clk) is
        begin
            if rising_edge(clk) then
                case state is
                    when IDLE =>
                        valid_output <= '0';
                        if valid_input = '1' then
                            state <= Input;
                        end if;
                    when Input =>
                        proc_data      <= signed(data_input)&proc_data(0 to proc_data'length-2);
                        if rising_edge(clk) then
                            state <= Sum_1;
                        end if;
                    when Sum_1 =>
                        sum0 <= resize(proc_data(0), 9) + resize(proc_data(4), 9);
                        sum1 <= resize(proc_data(1), 9) + resize(proc_data(3), 9);
                        if rising_edge(clk) then
                            state <= Mul;
                        end if;
                    when Mul =>
                        mul0 <= sum0 * coeff_0;
                        mul1 <= sum1 * coeff_1;
                        mul2 <= proc_data(2) * coeff_2;
                        if rising_edge(clk) then
                            state <= Sum_2;
                        end if;
                    when Sum_2 =>
                        sum_sf <= resize(mul0, 18) + resize(mul1, 18);
                        if rising_edge(clk) then
                            state <= Sum_3;
                        end if;
                    when Sum_3 =>
                        sum_tot <= resize(sum_sf, 19) + resize(mul2, 19);
                        if rising_edge(clk) then
                            state <= Output;
                        end if;
                    when Output =>
                        data_output     <= std_logic_vector(sum_tot(14 downto 7));
                        valid_output <= '1';
                        if rising_edge(clk) then
                            state <= IDLE;
                        end if;
                    when others => null;
                end case;
            end if;
        end process main;
        
    end architecture rtl;