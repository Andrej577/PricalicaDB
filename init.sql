CREATE TABLE korisnici (
    korisnik_id SERIAL PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    lozinka_hash VARCHAR(255) NOT NULL,
    tip_korisnika VARCHAR(10) CHECK (tip_korisnika IN ('user', 'autor', 'admin')),
    datum_registracije TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_racuna VARCHAR(10) CHECK (status_racuna IN ('aktivan', 'neaktivan')),
    ima_pretplatu BOOLEAN NOT NULL DEFAULT FALSE,
    iznos_prihoda NUMERIC(10, 2) DEFAULT 0.00
);

CREATE TABLE povijest_slusanja (
    povijest_id SERIAL PRIMARY KEY,
    korisnik_id INT NOT NULL,
    knjiga_id INT NOT NULL,
    pozicija INT NOT NULL DEFAULT 0,
    posljednje_slusanje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) CHECK (status IN ('u_tijeku', 'dovrseno'))
);

CREATE TABLE interakcije (
    interakcija_id SERIAL PRIMARY KEY,
    korisnik_id INT NOT NULL,
    knjiga_id INT NOT NULL,
    ocjena INT CHECK (ocjena BETWEEN 1 AND 5),
    recenzija TEXT,
    vrijeme_ostavljanja TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    omiljena BOOLEAN DEFAULT FALSE
);

CREATE TABLE transakcije (
    transakcija_id SERIAL PRIMARY KEY,
    korisnik_id INT NOT NULL,
    iznos DECIMAL(10, 2) NOT NULL,
    datum_transakcije TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(15) CHECK (status IN ('uspjesna', 'neuspjesna', 'na_cekanju'))
);

CREATE TABLE knjige (
    knjiga_id SERIAL PRIMARY KEY,
    naslov VARCHAR(150) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    zanr VARCHAR(50) NOT NULL,
    trajanje_min INT NOT NULL,
    opis TEXT,
    datum_dodavanja TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_dostupnosti VARCHAR(10) CHECK (status_dostupnosti IN ('free', 'premium')),
    poveznica VARCHAR(255),
    prosjecna_ocjena NUMERIC(3, 2) DEFAULT 0.00
);

CREATE TABLE analitika (
    analitika_id SERIAL PRIMARY KEY,
    knjiga_id INT NOT NULL,
    korisnik_id INT,
    datum DATE NOT NULL,
    broj_slusanja INT NOT NULL DEFAULT 0,
    prosjecna_ocjena DECIMAL(3,2) DEFAULT 0.00,
    vrijeme_slusanja INT NOT NULL DEFAULT 0
);

-- Povezivanje interakcija sa korisnicima i knjigama
ALTER TABLE interakcije
ADD CONSTRAINT fk_interakcije_korisnici
FOREIGN KEY (korisnik_id) REFERENCES korisnici(korisnik_id);

ALTER TABLE interakcije
ADD CONSTRAINT fk_interakcije_knjige
FOREIGN KEY (knjiga_id) REFERENCES knjige(knjiga_id);

-- Povezivanje povijesti slušanja sa korisnicima i knjigama
ALTER TABLE povijest_slusanja
ADD CONSTRAINT fk_povijest_korisnici
FOREIGN KEY (korisnik_id) REFERENCES korisnici(korisnik_id);

ALTER TABLE povijest_slusanja
ADD CONSTRAINT fk_povijest_knjige
FOREIGN KEY (knjiga_id) REFERENCES knjige(knjiga_id);

-- Povezivanje transakcija sa korisnicima
ALTER TABLE transakcije
ADD CONSTRAINT fk_transakcije_korisnici
FOREIGN KEY (korisnik_id) REFERENCES korisnici(korisnik_id);

-- Povezivanje analitike sa korisnicima i knjigama
ALTER TABLE analitika
ADD CONSTRAINT fk_analitika_korisnici
FOREIGN KEY (korisnik_id) REFERENCES korisnici(korisnik_id);

ALTER TABLE analitika
ADD CONSTRAINT fk_analitika_knjige
FOREIGN KEY (knjiga_id) REFERENCES knjige(knjiga_id);

