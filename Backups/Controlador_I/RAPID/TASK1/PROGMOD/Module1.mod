MODULE Module1
    
    !Definición de datos de la herramienta
        PERS tooldata SCREW_TCP:=[TRUE,[[170,-101,99],[0.5,-0.5,0.5,-0.5]],[10.3,[5,5,24],[1,0,0,0],0.02,0.04,0.04]];
        PERS tooldata GRIP_TCP:=[TRUE,[[0,106,94],[0.866025404,-0.5,0,0]],[10.3,[5,5,24],[1,0,0,0],0.02,0.04,0.04]];
    
    !Definición de workobjects 
        TASK PERS wobjdata wobj_maletero:=[FALSE,TRUE,"",[[5519.725,-2154.27,1118.321],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_puerta_T:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[4231.103,-1317.702,774.748],[1,0,0,0]]];
        TASK PERS wobjdata wobj_puerta_D:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[3317.634,-1317.059,670.933],[1,0,0,0]]];
        TASK PERS wobjdata wobj_rueda_D:=[FALSE,TRUE,"",[[2201.15,-1360.158691119,364.670844709],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_cinta_puertas:=[FALSE,TRUE,"",[[6185.923,1642.467,-125.5],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_cinta_maletero:=[FALSE,TRUE,"",[[3795.922534271,2061.667428489,-42.5],[0.958072899,0,0.286524553,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_cinta_ruedas:=[FALSE,TRUE,"",[[1567.923,1675.667,-189.5],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
        TASK PERS wobjdata wobj_rueda_T:=[FALSE,TRUE,"",[[4854.671891248,-1360.158691119,362.870844709],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
    
    !Definición de posiciones
    
        !wobj
            CONST robtarget Reposo_I:=[[1562.649944486,-101,1500.775681357],[0.965925826,0,0.258819045,0],[0,-1,0,0],[0,9E+09,9E+09,9E+09,9E+09,9E+09]];
            
        !workobjects_definidos
            CONST robtarget Coger_Maletero:=[[0,0,0],[0,1,0,0],[1,1,1,0],[4271.01,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Maletero:=[[0,0,0],[0,0,1,0],[-2,0,-2,0],[5677.093696939,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Coger_Puerta:=[[0,0,0],[-0.00000004,1,0.000001339,0.000000541],[0,-3,1,0],[5000.56,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Puerta_D:=[[0,0,0],[0,0,0.725374371,-0.688354575],[-1,-2,0,0],[1748.932868488,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Puerta_T:=[[-2.711465729,0.000428489,49.391],[0,0,0.743144825,-0.669130606],[-1,-2,0,0],[2713.864931459,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Coger_Rueda:=[[0,0,132.36838489],[-0.000000058,1,0.00000195,0.000000823],[0,-3,1,0],[1140.66335602,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Rueda_T:=[[0,0,0],[0.500000006,0.499999996,-0.500000002,0.499999995],[-1,-3,0,0],[3580.39044251,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CONST robtarget Poner_Rueda_D:=[[0,0,0],[0.499999996,0.499999996,-0.500000004,0.500000004],[-1,-2,-1,0],[424.959882848,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
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
        
        !Interrupción del movimiento conectada con rutina TRAP en caso de que haya intrusión del operario
        IDelete interrupcion_intrusion;
        CONNECT interrupcion_intrusion WITH rutina_parada;
        ISignalDI Parada_Emergencia,2,interrupcion_intrusion;
        
        !Ir a la poscición de inicio
        MoveJ Reposo_I,libre,fine,GRIP_TCP\WObj:=wobj0;
        
        !Esperar a selección del tipo de rueda;
        WaitDI Seleccion,1;
        WaitTime 1;
        
        !Almacenar el tipo de rueda seleccionado
        tipo_rueda:= Obtener_tipo_rueda();
        
        !Esperar a que la estructura llegue a la posición de trabajo
        WAITDI Estructura_Lista,1;
    
        !Comenzar a ensamblar
        Ensamblado_Puertas;
        Ensamblado_Maletero;
        Ensamblado_Ruedas;
        WaitTime 3;
        MoveJ Reposo_I,v1000,fine,GRIP_TCP\WObj:=wobj0;
        WaitDI Final_Cinta,1;
        
    ENDPROC
    
    PROC Ensamblado_Maletero()
        
        !Coger el maletero de la cinta de llegada
        MoveJ Offs(Coger_Maletero,0,0,500),libre,fine,GRIP_TCP\WObj:=wobj_cinta_maletero;
        MoveL Coger_Maletero,aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_maletero;
        SetDO Act_Gripper,1;
        WaitTime 1;
        MoveL Offs(Coger_Maletero,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_maletero;
        
        !Colocarlo en su posición
        MoveJ Offs(Poner_Maletero,0,0,500),manipulando,fine,GRIP_TCP\WObj:=wobj_maletero;
        MoveL Poner_Maletero,aproximacion,fine,GRIP_TCP\WObj:=wobj_maletero;
        SetDO Act_Gripper,0;
        WaitTime 1;
        MoveL Offs(Poner_Maletero,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_maletero;

    ENDPROC
    
    PROC Ensamblado_Puertas()
        
        !Coger la puerta delantera de la cinta de llegada
        MoveJ Offs(Coger_Puerta,0,0,500),libre,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        MoveL Coger_Puerta,aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        SetDO Act_Gripper,1;
        WaitTime 1;
        MoveL Offs(Coger_Puerta,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        
        !Colocar la puerta delantera en su posición
        MoveJ Offs(Poner_Puerta_D,0,200,0),manipulando,fine,GRIP_TCP\WObj:=wobj_puerta_D;
        MoveL Poner_Puerta_D,aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_D;
        SetDO Act_Gripper,0;
        WaitTime 1;
        MoveL Offs(Poner_Puerta_D,0,200,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_D;
        
        !Coger la puerta trasera de la cinta de llegada
        MoveJ Offs(Coger_Puerta,0,0,500),libre,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        MoveL Coger_Puerta,aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        SetDO Act_Gripper,1;
        WaitTime 1;
        MoveL Offs(Coger_Puerta,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_puertas;
        
        !Colocar la puerta trasera en su posición
        MoveJ Offs(Poner_Puerta_T,0,200,0),manipulando,fine,GRIP_TCP\WObj:=wobj_puerta_T;
        MoveL Poner_Puerta_T,aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_T;
        SetDO Act_Gripper,0;
        WaitTime 1;
        MoveL Offs(Poner_Puerta_T,0,200,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_puerta_T;
        
    ENDPROC
    
    PROC Ensamblado_Ruedas()
        
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
        MoveJ Offs(Poner_Rueda_T,0,300,0),manipulando,fine,GRIP_TCP\WObj:=wobj_rueda_T;
        MoveL Offs(Poner_Rueda_T,0,offs_h,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_T;
        SetDO Act_Gripper,0;
        WaitTime 1;
        MoveL Offs(Poner_Rueda_T,0,300,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_T;
        
        !Proceso variable de atornillado de rueda trasera
        MoveL Offs(Poner_Rueda_T,0,300,0),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
        angulo:=0;
        incremento:=360/agujeros;
        FOR i FROM 1 TO agujeros DO
            MoveL Offs(Poner_Rueda_T,-radio*Sin(angulo),300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
            MoveL Offs(Poner_Rueda_T,-radio*Sin(angulo),offs_h,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
            SetDO Act_Screw,1;
            WaitTime 1;
            SetDO Act_Screw,0;
            MoveL Offs(Poner_Rueda_T,-radio*Sin(angulo),300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_T;
            angulo:=angulo+incremento;
        ENDFOR
        
        !Coger la rueda delantera de la cinta de llegada
        MoveJ Offs(Coger_Rueda,0,0,500),libre,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        MoveL Offs(Coger_Rueda,0,0,offs_h),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        SetDO Act_Gripper,1;
        WaitTime 1;
        MoveL Offs(Coger_Rueda,0,0,500),aproximacion,fine,GRIP_TCP\WObj:=wobj_cinta_ruedas;
        
        !Colocar la rueda delantera en su posición
        MoveJ Offs(Poner_Rueda_D,0,300,0),manipulando,fine,GRIP_TCP\WObj:=wobj_rueda_D;
        MoveL Offs(Poner_Rueda_D,0,offs_h,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_D;
        SetDO Act_Gripper,0;
        WaitTime 1;
        MoveL Offs(Poner_Rueda_D,0,300,0),aproximacion,fine,GRIP_TCP\WObj:=wobj_rueda_D;
        
        !Proceso variable de atornillado de rueda delantera
        MoveL Offs(Poner_Rueda_D,0,300,0),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
        angulo:=0;
        incremento:=360/agujeros;
        FOR i FROM 1 TO agujeros DO
            MoveL Offs(Poner_Rueda_D,-radio*Sin(angulo),300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
            MoveL Offs(Poner_Rueda_D,-radio*Sin(angulo),offs_h,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
            SetDO Act_Screw,1;
            WaitTime 1;
            SetDO Act_Screw,0;
            MoveL Offs(Poner_Rueda_D,-radio*Sin(angulo),300,-radio*cos(angulo)),aproximacion,fine,SCREW_TCP\WObj:=wobj_rueda_D;
            angulo:=angulo+incremento;
        ENDFOR
        
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
    
    !Función para obtener el offset de altura según la rueda
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