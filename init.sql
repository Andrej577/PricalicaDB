CREATE TABLE tip_korisnika (
    tipKorisnika_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivTipaKorisnika VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE status_racuna (
    statusRacuna_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivStatusaRacuna VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE status_transakcije (
    statusTransakcije_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivStatusaTransakcije VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE status_slusanja (
    statusSlusanja_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivStatusaSlusanja VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE status_dostupnosti (
    statusDostupnosti_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivStatusaDostupnosti VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE korisnici (
    korisnik_id INT AUTO_INCREMENT PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    lozinka_hash VARCHAR(255) NOT NULL,
    tipKorisnika_id INT,
    datum_registracije TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusRacuna_id INT,
    ima_pretplatu BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (tipKorisnika_id) REFERENCES tip_korisnika(tipKorisnika_id),
    FOREIGN KEY (statusRacuna_id) REFERENCES status_racuna(statusRacuna_id)
);

CREATE TABLE autori (
    autor_id INT PRIMARY KEY,
    iznos_prihoda DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (autor_id) REFERENCES korisnici(korisnik_id)
);

CREATE TABLE zanrovi (
    zanr_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivZanra VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE knjige (
    knjiga_id INT AUTO_INCREMENT PRIMARY KEY,
    naslov VARCHAR(150) NOT NULL,
    autor_id INT NOT NULL,
    zanr_id INT NOT NULL,
    trajanje_min INT NOT NULL,
    opis TEXT,
    datum_dodavanja TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusDostupnosti_id INT,
    poveznica VARCHAR(255),
    prosjecna_ocjena DECIMAL(3, 2) DEFAULT 0.00,
    FOREIGN KEY (statusDostupnosti_id) REFERENCES status_dostupnosti(statusDostupnosti_id),
    FOREIGN KEY (zanr_id) REFERENCES zanrovi(zanr_id),
    FOREIGN KEY (autor_id) REFERENCES autori(autor_id)
);

CREATE TABLE transakcije (
    transakcija_id INT AUTO_INCREMENT PRIMARY KEY,
    korisnik_id INT NOT NULL,
    iznos DECIMAL(10, 2) NOT NULL,
    datum_transakcije TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusTransakcije_id INT NOT NULL ,
    FOREIGN KEY (korisnik_id) REFERENCES korisnici(korisnik_id),
    FOREIGN KEY (statusTransakcije_id) REFERENCES status_transakcije(statusTransakcije_id)
);

CREATE TABLE povijest_slusanja (
    povijestSlusanja_id INT AUTO_INCREMENT PRIMARY KEY,
    korisnik_id INT NOT NULL,
    knjiga_id INT NOT NULL,
    pozicija INT NOT NULL DEFAULT 0,
    posljednje_slusanje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusSlusanja_id INT,
    FOREIGN KEY (korisnik_id) REFERENCES korisnici(korisnik_id),
    FOREIGN KEY (knjiga_id) REFERENCES knjige(knjiga_id),
    FOREIGN KEY (statusSlusanja_id) REFERENCES status_slusanja(statusSlusanja_id)
);

CREATE TABLE interakcije (
    interakcija_id INT AUTO_INCREMENT PRIMARY KEY,
    korisnik_id INT NOT NULL,
    knjiga_id INT NOT NULL,
    ocjena INT CHECK (ocjena BETWEEN 1 AND 5),
    recenzija TEXT,
    vrijeme_ostavljanja TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    omiljena BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (korisnik_id) REFERENCES korisnici(korisnik_id),
    FOREIGN KEY (knjiga_id) REFERENCES knjige(knjiga_id)
);

CREATE TABLE analitika (
    analitika_id INT AUTO_INCREMENT PRIMARY KEY,
    knjiga_id INT NOT NULL,
    datum DATE NOT NULL,
    broj_slusanja INT NOT NULL DEFAULT 0,
    prosjecna_ocjena DECIMAL(3,2) DEFAULT 0.00,
    vrijeme_slusanja INT NOT NULL DEFAULT 0,
    FOREIGN KEY (knjiga_id) REFERENCES knjige(knjiga_id)
);



DELIMITER //
CREATE TRIGGER dodaj_autora
AFTER INSERT ON korisnici
FOR EACH ROW
BEGIN
    IF NEW.tipKorisnika_id = 2 THEN
        INSERT INTO autori (autor_id)
        VALUES (NEW.korisnik_id);
    END IF;
END;//
DELIMITER ;

DELIMITER //

CREATE TRIGGER azuriraj_prosjecnu_ocjenu
AFTER INSERT ON interakcije
FOR EACH ROW
BEGIN
    UPDATE knjige
    SET prosjecna_ocjena = (
        SELECT ROUND(AVG(ocjena), 2)
        FROM interakcije
        WHERE knjiga_id = NEW.knjiga_id
    )
    WHERE knjiga_id = NEW.knjiga_id;
END;//

DELIMITER ;

DELIMITER $$

CREATE TRIGGER azuriraj_pretplatu
AFTER UPDATE ON transakcije
FOR EACH ROW
BEGIN
    DECLARE uspjesno BOOLEAN;

    -- Dohvati da li je novi status transakcije uspješan
    SELECT statusTransakcije_id INTO uspjesno
    FROM status_transakcije
    WHERE statusTransakcije_id = NEW.statusTransakcije_id;

    -- Ako je uspješan, ažuriraj korisnika
    IF uspjesno = 'Uspjesno' THEN
        UPDATE korisnici
        SET ima_pretplatu = TRUE
        WHERE korisnik_id = NEW.korisnik_id;
    END IF;
END $$

DELIMITER ;

INSERT INTO tip_korisnika (tipKorisnika_id, nazivTipaKorisnika) VALUES (1, 'Administrator');
INSERT INTO tip_korisnika (tipKorisnika_id, nazivTipaKorisnika) VALUES (2, 'Autor');
INSERT INTO tip_korisnika (tipKorisnika_id, nazivTipaKorisnika) VALUES (3, 'Korisnik');

INSERT INTO status_racuna (statusRacuna_id, nazivStatusaRacuna) VALUES (1, 'Ativan');
INSERT INTO status_racuna (statusRacuna_id, nazivStatusaRacuna) VALUES (2, 'Neaktivan');

INSERT INTO status_dostupnosti (statusDostupnosti_id, nazivStatusaDostupnosti) VALUES (1, 'Dostupno');
INSERT INTO status_dostupnosti (statusDostupnosti_id, nazivStatusaDostupnosti) VALUES (2, 'Nedostupno');
INSERT INTO status_dostupnosti (statusDostupnosti_id, nazivStatusaDostupnosti) VALUES (3, 'U pripremi');

INSERT INTO status_transakcije (statusTransakcije_id, nazivStatusaTransakcije) VALUES (1, 'Uspjesno');
INSERT INTO status_transakcije (statusTransakcije_id, nazivStatusaTransakcije) VALUES (2, 'Neuspjesno');

INSERT INTO zanrovi (nazivZanra) VALUES ('Triler');
INSERT INTO zanrovi (nazivZanra) VALUES ('Fantastika');
INSERT INTO zanrovi (nazivZanra) VALUES ('Drama');
INSERT INTO zanrovi (nazivZanra) VALUES ('Pustolovina');
INSERT INTO zanrovi (nazivZanra) VALUES ('Ljubavni roman');

INSERT INTO korisnici (ime, prezime, email, lozinka_hash, tipKorisnika_id, statusRacuna_id, ima_pretplatu) VALUES
('Ivan', 'Horvat', 'ivan.horvat@example.com', 'Ivan123!', 2, 1, TRUE), -- Autor ID 1
('Ana', 'Maric', 'ana.maric@example.com', 'AnaSuper#1', 2, 1, FALSE), -- Autor ID 2
('Marko', 'Kovac', 'marko.kovac@example.com', 'MarkoPass99', 2, 1, TRUE), -- Autor ID 3
('Petra', 'Novak', 'petra.novak@example.com', 'Petra$Cool7', 2, 1, FALSE), -- Autor ID 4
('Luka', 'Babic', 'luka.babic@example.com', 'LukaBest88', 2, 1, TRUE), -- Autor ID 5
('Nikola', 'Petrovic', 'nikola.petrovic@example.com', 'NikolaPass1!', 2, 1, TRUE),
('Jelena', 'Vukovic', 'jelena.vukovic@example.com', 'Jelena@123', 2, 1, FALSE),
('Marin', 'Todorovic', 'marin.todorovic@example.com', 'MarinPass7!', 2, 1, TRUE),
('Ivana', 'Radic', 'ivana.radic@example.com', 'Ivana#Best9', 2, 1, FALSE),
('Goran', 'Djuric', 'goran.djuric@example.com', 'Goran2023$', 2, 1, TRUE),
('Maja', 'Peric', 'maja.peric@example.com', 'Maja*Secure5', 1, 1, FALSE), -- Administrator
('Ante', 'Bozic', 'ante.bozic@example.com', 'AntePower@3', 3, 2, TRUE), -- Korisnik
('Sara', 'Juric', 'sara.juric@example.com', 'SaraLove44', 3, 1, FALSE), -- Korisnik
('Filip', 'Lovric', 'filip.lovric@example.com', 'FilipTop_2', 3, 1, TRUE), -- Korisnik
('Iva', 'Simic', 'iva.simic@example.com', 'IvaHappy!77', 3, 2, FALSE); -- Korisnik

INSERT INTO knjige (naslov, autor_id, zanr_id, trajanje_min, opis, statusDostupnosti_id, poveznica, prosjecna_ocjena) VALUES
('Ponocni vlak', 1, 2, 320, 'Napeta prica o putovanju koje se pretvara u borbu za opstanak.', 1, 'ponocni_vlak', 4.25),
('Tajna vrta', 2, 3, 210, 'Inspirativna prica o otkrivanju zaboravljenog vrta i unutarnjoj snazi.', 1, 'tajna_vrta', 4.50),
('Lovac na snove', 3, 5, 400, 'Fantasticna prica o svijetu snova i borbi izmedju dobra i zla.', 2, 'lovac_na_snove', 4.10),
('Dolina sjenki', 4, 4, 280, 'Mracan triler smjesten u osamljenu dolinu punu tajni.', 1, 'dolina_sjenki', 4.00),
('Prasina u vremenu', 5, 1, 360, 'Pustolovina kroz prostor i vrijeme u potrazi za izgubljenim civilizacijama.', 1, 'prasina_vremena', 4.35),
('Zvijezdana prasina', 2, 1, 310, 'Magican put kroz svemir ispunjen iznenadnim obratima.', 1, 'zvijezdana_prasina', 4.20),
('Tama u svetlosti', 3, 2, 290, 'Triler o nestanku i mracnim porodičnim tajnama.', 1, 'tama_u_svetlosti', 4.05),
('Vrt bez vrata', 1, 3, 250, 'Emotivna prica o izgubljenom detinjstvu i ponovnom pronalazenju sebe.', 1, 'vrt_bez_vrata', 4.45),
('Izgubljeni horizonti', 4, 4, 340, 'Psiholoski triler na granici stvarnog i nestvarnog.', 1, 'izgubljeni_horizonti', 4.15),
('Cuvarkuca snova', 5, 5, 370, 'Fantazija o svetu gde se snovi materijalizuju.', 2, 'cuvarkuca_snova', 4.30),
('Sjena svitanja', 10, 1, 305, 'Putovanje kroz vrijeme koje menja tok istorije.', 1, 'sjena_svitanja', 4.10),
('Nocna linija', 9, 2, 275, 'Napeta prica o voznji koja se pretvara u borbu za istinu.', 1, 'nocna_linija', 4.00),
('Ulica tihe nade', 8, 3, 220, 'Topla prica o ljubavi i drugoj sansi.', 1, 'ulica_tihe_nade', 4.50),
('Skrivena istina', 7, 4, 260, 'Istrazitelj se suocava sa misterijom iz proslosti.', 2, 'skrivena_istina', 4.20),
('Cuvaj moje rijeci', 6, 5, 310, 'Svijet u kojem rijeci imaju moc da mjenjaju stvarnost.', 1, 'cuvaj_moje_rijeci', 4.40),
('Odlazak bez povratka', 6, 1, 330, 'Pustolovina kroz izgubljene svijetove i nepoznate dimenzije.', 1, 'odlazak_bez_povratka', 4.25),
('Tiha osuda', 7, 2, 245, 'Triler u kojem je tisina najsnaznije oruzje.', 1, 'tiha_osuda', 3.95),
('Miris proslosti', 8, 3, 230, 'Sjecanja koja pokrecu lavinu emocija i promena.', 1, 'miris_proslosti', 4.60),
('Zidovi tame', 9, 4, 290, 'Napeta psiholoska igra u zatvorenom kompleksu.', 2, 'zidovi_tame', 4.10),
('Dnevnik svijetlosti', 10, 5, 350, 'Fantazija o borbi sijvetlosti i tame u svijetu snova.', 1, 'dnevnik_svijetlosti', 4.35);

INSERT INTO interakcije (korisnik_id, knjiga_id, ocjena, recenzija, omiljena, vrijeme_ostavljanja)
VALUES
-- Ante Bozic
(12, 1, 5, 'Nevjerojatna priča, slušao sam je u jednom dahu!', TRUE, NOW()),
-- Sara Juric
(13, 4, 4, 'Dosta zanimljivo, iako je kraj mogao biti jači.', FALSE, NOW()),
-- Filip Lovric
(14, 3, 5, 'Volim fantaziju, a ova knjiga je pravo blago!', TRUE, NOW()),
-- Iva Simic
(15, 2, 3, 'Solidno, ali nije baš moj stil. Glas naratora je bio dobar.', FALSE, NOW());