INSERT INTO korisnici (ime, prezime, email, lozinka_hash, tip_korisnika, status_racuna, ima_pretplatu, iznos_prihoda) VALUES
('Lana', 'Kovac', 'lana.kovac@example.com', 'hashedpassword5', 'user', 'aktivan', FALSE, 0.00),
('Filip', 'Novak', 'filip.novak@example.com', 'hashedpassword6', 'autor', 'aktivan', TRUE, 750.00),
('Marina', 'Babić', 'marina.babic@example.com', 'hashedpassword7', 'user', 'neaktivan', FALSE, 0.00),
('Tomislav', 'Juric', 'tomislav.juric@example.com', 'hashedpassword8', 'autor', 'aktivan', TRUE, 950.75),
('Ivana', 'Kralj', 'ivana.kralj@example.com', 'hashedpassword9', 'admin', 'aktivan', TRUE, 0.00),
('Nikola', 'Bosnjak', 'nikola.bosnjak@example.com', 'hashedpassword10', 'autor', 'aktivan', TRUE, 120.20),
('Maja', 'Vukovic', 'maja.vukovic@example.com', 'hashedpassword11', 'user', 'aktivan', FALSE, 0.00),
('Dino', 'Lovric', 'dino.lovric@example.com', 'hashedpassword12', 'autor', 'neaktivan', TRUE, 300.00),
('Katarina', 'Soldo', 'katarina.soldo@example.com', 'hashedpassword13', 'user', 'aktivan', FALSE, 0.00),
('Goran', 'Majic', 'goran.majic@example.com', 'hashedpassword14', 'autor', 'aktivan', TRUE, 680.00),
('Tea', 'Radic', 'tea.radic@example.com', 'hashedpassword15', 'user', 'aktivan', FALSE, 0.00),
('Josip', 'Vidovic', 'josip.vidovic@example.com', 'hashedpassword16', 'autor', 'aktivan', TRUE, 540.40),
('Lucija', 'Erceg', 'lucija.erceg@example.com', 'hashedpassword17', 'user', 'neaktivan', FALSE, 0.00),
('Karlo', 'Zoric', 'karlo.zoric@example.com', 'hashedpassword18', 'autor', 'aktivan', TRUE, 870.00),
('Petra', 'Varga', 'petra.varga@example.com', 'hashedpassword19', 'user', 'aktivan', FALSE, 0.00),
('Antonio', 'Skoko', 'antonio.skoko@example.com', 'hashedpassword20', 'admin', 'aktivan', TRUE, 0.00),
('Ines', 'Barisic', 'ines.barisic@example.com', 'hashedpassword21', 'user', 'neaktivan', FALSE, 0.00),
('Toni', 'Knezevic', 'toni.knezevic@example.com', 'hashedpassword22', 'autor', 'aktivan', TRUE, 1230.55),
('Lea', 'Matijevic', 'lea.matijevic@example.com', 'hashedpassword23', 'user', 'aktivan', FALSE, 0.00),
('Stjepan', 'Miletic', 'stjepan.miletic@example.com', 'hashedpassword24', 'autor', 'aktivan', TRUE, 450.00),
('Helena', 'Kujundzic', 'helena.kujundzic@example.com', 'hashedpassword25', 'user', 'aktivan', FALSE, 0.00),
('Kristijan', 'Zupan', 'kristijan.zupan@example.com', 'hashedpassword26', 'autor', 'neaktivan', TRUE, 200.00),
('Sara', 'Milic', 'sara.milic@example.com', 'hashedpassword27', 'user', 'aktivan', FALSE, 0.00),
('Davor', 'Crnkovic', 'davor.crnkovic@example.com', 'hashedpassword28', 'autor', 'aktivan', TRUE, 975.25),
('Marta', 'Stepic', 'marta.stepic@example.com', 'hashedpassword29', 'user', 'neaktivan', FALSE, 0.00),
('Bruno', 'Dragic', 'bruno.dragic@example.com', 'hashedpassword30', 'admin', 'aktivan', TRUE, 0.00),
('Andrea', 'Kresic', 'andrea.kresic@example.com', 'hashedpassword31', 'user', 'aktivan', FALSE, 0.00),
('Domagoj', 'Kovacevic', 'domagoj.kovacevic@example.com', 'hashedpassword32', 'autor', 'aktivan', TRUE, 840.00),
('Martina', 'Delic', 'martina.delic@example.com', 'hashedpassword33', 'user', 'neaktivan', FALSE, 0.00),
('Renato', 'Sabljak', 'renato.sabljak@example.com', 'hashedpassword34', 'autor', 'aktivan', TRUE, 1080.10);



