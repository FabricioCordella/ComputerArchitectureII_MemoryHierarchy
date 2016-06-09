-------------------------------------------------------------------------
--
-- 32 bits PROCESSOR TESTBENCH    LITTLE  ENDIAN      13/october/2004
--
-- It must be observed that the processor is hold in reset
-- (rstCPU <= '1') at the start of simulation, being activated
-- (rstCPU <= '0') just after the end of the object file reading be the
-- testbench.
--
-- This testbench employs two memories implying a HARVARD organization
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;

package aux_functions is  

   subtype reg32  is std_logic_vector(31 downto 0);
   subtype reg16  is std_logic_vector(15 downto 0);
   subtype reg8   is std_logic_vector( 7 downto 0);
   subtype reg4   is std_logic_vector( 3 downto 0);

   -- definio do tipo 'memory', que ser utilizado para as memrias de dados/instrues
   constant MEMORY_SIZE : integer := 2048;     
   type memory is array (0 to MEMORY_SIZE) of reg8;

   constant TAM_LINHA : integer := 200;
   
   function CONV_VECTOR( letra : string(1 to TAM_LINHA);  pos: integer ) return std_logic_vector;
	
	type blocksL1 is array (3 downto 0) of reg32 ;--:=(others=>'0');

	type linhaL1 is record
			 validade : std_logic ;--:= '0';
			 tag : std_logic_vector(25 downto 0);--:=(others=>'0';);
			 blks : blocksL1;
	end record;
			
			
	type TypeCacheL1 is array (3 downto 0) of linhaL1;
   
end aux_functions;

package body aux_functions is

  --
  -- converte um caracter de uma dada linha em um std_logic_vector
  --
  function CONV_VECTOR( letra:string(1 to TAM_LINHA);  pos: integer ) return std_logic_vector is         
     variable bin: reg4;
   begin
      case (letra(pos)) is  
              when '0' => bin := "0000";
              when '1' => bin := "0001";
              when '2' => bin := "0010";
              when '3' => bin := "0011";
              when '4' => bin := "0100";
              when '5' => bin := "0101";
              when '6' => bin := "0110";
              when '7' => bin := "0111";
              when '8' => bin := "1000";
              when '9' => bin := "1001";
              when 'A' | 'a' => bin := "1010";
              when 'B' | 'b' => bin := "1011";
              when 'C' | 'c' => bin := "1100";
              when 'D' | 'd' => bin := "1101";
              when 'E' | 'e' => bin := "1110";
              when 'F' | 'f' => bin := "1111";
              when others =>  bin := "0000";  
      end case;
     return bin;
  end CONV_VECTOR;

end aux_functions;     

--------------------------------------------------------------------------
-- Module implementing a behavioral model of an ASYNCHRONOUS INTERFACE RAM
--------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.aux_functions.all;

entity RAM_mem is
      generic(  START_ADDRESS: reg32 := (others=>'0')  );
      port( ce_n, we_n, oe_n, bw: in std_logic;    address: in reg32;   data: inout reg32);
end RAM_mem;

architecture RAM_mem of RAM_mem is 
   signal RAM : memory;
   signal tmp_address: reg32;
   alias  low_address: reg16 is tmp_address(15 downto 0);    --  baixa para 16 bits devido ao CONV_INTEGER --
begin     

   tmp_address <= address - START_ADDRESS;   --  offset do endereamento  -- 
   
   -- writes in memory ASYNCHRONOUSLY  -- LITTLE ENDIAN -------------------
   process(ce_n, we_n, low_address, data)
     begin
       if ce_n='0' and we_n='0' then
          if CONV_INTEGER(low_address)>=0 and CONV_INTEGER(low_address+3)<=MEMORY_SIZE then
               if bw='1' then
                   RAM(CONV_INTEGER(low_address+3)) <= data(31 downto 24);
                   RAM(CONV_INTEGER(low_address+2)) <= data(23 downto 16);
                   RAM(CONV_INTEGER(low_address+1)) <= data(15 downto  8);
               end if;
               RAM(CONV_INTEGER(low_address  )) <= data( 7 downto  0); 
          end if;
         end if;   
    end process;   
    
   -- read from memory
   process(ce_n, oe_n, low_address)
     begin
       if ce_n='0' and oe_n='0' and
          CONV_INTEGER(low_address)>=0 and CONV_INTEGER(low_address+3)<=MEMORY_SIZE then
            data(31 downto 24) <= RAM(CONV_INTEGER(low_address+3));
            data(23 downto 16) <= RAM(CONV_INTEGER(low_address+2));
            data(15 downto  8) <= RAM(CONV_INTEGER(low_address+1));
            data( 7 downto  0) <= RAM(CONV_INTEGER(low_address  ));
        else
            data(31 downto 24) <= (others=>'Z');
            data(23 downto 16) <= (others=>'Z');
            data(15 downto  8) <= (others=>'Z');
            data( 7 downto  0) <= (others=>'Z');
        end if;
   end process;   

