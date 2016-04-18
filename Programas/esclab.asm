
_CalcularCRC:

;esclab.mbas,28 :: 		sub procedure CalcularCRC()
;esclab.mbas,29 :: 		crc=65535
	MOVLW      255
	MOVWF      _CRC+0
	MOVLW      255
	MOVWF      _CRC+1
;esclab.mbas,30 :: 		for iter=0 to Longitud - 1
	CLRF       _Iter+0
L__CalcularCRC1:
	DECF       _Longitud+0, 0
	MOVWF      R2+0
	MOVF       _Iter+0, 0
	SUBWF      R2+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__CalcularCRC5
;esclab.mbas,31 :: 		crc=crc xor mensaje[iter]
	MOVF       _Iter+0, 0
	ADDLW      _Mensaje+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      _CRC+0, 1
	MOVLW      0
	XORWF      _CRC+1, 1
;esclab.mbas,32 :: 		for bites= 1 to 8
	MOVLW      1
	MOVWF      _bites+0
L__CalcularCRC7:
;esclab.mbas,33 :: 		if crc mod 2 then
	BTFSS      _CRC+0, 0
	GOTO       L__CalcularCRC12
;esclab.mbas,34 :: 		crc=(crc / 2) xor 40961
	RRF        _CRC+1, 1
	RRF        _CRC+0, 1
	BCF        _CRC+1, 7
	MOVLW      1
	XORWF      _CRC+0, 1
	MOVLW      160
	XORWF      _CRC+1, 1
	GOTO       L__CalcularCRC13
;esclab.mbas,35 :: 		else
L__CalcularCRC12:
;esclab.mbas,36 :: 		crc=crc / 2
	RRF        _CRC+1, 1
	RRF        _CRC+0, 1
	BCF        _CRC+1, 7
;esclab.mbas,37 :: 		end if
L__CalcularCRC13:
;esclab.mbas,38 :: 		next bites
	MOVF       _bites+0, 0
	XORLW      8
	BTFSC      STATUS+0, 2
	GOTO       L__CalcularCRC10
	INCF       _bites+0, 1
	GOTO       L__CalcularCRC7
L__CalcularCRC10:
;esclab.mbas,39 :: 		next iter
	MOVF       _Iter+0, 0
	XORWF      R2+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L__CalcularCRC5
	INCF       _Iter+0, 1
	GOTO       L__CalcularCRC1
L__CalcularCRC5:
;esclab.mbas,40 :: 		CRC_h=hi(crc)
	MOVF       _CRC+1, 0
	MOVWF      _CRC_H+0
;esclab.mbas,41 :: 		CRC_l=lo(crc)
	MOVF       _CRC+0, 0
	MOVWF      _CRC_L+0
;esclab.mbas,42 :: 		end sub
	RETURN
; end of _CalcularCRC

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;esclab.mbas,43 :: 		sub procedure interrupt()
;esclab.mbas,44 :: 		GIE_bit = 0
	BCF        GIE_bit+0, 7
;esclab.mbas,45 :: 		if uart1_data_ready=1 then
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt16
;esclab.mbas,46 :: 		Recivido=uart1_read
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _Recivido+0
;esclab.mbas,47 :: 		llamada[0]=llamada[1]
	MOVF       _Llamada+1, 0
	MOVWF      _Llamada+0
;esclab.mbas,48 :: 		llamada[1]=llamada[2]
	MOVF       _Llamada+2, 0
	MOVWF      _Llamada+1
;esclab.mbas,49 :: 		llamada[2]=llamada[3]
	MOVF       _Llamada+3, 0
	MOVWF      _Llamada+2
;esclab.mbas,50 :: 		llamada[3]=recivido
	MOVF       R0+0, 0
	MOVWF      _Llamada+3
;esclab.mbas,51 :: 		if Llamada[1]=esclavo then
	MOVF       _Llamada+1, 0
	XORWF      _Esclavo+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt19
;esclab.mbas,52 :: 		mensaje[0]=llamada[0]
	MOVF       _Llamada+0, 0
	MOVWF      _Mensaje+0
