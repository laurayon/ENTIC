clear; 
var=0;
entrat=0; %es 0 si no ha entrat en el case 1
cont=0; 
y4=3.4+rand(1,3000)*(3.4-4.6);
o = 1:1:2000;
while (var == 0)
    choice = menu('What do you want to do?.','Take measurements', 'Exit');
    %netejar les dades antigues del matlab
    delete(instrfind({'port'},{'COM3'}));
    delete(instrfind({'port'},{'COM8'}));
    switch choice
        case 1
            entrat = 1; 
            %crear i obrir serial port 1
            s1 = serial('COM8');
            set(s1,'BaudRate',9600, 'Terminator', 'CR/LF');
            fopen(s1); %obre serial port
         %crear i obrir serial port 2
                s2 = serial('COM3');
                set(s2,'BaudRate',9600, 'Terminator', 'CR/LF');
                fopen(s2); %obre serial port
          
            x = input('For how many hours you want to measure?');%x = número d'hores
            t = []; %vector temps pels sensors de temperatura, pH i salinitat
            tp = []; %vector temps pel sensor de presió 
            
          %Vectors per llegir pressió  
            p = []; %vector que rep les dades directes de l'arduino
            meanp = []; %vector on es guarden les mitjanes

          %Vectors per llegir temperatura
            temp = []; %vector que rep les dades directes de l'arduino
            meant = []; %vector on es guarden les mitjanes

          %Vectors per llegir pH
            h = []; %vector que rep les dades directes de l'arduino
            meanh = []; %vector on es guarden les mitjanes

          %Vectors per llegir salinitat
            sal = []; %vector que rep les dades directes de l'arduino
            meana = []; %vector on es guarden les mitjanes

            %es necessiten 30 min per fer una gràfica de cada tipus
            y = x*2; %x mostres / 0,5h per roda de gràfics
            for j = 0:y
                ft = fopen('temperature.txt', 'w+');
                fh = fopen('pH.txt', 'w+');
                fa = fopen('salinity.txt', 'w+');
                fp = fopen ('depth.txt','w+');
                
                fprintf(ft,'Temperature-Time data\n');
                fprintf(fh,'pH-Time data\n');
                fprintf(fa,'Salinity-Time data\n');
                fprintf(fp,'Depth-Time data\n');
                for i = 0:2999 %3000 cops
                    pause(0.9);
                    b=str2num(fscanf(s1))*0.017-10;
                    datos=fscanf(s2);
                    sensors=regexp(datos, ';', 'split');
                    temp = [temp, str2double(sensors(1))]; 
                    h = [h, str2double(sensors(2))];
                    sal = [sal,str2double(sensors(3))]; 
                    p = [p,b];
                    if (rem(i,4)==0) && (i~=0)
                        bt=(temp(i)+temp(i-1)+temp(i-2)+temp(i-3))/4;
                        meant = [meant, bt];
                        bh=((h(i)+h(i-1)+h(i-2)+h(i-3))/4)+y4(i);
                        meanh = [meanh, bh];
                        ba=(sal(i)+sal(i-1)+sal(i-2)+sal(i-3))/4;
                        meana = [meana, ba]; %x=[x, newval] sirve para concatenar el valor newval
                        %a un vector fila x.
                        bp=((p(i)+p(i-1)+p(i-2)+p(i-3))/4);
                        meanp = [meanp, bp];
                        
                        tp = [tp, cont*0.2*4]; %les mostres de depth es prenen cada 0,2s 
                        t = [t, cont*0.9*4]; %les mostres de la resta es prenen cada 0,9s
                        fprintf(ft,'Time: %ds\tMeasure: %sºC\n', cont*0.9*4, bt);
                        fprintf(fh,'Time: %ds\tMeasure: %spH units\n ', cont*0.9*4, bh);
                        fprintf(fa,'Time: %ds\tMeasure: %sV\n', cont*0.9*4, ba);
                        fprintf(fp,'Time: %ds\tMeasure: %sm\n', cont*0.2, bp);
                    end
                   
                    subplot(2,2,1); plot(t,meant,'r');drawnow %dibuixa la linea en color vermell 
                        ylim([0 30]) %limita els valors de l'eix de les y 
                        title('Temperature - Time graph');
                        xlabel('Time(s)'); 
                        ylabel('Temperature (ºC)'); %Temperatura en celsius 
                        grid on; 
                    if(length(temp)>=1)
                    subplot(2,2,2); plot(t,meanh, 'r');drawnow %dibuixa la linea en color vermell
                        ylim([-1.1 12.5])
                        title('pH - Time graph');
                        xlabel('Time(s)'); 
                        ylabel('pH([H+])'); %pH es mesura en concentració de ions H+
                        grid on;
                    end
                    subplot(2,2,3); plot(t,meana,'r');drawnow %dibuixa la linea en color vermell 
                        title('Salinity-Time graph'); 
                        xlabel('Time(s)'); 
                        ylabel('Salinity(V)'); 
                        grid on; 
                    subplot(2,2,4); plot(tp,meanp,'r');drawnow %dibuixa la linea en color vermell 
                        title('Depth-Time graph');
                        xlabel('Time(s)'); 
                        ylabel('Depth(m)'); 
                        grid on;  
                    cont=cont+1;   
                end 
                fclose(ft);
                fclose(fh);
                fclose(fa);
                fclose(fp); 
            end
       case 2
            var=1;
    end
end
if (entrat==1)
    fclose(s1);
    fclose(s2);
    delete(s1);
    delete(s2);
    clear s1;
    clear s2;
    instrresetz;
end 
