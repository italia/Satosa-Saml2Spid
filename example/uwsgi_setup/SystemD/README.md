### Avvio satosa tramite systemd

I seguenti script sono esempi per avviare il proy satosa tramite SystemD. Negli esempi vengono considerati i seguenti presupposti:
* Satosa è installano nella directory `/home/satosa/production/current`
* Satosa viene eseguito in un VirtualENV di Python
* Il VitualENV di python è installato su `/home/satosa/production/current/satosa.env`
* Il Satosa proxy viene eseguito da l'utente satosa
* Il Satosa proxy è configurato per offrire servizi tramite socket
* Il socket Satosa è posizioneto su `ListenStream=/home/satosa/production/current/tmp/sockets/satosa.sock`

Per configurare SystemD seguire la seguente procedura:

* copiare i file `satosa.service` e `satosa.sock` nella directory /etc/systemd/systemd
* far rilegere i file di configurazione a SistemD con il comando `sudo systemctl daemon-reload`
* abilitare socket `sudo systemctl enable satosa.socket`
* abilitare il service `sudo systemct enable satosa.service`

Nel caso Satosa proxy lavori tramite rete (es: 127.0.0.1:8003)
* disabilitare il socket `systemctl disable satosa.socket`
* commentare nel file `satosa.service` la riga `Requires=satosa.sock`
* decommentare nel file `satosa.service` la riga `Requires=network.target`
* decommentare nel file `satosa.service` la riga `After=network.target`
