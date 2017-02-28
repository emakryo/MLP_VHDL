library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mlp is
  generic (
    DATA_WIDTH : integer := 14;
    COUNT_WIDTH : integer := 8;
    NUM_HIDDEN_WIDTH : integer := 8);

  port (
    clk : in std_logic;
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    data_in_valid : in std_logic;
    data_number : in std_logic_vector(COUNT_WIDTH-1 downto 0);
    data_out : out std_logic_vector(15 downto 0);
    data_out_valid : out std_logic);
end mlp;

architecture default of mlp is
  constant HIDDEN : integer := NUM_HIDDEN_WIDTH**2;
  constant IN_COUNT : integer := COUNT_WIDTH**2;
  constant zero : unsigned(IN_COUNT-1 downto 0) := (others => '0');
  subtype half is std_logic_vector(15 downto 0);
  type W1t is array(IN_COUNT-1 downto 0, HIDDEN-1 downto 0) of half;
  type W2t is array(HIDDEN-1 downto 0) of half;

  -- parameters
  signal W1 : W1t := (others => (others => (others => '0')));
  signal B1 : W2t := (others => (others => '0'));
  signal W2 : W2t := (others => (others => '0'));
  signal B2 : half := (others => '0');

  signal float_in: half;
  signal float_out :half;
  signal l1_multiplication_in : W1t;
  signal l1_multiplication_out : W1t;
  signal l1_accumulation_in : W1t;
  signal l1_accumulation_out : W1t;
  signal l1_activation_in : W2t;
  signal l1_activation_out : W2t;
  signal l2_multiplication_in : W2t;
  signal l2_multiplication_out : W2t;
  signal l2_accumulation_in : W2t;
  signal l2_accumulation_out : W2t;

  type statet is record
    data_counter : unsigned(COUNT_WIDTH+1 downto 0);
    data_number : unsigned(COUNT_WIDTH-1 downto 0);
    finish : std_logic;
    float : half;
    float_valid : std_logic;
    float_last : std_logic;
    l1_multiplication : W1t;
    l1_multiplication_valid : std_logic;
    l1_multiplication_last : std_logic;
    l1_accumulation : W1t;
    l1_accumulation_valid : std_logic;
    l1_activation : W2t;
    l1_activation_valid : std_logic;
    l2_multiplication : W2t;
    l2_accumulation : W2t;
    l2_state : unsigned(NUM_HIDDEN_WIDTH downto 0);
  end record;

  signal state : statet := (
    data_counter => (others => '0'),
    data_number => (others => '0'),
    finish => '0',
    float => (others => '0'),
    float_valid => '0',
    float_last => '0',
    l1_multiplication => (others => (others => (others => '0'))),
    l1_multiplication_valid => '0',
    l1_multiplication_last => '0',
    l1_accumulation => (others => (others => (others => '0'))),
    l1_accumulation_valid => '0',
    l1_activation => (others => (others => '0')),
    l1_activation_valid => '0',
    l2_multiplication => (others => (others => '0')),
    l2_accumulation => (others => (others => '0')),
    l2_state => (others => '0')
  );

  component conv_half
    generic (
    DATA_WIDTH : integer := DATA_WIDTH);
    port (
    di : in std_logic_vector(DATA_WIDTH-1 downto 0);
    do : out half);
  end component;

  component mul
    port (
    da : in half;
    db : in half;
    do : out half);
  end component;

  component add
    port (
    da : in half;
    db : in half;
    do : out half);
  end component;

  component activate
    port (
    da : in half;
    do : out half);
  end component;
begin

  conv0 : conv_half port map (
  di => data_in,
  do => float_in);
  
  first_multiplication_i : for i in 0 to IN_COUNT-1 generate
    first_multiplication_j : for j in 0 to HIDDEN-1 generate
      mul0 : mul port map (
      da => state.float,
      db => W1(i, j),
      do => l1_multiplication_in(i, j));
    end generate;
  end generate;

  first_accumulation_0 : for j in 0 to HIDDEN-1 generate
    add0 : add port map (
    da => state.l1_multiplication(0, j),
    db => B1(j),
    do => l1_accumulation_in(0, j));
  end generate;

  first_accumulation_i : for i in 1 to IN_COUNT-1 generate
    first_accumulation_j : for j in 0 to HIDDEN-1 generate
      add1 : add port map (
      da => state.l1_multiplication(i, j),
      db => state.l1_accumulation(i-1, j),
      do => l1_accumulation_in(i, j));
    end generate;
  end generate;

  activation : for j in 0 to HIDDEN-1 generate
    act0 : activate port map (
    da => state.l1_accumulation(IN_COUNT-1, j),
    do => l1_activation_in(j));
  end generate;

  second_multiplication : for j in 0 to HIDDEN-1 generate
    mul1 : mul port map (
    da => state.l1_activation(j),
    db => W2(j),
    do => l2_multiplication_in(j));
  end generate;

  second_accumulation_0 : for j in 0 to HIDDEN/2-1 generate
    add2 : add port map (
    da => state.l2_multiplication(2*j),
    db => state.l2_multiplication(2*j+1),
    do => l2_accumulation_in(j+HIDDEN/2));
  end generate;

  second_accumulation_j : for j in NUM_HIDDEN_WIDTH-3 downto 1 generate
    second_accumulation_k : for k in 0 to 0 generate
      add3 : add port map (
      da => state.l2_accumulation((2*k)+(2**j)),
      db => state.l2_accumulation((2*k+1)+(2**j)),
      do => l2_accumulation_in(k+2**(j-1)));
    end generate;
  end generate;

  add4 : add port map (
  da => state.l2_accumulation(1),
  db => B2,
  do => data_out);

  process(clk)
    variable vstate : statet := state;
    variable vout_valid : std_logic;
  begin

    if data_in_valid = '1' then
      if unsigned(data_number) = zero then
        vstate.data_counter := state.data_counter+1;
        if state.data_counter = state.data_number then
          vstate.finish := '1';
        end if;
      else
        vstate.data_counter := (others => '0');
        vstate.data_number := unsigned(data_number);
      end if;

      vstate.float_valid := data_in_valid;
      if data_in_valid = '1' then
        vstate.float := float_in;
      else
        vstate.float := (others => '0');
      end if;
    else
      if state.finish = '1' then
        vstate.data_counter := state.data_counter+1;
      end if;
    end if;

    if state.data_counter = to_unsigned(IN_COUNT-1, COUNT_WIDTH) then
      vstate.float_last := '1';
      vstate.data_counter := (others => '0');
    else
      vstate.float_last := '0';
    end if;

    vstate.l1_multiplication_valid := state.float_valid;
    vstate.l1_multiplication_last := state.float_last;
    vstate.l1_multiplication := l1_multiplication_in;

    if state.l1_multiplication_valid = '1' then
      vstate.l1_accumulation := l1_accumulation_in;
      vstate.l1_accumulation_valid := state.l1_multiplication_last;
    end if;

    vstate.l1_activation := l1_activation_in;
    vstate.l1_activation_valid := state.l1_accumulation_valid;

    vstate.l2_state(0) := state.l1_accumulation_valid;
    for i in 1 to NUM_HIDDEN_WIDTH loop
      vstate.l2_state(i) := state.l2_state(i-1);
    end loop;

    vout_valid := state.l2_state(NUM_HIDDEN_WIDTH);

    if rising_edge(clk) then
      state <= vstate;
      data_out_valid <= vout_valid;
    end if;
  end process;

end default;