;esclab.mbas,53 :: 		Mensaje[1]=llamada[1]
	MOVF       _Llamada+1, 0
	MOVWF      _Mensaje+1
;esclab.mbas,54 :: 		Longitud=2
	MOVLW      2
	MOVWF      _Longitud+0
;esclab.mbas,55 :: 		CalcularCRC
	CALL       _CalcularCRC+0
;esclab.mbas,56 :: 		CRC_ok=false
	CLRF       _CRC_ok+0
;esclab.mbas,57 :: 		if Llamada[3]=crc_h then
	MOVF       _Llamada+3, 0
	XORWF      _CRC_H+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt22
;esclab.mbas,58 :: 		if Llamada[2]=crc_l then
	MOVF       _Llamada+2, 0
	XORWF      _CRC_L+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt25
;esclab.mbas,59 :: 		if Llamada[0]=15 then
	MOVF       _Llamada+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt28
;esclab.mbas,60 :: 		ledrojo=0                ' encender led rojo
	BCF        PORTC+0, 0
;esclab.mbas,61 :: 		portc.1=1                ' apagar led verde
	BSF        PORTC+0, 1
L__interrupt28:
;esclab.mbas,63 :: 		if Llamada[0]=6 then
	MOVF       _Llamada+0, 0
	XORLW      6
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt31
;esclab.mbas,64 :: 		portc.0=1                ' apagar el led rojo
	BSF        PORTC+0, 0
;esclab.mbas,65 :: 		portc.1=0                ' encender led verde
	BCF        PORTC+0, 1
;esclab.mbas,67 :: 		porta.4=1
	BSF        PORTA+0, 4
L__interrupt31:
;esclab.mbas,69 :: 		if Llamada[0]=5 then
	MOVF       _Llamada+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt34
;esclab.mbas,70 :: 		clrwdt
	CLRWDT
;esclab.mbas,71 :: 		CRC_ok=true
	MOVLW      255
	MOVWF      _CRC_ok+0
;esclab.mbas,72 :: 		porta.5=0
	BCF        PORTA+0, 5
;esclab.mbas,73 :: 		adc_init
	CALL       _ADC_Init+0
;esclab.mbas,74 :: 		Suma=0
	CLRF       _Suma+0
	CLRF       _Suma+1
;esclab.mbas,75 :: 		for Iter=1 to 3
	MOVLW      1
	MOVWF      _Iter+0
L__interrupt37:
;esclab.mbas,76 :: 		Temp = adc_read(0)
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	MOVWF      _Temp+0
	MOVF       R0+1, 0
	MOVWF      _Temp+1
;esclab.mbas,77 :: 		Suma=suma+temp
	MOVF       R0+0, 0
	ADDWF      _Suma+0, 1
	MOVF       R0+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _Suma+1, 1
;esclab.mbas,78 :: 		next Iter
	MOVF       _Iter+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt40
	INCF       _Iter+0, 1
	GOTO       L__interrupt37
L__interrupt40:
;esclab.mbas,79 :: 		Temp=suma/3
	MOVLW      3
	MOVWF      R4+0
	CLRF       R4+1
	MOVF       _Suma+0, 0
	MOVWF      R0+0
	MOVF       _Suma+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVF       R0+0, 0
	MOVWF      _Temp+0
	MOVF       R0+1, 0
	MOVWF      _Temp+1
;esclab.mbas,80 :: 		Temp1_H=hi(temp)
	MOVF       _Temp+1, 0
	MOVWF      _Temp1_H+0
;esclab.mbas,81 :: 		Temp1_L=lo(temp)
	MOVF       _Temp+0, 0
	MOVWF      _Temp1_L+0
;esclab.mbas,82 :: 		if portc.2=0 then
	BTFSC      PORTC+0, 2
	GOTO       L__interrupt42
;esclab.mbas,83 :: 		Entrada1=0
	CLRF       _Entrada1+0
	GOTO       L__interrupt43
;esclab.mbas,84 :: 		else
L__interrupt42:
;esclab.mbas,85 :: 		Entrada1=1
	MOVLW      1
	MOVWF      _Entrada1+0
