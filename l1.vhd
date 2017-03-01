library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity l1 is
  generic (
    DIM_X_WIDTH : integer := 10);
  port (
  clk : in std_logic;
  xi : in std_logic_vector(15 downto 0);
  addr : in std_logic_vector(DIM_X_WIDTH-1 downto 0);
  last : in std_logic;
  wi : inout std_logic_vector(15 downto 0);
  wi_en : in std_logic;
  wi_wr : in std_logic;
  b : inout std_logic_vector(15 downto 0);
  b_en : in std_logic;
  b_wr : in std_logic;
  z : out std_logic_vector(15 downto 0);
  z_valid : out std_logic);
end l1;

architecture default of l1 is
  constant DIM_X : integer := 2**DIM_X_WIDTH;
  subtype float is std_logic_vector(15 downto 0);
  type Wreg_type is array(DIM_X-1 downto 0) of float;

  signal Wreg : Wreg_type := (others => (others => '0'));

  component mul
    port (
    da : in float;
    db : in float;
    do : out float);
  end component;

  component add
    port (
    da : in float;
    db : in float;
    do : out float);
  end component;

  component activate
    port (
    da : in float;
    do : out float);
  end component;

  signal Wreg_out :float;
  signal breg : float;
  signal mul0_out : float;
  signal add0_out : float;
  signal activate0_out : float;

  type state_type is record 
    x : float;
    z : float;
    z_valid : std_logic;
  end record;

  signal state : state_type := (
    x => (others => '0'),
    z => (others => '0'),
    z_valid => '0');
begin


  mul0 : mul port map(
    da => Wreg_out,
    db => state.x,
    do => mul0_out);

  add0 : add port map(
    da => mul0_out,
    db => state.z,
    do => add0_out);

  activate0: activate port map(
    da => add0_out,
    do => activate0_out);

  z <= state.z;
  z_valid <= state.z_valid;

  process(clk)
    variable vstate : state_type;
    variable iaddr : integer;
  begin
    vstate := state;
    iaddr := to_integer(unsigned(addr));
    vstate.x := xi;
    vstate.z_valid := last;
    if iaddr = 0 then
      vstate.z := breg;
    else
      vstate.z := activate0_out;
    end if;

    if rising_edge(clk) then
      Wreg_out <= Wreg(iaddr);
      state <= vstate;
      if wi_en = '1' then
        if wi_wr = '1' then
          Wreg(iaddr) <= wi;
        else
          wi <= Wreg(iaddr);
        end if;
      else
        wi <= (others => 'Z');
      end if;

      if b_en = '1' then
        if b_wr = '1' then
          breg <= b;
        else
          b <= breg;
        end if;
      else
        b <= (others => 'Z');
      end if;
    end if;

  end process;

end default;
