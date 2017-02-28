library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mlp_tb is
end mlp_tb;

architecture default of mlp_tb is
  signal clk : std_logic := '1';
  signal data_in : std_logic_vector(7 downto 0);
  signal data_in_valid : std_logic;
  signal data_number : std_logic_vector(7 downto 0);
  signal data_out : std_logic_vector(15 downto 0);
  signal data_out_valid : std_logic;

  signal state : unsigned(10 downto 0) := (others => '0');

  component mlp is
    generic (
      DATA_WIDTH : integer := 8;
      COUNT_WIDTH : integer := 8;
      NUM_HIDDEN_WIDTH : integer := 8);
    port (
      clk : in std_logic;
      data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
      data_in_valid : in std_logic;
      data_number : in std_logic_vector(COUNT_WIDTH-1 downto 0);
      data_out : out std_logic_vector(15 downto 0);
      data_out_valid : out std_logic);
  end component;

begin

  mlp0: mlp port map (
    clk => clk,
    data_in => data_in,
    data_in_valid => data_in_valid,
    data_number => data_number,
    data_out => data_out,
    data_out_valid => data_out_valid);

  process
  begin
    clk <= '1';
    wait for 1 fs;
    clk <= '0';
    wait for 1 fs;
  end process;

  process(data_in, data_in_valid, data_number)
  begin
    data_in <= std_logic_vector(state(8 downto 1));
    data_in_valid <= state(0);
    if state = x"0" then
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