end RAM_mem;


--------------------------------------------------------------------------
-- Module implementing a behavioral model of an ASYNCHRONOUS INTERFACE RAM
--------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.aux_functions.all;

entity INST_mem is
      generic(  START_ADDRESS: reg32 := (others=>'0')  );
      port(ce_n, we_n, oe_n, bw: in std_logic;
			address: in reg32;
			reset : in std_logic;
			mem_access : in std_logic;
			hold: out std_logic;
			data: inout reg32
			);
end INST_mem;

architecture INST_mem of INST_mem is 
   signal RAM : memory;
   signal tmp_address: reg32;
	signal ready: std_logic:='0';
   alias  low_address: reg16 is tmp_address(15 downto 0);    --  baixa para 16 bits devido ao CONV_INTEGER --
begin     

   tmp_address <= address - START_ADDRESS;   --  offset do endereamento  -- 
   
   -- writes in memory ASYNCHRONOUSLY  -- LITTLE ENDIAN -------------------
   process(ready,ce_n, we_n, low_address, data)
     begin
		if ready='1' or reset='1' then
       if ce_n='0' and we_n='0' then
          if CONV_INTEGER(low_address)>=0 and CONV_INTEGER(low_address+3)<=MEMORY_SIZE then
               if bw='1' then
                   RAM(CONV_INTEGER(low_address+3)) <= data(31 downto 24);
                   RAM(CONV_INTEGER(low_address+2)) <= data(23 downto 16);
                   RAM(CONV_INTEGER(low_address+1)) <= data(15 downto  8);
               end if;
               RAM(CONV_INTEGER(low_address  )) <= data( 7 downto  0); 
          end if;
         end if;
		end if;
    end process;   
    
   -- read from memory
   --process(ce_n, oe_n, low_address)
	process(ready, ce_n, oe_n, low_address)
     begin
	  if ready='1' or reset='1' then
	  --if ready='1' then
       if ce_n='0' and oe_n='0' and
          CONV_INTEGER(low_address)>=0 and CONV_INTEGER(low_address+3)<=MEMORY_SIZE then
            data(31 downto 24) <= RAM(CONV_INTEGER(low_address+3));
            data(23 downto 16) <= RAM(CONV_INTEGER(low_address+2));
            data(15 downto  8) <= RAM(CONV_INTEGER(low_address+1));
            data( 7 downto  0) <= RAM(CONV_INTEGER(low_address  ));
        else
            data(31 downto 24) <= (others=>'Z');
            data(23 downto 16) <= (others=>'Z');
            data(15 downto  8) <= (others=>'Z');
            data( 7 downto  0) <= (others=>'Z');
        end if;
	  end if;
   end process;   
	
	--hold <= '0','1' after 80ns when mem_access='1' else '0';
	--hold <= '0';
	process(mem_access,reset)
	begin
		if reset='1' then
			hold<='0';
		elsif mem_access'event and mem_access='1' then
			hold <= '1', '0' after 80 ns;
			ready <= '0','1' after 80 ns ;
		end if;
   end process;
end INST_mem;


--------------------------------------------------------------------------
-- Module implementing a behavioral model of an CACHE L1
--------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.aux_functions.all;



entity CacheL1 is
      --generic(  START_ADDRESS: reg32 := (others=>'0')  );
      port(
			clock, reset : in std_logic;
			address: in reg32;
			data: inout reg32;
			addressOut : out reg32;
			cache_access : out std_logic;
			hold: out std_logic
			);
