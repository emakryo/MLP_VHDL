library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mlp_tb is
end mlp_tb;

architecture default of mlp_tb is
  constant DATA_WIDTH : integer := 14;
  constant DIM_DATA_WIDTH : integer := 4;
  constant DIM_HIDDEN_WIDTH : integer := 4;
  signal clk : std_logic := '1';
  signal state : std_logic_vector(10 downto 0) := (others => '0');

  signal xi : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal xi_valid : std_logic := '0';
  signal first : std_logic := '0';
  signal last : std_logic := '0';
  signal w1 : std_logic_vector(15 downto 0) := (others => 'Z');
  signal w1_en : std_logic := '0';
  signal w1_wr : std_logic := '0';
  signal w1_addrx : std_logic_vector(DIM_DATA_WIDTH-1 downto 0) := (others => '0');
  signal w1_addrz : std_logic_vector(DIM_HIDDEN_WIDTH-1 downto 0) := (others => '0');
  signal b1 : std_logic_vector(15 downto 0) := (others => 'Z');
  signal b1_en : std_logic := '0';
  signal b1_wr : std_logic := '0';
  signal b1_addr : std_logic_vector(DIM_HIDDEN_WIDTH-1 downto 0) := (others => '0');
  signal w2 : std_logic_vector(15 downto 0) := (others => 'Z');
  signal w2_en : std_logic := '0';
  signal w2_wr : std_logic := '0';
  signal w2_addr : std_logic_vector(DIM_HIDDEN_WIDTH-1 downto 0) := (others => '0');
  signal b2 : std_logic_vector(15 downto 0) := (others => 'Z');
  signal b2_en : std_logic := '0';
  signal b2_wr : std_logic := '0';
  signal fx : std_logic_vector(15 downto 0);
  signal fx_valid : std_logic;

  component mlp is
    generic (
      DATA_WIDTH : integer := DATA_WIDTH;
      DIM_DATA_WIDTH : integer := DIM_DATA_WIDTH;
      DIM_HIDDEN_WIDTH : integer := DIM_HIDDEN_WIDTH);

    port (
      clk : in std_logic;
      xi : in std_logic_vector(DATA_WIDTH-1 downto 0);
      xi_valid : in std_logic;
      first : in std_logic;
      last : in std_logic;
      w1 : inout std_logic_vector(15 downto 0);
      w1_en : in std_logic;
      w1_wr : in std_logic;
      w1_addrx : in std_logic_vector(DIM_DATA_WIDTH-1 downto 0);
      w1_addrz : in std_logic_vector(DIM_HIDDEN_WIDTH-1 downto 0);
      b1 : inout std_logic_vector(15 downto 0);
      b1_en : in std_logic;
      b1_wr : in std_logic;
      b1_addr : in std_logic_vector(DIM_HIDDEN_WIDTH-1 downto 0);
      w2 : inout std_logic_vector(15 downto 0);
      w2_en : in std_logic;
      w2_wr : in std_logic;
      w2_addr : in std_logic_vector(DIM_HIDDEN_WIDTH-1 downto 0);
      b2 : inout std_logic_vector(15 downto 0);
      b2_en : in std_logic;
      b2_wr : in std_logic;
      fx : out std_logic_vector(15 downto 0);
      fx_valid : out std_logic);
  end component;

begin

  mlp0: mlp port map (
    clk => clk,
    xi => xi,
    xi_valid => xi_valid,
    first => first,
    last => last,
    w1 => w1,
    w1_en => w1_en,
    w1_wr => w1_wr,
    w1_addrx => w1_addrx,
    w1_addrz => w1_addrz,
    b1 => b1,
    b1_en => b1_en,
    b1_wr => b1_wr,
    b1_addr => b1_addr,
    w2 => w2,
    w2_en => w2_en,
    w2_wr => w2_wr,
    w2_addr => w2_addr,
    b2 => b2,
    b2_en => b2_en,
    b2_wr => b2_wr,
    fx => fx,
    fx_valid => fx_valid);

  process
  begin
    clk <= '1';
    wait for 1 fs;
    clk <= '0';
    wait for 1 fs;
  end process;

  process(state)
    variable s : std_logic_vector(2 downto 0);
  begin
    s := state(10 downto 8);

    if s = x"0" then
      w1 <= x"000" & state(3 downto 0);
      w1_addrx <= state(3 downto 0);
      w1_addrz <= state(7 downto 4);
      w1_en <= '1';
      w1_wr <= '1';
      b1 <= x"1000";
      b1_en <= '1';
      b1_wr <= '1';
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      state <= std_logic_vector(unsigned(state)+1);
    end if;
  end process;

end default;
