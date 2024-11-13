MODULE Module1
    
    !Definición de datos de la herramienta
        PERS tooldata SCREW_TCP:=[TRUE,[[170,-101,99],[0.5,-0.5,0.5,-0.5]],[10.3,[5,5,24],[1,0,0,0],0.02,0.04,0.04]];
        PERS tooldata GRIP_TCP:=[TRUE,[[0,106,94],[0.866025404,-0.5,0,0]],[10.3,[5,5,24],[1,0,0,0],0.02,0.04,0.04]];
    
    !Definición de workobjects    
        TASK PERS wobjdata wobj_puerta_T:=[FALSE,TRUE,"",[[4205.674,937.104,745.873],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_capo:=[FALSE,TRUE,"",[[2030.291,1769.993,931.559],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_cinta_puertas:=[FALSE,TRUE,"",[[6220.923,-1719.9,-131.5],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_cinta_capo:=[FALSE,TRUE,"",[[3833.923,-2149.1,-108.5],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_cinta_ruedas:=[FALSE,TRUE,"",[[1567.923,-1778.1,-189.5],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_rueda_D:=[FALSE,TRUE,"",[[2206.103143142,968.450277461,383.706],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_rueda_T:=[FALSE,TRUE,"",[[4865.794706024,1027.186893933,383.706],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_puerta_D:=[FALSE,TRUE,"",[[3310.336,936.748,678.575],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        
    !Definición de posiciones
    
        !wobj0
            CONST robtarget Reposo_D:=[[1562.649944486,-101,1500.775681357],[0.965925826,0,0.258819045,0],[0,-1,0,0],[0,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
        !Workobjects definidos:
            CONST robtarget Coger_Capo:=[[0,0,0],[-0.000000048,-0.707106719,0.707106843,-0.00000009],[-1,0,1,0],[2688.06,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Capo:=[[-3.211913198,0,-3.341590369],[0.081517979,-0.702392184,0.702392241,-0.081517966],[0,1,1,1],[635.05,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Coger_Puerta:=[[0,0,5.596884504],[0,0,1,0],[-1,-1,-1,0],[5671.108806681,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Puerta_D:=[[0,-5.626592545,0],[0.675590207,-0.737277337,0,0],[0,-1,-1,1],[1480.21,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Puerta_T:=[[0,-1.477188671,29.563467176],[0.675590206,-0.737277338,-0.000000004,0.000000006],[0,-1,-1,1],[2387.78,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Coger_Rueda:=[[0,0,133.83313964],[-0.00000001,-0.000000022,1,0.000000049],[-1,-2,0,0],[892.655807084,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Rueda_T:=[[0,0,0],[0.500000022,-0.499999946,0.500000024,0.500000008],[0,-2,1,0],[3715.956349537,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Rueda_D:=[[0,0,0],[0.5,-0.5,0.5,0.5],[0,-2,1,0],[892.655807084,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    !Definición de variables del proceso
        VAR num offs_h;
        VAR num radio;
        VAR num agujeros;
        VAR num angulo;
        VAR num incremento;
        VAR num tipo_rueda;
        VAR  intnum interrupcion_intrusion;
        
    !Definición de velocidades
        VAR speeddata libre:= v3000;
        VAR speeddata manipulando:= v1500;
        VAR speeddata aproximacion:= v500;
        
    
!***********************************************************
!
!   Proyecto final Robótica Industrial
!
!
!   Autores: Joaquín Coloma, Andrés Gracia y Fernando Vela
!
!
!***********************************************************

!Procedimiento Main, reproducíendose en bucle continuo
    PROC main()
        
        !Poner a cero todas las salidas para no conservar valores anteriores
        SetDO Act_Gripper,0;
        SetDO Act_Screw,0;
        SetDO Cintas_Ruedas,0;
        SetDO Cinta_Principal,0;
        SetDO Cintas_Secundarias,0;
        SetDO Unir_Al_Coche,0;
        
        !Interrupción del movimiento conectada con rutina TRAP en caso de que haya intrusión del operario
        IDelete interrupcion_intrusion;
        CONNECT interrupcion_intrusion WITH rutina_parada;
        ISignalDI Parada_Emergencia,2,interrupcion_intrusion;
        
        !Ir a posición de inicio
        MoveJ Reposo_D,libre,fine,GRIP_TCP\WObj:=wobj0;
        
        !Esperar a selección del tipo de rueda
        WaitDI Seleccion,1;
        WaitTime 1;
        
        !Almacenar el tipo de rueda seleccionado
        tipo_rueda:= Obtener_tipo_rueda();
        
        !Introducir estructura principal a la línea
        SetDO Cinta_Principal,1;
        
        !Introducir piezas en la línea
        SetDO Cintas_Secundarias,1;
        SetDO Cintas_Ruedas,1;
    
        !Esperar a que la estructura llegue a la posición de trabajo
        WAITDI Estructura_Lista,1;
        SetDO Cinta_Principal,0;
        
        !Comenzar a ensamblar
        Ensamblado_Puertas;
        Ensamblado_Capo;
        Ensamblado_Ruedas(tipo_rueda);
        SetDO Unir_Al_Coche,1;
        WaitTime 3;
        SetDO Cinta_Principal,1;
        MoveJ Reposo_D,v1000,fine,GRIP_TCP\WObj:=wobj0;
        WaitDI Final_Cinta,1;
        
    ENDPROC
    
    PROC Ensamblado_Capo()
        
        !Coger el capó de la cinta de llegada
        MoveJ Offs(Coger_Capo,0,0,200),libre,fine,GRIP_TCP\WObj:=wobj_cinta_capo;
        MoveL Coger_Capo,aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_capo;
        SetDO Act_Gripper,1;
        WaitTime 1; 
        MoveL Offs(Coger_Capo,0,0,200),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_capo;
        
       !Colocarlo en su posición
        MoveJ Offs(Reposo_D,0,0,400),manipulando,fine,GRIP_TCP\WObj:=wobj0;
        MoveJ Offs(Poner_Capo,0,0,700),manipulando,fine,GRIP_TCP\WObj:=wobj_capo;
        MoveL Poner_Capo,aproximacion,fine,GRIP_TCP\WObj:=wobj_capo;
        SetDO Act_Gripper,0;
        WaitTime 1; 
        MoveL Offs(Poner_Capo,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_capo;     
        
    ENDPROC
    
    PROC Ensamblado_Puertas()
        
        !Coger la puerta delantera de la cinta de llegada
        MoveJ Offs(Coger_Puerta,0,0,600),libre,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        MoveL Coger_Puerta,aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        SetDO Act_Gripper,1;
        WaitTime 1; 
        MoveL Offs(Coger_Puerta,0,0,600),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        
        !Colocar la puerta delantera en su posición
        MoveJ Offs(Poner_Puerta_D,0,-300,0),manipulando,fine,GRIP_TCP\WObj:=wobj_puerta_D;
        MoveL Poner_Puerta_D,aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_D;
        SetDO Act_Gripper,0;
        WaitTime 1; 
        MoveL Offs(Poner_Puerta_D,0,-300,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_D;
        
        !Coger la puerta trasera de la cinta de llegada
        MoveJ Offs(Coger_Puerta,0,-131,600),libre,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        MoveL Offs(Coger_Puerta,0,-131,22),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        SetDO Act_Gripper,1;
        WaitTime 1; 
        MoveL Offs(Coger_Puerta,0,-131,600),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        
        !Colocar la puerta trasera en su posición
        MoveJ Offs(Poner_Puerta_T,0,-300,0),manipulando,fine,GRIP_TCP\WObj:=wobj_puerta_T;
        MoveL Poner_Puerta_T,aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_T;
        SetDO Act_Gripper,0;
        WaitTime 1; 
        MoveL Offs(Poner_Puerta_T,0,-300,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_T;
        
    ENDPROC
    
  PROC Ensamblado_Ruedas(num tipo_rueda)
        
        !Obtener los parámetros del proceso variable en función del tipo de rueda 
        offs_h:= Obtener_h (tipo_rueda);
        agujeros:=Obtener_agujeros(tipo_rueda);
        radio:=Obtener_radio(tipo_rueda);
        
        
        !Coger la rueda trasera de la cinta de llegada
        MoveJ Offs(Coger_Rueda,0,0,500),libre,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        MoveL Offs(Coger_Rueda,0,0,offs_h),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        SetDO Act_Gripper,1;
        WaitTime 1;
        MoveL Offs(Coger_Rueda,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        
        !Colocar la rueda trasera en su posición
        MoveJ Offs(Poner_Rueda_T,0,-300,0),manipulando,fine,GRIP_TCP\WObj:=wobj_rueda_T;
        MoveL Offs(Poner_Rueda_T,0,-offs_h,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_T;
        SetDO Act_Gripper,0;
        SetDO Cintas_Ruedas,0;
        WaitTime 1;
        MoveL Offs(Poner_Rueda_T,0,-300,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_T;
        
        !Proceso variable de atornillado de rueda trasera
        MoveL Offs(Poner_Rueda_T,0,-300,0),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
        angulo:=0;
        incremento:=360/agujeros;
        FOR i FROM 1 TO agujeros DO
            MoveL Offs(Poner_Rueda_T,radio*Sin(angulo),-300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
            MoveL Offs(Poner_Rueda_T,radio*Sin(angulo),-offs_h,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
            SetDO Act_Screw,1;
            WaitTime 1;
            SetDO Act_Screw,0;
            MoveL Offs(Poner_Rueda_T,radio*Sin(angulo),-300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
            angulo:=angulo+incremento;
        ENDFOR
        MoveL Offs(Poner_Rueda_T,0,-300,0),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
        
        !Coger la rueda delantera de la cinta de llegada
        MoveJ Offs(Coger_Rueda,0,0,500),libre,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        MoveL Offs(Coger_Rueda,0,0,offs_h),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        SetDO Act_Gripper,1;
        WaitTime 1;
        MoveL Offs(Coger_Rueda,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        
        !Colocar la rueda delantera en su posición
        MoveJ Offs(Poner_Rueda_D,0,-300,0),manipulando,fine,GRIP_TCP\WObj:=wobj_rueda_D;
        MoveL Offs(Poner_Rueda_D,0,-offs_h,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_D;
        SetDO Act_Gripper,0;
        WaitTime 1;
        MoveL Offs(Poner_Rueda_D,0,-300,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_D;
        
        !Proceso variable de atornillado de rueda delantera
        MoveL Offs(Poner_Rueda_D,0,-300,0),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
        angulo:=0;
        incremento:=360/agujeros;
        FOR i FROM 1 TO agujeros DO
            MoveL Offs(Poner_Rueda_D,radio*Sin(angulo),-300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
            MoveL Offs(Poner_Rueda_D,radio*Sin(angulo),-offs_h,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
            SetDO Act_Screw,1;
            WaitTime 1;
            SetDO Act_Screw,0;
            MoveL Offs(Poner_Rueda_D,radio*Sin(angulo),-300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
            angulo:=angulo+incremento;
        ENDFOR
        MoveL Offs(Poner_Rueda_D,0,-300,0),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
        
  ENDPROC
  
  !Función TRAP de interrupción para la parada de emergencia
  TRAP rutina_parada
      IF Parada_Emergencia=1 THEN
          StopMove;
      ELSEIF Parada_Emergencia=0 THEN
          StartMove;
      ELSE
      ENDIF
  ENDTRAP
  
  
 !Función para conservar el tipo de rueda de la iteración actual
  FUNC num Obtener_tipo_rueda()
    IF Ruedas_Serie=1 THEN
        return 1; 
    ELSEIF Ruedas_Deportivas=1 THEN
        RETURN 2;
    ELSEIF Ruedas_Camion=1 THEN
        RETURN 3;
    ENDIF
  ENDFUNC

  !Función para obtener el offset de altura de cada rueda
  FUNC num Obtener_h(num a)
    IF a=1 THEN
        return 0; 
    ELSEIF a=2 THEN
        RETURN 50;
    ELSEIF a=3 THEN
        RETURN 180;
    ENDIF
  ENDFUNC
  
  !Función para obtener el número de agujeros según la rueda
  FUNC num Obtener_agujeros(num a)
    IF a=1 THEN
        return 5; 
    ELSEIF a=2 THEN
        RETURN 5;
    ELSEIF a=3 THEN
        RETURN 8;
    ENDIF
  ENDFUNC
  
  !Función para obtener el radio según la rueda
  FUNC num Obtener_radio(num a)
    IF a=1 THEN
        return 40; 
    ELSEIF a=2 THEN
        RETURN 45;
    ELSEIF a=3 THEN
        RETURN 100;
    ENDIF
  ENDFUNC
  
 
    
ENDMODULE