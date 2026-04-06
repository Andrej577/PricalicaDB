SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

DROP TRIGGER IF EXISTS azuriraj_autore_nakon_unosa_korisnika;
DROP TRIGGER IF EXISTS azuriraj_autore_nakon_izmjene_korisnika;
DROP TRIGGER IF EXISTS azuriraj_prosjecnu_ocjenu_nakon_unosa;
DROP TRIGGER IF EXISTS azuriraj_prosjecnu_ocjenu_nakon_izmjene;
DROP TRIGGER IF EXISTS azuriraj_prosjecnu_ocjenu_nakon_brisanja;

DROP TABLE IF EXISTS analitika;
DROP TABLE IF EXISTS interakcije;
DROP TABLE IF EXISTS povijest_slusanja;
DROP TABLE IF EXISTS knjige;
DROP TABLE IF EXISTS autori;
DROP TABLE IF EXISTS zanrovi;
DROP TABLE IF EXISTS korisnici;
DROP TABLE IF EXISTS status_dostupnosti;
DROP TABLE IF EXISTS status_slusanja;
DROP TABLE IF EXISTS status_racuna;
DROP TABLE IF EXISTS tip_korisnika;

CREATE TABLE tip_korisnika (
    tipKorisnika_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivTipaKorisnika VARCHAR(20) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE status_racuna (
    statusRacuna_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivStatusaRacuna VARCHAR(20) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE status_slusanja (
    statusSlusanja_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivStatusaSlusanja VARCHAR(20) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE status_dostupnosti (
    statusDostupnosti_id INT AUTO_INCREMENT PRIMARY KEY,
    nazivStatusaDostupnosti VARCHAR(20) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE korisnici (
    korisnik_id INT AUTO_INCREMENT PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    lozinka_hash VARCHAR(255) NOT NULL,
    tipKorisnika_id INT NOT NULL DEFAULT 3,
    datum_registracije TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusRacuna_id INT NOT NULL DEFAULT 1,
    ima_pretplatu BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_korisnici_tip FOREIGN KEY (tipKorisnika_id)
        REFERENCES tip_korisnika(tipKorisnika_id)
        ON UPDATE CASCADE,
    CONSTRAINT fk_korisnici_status FOREIGN KEY (statusRacuna_id)
        REFERENCES status_racuna(statusRacuna_id)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE autori (
    autor_id INT PRIMARY KEY,
    datum_dodavanja TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_autori_korisnik FOREIGN KEY (autor_id)
        REFERENCES korisnici(korisnik_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE zanrovi (
    zanr_id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(50) UNIQUE NOT NULL,
    nazivZanra VARCHAR(50) GENERATED ALWAYS AS (naziv) VIRTUAL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE knjige (
    knjiga_id INT AUTO_INCREMENT PRIMARY KEY,
    naslov VARCHAR(150) NOT NULL,
    autor_id INT NOT NULL,
    zanr_id INT NOT NULL,
    trajanje_min INT NOT NULL DEFAULT 0,
    opis TEXT,
    datum_dodavanja TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusDostupnosti_id INT NOT NULL DEFAULT 1,
    poveznica VARCHAR(255) DEFAULT '',
    prosjecna_ocjena DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_knjige_status FOREIGN KEY (statusDostupnosti_id)
        REFERENCES status_dostupnosti(statusDostupnosti_id)
        ON UPDATE CASCADE,
    CONSTRAINT fk_knjige_zanr FOREIGN KEY (zanr_id)
        REFERENCES zanrovi(zanr_id)
        ON UPDATE CASCADE,
    CONSTRAINT fk_knjige_autor FOREIGN KEY (autor_id)
        REFERENCES korisnici(korisnik_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE povijest_slusanja (
    povijest_id INT AUTO_INCREMENT PRIMARY KEY,
    korisnik_id INT NOT NULL,
    knjiga_id INT NOT NULL,
    pozicija INT NOT NULL DEFAULT 0,
    posljednje_slusanje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusSlusanja_id INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_povijest_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnici(korisnik_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_povijest_knjiga FOREIGN KEY (knjiga_id)
        REFERENCES knjige(knjiga_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_povijest_status FOREIGN KEY (statusSlusanja_id)
        REFERENCES status_slusanja(statusSlusanja_id)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE interakcije (
    interakcija_id INT AUTO_INCREMENT PRIMARY KEY,
    korisnik_id INT NOT NULL,
    knjiga_id INT NOT NULL,
    ocjena INT CHECK (ocjena BETWEEN 1 AND 5),
    recenzija TEXT,
    vrijeme_ostavljanja TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    omiljena BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_interakcija_korisnik_knjiga UNIQUE (korisnik_id, knjiga_id),
    CONSTRAINT fk_interakcije_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnici(korisnik_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_interakcije_knjiga FOREIGN KEY (knjiga_id)
        REFERENCES knjige(knjiga_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE analitika (
    analitika_id INT AUTO_INCREMENT PRIMARY KEY,
    knjiga_id INT NOT NULL,
    datum DATE NOT NULL,
    broj_slusanja INT NOT NULL DEFAULT 0,
    prosjecna_ocjena DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    vrijeme_slusanja INT NOT NULL DEFAULT 0,
    CONSTRAINT uq_analitika_knjiga_datum UNIQUE (knjiga_id, datum),
    CONSTRAINT fk_analitika_knjiga FOREIGN KEY (knjiga_id)
        REFERENCES knjige(knjiga_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER //

CREATE TRIGGER azuriraj_autore_nakon_unosa_korisnika
AFTER INSERT ON korisnici
FOR EACH ROW
BEGIN
    IF NEW.tipKorisnika_id = 2 THEN
        INSERT IGNORE INTO autori (autor_id) VALUES (NEW.korisnik_id);
    END IF;
END//

CREATE TRIGGER azuriraj_autore_nakon_izmjene_korisnika
AFTER UPDATE ON korisnici
FOR EACH ROW
BEGIN
    IF NEW.tipKorisnika_id = 2 THEN
        INSERT IGNORE INTO autori (autor_id) VALUES (NEW.korisnik_id);
    ELSE
        DELETE FROM autori WHERE autor_id = NEW.korisnik_id;
    END IF;
END//

CREATE TRIGGER azuriraj_prosjecnu_ocjenu_nakon_unosa
AFTER INSERT ON interakcije
FOR EACH ROW
BEGIN
    UPDATE knjige
    SET prosjecna_ocjena = COALESCE((
        SELECT ROUND(AVG(ocjena), 2)
        FROM interakcije
        WHERE knjiga_id = NEW.knjiga_id
    ), 0.00)
    WHERE knjiga_id = NEW.knjiga_id;
END//

CREATE TRIGGER azuriraj_prosjecnu_ocjenu_nakon_izmjene
AFTER UPDATE ON interakcije
FOR EACH ROW
BEGIN
    UPDATE knjige
    SET prosjecna_ocjena = COALESCE((
        SELECT ROUND(AVG(ocjena), 2)
        FROM interakcije
        WHERE knjiga_id = NEW.knjiga_id
    ), 0.00)
    WHERE knjiga_id = NEW.knjiga_id;

    IF OLD.knjiga_id <> NEW.knjiga_id THEN
        UPDATE knjige
        SET prosjecna_ocjena = COALESCE((
            SELECT ROUND(AVG(ocjena), 2)
            FROM interakcije
            WHERE knjiga_id = OLD.knjiga_id
        ), 0.00)
        WHERE knjiga_id = OLD.knjiga_id;
    END IF;
END//

CREATE TRIGGER azuriraj_prosjecnu_ocjenu_nakon_brisanja
AFTER DELETE ON interakcije
FOR EACH ROW
BEGIN
    UPDATE knjige
    SET prosjecna_ocjena = COALESCE((
        SELECT ROUND(AVG(ocjena), 2)
        FROM interakcije
        WHERE knjiga_id = OLD.knjiga_id
    ), 0.00)
    WHERE knjiga_id = OLD.knjiga_id;
END//

DELIMITER ;

INSERT INTO tip_korisnika (tipKorisnika_id, nazivTipaKorisnika) VALUES
(1, 'Administrator'),
(2, 'Autor'),
(3, 'Korisnik');

INSERT INTO status_racuna (statusRacuna_id, nazivStatusaRacuna) VALUES
(1, 'Aktivan'),
(2, 'Neaktivan');

INSERT INTO status_slusanja (statusSlusanja_id, nazivStatusaSlusanja) VALUES
(1, 'U tijeku'),
(2, 'Završeno'),
(3, 'Planirano');

INSERT INTO status_dostupnosti (statusDostupnosti_id, nazivStatusaDostupnosti) VALUES
(1, 'Dostupno'),
(2, 'Nedostupno'),
(3, 'U pripremi');

INSERT INTO zanrovi (naziv) VALUES
('Triler'),
('Fantastika'),
('Drama'),
('Pustolovina'),
('Ljubavni roman');

INSERT INTO korisnici (ime, prezime, email, lozinka_hash, tipKorisnika_id, statusRacuna_id, ima_pretplatu) VALUES
('Ivan', 'Horvat', 'ivan.horvat@example.com', 'Ivan123!', 2, 1, FALSE),
('Ana', 'Marić', 'ana.maric@example.com', 'AnaSuper#1', 2, 1, FALSE),
('Marko', 'Kovač', 'marko.kovac@example.com', 'MarkoPass99', 2, 1, FALSE),
('Petra', 'Novak', 'petra.novak@example.com', 'Petra$Cool7', 2, 1, FALSE),
('Luka', 'Babić', 'luka.babic@example.com', 'LukaBest88', 2, 1, FALSE),
('Nikola', 'Petrović', 'nikola.petrovic@example.com', 'NikolaPass1!', 2, 1, FALSE),
('Jelena', 'Vuković', 'jelena.vukovic@example.com', 'Jelena@123', 2, 1, FALSE),
('Marin', 'Todorović', 'marin.todorovic@example.com', 'MarinPass7!', 2, 1, FALSE),
('Ivana', 'Radić', 'ivana.radic@example.com', 'Ivana#Best9', 2, 1, FALSE),
('Goran', 'Đurić', 'goran.djuric@example.com', 'Goran2023$', 2, 1, FALSE),
('Maja', 'Perić', 'maja.peric@example.com', 'Maja*Secure5', 1, 1, FALSE),
('Ante', 'Božić', 'ante.bozic@example.com', 'AntePower@3', 3, 2, TRUE),
('Sara', 'Jurić', 'sara.juric@example.com', 'SaraLove44', 3, 1, TRUE),
('Filip', 'Lovrić', 'filip.lovric@example.com', 'FilipTop_2', 3, 1, FALSE),
('Iva', 'Šimić', 'iva.simic@example.com', 'IvaHappy!77', 3, 2, FALSE);

INSERT INTO knjige (naslov, autor_id, zanr_id, trajanje_min, opis, statusDostupnosti_id, poveznica, prosjecna_ocjena) VALUES
('Ponoćni vlak', 1, 2, 320, 'Napeta priča o putovanju koje se pretvara u borbu za opstanak.', 1, 'ponocni_vlak', 4.25),
('Tajna vrta', 2, 3, 210, 'Inspirativna priča o otkrivanju zaboravljenog vrta i unutarnjoj snazi.', 1, 'tajna_vrta', 4.50),
('Lovac na snove', 3, 5, 400, 'Fantastična priča o svijetu snova i borbi između dobra i zla.', 2, 'lovac_na_snove', 4.10),
('Dolina sjenki', 4, 4, 280, 'Mračan triler smješten u osamljenu dolinu punu tajni.', 1, 'dolina_sjenki', 4.00),
('Prašina u vremenu', 5, 1, 360, 'Pustolovina kroz prostor i vrijeme u potrazi za izgubljenim civilizacijama.', 1, 'prasina_u_vremenu', 4.35),
('Zvjezdana prašina', 2, 1, 310, 'Magičan put kroz svemir ispunjen iznenadnim obratima.', 1, 'zvijezdana_prasina', 4.20),
('Tama u svjetlosti', 3, 2, 290, 'Triler o nestanku i mračnim obiteljskim tajnama.', 1, 'tama_u_svjetlosti', 4.05),
('Vrt bez vrata', 1, 3, 250, 'Emotivna priča o izgubljenom djetinjstvu i ponovnom pronalasku sebe.', 1, 'vrt_bez_vrata', 4.45),
('Izgubljeni horizonti', 4, 4, 340, 'Psihološki triler na granici stvarnog i nestvarnog.', 1, 'izgubljeni_horizonti', 4.15),
('Čuvarkuća snova', 5, 5, 370, 'Fantazija o svijetu u kojem se snovi materijaliziraju.', 2, 'cuvarkuca_snova', 4.30),
('Sjena svitanja', 10, 1, 305, 'Putovanje kroz vrijeme koje mijenja tok povijesti.', 1, 'sjena_svitanja', 4.10),
('Noćna linija', 9, 2, 275, 'Napeta priča o vožnji koja se pretvara u borbu za istinu.', 1, 'nocna_linija', 4.00),
('Ulica tihe nade', 8, 3, 220, 'Topla priča o ljubavi i drugoj šansi.', 1, 'ulica_tihe_nade', 4.50),
('Skrivena istina', 7, 4, 260, 'Istražitelj se suočava s misterijom iz prošlosti.', 2, 'skrivena_istina', 4.20),
('Čuvaj moje riječi', 6, 5, 310, 'Svijet u kojem riječi imaju moć mijenjati stvarnost.', 1, 'cuvaj_moje_rijeci', 4.40),
('Odlazak bez povratka', 6, 1, 330, 'Pustolovina kroz izgubljene svjetove i nepoznate dimenzije.', 1, 'odlazak_bez_povratka', 4.25),
('Tiha osuda', 7, 2, 245, 'Triler u kojem je tišina najsnažnije oružje.', 1, 'tiha_osuda', 3.95),
('Miris prošlosti', 8, 3, 230, 'Sjećanja koja pokreću lavinu emocija i promjena.', 1, 'miris_proslosti', 4.60),
('Zidovi tame', 9, 4, 290, 'Napeta psihološka igra u zatvorenom kompleksu.', 2, 'zidovi_tame', 4.10),
('Dnevnik svjetlosti', 10, 5, 350, 'Fantazija o borbi svjetlosti i tame u svijetu snova.', 1, 'dnevnik_svjetlosti', 4.35);

INSERT INTO povijest_slusanja (korisnik_id, knjiga_id, pozicija, statusSlusanja_id) VALUES
(12, 1, 120, 1),
(13, 4, 210, 2),
(14, 3, 90, 1),
(15, 2, 45, 1);

INSERT INTO interakcije (korisnik_id, knjiga_id, ocjena, recenzija, omiljena, vrijeme_ostavljanja) VALUES
(12, 1, 5, 'Nevjerojatna priča, slušao sam je u jednom dahu!', TRUE, NOW()),
(13, 4, 4, 'Dosta zanimljivo, iako je kraj mogao biti jači.', FALSE, NOW()),
(14, 3, 5, 'Volim fantastiku, a ova knjiga je pravo blago!', TRUE, NOW()),
(15, 2, 3, 'Solidno, ali nije baš moj stil. Glas naratora bio je odličan.', FALSE, NOW());

INSERT INTO analitika (knjiga_id, datum, broj_slusanja, prosjecna_ocjena, vrijeme_slusanja) VALUES
(1, CURDATE(), 12, 5.00, 560),
(2, CURDATE(), 8, 3.00, 245),
(3, CURDATE(), 14, 5.00, 690),
(4, CURDATE(), 6, 4.00, 320);