end CacheL1;

architecture CacheL1 of CacheL1 is 

	type type_state is (STOPPED, IDLE, VERIFY_CACHE, SEND_CPU, WAIT_B0,WAIT_B1, WAIT_B2, WAIT_B3, WRITE_CACHE);
   signal EA, PE : type_state;

	signal cache : TypeCacheL1:= (others=>(validade=>'0',tag=>(others=>'0'),blks=>(others=>(others=>'0'))));--('0',others=>'0',others=>(others=>'0')));
	signal hit, miss: std_logic:='0';
	signal linha, bloco : std_logic_vector(1 downto 0);
	signal tag : std_logic_vector(25 downto 0);
	signal c		: integer:='0';
   --signal RAM : memory;
   --signal tmp_address: reg32;
	--signal ready: std_logic:='0';
   --alias  low_address: reg16 is tmp_address(15 downto 0);    --  baixa para 16 bits devido ao CONV_INTEGER --
begin     

	tag	<= address(31 downto 6);
	bloco <= address(3 downto 2);
	linha <= address(5 downto 4);

	 process(clock, reset)
    begin
       if reset='1' then
         EA <= STOPPED;          -- Sidle is the state the machine stays while processor is being reset
       elsif ck'event and ck='1' then
		   --if hold='0' then
				--if PS=Sidle then
					--PS <= Sfetch;
				--else
			EA <= PE;
				--end if;
			--end if;
		 end if;
    end process;

	process(EA,PE, address,data)
	begin
		if 
		case EA is
				when STOPPED => 
						if reset='1' then
							PE <= STOPPED;
						else
							PE <= IDLE;
						end if;
						
				when IDLE =>
						if address'event then
							PE <= VERIFY_CACHE;
						
				when	VERIFY_CACHE =>
						if cache(CONV_INTEGER(linha)).validade ='1' and cache(CONV_INTEGER(linha)).tag = tag then
							hit<'1';
							PE <= SEND_CPU;
						else
							miss<='1';
							--addressOut <= address;
							hold<='1';
							c=0;
							PE<=WAIT_B0;
						end if;
								
				when	WAIT_B0 => 
						--if address'event then
						if c<4 then
							PE <= WAIT_B0;
							addressOut<= tag&linha&-->>>>>>>>>>TODO CONVERTER INT-> BINARIO<<<<<<&"00";
							cache(CONV_INTEGER(linha)).blks(c) <= data;
							c<=c+1;
						if c=4 then
							PE=<WAIT_B1
							
				when	WAIT_B1, 
				when	WAIT_B2, 
				when	WAIT_B3, 
				when	WRITE_CACHE
				when	SEND_CPU, 
		end case;
	end process;

--		STOPPED
--			|
--			|
--			V
--		 IDLE <------------------------------------------
--			|															|
--			|															|
--			|															|
--	 VERIFY_CACHE -------> WRITE_CACHE						|
--			|						|									|
--			|						V		C<4						|
--			|					 WAIT_B1 ----						|
--			|						|	^		|C<4					|
--			|					C=4|	-------						|
--			|						V									|
--			|					 WAIT_B1 ----						|
--			|						|	^		|C<4					|
--			|					C=4|	-------						|
--			|						V									|
--			|HIT='1' 		 WAIT_B2 ----						|
--			|						|	^		|C<4					|
--			|					C=4|	-------						|
--			|						V									|
--			|					 WAIT_B3 ----						|
--			|						|	^		|C<4					|
--			|					C=4|	------						|
--			|						|									|
--			V						|									|
--		SEND_CPU	<------------									|
--			|															|
--			----------------------------------------------







   process(clock, reset)
	  begin
		if reset='1' then
			hold<='0';
		elsif clock'event and clock='1' then
			if cache(CONV_INTEGER(linha)).validade ='0' then
				cache_access <= '1';
				miss <= '1';
				hold<='1';
				addressOut <= address;
				--wait for 80ns;
				--cache(CONV_INTEGER(linha)).
			end if;
		end if;
	end process;
	
end CacheL1;





