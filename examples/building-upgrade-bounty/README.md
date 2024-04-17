```mermaid
sequenceDiagram
    YAKUZA->>Primordium: spawn
    Primordium-->>YAKUZA: you now own Asteroid Y
    P1->>Primordium: spawn
    Primordium-->>P1: you now own Asteroid A
    P2->>Primordium: spawn
    Primordium-->>P2: you now own Asteroid B
    P1->>YAKUZA: transfer resources
    YAKUZA-->>P1: you are subscribed for 30 days
    P2->>Primordium: attack P1 from Asteroid B
    Primordium-->>P2: you now own Asteroid A
    P1->>YAKUZA: claim revenge to attack Asteroid A
    YAKUZA->>Primordium: attack P2 from Asteroid Y
    Primordium-->>P1: YAKUZA now owns Asteroid A
```