INSERT INTO knjige (naslov, autor, zanr, trajanje_min, opis, status_dostupnosti, poveznica, prosjecna_ocjena) VALUES
('Mali princ', 'Antoine de Saint-Exupéry', 'Bajka', 95, 'Filozofska bajka o djetetu i odraslom svijetu.', 'free', 'http://example.com/mali_princ.mp3', 4.95),
('Kafka na žalu', 'Haruki Murakami', 'Magični realizam', 410, 'Mistično putovanje kroz identitet i sudbinu.', 'premium', 'http://example.com/kafka.mp3', 4.60),
('Derviš i smrt', 'Meša Selimović', 'Roman', 320, 'Duboko filozofsko djelo o slobodi i čovjeku.', 'free', 'http://example.com/dervis.mp3', 4.88),
('Lovac u žitu', 'J.D. Salinger', 'Kultni roman', 210, 'Priča o mladosti, otuđenju i traženju smisla.', 'premium', 'http://example.com/lovac.mp3', 4.45),
('Na Drini ćuprija', 'Ivo Andrić', 'Istorijski roman', 370, 'Epska priča o mostu koji povezuje ljude i sudbine.', 'free', 'http://example.com/cuprija.mp3', 4.92),
('Stoner', 'John Williams', 'Roman', 250, 'Tiha drama o životu običnog čovjeka.', 'premium', 'http://example.com/stoner.mp3', 4.70),
('Sjena vjetra', 'Carlos Ruiz Zafón', 'Misterija', 430, 'Ljubavno pismo knjigama i misterijama prošlosti.', 'premium', 'http://example.com/sjena.mp3', 4.85),
('Bratstvo crnog bodeža', 'J.R. Ward', 'Fantazija', 310, 'Vampiri, ljubav i rat u podzemnom društvu.', 'premium', 'http://example.com/bodez.mp3', 4.30),
('Čovjek po imenu Uve', 'Fredrik Backman', 'Humor', 195, 'Dirljiva i zabavna priča o mrzovoljnom starcu.', 'free', 'http://example.com/uve.mp3', 4.77),
('Alhemičar', 'Paulo Coelho', 'Inspirativni roman', 170, 'Putovanje samootkrića i sudbine.', 'free', 'http://example.com/alhemicar.mp3', 4.40),
('Tvrđava', 'Meša Selimović', 'Roman', 350, 'Duboko ljudsko i filozofsko preispitivanje smisla.', 'premium', 'http://example.com/tvrdjava.mp3', 4.83),
('Norveška šuma', 'Haruki Murakami', 'Ljubavni roman', 280, 'Ljubav i gubitak u studentskim danima.', 'premium', 'http://example.com/norveska.mp3', 4.50),
('Zločin i kazna', 'Fjodor Dostojevski', 'Klasik', 420, 'Psihološki roman o moralu i iskupljenju.', 'free', 'http://example.com/zlocin.mp3', 4.93),
('Ana Karenjina', 'Lav Tolstoj', 'Klasik', 540, 'Ljubavna tragedija u ruskom društvu.', 'premium', 'http://example.com/karenjina.mp3', 4.70),
('Veliki Getsbi', 'F. Scott Fitzgerald', 'Roman', 190, 'Američki san, ljubav i propast.', 'free', 'http://example.com/getsbi.mp3', 4.60),
('Lovac na zmajeve', 'Khaled Hosseini', 'Drama', 380, 'Priča o prijateljstvu i iskupljenju u Afganistanu.', 'premium', 'http://example.com/zmajevi.mp3', 4.75),
('Bijela kuća', 'Petar Peca Popović', 'Biografija', 240, 'Život rock novinara kroz muziku i vrijeme.', 'free', 'http://example.com/bijela_kuca.mp3', 4.35),
('Doktor Živago', 'Boris Pasternak', 'Istorijska drama', 510, 'Ljubav usred revolucije.', 'premium', 'http://example.com/zivago.mp3', 4.55),
('Čarobnjak iz Oza', 'L. Frank Baum', 'Fantazija', 130, 'Putovanje malene devojčice u čudesni svet.', 'free', 'http://example.com/oz.mp3', 4.20),
('Put', 'Cormac McCarthy', 'Postapokalipsa', 220, 'Otac i sin putuju kroz razoreni svijet.', 'premium', 'http://example.com/put.mp3', 4.48),
('Ponos i predrasude', 'Jane Austen', 'Roman', 260, 'Ljubav i društvene norme u viktorijanskoj Engleskoj.', 'free', 'http://example.com/ponos.mp3', 4.82),
('Besnilo', 'Borislav Pekić', 'Triler', 350, 'Zaraza, zatvoreni aerodrom i paranoja.', 'premium', 'http://example.com/besnilo.mp3', 4.70),
('To', 'Stephen King', 'Horor', 600, 'Zlo iz kanalizacije koje napada djecu.', 'premium', 'http://example.com/it.mp3', 4.65),
('Dina', 'Frank Herbert', 'Sci-Fi', 520, 'Pješčani svijet, politika i moć.', 'premium', 'http://example.com/dina.mp3', 4.80),
('Moby Dick', 'Herman Melville', 'Avantura', 480, 'Opsesivni lov na bijelog kita.', 'free', 'http://example.com/moby.mp3', 4.50),
('Životinjska farma', 'George Orwell', 'Satira', 115, 'Politička alegorija kroz životinje.', 'free', 'http://example.com/farma.mp3', 4.76),
('Braća Karamazovi', 'Fjodor Dostojevski', 'Klasik', 630, 'Filozofska i porodična drama.', 'premium', 'http://example.com/karamazovi.mp3', 4.91),
('Frankenštajn', 'Mary Shelley', 'Horor', 210, 'Stvorenje koje nadmaši svog tvorca.', 'free', 'http://example.com/frankenstajn.mp3', 4.34),
('Otac Goriot', 'Honoré de Balzac', 'Realizam', 300, 'Očeva žrtva u licemjernom društvu.', 'premium', 'http://example.com/goriot.mp3', 4.58),
('Soba', 'Emma Donoghue', 'Drama', 270, 'Majka i dijete zatvoreni u sobi.', 'premium', 'http://example.com/soba.mp3', 4.69);