;esclab.mbas,86 :: 		end if
L__interrupt43:
;esclab.mbas,87 :: 		if portc.3=0 then
	BTFSC      PORTC+0, 3
	GOTO       L__interrupt45
;esclab.mbas,88 :: 		Entrada2=0
	CLRF       _Entrada2+0
	GOTO       L__interrupt46
;esclab.mbas,89 :: 		else
L__interrupt45:
;esclab.mbas,90 :: 		Entrada2=1
	MOVLW      1
	MOVWF      _Entrada2+0
;esclab.mbas,91 :: 		end if
L__interrupt46:
;esclab.mbas,92 :: 		longitud=94
	MOVLW      94
	MOVWF      _Longitud+0
;esclab.mbas,93 :: 		Mensaje[0]=0
	CLRF       _Mensaje+0
;esclab.mbas,94 :: 		mensaje[1]=esclavo
	MOVF       _Esclavo+0, 0
	MOVWF      _Mensaje+1
;esclab.mbas,95 :: 		Mensaje[2]=temp1_h
	MOVF       _Temp1_H+0, 0
	MOVWF      _Mensaje+2
;esclab.mbas,96 :: 		Mensaje[3]=temp1_l
	MOVF       _Temp1_L+0, 0
	MOVWF      _Mensaje+3
;esclab.mbas,97 :: 		Mensaje[4]=0
	CLRF       _Mensaje+4
;esclab.mbas,98 :: 		Mensaje[5]=0
	CLRF       _Mensaje+5
;esclab.mbas,99 :: 		Mensaje[6]=entrada1
	MOVF       _Entrada1+0, 0
	MOVWF      _Mensaje+6
;esclab.mbas,100 :: 		Mensaje[7]=entrada2
	MOVF       _Entrada2+0, 0
	MOVWF      _Mensaje+7
;esclab.mbas,102 :: 		Mensaje[8]=49
	MOVLW      49
	MOVWF      _Mensaje+8
;esclab.mbas,103 :: 		mensaje[9]=48
	MOVLW      48
	MOVWF      _Mensaje+9
;esclab.mbas,104 :: 		Mensaje[10]=48
	MOVLW      48
	MOVWF      _Mensaje+10
;esclab.mbas,105 :: 		Mensaje[11]=58
	MOVLW      58
	MOVWF      _Mensaje+11
;esclab.mbas,107 :: 		Mensaje[92]=version_h
	MOVF       _Version_H+0, 0
	MOVWF      _Mensaje+92
;esclab.mbas,108 :: 		Mensaje[93]=version_l
	MOVF       _Version_L+0, 0
	MOVWF      _Mensaje+93
;esclab.mbas,109 :: 		clrwdt
	CLRWDT
;esclab.mbas,110 :: 		calcularcrc
	CALL       _CalcularCRC+0
;esclab.mbas,111 :: 		portc.1=0
	BCF        PORTC+0, 1
;esclab.mbas,112 :: 		portc.4=1
	BSF        PORTC+0, 4
;esclab.mbas,113 :: 		portc.5=1
	BSF        PORTC+0, 5
;esclab.mbas,114 :: 		for Iter=0 to longitud   -1
	CLRF       _Iter+0
L__interrupt47:
	DECF       _Longitud+0, 0
	MOVWF      FLOC__interrupt+0
	MOVF       _Iter+0, 0
	SUBWF      FLOC__interrupt+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt51
;esclab.mbas,115 :: 		uart1_write(mensaje[iter])
	MOVF       _Iter+0, 0
	ADDLW      _Mensaje+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;esclab.mbas,116 :: 		next iter
	MOVF       _Iter+0, 0
	XORWF      FLOC__interrupt+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt51
	INCF       _Iter+0, 1
	GOTO       L__interrupt47
L__interrupt51:
;esclab.mbas,117 :: 		uart1_write(crc_l)
	MOVF       _CRC_L+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;esclab.mbas,118 :: 		uart1_write(crc_h)
	MOVF       _CRC_H+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;esclab.mbas,119 :: 		clrwdt
	CLRWDT
;esclab.mbas,120 :: 		delay_ms(5)
	MOVLW      7
	MOVWF      R12+0
	MOVLW      125
	MOVWF      R13+0
