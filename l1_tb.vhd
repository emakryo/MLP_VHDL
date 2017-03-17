library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity l1_tb is
end l1_tb;

architecture default of l1_tb is
  subtype float is std_logic_vector(15 downto 0);

  component l1 is
    generic (
      DIM_X_WIDTH : integer := 4);
    port (
      clk : in std_logic;
      xi : in std_logic_vector(15 downto 0);
      xi_valid : in std_logic;
      first : in std_logic;
      last : in std_logic;
      wi : inout std_logic_vector(15 downto 0);
      wi_addr : in std_logic_vector(DIM_X_WIDTH-1 downto 0);
      wi_en : in std_logic;
      wi_wr : in std_logic;
      b : inout std_logic_vector(15 downto 0);
      b_en : in std_logic;
      b_wr : in std_logic;
      z : out std_logic_vector(15 downto 0);
      z_valid : out std_logic);
  end component;

  signal clk : std_logic;
  signal state : unsigned(7 downto 0) := (others => '0');
  signal xi : float;
  signal xi_valid : std_logic;
  signal wi_addr : std_logic_vector(3 downto 0);
  signal first : std_logic;
  signal last : std_logic;
  signal wi : float;
  signal wi_en : std_logic;
  signal wi_wr : std_logic;
  signal b : float;
  signal b_en : std_logic;
  signal b_wr : std_logic;
  signal z : float;
  signal z_valid : std_logic;

begin

  l1_0 : l1 port map(
    clk => clk,
    xi => xi,
    xi_valid => xi_valid,
    first => first,
    wi_addr => wi_addr,
    last => last,
    wi => wi,
    wi_en => wi_en,
    wi_wr => wi_wr,
    b => b,
    b_en => b_en,
    b_wr => b_wr,
    z => z,
    z_valid => z_valid);

  process
  begin
    clk <= '1';
    wait for 1 fs;
    clk <= '0';
    wait for 1 fs;
  end process;

  process(clk)
    variable vstate : unsigned(7 downto 0);
  begin
    vstate := state+1;

    if rising_edge(clk) then
      state <= vstate;
      wi_addr <= std_logic_vector(state(4 downto 1));

      if state(6 downto 5) = "00" then
        xi_valid <= '0';

        wi_en <= '1';
        wi_wr <= '1';
        wi <= x"00" & std_logic_vector(state);
        b_en <= '1';
        b_wr <= '1';
        b <= x"1234";
      elsif state(6 downto 5) = "01" then
        xi_valid <= '0';

        wi_en <= '1';
        wi_wr <= '0';
        wi <= (others => 'Z');
        b_en <= '1';
        b_wr <= '0';
        b <= (others => 'Z');
      else
        xi_valid <= state(0);
        xi <= x"00" & std_logic_vector(state);
        if state(4 downto 1) = x"0" then
          first <= '1';
        else
          first <= '0';
        end if;

        if state(4 downto 1) = x"f" then
          last <= '1';
        else
          last <= '0';
        end if;

        wi_en <= '0';
        wi_wr <= '0';
        wi <= (others => 'Z');
        b_en <= '1';
        b_wr <= '0';
        b <= (others => 'Z');
      end if;

    end if;
  end process;

end default;
