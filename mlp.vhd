library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mlp is
  generic (
    DATA_WIDTH : integer := 14;
    DIM_DATA_WIDTH : integer := 8;
    DIM_HIDDEN_WIDTH : integer := 8);

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
end mlp;

architecture default of mlp is
  constant HIDDEN : integer := DIM_HIDDEN_WIDTH**2;
  constant IN_COUNT : integer := DIM_DATA_WIDTH**2;
  subtype float is std_logic_vector(15 downto 0);
  type hidden_array_t is array(HIDDEN-1 downto 0) of float;

  signal conv_half0_out : float;
  signal z : hidden_array_t;
  signal mul1_do : hidden_array_t;
  signal l2_multiplication : hidden_array_t;
  signal l2_accumulation : hidden_array_t;
  signal output : float;

  type state_type is record
    w1_addr : std_logic_vector(DIM_DATA_WIDTH-1 downto 0);
    w1_en : std_logic_vector(HIDDEN-1 downto 0);
    w1_wr : std_logic;
    b1_addr : std_logic_vector(DIM_DATA_WIDTH-1 downto 0);
    b1_en : std_logic_vector(HIDDEN-1 downto 0);
    b1_wr : std_logic;
    w2 : hidden_array_t;
    b2 : float;
    last : std_logic_vector(DIM_HIDDEN_WIDTH downto 0);
    l2_multiplication : hidden_array_t;
    l2_accumulation : hidden_array_t;
  end record;

  signal state : state_type := (
    w1_addr => (others => '0'),
    w1_en => (others => '0'),
    w1_wr =>  '0',
    b1_addr => (others => '0'),
    b1_en => (others => '0'),
    b1_wr => '0',
    w2 => (others => (others => '0')),
    b2 => (others => '0'),
    last => (others => '0'),
    l2_multiplication => (others => (others => '0')),
    l2_accumulation => (others => (others => '0')));

    type tristate_type is record
      w1 : hidden_array_t;
      b1 : hidden_array_t;
    end record;

    signal tristate : tristate_type := (
      w1 => (others => (others => 'Z')),
      b1 => (others => (others => 'Z')));


  component conv_half
    port (
    di : in std_logic_vector(DATA_WIDTH-1 downto 0);
    do : out float);
  end component;

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

  component l1
    generic (
    DIM_X_WIDTH : integer := DIM_DATA_WIDTH);
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
    
begin

  conv_half0 : conv_half port map (
    di => xi,
    do => conv_half0_out);

  first_layers : for i in 0 to HIDDEN-1 generate
    l1_0 : l1 port map (
    clk => clk,
    xi => conv_half0_out,
    xi_valid => xi_valid,
    first => first,
    last => last,
    wi_addr => w1_addrx,
    wi => tristate.w1(i),
    wi_en => state.w1_en(i),
    wi_wr => state.w1_wr,
    b => tristate.b1(i),
    b_en => state.b1_en(i),
    b_wr => state.b1_wr,
    z => z(i),
    z_valid => open);
  end generate;

  second_multiplication : for j in 0 to HIDDEN-1 generate
    mul1 : mul port map (
    da => z(j),
    db => state.w2(j),
    do => l2_multiplication(j));
  end generate;

  second_accumulation_0 : for j in 0 to HIDDEN/2-1 generate
    add2 : add port map (
    da => state.l2_multiplication(2*j),
    db => state.l2_multiplication(2*j+1),
    do => l2_accumulation(j+HIDDEN/2));
  end generate;

  second_accumulation_j : for j in DIM_HIDDEN_WIDTH-3 downto 1 generate
    second_accumulation_k : for k in 0 to 0 generate
      add3 : add port map (
      da => state.l2_accumulation((2*k)+(2**j)),
      db => state.l2_accumulation((2*k+1)+(2**j)),
      do => l2_accumulation(k+2**(j-1)));
    end generate;
  end generate;

  add4 : add port map (
  da => state.l2_accumulation(1),
  db => state.b2,
  do => output);

  process(clk)
    variable vstate : state_type;
    variable vtristate : tristate_type;
  begin
    vstate := state;
    vtristate.w1 := (others => (others => 'Z'));
    vtristate.b1 := (others => (others => 'Z'));

    vstate.l2_multiplication := l2_multiplication;
    vstate.l2_accumulation := l2_accumulation;
    vstate.last := state.last(DIM_HIDDEN_WIDTH-1 downto 0) & last;

    vstate.w1_en := (others => '0');
    vstate.w1_en(to_integer(unsigned(w1_addrz))) := '1';
    vstate.w1_wr := w1_wr;
    vstate.b1_en := (others => '0');
    vstate.b1_en(to_integer(unsigned(b1_addr))) := '1';
    vstate.b1_wr := b1_wr;

    if w1_en = '1' and w1_wr = '1' then
      vtristate.w1(to_integer(unsigned(w1_addrz))) := w1;
    end if;

    for i in 0 to HIDDEN-1 loop
      if state.w1_en(i) = '1' and state.w1_wr = '0' then
        w1 <= tristate.w1(i);
      end if;
    end loop;

    if b1_en = '1' and b1_wr = '1' then
      vtristate.b1(to_integer(unsigned(b1_addr))) := b1;
    end if;

    for i in 0 to HIDDEN-1 loop
      if state.b1_en(i) = '1' and state.b1_wr = '0' then
        b1 <= tristate.b1(i);
      end if;
    end loop;

    if w2_en = '1' then
      if w2_wr = '1' then
        vstate.w2(to_integer(unsigned(w2_addr))) := w2;
        w2 <= (others => 'Z');
      else
        w2 <= state.w2(to_integer(unsigned(w2_addr)));
      end if;
    else
      w2 <= (others => 'Z');
    end if;

    if b2_en = '1' then
      if b2_wr = '1' then
        vstate.b2 := b2;
        b2 <= (others => 'Z');
      else
        b2 <= state.b2;
      end if;
    else
      b2 <= (others => 'Z');
    end if;

    if rising_edge(clk) then
      state <= vstate;
    end if;
  end process;

end default;
