-- [01]

SELECT Name
FROM Track
WHERE Milliseconds < 
(SELECT Milliseconds
FROM Track
WHERE TrackId = 3457)

-- [02]

SELECT Name
FROM Track
WHERE MediaTypeId = 
(SELECT MediaTypeId
FROM Track
WHERE Name = 'Rehab')

-- [03]

SELECT Playlist.PlaylistId, 
  Playlist.Name,
  COUNT(PlaylistTrack.TrackId) as NbTrack, 
  ISNULL(SUM(Track.Milliseconds), 0) as DuréeTotale,
  ISNULL(SUM(Track.Milliseconds) / COUNT(PlaylistTrack.TrackId), 0) as DuréeMoyTrack
FROM PlaylistTrack
FULL JOIN Track ON PlaylistTrack.TrackId = Track.TrackId
FULL JOIN Playlist ON PlaylistTrack.PlaylistId = Playlist.PlaylistId
GROUP BY Playlist.PlaylistId, Playlist.Name
ORDER BY Playlist.PlaylistId

-- [04]

SELECT Playlist.PlaylistId, 
  Playlist.Name
FROM PlaylistTrack
FULL JOIN Track ON PlaylistTrack.TrackId = Track.TrackId
FULL JOIN Playlist ON PlaylistTrack.PlaylistId = Playlist.PlaylistId
GROUP BY Playlist.PlaylistId, Playlist.Name
HAVING ISNULL(SUM(Track.Milliseconds), 0) > 
(
  SELECT SUM(CAST(tab1.DuréeTotale as bigint)) / COUNT(tab1.PlaylistId) as DuréeMoyPlaylist
  FROM (
  SELECT Playlist.PlaylistId, 
    Playlist.Name,
    ISNULL(SUM(Track.Milliseconds), 0) as DuréeTotale
  FROM PlaylistTrack
  FULL JOIN Track ON PlaylistTrack.TrackId = Track.TrackId
  FULL JOIN Playlist ON PlaylistTrack.PlaylistId = Playlist.PlaylistId
  GROUP BY Playlist.PlaylistId, Playlist.Name
  ) as tab1
)
ORDER BY Playlist.PlaylistId

-- [05]

SELECT Playlist.PlaylistId, Playlist.Name
FROM Playlist
JOIN PlaylistTrack ON Playlist.PlaylistId = PlaylistTrack.PlaylistId
GROUP BY Playlist.PlaylistId, Playlist.Name
HAVING COUNT(PlaylistTrack.TrackId) IN (
  SELECT COUNT(PlaylistTrack.TrackId) as NbTrack
  FROM PlaylistTrack
  WHERE PlaylistTrack.PlaylistId = 1
  UNION
  SELECT COUNT(PlaylistTrack.TrackId) as NbTrack
  FROM PlaylistTrack
  WHERE PlaylistTrack.PlaylistId = 13)

-- [06]

SELECT Distinct c.customerid, c.FirstName, c.LastName
FROM invoice i
JOIN Customer c ON c.CustomerId = i.CustomerId
WHERE i.Total > (SELECT MAX(Total)
					FROM Invoice
          WHERE BillingCountry LIKE 'France')

-- [07]

-- [08]

SELECT t.TrackId, t.Name, t.Composer, t.Milliseconds, t.Bytes, t.UnitPrice, m.MediaTypeId, m.Name as Name_media,
(SELECT AVG(UnitPrice) FROM Track) as prix_moyen_global, AVG(UnitPrice) as prix_moyen_media
FROM track t
JOIN mediatype m ON m.MediaTypeId = t.MediaTypeId
WHERE unitprice > (SELECT AVG(UnitPrice) FROM Track)
GROUP BY  t.TrackId, t.Name, t.Composer, t.Milliseconds, t.Bytes, t.UnitPrice, m.MediaTypeId, m.Name

-- [09]

-- [10]

SELECT p.playlistid, p.name, COUNT(ar.ArtistId) Nb_Artist,
COUNT(t.TrackId) / COUNT(ar.artistId) 'Nb_Song/Artist',
AVG(i.unitprice) 'prix_moyen', MAX(ar.Name),  COUNT(ar.ArtistId) Max_Artist
FROM playlist p
JOIN PlaylistTrack pt ON pt.PlaylistId = p.PlaylistId
JOIN Track t ON t.TrackId = pt.TrackId
JOIN InvoiceLine i ON t.TrackId = i.TrackId
JOIN Album a ON a.AlbumId = t.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
GROUP BY p.PlaylistId, p.Name

-- [11]

SELECT c.Country, COUNT(c.country)+ COUNT(i.billingcountry)+COUNT(e.country) 'Nb_Line/States'
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId 
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.Country

-- [12]

SELECT c.Country as Pays, COUNT(c.country)+ COUNT(i.billingcountry)+COUNT(e.country) 'Total',
COUNT(e.country) Employee, COUNT(c.country) Customer, COUNT(i.billingcountry) Invoice
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId 
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.Country

-- [13]

-- [14]

SELECT il.invoicelineid, il.invoiceid, il.trackid, il.unitprice, il.quantity, AVG(il.unitprice) 'prix_moyen', 
il.UnitPrice/t.Milliseconds*1000 'cout_prix/sec', t.Milliseconds 'durée_total'
FROM InvoiceLine il
JOIN Track t ON t.TrackId = il.TrackId
GROUP BY il.invoicelineid, il.invoiceid, il.trackid, il.unitprice, il.quantity, t.Milliseconds

-- [15]

-- [16]

-- [17]

-- Partie 2 - Création d'une base
-- [18]

-- Partie 3 - Modifier des données
-- [19]

INSERT INTO Track
  (Name, 
  AlbumId, 
  MediaTypeId, 
  GenreId, 
  Composer, 
  Milliseconds, 
  Bytes, 
  UnitPrice) 
VALUES 
  ('Bass', 11, 1, 1, 'Test', 33720, 2905, 0.99), 
  ('Kick', 11, 1, 1, 'Test', 33720, 2905, 0.99), 
  ('Low', 11, 1, 1, 'Test', 33720, 2905, 0.99);

-- [20]

INSERT INTO Employee 
  (LastName, 
  FirstName, 
  Title, 
  ReportsTo,
  BirthDate, 
  HireDate, 
  Address, 
  City, 
  State, 
  Country, 
  PostalCode, 
  Phone, 
  Fax, 
  Email) 
VALUES 
  ('Chien', 'Cocker', 'Maitre', 1, 1666-05-29, 2019-12-10, '41 Quais des Chartrons', 'Bordeaux', 'FR', 'France', '33000', '+33610000000', '1000000000', 'lechien@ynov.com'), 
  ('Chat', 'Noir', 'Portier', 1, 1999-05-23, 2019-12-10, '41 Quais des Chartrons', 'Bordeaux', 'FR', 'France', '33000', '+33620000000', '2000000000', 'leportier@ynov.com')

select * from Employee

-- [21]

ALTER TABLE InvoiceLine
DROP InvoiceId
ALTER TABLE InvoiceLine
ADD CONSTRAINT InvoiceId
FOREIGN KEY (InvoiceId)
REFERENCES Invoice(InvoiceId)
ON DELETE CASCADE
DELETE FROM Invoice
WHERE YEAR(InvoiceDate) = 2010;

-- [22]

-- [23]

-- [24]

ALTER TABLE Employee 
ADD Salary int;

-- [25]

UPDATE Employee 
SET Salary = ROUND(RAND()*(100000-30000)+30000, 0);

-- [26]

ALTER TABLE Invoice
DROP COLUMN BillingPostalCode;