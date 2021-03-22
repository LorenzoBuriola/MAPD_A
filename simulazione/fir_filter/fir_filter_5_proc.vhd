library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
port (
  clk           : in std_logic;
  valid_input   : in std_logic;
  data_input    : in std_logic_vector(7 downto 0);
  busy		: in std_logic;
  valid_output  : out std_logic;
  data_output   : out std_logic_vector(7 downto 0)
  
);
end fir_filter;

architecture rtl of fir_filter is

  -- coefficients
  signal coeff_0      : signed(7 downto 0) := to_signed(4, 8);
  signal coeff_1      : signed(7 downto 0) := to_signed(31, 8);
  signal coeff_2      : signed(7 downto 0) := to_signed(58, 8);

  -- first sum
  signal sum0        : signed(8 downto 0) := (others => '0');
  signal sum1        : signed(8 downto 0) := (others => '0');
  signal sum2        : signed(7 downto 0) := (others => '0');

  -- mul
  signal mul0        : signed(16 downto 0) := (others => '0');
  signal mul1        : signed(16 downto 0) := (others => '0');
  signal mul2        : signed(15 downto 0) := (others => '0');

  -- second sum
  signal sum_sf       : signed(17 downto 0) := (others => '0');
  signal sum_sf2      : signed(15 downto 0) := (others => '0');

  -- third sum
  signal sum_tot      : signed(18 downto 0) := (others => '0');

  -- type for input data
  type data_type       is array (0 to 4) of signed(7  downto 0);
  signal proc_data    : data_type := (others => (others => '0'));

begin
  -- Input process data are red
  Input : process (clk)
  begin
    if(rising_edge(clk)) then
      if (valid_input = '1') then
        proc_data      <= signed(data_input)&proc_data(0 to proc_data'length-2);
        valid_output <= '1';
      else
        valid_output <= '0';
      end if;
    end if;
  end process Input;

  -- sum of values associated to same coefficient (coefficients are symmetric)
  sum_1st : process (clk)
  begin
    if(rising_edge(clk)) then
      sum0 <= resize(proc_data(0), 9) + resize(proc_data(4), 9);
      sum1 <= resize(proc_data(1), 9) + resize(proc_data(3), 9);
      sum2 <= proc_data(2);
    end if;
  end process sum_1st;

  -- multiplication data times coefficient
  mul : process (clk)
  begin
    if(rising_edge(clk)) then
      mul0 <= sum0 * coeff_0;
      mul1 <= sum1 * coeff_1;
      mul2 <= sum2 * coeff_2;
    end if;
  end process mul;

  sum_2nd : process (clk)
  begin
    if(rising_edge(clk)) then
      sum_sf <= resize(mul0, 18) + resize(mul1, 18);
      sum_sf2 <= mul2;
    end if;
  end process sum_2nd;

  sum_3rd : process(clk)
  begin  
    if rising_edge(clk) then
      sum_tot <= resize(sum_sf, 19) + resize(sum_sf2, 19);
    end if;
  end process sum_3rd;

  -- Output process, we choose the 8 bits we are interested in
  Output : process (clk)
  begin
    if(rising_edge(clk)) then
	if busy = '0' then 
      		data_output     <= std_logic_vector(sum_tot(14 downto 7));
	end if;
    end if;
  end process Output;

end rtl;