INSERT INTO transakcije (korisnik_id, iznos, status) VALUES
                        (2, 250.00, 'uspjesna'),
                        (3, 99.99, 'neuspjesna'),
                        (4, 150.75, 'uspjesna'),
                        (5, 300.00, 'uspjesna'),
                        (6, 50.00, 'uspjesna'),
                        (7, 120.40, 'neuspjesna'),
                        (8, 430.99, 'uspjesna'),
                        (9, 200.00, 'neuspjesna'),
                        (10, 180.20, 'uspjesna'),
                        (11, 75.75, 'uspjesna'),
                        (12, 90.00, 'uspjesna'),
                        (13, 210.10, 'neuspjesna'),
                        (14, 320.00, 'uspjesna'),
                        (15, 145.45, 'uspjesna'),
                        (16, 60.00, 'neuspjesna'),
                        (17, 310.50, 'uspjesna'),
                        (18, 88.80, 'neuspjesna'),
                        (19, 540.00, 'uspjesna'),
                        (20, 175.25, 'uspjesna'),
                        (21, 110.00, 'uspjesna'),
                        (22, 99.95, 'neuspjesna'),
                        (23, 205.00, 'uspjesna'),
                        (24, 260.60, 'uspjesna'),
                        (25, 150.50, 'uspjesna'),
                        (26, 70.70, 'neuspjesna'),
                        (27, 395.00, 'uspjesna'),
                        (28, 480.00, 'uspjesna'),
                        (29, 130.00, 'neuspjesna'),
                        (30, 255.55, 'uspjesna');



INSERT INTO interakcije (korisnik_id, knjiga_id, ocjena, recenzija, omiljena) VALUES
(2, 5, 4, 'Zanimljiva priča, ali kraj mi je bio slabiji.', FALSE),
(3, 1, 5, 'Predivno napisano, pročitao sam u dahu.', TRUE),
(4, 7, 3, 'Ok knjiga, nije me baš oduševila.', FALSE),
(5, 2, 5, 'Jedna od najboljih koje sam čitala!', TRUE),
(6, 4, 2, 'Nisam uspio/la da se povežem sa likovima.', FALSE),
(7, 6, 4, 'Dosta dobra knjiga, preporuka.', FALSE),
(8, 10, 5, 'Stvarno remek-djelo!', TRUE),
(9, 9, 3, 'Solidno štivo, iako pomalo predvidljivo.', FALSE),
(10, 3, 5, 'Ne mogu je dovoljno hvaliti. Vrhunski rad!', TRUE),
(11, 11, 4, 'Dobra knjiga, ali fali malo dubine.', FALSE),
(12, 8, 1, 'Meni nije legla, prespora i dosadna.', FALSE),
(13, 15, 5, 'Inspirativna i emotivna.', TRUE),
(14, 12, 3, 'Ništa posebno, ali vrijedilo je pročitati.', FALSE),
(15, 13, 4, 'Odlična atmosfera i stil pisanja.', FALSE),
(16, 20, 5, 'Fantastična knjiga!', TRUE),
(17, 17, 2, 'Previše razvlačenja bez poente.', FALSE),
(18, 18, 4, 'Zanimljiva i drugačija.', FALSE),
(19, 14, 5, 'Moj favorit ove godine!', TRUE),
(20, 19, 3, 'Dobra knjiga, ali sam očekivao više.', FALSE),
(21, 16, 4, 'Vrijedi svake minute.', FALSE),
(22, 21, 5, 'Prelijepa poruka i stil.', TRUE),
(23, 22, 1, 'Najgore što sam pročitao ove godine.', FALSE),
(24, 23, 5, 'Izvanredno iskustvo.', TRUE),
(25, 24, 4, 'Zanimljiv pogled na temu.', FALSE),
(26, 25, 2, 'Imala je potencijala, ali nije ispunila očekivanja.', FALSE),
(27, 26, 3, 'Prosječna knjiga, ali ne gubite vrijeme.', FALSE),
(28, 27, 5, 'Apsolutno fantastično!', TRUE),
(29, 28, 4, 'Jako lijepo napisana.', FALSE),
(30, 29, 3, 'Ništa spektakularno, ali ok.', FALSE);


