CREATE DATABASE Housing

SELECT *
FROM Nashville_Housing_Data


-- Standardize Date Format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SaleDate = CONVERT(date, SaleDate)


-- Populate Property Address data 
SELECT *
FROM Nashville_Housing_Data
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, B.PropertyAddress)
FROM Nashville_Housing_Data a 
JOIN Nashville_Housing_Data b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, B.PropertyAddress)
FROM Nashville_Housing_Data a 
JOIN Nashville_Housing_Data b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)
-- Breaking out PropertyAddress using SUBSTRING
SELECT PropertyAddress
FROM Nashville_Housing_Data

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Adress,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Adress
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD PropertyAddress_split NVARCHAR(255)
GO

UPDATE Nashville_Housing_Data
SET PropertyAddress_split = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing_Data
ADD PropertyCity_split NVARCHAR(255)
GO

UPDATE Nashville_Housing_Data
SET PropertyCity_split = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Nashville_Housing_Data


-- Breaking out OwnerAddress using PARSENAME
SELECT OwnerAddress
FROM Nashville_Housing_Data

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
       PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2), 
       PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD OwnerAddress_split NVARCHAR(255)
GO

UPDATE Nashville_Housing_Data
SET OwnerAddress_split = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville_Housing_Data
ADD OwnerCity_split NVARCHAR(255)
GO

UPDATE Nashville_Housing_Data
SET OwnerCity_split = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville_Housing_Data
ADD OwnerState_split NVARCHAR(255)
GO

UPDATE Nashville_Housing_Data
SET OwnerState_split = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM Nashville_Housing_Data


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'N' THEN 'No'
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    ELSE SoldAsVacant
END    
FROM Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SoldAsVacant = 
    CASE
        WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        ELSE SoldAsVacant
    END  

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Nashville_Housing_Data
GROUP BY SoldAsVacant;


-- Remove Duplicates
WITH row_CTE AS (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                    PropertyAddress,
                                    SalePrice,
                                    SaleDate,
                                    LegalReference
                      ORDER BY UniqueID) AS num#
FROM Nashville_Housing_Data
)
DELETE
FROM row_CTE
WHERE num# > 1

WITH row_CTE AS (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                    PropertyAddress,
                                    SalePrice,
                                    SaleDate,
                                    LegalReference
                      ORDER BY UniqueID) AS num#
FROM Nashville_Housing_Data
)
SELECT *
FROM row_CTE
WHERE num# > 1


-- Delete Unused Columns
Select *
From Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate