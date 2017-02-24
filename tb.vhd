library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_bench is
end test_bench;

architecture default of test_bench is
  signal clk : std_logic := '1';
  signal data_in : std_logic_vector(7 downto 0);
  signal data_valid : std_logic;
  signal data_number : std_logic_vector(7 downto 0);

  signal state : unsigned(10 downto 0);

  component mlp is
    generic (
      IN_WIDTH : integer := 8;
      LOG_IN_COUNT : integer := 8;
      LOG_HIDDEN : integer := 8);
    port (
      clk : in std_logic;
      data_in : in std_logic_vector(IN_WIDTH-1 downto 0);
      data_in_valid : in std_logic;
      data_number : in std_logic_vector(LOG_IN_COUNT-1 downto 0);
      data_out : out std_logic_vector(15 downto 0);
      data_out_valid : out std_logic);
  end component;

begin

  process
  begin
    clk <= '1';
    wait for 1 fs;
    clk <= '0';
    wait for 1 fs;
  end process;

  process(data_in, data_valid, data_number)
  begin
    data_in <= std_logic_vector(state(8 downto 1));
    data_valid <= state(0);
    if state = 0 then
      data_number <= x"b4";
    else
      data_number <= (others => '0');
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      state <= state+1;
    end if;
  end process;

end default;