-------------------------------------------------------------------------
--  CPU PROCESSOR SIMULATION TESTBENCH
-------------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;          
use STD.TEXTIO.all;
use work.aux_functions.all;

entity CPU_tb is
end CPU_tb;

architecture cpu_tb of cpu_tb is
    
    signal Dadress, Ddata, Iadress, Idata,
           i_cpu_address, d_cpu_address, data_cpu, tb_add, tb_data : reg32 := (others => '0' );
    
    signal Dce_n, Dwe_n, Doe_n, Ice_n, Iwe_n, Ioe_n, ck, rst, rstCPU,
           go_i, go_d, ce, rw, bw: std_logic;
    
	 
	 
	 signal IadressOut, IdataOut : std_logic_vector(31 downto 0) :=(others=>'0');
	 signal ck_mp, ck_l2 : std_logic:='0';
	 signal barr_rst	:std_logic;
	 signal mem_access: std_logic;--:='0';
	 signal addressTest : reg32:=x"00400020";
	 signal hold, hold_cache : std_logic:='0';
	 signal addressOut : reg32;
	 signal cache_access : std_logic;
	 
    file ARQ : TEXT open READ_MODE is "PCSpim.log";
 
begin
           
    Data_mem:  entity work.RAM_mem 
               generic map( START_ADDRESS => x"10010000" )
               port map (ce_n=>Dce_n, we_n=>Dwe_n, oe_n=>Doe_n, bw=>bw, address=>Dadress, data=>Ddata);

                                            
    Instr_mem: entity work.INST_mem 
               generic map( START_ADDRESS => x"00400020" )
					port map (	reset=> rst, 
									mem_access=>cache_access, 
									hold=> hold, 
									ce_n=>Ice_n, 
									we_n=>Iwe_n, 
									oe_n=>Ioe_n, 
									bw=>'1', 
									address=>addressOut, 
									data=>Idata
									);
               --port map (ce_n=>Ice_n, we_n=>Iwe_n, oe_n=>Ioe_n, bw=>'1', address=>Iadress, data=>Idata);

	 --TODO
		CacheL1: entity work.CacheL1
					port map (	clock=> ck, 
									reset=> rst, 
									address => Iadress, 
									data=>Idata, 
									cache_access=>cache_access,
									hold=>hold_cache,
									addressOut=> addressOut
									);

			



	 addressTest <= Iadress when rst='1' else
						addressTest+4 after 80ns;
     
	 --ck_l2 <= not ck_l2 	when (ck'event AND ck='1');
	 --ck_mp <= not ck_mp when (ck_l2'event and ck_l2='1');
	  
	  
    --hold <= '0';


    -- data memory signals --------------------------------------------------------
    Dce_n <= '0' when  ce='1' or go_d='1'             else '1';
    Doe_n <= '0' when (ce='1' and rw='1')             else '1';       
    Dwe_n <= '0' when (ce='1' and rw='0') or go_d='1' else '1';    

    Dadress <= tb_add  when rstCPU='1' else d_cpu_address;
    Ddata   <= tb_data when rstCPU='1' else data_cpu when (ce='1' and rw='0') else (others=>'Z'); 
    
    data_cpu <= Ddata when (ce='1' and rw='1') else (others=>'Z');
    
    -- instructions memory signals --------------------------------------------------------
    Ice_n <= '0';                                 
    Ioe_n <= '1' when rstCPU='1' else '0';           -- impede leitura enquanto est escrevendo                             
    Iwe_n <= '0' when go_i='1'   else '1';           -- escrita durante a leitura do arquivo 
    
    Iadress <= tb_add  when rstCPU='1' else i_cpu_address;
    Idata   <= tb_data when rstCPU='1' else (others => 'Z'); 
  

    cpu: entity work.MRstd  port map(
              clock=>ck, 
				  reset=>rstCPU,	
				  --hold=>hold,
				  hold => hold_cache,
              i_address => i_cpu_address,
              instruction => Idata,
              ce=>ce,  
				  rw=>rw,  
				  bw=>bw,
              d_address => d_cpu_address,
              data => data_cpu,
				  mem_access=> mem_access
        ); 

    rst <='1', '0' after 18 ns;       -- generates the reset signal 

    process                          -- generates the clock signal 
        begin
        ck <= '1', '0' after 10 ns;
        wait for 20 ns;
    end process;

    
    ----------------------------------------------------------------------------
    -- this process loads the instruction memory and the data memory during reset
    --
    --
    --   O PROCESSO ABAIXO  UMA PARSER PARA LER CDIGO GERADO PELO SPIM NO
    --   SEGUINTE FORMATO:
    --
    --      .CODE
    --      [0x00400020]        0x3c011001  lui $1, 4097 [d2]               ; 16: la    $t0, d2
    --      [0x00400024]        0x34280004  ori $8, $1, 4 [d2]
    --      [0x00400028]        0x8d080000  lw $8, 0($8)                    ; 17: lw    $t0,0($t0)
    --      .....
    --      [0x00400048]        0x0810000f  j 0x0040003c [loop]             ; 30: j     loop
    --      [0x0040004c]        0x01284821  addu $9, $9, $8                 ; 32: addu $t1, $t1, $t0
    --      [0x00400050]        0x08100014  j 0x00400050 [x]                ; 34: j     x
    --      .DATA
    --      [0x10010000]                        0x0000faaa  0x00000083  0x00000000  0x00000000
    --
    ----------------------------------------------------------------------------
    process
        variable ARQ_LINE : LINE;
        variable line_arq : string(1 to 200);
        variable code     : boolean;
        variable i, address_flag : integer;
    begin  
        go_i <= '0';
        go_d <= '0';
        rstCPU <= '1';           -- hold the processor during file reading
        code:=true;              -- default value of code is 1 (CODE)
                                 
        wait until rst = '1';
        
        while NOT (endfile(ARQ)) loop    -- INCIO DA LEITURA DO ARQUIVO CONTENDO INSTRUO E DADOS -----
            readline(ARQ, ARQ_LINE);      
            read(ARQ_LINE, line_arq(1 to  ARQ_LINE'length) );
                        
            if line_arq(1 to 5)=".CODE" then 
                   code:=true;                     -- code 
            elsif line_arq(1 to 5)=".DATA" then
                   code:=false;                    -- data 
            else 
               i := 1;                                  -- LEITORA DE LINHA - analizar o loop abaixo para compreender 
               address_flag := 0;                       -- para INSTRUO  um para (end,inst)
                                                        -- para DADO aceita (end, dado 0, dado 1, dado 2 ....)
               loop                                     
                  if line_arq(i) = '0' and line_arq(i+1) = 'x' then      -- encontrou indicao de nmero hexa: '0x'
                         i := i + 2;
                         if address_flag=0 then
                               for w in 0 to 7 loop
                                   tb_add( (31-w*4) downto (32-(w+1)*4))  <= CONV_VECTOR(line_arq,i+w);
                               end loop;    
                               i := i + 8; 
                               address_flag := 1;
                         else
                               for w in 0 to 7 loop
                                   tb_data( (31-w*4) downto (32-(w+1)*4))  <= CONV_VECTOR(line_arq,i+w);
                               end loop;    
                               i := i + 8;
                               
                               wait for 0.1 ns;
                               
                               if code=true then go_i <= '1';    -- the go_i signal enables instruction memory writing
                                            else go_d <= '1';    -- the go_d signal enables data memory writing
                               end if; 
                               
                               wait for 0.1 ns;
                               
                               tb_add <= tb_add + 4;       -- *great!* consigo ler mais de uma word por linha!
                               go_i <= '0';
                               go_d <= '0'; 
                               
                               address_flag := 2;    -- sinaliza que j leu o contedo do endereo;

                         end if;
                  end if;
                  i := i + 1;
                  
                  -- sai da linha quando chegou no seu final OU j leu par(endereo, instruo) no caso de cdigo
                  exit when i=TAM_LINHA or (code=true and address_flag=2);
               end loop;
            end if;
            
        end loop;                        -- FINAL DA LEITURA DO ARQUIVO CONTENDO INSTRUO E DADOS -----
        
        rstCPU <= '0';   -- release the processor to execute
        wait for 2 ns;   -- To activate the RST CPU signal
        wait until rst = '1';  -- to Hold again!
        
    end process;
    
end cpu_tb;
