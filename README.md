# GHRepoOperations
Programma per effettuare il push di tag in repository GitHub

## GitHubCLI
Per poter funzionare correttamente, è necessario aver installato GitHubCLI e aver effettuato la login attraverso il comando `gh auth login`. 

Durante l`autenticazione, se non si ha già una chiave SSH, è necessario seguire i passaggi descritti di seguito quando GitHubCLI vi chiederà della chiave SSH:
1. Generare la chiave tramite il comando sopra citato
2. Dare un nome alla chiave 
3. Creata la chiave, nella cartella utente (es. `C:\Users\<NomeUtente>\.ssh`) viene creata una chiave SSH
4. Aprire il file della chiave pubblica (il cui nome finisce per `.pub`)
5. Copiare il contenuto del file (dovrebbe essere una riga sola)
    > Il testo del file dovrebbe iniziare per `ssh-rsa`, `ecdsa-sha2-nistp256`, `ecdsa-sha2-nistp384`, `ecdsa-sha2-nistp521`, `ssh-ed25519`, `sk-ecdsa-sha2-nistp256@openssh.com`, or `sk-ssh-ed25519@openssh.com`
6. Creare una [nuova chiave SSH](https://github.com/settings/ssh/new) dal proprio profilo GitHub
   1. Dare un titolo alla chiave (lo stesso nome viene richiesto da GitHubCLI)
   2. Copiare il contenuto della chiave pubblica
7. Aggiungere la chiave SSH
8. Ritornare su GitHubCLI e terminare l'autenticazione
> Se l'autenticazione dovesse terminare con errori, lanciare il comando `gh auth logout`, rilanciare il comando `gh auth login` e seguire nuovamente i passaggi selezionando la chiave SSH già esistente

Per poter eseguire i comandi correttamente, è necessario aver creato un [Personal Access Token](https://github.com/settings/tokens/new) dal proprio profilo GitHub, il quale deve avere almeno i seguenti `scopes` selezionati:
- `repo`
- `admin:org`
- `admin:public_key`
