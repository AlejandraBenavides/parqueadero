library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Parqueadero is
    port (
        FRONT_SENSOR : in std_logic;
        BACK_SENSOR : in std_logic;
        COUNTER_CLK : in std_logic;
        CLOCK : in std_logic;
        RESET : in std_logic;
        PASSWORD : in std_logic_vector(3 downto 0);
        SEGMENT : out std_logic_vector(6 downto 0);
        LED_RED : out std_logic;
        LED_GREEN : out std_logic
    );
end Parqueadero;

architecture Behavioral of Parqueadero is
    -- Estados
    type maquina_externa is (Inicio, Espera_contraseña, Verifica_contraseña, Verifica_BACK_SENSOR, Valor_servicio, Tiempo_uso);
    signal currentState : maquina_externa;
	 
	 type maquina_interna is (Escribe_clave, Segundo_intento, Tercer_intento, Intento_verificado, No_ingresa)
	 signal currentState2 : maquina_interna;
    
    -- Contador para el tiempo de servicio
    signal counter : unsigned(31 downto 0);
    
    -- Registro de tiempo de ingreso y salida
    signal entryTime : unsigned(31 downto 0);
    signal exitTime : unsigned(31 downto 0);
    
    -- Capacidad del parqueadero
    signal capacity : unsigned(2 downto 0);
    
     -- Contador para los intentos de contraseña
    signal retryCounter : integer range 0 to 3 := 0;
    
    -- Contraseña correcta
    constant correctPassword : std_logic_vector(3 downto 0) := "0001"; -- Reemplazar con la contraseña correcta en binario
    
begin
    -- Procesos de control
    
    process(CLOCK)
    begin
        if rising_edge(CLOCK) then
            if RESET = '1' then
                currentState <= IDLE;
					 currentState2 <= Escribe_clave;
                counter <= (others => '0');
                entryTime <= (others => '0');
                exitTime <= (others => '0');
                capacity <= "000";
                LED_RED <= '0';
                LED_GREEN <= '0';
            else
                case currentState is
                    when Inicio =>
                        if FRONT_SENSOR = '1' then
                            currentState <= Espera_contraseña;passwordAttempts <= 0;
                            LED_RED <= '0';
                            LED_GREEN <= '0';
                        end if;
                    
                    when Espera_contraseña =>
                        if FRONT_SENSOR = '0' then
								   currentState <= Verifica_contraseña;
								else 
							      currentState <= Espera_contraseña;
								end if;	
                            
											
                    
                    when Verifica_contraseña =>
                        if retryCounter < 3 then
								    if FRONT_SENSOR = '1' then
									    currentState <= Verifica_contraseña;
										 LED_RED <= '0';
                               LED_GREEN <= '0';
									 else
								       currentState <= Verifica_BACK_SENSOR;
										 LED_RED <= '0';
                               LED_GREEN <= '1';
									end if;
							   else
						         currentState <= Inicio;
							   end if;		
								
					
                    
                    when Verifica_BACK_SENSOR =>
                        if BACK_SENSOR = '1' then
                            currentState <= Valor_servicio;
                            entryTime <= counter;
                            capacity <= capacity - 1;
                            LED_RED <= '0';
                            LED_GREEN <= '1';
                        end if;
                    
                    when Valor_servicio =>
                        if FRONT_SENSOR = '1' then
                            currentState <= Espera_contraseña;
                            LED_RED <= '0';
                            LED_GREEN <= '0';
                        elsif BACK_SENSOR = '0' then
                            currentState <= Tiempo_uso;
                            exitTime <= counter;
                            capacity <= capacity + 1;
                            LED_RED <= '0';
                            LED_GREEN <= '0';
                        end if;
                    
                    when Tiempo_uso =>
                        if FRONT_SENSOR = '1' then
                            currentState <= Espera_contraseña;
                            LED_RED <= '0';
                            LED_GREEN <= '0';
                        end if;
                end case;
					 
					 
					case currentState2 is
								when Escribe_clave =>
									if currentState = Espera_contraseña then
											if PASSWORD = correctPassword then
                            currentState2 <= Intento_verificado;
									 retryCounter <= 0;
									 LED_RED <= '0';
									 LED_GREEN <= '1';
									      else
									 currentState2 <= Segundo_intento;
									 retryCounter <= retryCounter + 1;
								    LED_RED <= '1';
                            LED_GREEN <= '0';	 
											end if;
											
											
										when Segundo_intento =>
									      if PASSWORD = correctPassword then
                            currentState2 <= Intento_verificado;
									 retryCounter <= 0;
									 LED_RED <= '0';
                            LED_GREEN <= '1';
									      else
									 currentState2 <= Tercer_intento_intento;
									 retryCounter <= retryCounter + 1;
								    LED_RED <= '1';
                            LED_GREEN <= '0';	 
											end if;	
											
										when Tercer_intento =>
									      if PASSWORD = correctPassword then
                            currentState2 <= Intento_verificado;
									 retryCounter <= 0;
									 LED_RED <= '0';
                            LED_GREEN <= '1';
									      else
									 currentState2 <= No_ingresa;	
									 retryCounter <= retryCounter + 1;
									 LED_RED <= '1';
                            LED_GREEN <= '0'; 
											end if;		
											
								end if;			
					end case;			 
                
                if COUNTER_CLK = '1' then
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    
end Behavioral;
