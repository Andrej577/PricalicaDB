## Pokretanje aplikacije

Prije pokretanja aplikacije potrebno je prvo kreirati Docker mrežu:

```bash
docker network create pricalica-network
```

Nakon toga pokrenuti Docker Compose:

```bash
docker-compose up
```

## Provjera

Nakon pokretanja provjeriti u Docker Desktop aplikaciji je li kontejner uspješno pokrenut.

## Napomena

Ako se rade promjene u aplikaciji, preporuka je:

1. obrisati postojeći kontejner
2. obrisati postojeći image
3. ponovno napraviti build i pokrenuti aplikaciju
