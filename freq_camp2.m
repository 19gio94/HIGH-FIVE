% Creazione dell'oggetto seriale
s = serial('/dev/ttyACM1');  % Sostituisci con la porta seriale corretta del tuo Arduino
set(s, 'BaudRate', 9600);

% Apertura della connessione seriale
fopen(s);

% Inizializzazione delle variabili
prevTime = tic; % Tempo iniziale
counter = 0;

% Numero massimo di campioni per il calcolo della frequenza
maxSamples = 1000;

% Ciclo di lettura e calcolo della frequenza
while counter < maxSamples
    % Lettura dei dati dalla porta seriale
    data = fscanf(s, '%d %d %d');
    
    % Calcolo della frequenza
    currentTime = tic;
    elapsedTime = toc(prevTime);
    frequency = counter / elapsedTime;
    
    % Visualizzazione della frequenza ogni secondo
    if elapsedTime >= 1
        fprintf('Frequenza di campionamento: %.2f Hz\n', frequency);
        counter = 0;
        prevTime = tic; % Reset del tempo
    end
    
    counter = counter + 1;
end

% Chiusura della connessione seriale quando hai finito
fclose(s);
delete(s);
clear s;