L__interrupt52:
	DECFSZ     R13+0, 1
	GOTO       L__interrupt52
	DECFSZ     R12+0, 1
	GOTO       L__interrupt52
;esclab.mbas,121 :: 		portc.4=0
	BCF        PORTC+0, 4
;esclab.mbas,122 :: 		portc.5=0
	BCF        PORTC+0, 5
;esclab.mbas,123 :: 		porta.5=1
	BSF        PORTA+0, 5
;esclab.mbas,124 :: 		portc.1=1
	BSF        PORTC+0, 1
L__interrupt34:
;esclab.mbas,125 :: 		end if
L__interrupt25:
;esclab.mbas,126 :: 		end if
L__interrupt22:
;esclab.mbas,127 :: 		end if
L__interrupt19:
;esclab.mbas,129 :: 		end if
L__interrupt16:
;esclab.mbas,131 :: 		GIE_bit = 1
	BSF        GIE_bit+0, 7
;esclab.mbas,132 :: 		end sub
L__interrupt64:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;esclab.mbas,134 :: 		main:
;esclab.mbas,135 :: 		trisa=%00001111
	MOVLW      15
	MOVWF      TRISA+0
;esclab.mbas,136 :: 		adcon1=%1101
	MOVLW      13
	MOVWF      ADCON1+0
;esclab.mbas,137 :: 		trisb=0
	CLRF       TRISB+0
;esclab.mbas,138 :: 		trisc=%10001100
	MOVLW      140
	MOVWF      TRISC+0
;esclab.mbas,139 :: 		option_reg=%01111111
	MOVLW      127
	MOVWF      OPTION_REG+0
;esclab.mbas,140 :: 		Version_H=2
	MOVLW      2
	MOVWF      _Version_H+0
;esclab.mbas,141 :: 		Version_L=5
	MOVLW      5
	MOVWF      _Version_L+0
;esclab.mbas,142 :: 		Esclavo=eeprom_read(0)
	CLRF       FARG_EEPROM_Read_address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      _Esclavo+0
;esclab.mbas,144 :: 		for Iter=0 to 95
	CLRF       _Iter+0
L__main55:
;esclab.mbas,145 :: 		Mensaje[iter]=32
	MOVF       _Iter+0, 0
	ADDLW      _Mensaje+0
	MOVWF      FSR
	MOVLW      32
	MOVWF      INDF+0
;esclab.mbas,146 :: 		next iter
	MOVF       _Iter+0, 0
	XORLW      95
	BTFSC      STATUS+0, 2
	GOTO       L__main58
	INCF       _Iter+0, 1
	GOTO       L__main55
L__main58:
;esclab.mbas,147 :: 		portc.4=0
	BCF        PORTC+0, 4
;esclab.mbas,148 :: 		portc.5=0
	BCF        PORTC+0, 5
;esclab.mbas,149 :: 		porta.4=1
	BSF        PORTA+0, 4
;esclab.mbas,150 :: 		porta.5=1
	BSF        PORTA+0, 5
;esclab.mbas,151 :: 		portc.0=1
	BSF        PORTC+0, 0
;esclab.mbas,152 :: 		portc.1=1
	BSF        PORTC+0, 1
;esclab.mbas,154 :: 		uart1_init(9600)
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;esclab.mbas,155 :: 		RCIE_bit = 1                  ' enable interrupt on UART1 receive
	BSF        RCIE_bit+0, 5
;esclab.mbas,156 :: 		TXIE_bit = 0                  ' disable interrupt on UART1 transmit
	BCF        TXIE_bit+0, 4
;esclab.mbas,157 :: 		PEIE_bit = 1                  ' enable peripheral interrupts
	BSF        PEIE_bit+0, 6
;esclab.mbas,158 :: 		GIE_bit = 1                   ' enable all interrupts
	BSF        GIE_bit+0, 7
;esclab.mbas,159 :: 		clrwdt
	CLRWDT
;esclab.mbas,160 :: 		while true
L__main60:
;esclab.mbas,161 :: 		nop
	NOP
;esclab.mbas,162 :: 		wend
	GOTO       L__main60
	GOTO       $+0
; end of _main