INSERT INTO povijest_slusanja (korisnik_id, knjiga_id, pozicija, status) VALUES
(2, 3, 125, 'u_tijeku'),
(3, 5, 0, 'u_tijeku'),
(4, 1, 360, 'dovrseno'),
(5, 7, 70, 'u_tijeku'),
(6, 4, 180, 'dovrseno'),
(7, 6, 310, 'dovrseno'),
(8, 2, 90, 'u_tijeku'),
(9, 8, 240, 'dovrseno'),
(10, 10, 0, 'u_tijeku'),
(11, 9, 95, 'u_tijeku'),
(12, 11, 150, 'dovrseno'),
(13, 12, 0, 'u_tijeku'),
(14, 14, 275, 'dovrseno'),
(15, 13, 260, 'dovrseno'),
(16, 15, 25, 'u_tijeku'),
(17, 16, 0, 'u_tijeku'),
(18, 17, 370, 'dovrseno'),
(19, 18, 85, 'u_tijeku'),
(20, 19, 520, 'dovrseno'),
(21, 20, 110, 'u_tijeku'),
(22, 21, 260, 'dovrseno'),
(23, 22, 0, 'u_tijeku'),
(24, 23, 120, 'u_tijeku'),
(25, 24, 270, 'dovrseno'),
(26, 25, 0, 'u_tijeku'),
(27, 26, 320, 'dovrseno'),
(28, 27, 480, 'dovrseno'),
(29, 28, 100, 'u_tijeku'),
(30, 29, 0, 'u_tijeku');

INSERT INTO analitika (knjiga_id, korisnik_id, datum, broj_slusanja, prosjecna_ocjena, vrijeme_slusanja) VALUES
(1, 2, '2025-03-20', 3, 4.50, 2700),
(2, 3, '2025-03-21', 2, 4.20, 1800),
(3, 4, '2025-03-22', 6, 4.75, 3600),
(4, 5, '2025-03-23', 4, 4.10, 2400),
(5, 6, '2025-03-24', 1, 3.90, 1200),
(6, 7, '2025-03-25', 8, 4.80, 4800),
(7, 8, '2025-03-26', 2, 4.00, 1600),
(8, 9, '2025-03-27', 5, 4.60, 3500),
(9, 10, '2025-03-28', 3, 4.35, 2700),
(10, 11, '2025-03-29', 7, 4.90, 4200),
(11, 12, '2025-03-30', 4, 4.50, 2500),
(12, 13, '2025-03-31', 1, 3.80, 900),
(13, 14, '2025-04-01', 6, 4.25, 3100),
(14, 15, '2025-04-02', 3, 4.10, 2300),
(15, 16, '2025-04-03', 5, 4.70, 3600),
(16, 17, '2025-04-04', 2, 4.05, 1500),
(17, 18, '2025-04-05', 4, 4.60, 2800),
(18, 19, '2025-04-06', 6, 4.85, 4000),
(19, 20, '2025-04-07', 1, 3.95, 1200),
(20, 21, '2025-04-08', 5, 4.50, 3300),
(21, 22, '2025-04-09', 2, 4.15, 1900),
(22, 23, '2025-04-10', 3, 4.00, 2100),
(23, 24, '2025-04-11', 4, 4.40, 2600),
(24, 25, '2025-04-12', 2, 4.55, 2300),
(25, 26, '2025-04-13', 7, 4.80, 3700),
(26, 27, '2025-04-14', 6, 4.25, 2900),
(27, 28, '2025-04-15', 5, 4.65, 3100),
(28, 29, '2025-04-16', 3, 4.10, 2200),
(29, 30, '2025-04-17', 1, 3.75, 1300),
(30, 1, '2025-04-18', 4, 4.50, 2800);

