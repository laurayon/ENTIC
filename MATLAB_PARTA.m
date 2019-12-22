
%netejar les dades antigues del matlab
delete(instrfind({'port'},{'COM4'}));
clear;

%crear i obrir serial port
s = serial('COM4');
set(s,'BaudRate',9600, 'Terminator', 'CR/LF');
fopen(s); %obre serial port
%serveix per que matlab no et processi els missatges de 
%text que envia l'arduino abans de començar la presa de dades.
  while 1 %while true
        fprintf(s, 'S'); %envia una 'S' al arduino
        %fwrite(s, 'S');
        a=fscanf(s, '%d');
        %mentre caracter que li envia arduino no es numeric
        if isnumeric(a)  
            break %quan es numèric, breaks 
        end
  end
  
    a0 = []; %vector que reb les dades directes de l'arduino 
    t = []; %vector temps 
    mean = []; %vector on es guarden les mitjanes
    
    %preparació de la finestra on anirà el gràfic 
    figure('Name','ROUVs depth against time');
    title('Depth-Time graph'); 
    xlabel('Time(s)'); 
    ylabel('Depth(m)'); 
    grid on; 
    ylim([-4 0]) %limita els valors de l'eix de les y 
    hold on
    
    for i = 0:1999 %2000 cops 
        a0 = [a0,(fscanf(s,'%d')*0.017)-10];
        if (rem(i,2)==0) && (i~=0)
            b=(a0(i)+a0(i+1))/2;
            mean = [mean, b];
            t = [t, i*0.2]; %les mostres es prenen cada 0,2s 
            %x=[x, newval] sirve para concatenar el valor newval
            %a un vector fila x.
        end
        plot(t,mean,'r');drawnow %dibuixa la linea en color vermell 
    end  
    f = fopen('resultats.txt', 'w+');
    t = sprintf('%d ', time);
    m = sprintf('%d ', mean);
    fprintf(f,'Time: %s\nMesures: %s\n', t, m);
    fclose(f);

    fclose(s);
    delete(s);
    clear s;
    instrreset;
    
    

