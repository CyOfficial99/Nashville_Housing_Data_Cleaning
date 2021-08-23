--Checking data overview--
SELECT *
FROM DataCleaningProject..Nashville_Housing

--Convert Date Format--
SELECT SaleDate
FROM DataCleaningProject..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM DataCleaningProject..Nashville_Housing

--Populate Property Address Data--
SELECT *
FROM DataCleaningProject..Nashville_Housing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM DataCleaningProject..Nashville_Housing a
JOIN DataCleaningProject..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject..Nashville_Housing a
JOIN DataCleaningProject..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Seperate Address into Individual Term ~ Property Address (Address, City)--
SELECT PropertyAddress
FROM DataCleaningProject..Nashville_Housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM DataCleaningProject..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertyAddressSplitted Nvarchar(255)

UPDATE Nashville_Housing
SET PropertyAddressSplitted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD PropertyCitySplitted Nvarchar(255)

UPDATE Nashville_Housing
SET PropertyCitySplitted = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Seperate Address into Individual Term ~ Owner Address (Address, City, State)--
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaningProject..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerAddressSplitted Nvarchar(255)

UPDATE Nashville_Housing
SET OwnerAddressSplitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerCitySplitted Nvarchar(255)

UPDATE Nashville_Housing
SET OwnerCitySplitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerStateSplitted Nvarchar(255)

UPDATE Nashville_Housing
SET OwnerStateSplitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in Sold as Vacant column--
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject..Nashville_Housing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM DataCleaningProject..Nashville_Housing

UPDATE DataCleaningProject..Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates--
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM DataCleaningProject..Nashville_Housing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

--Delete Unused Columns--
SELECT *
FROM DataCleaningProject..Nashville_Housing

ALTER TABLE DataCleaningProject..Nashville_Housing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict