
 --Standardize Data Format
 SELECT SaleDate, CONVERT(Date,SaleDate)
 FROM [Portfolio Project 1]..NashvilleHousingData$
 

ALTER TABLE NashvilleHousingData$
ADD SaleDateConverted Date;

 UPDATE NashvilleHousingData$
 SET SaleDateConverted = CONVERT(Date,SaleDate)

 SELECT *
 FROM [Portfolio Project 1]..NashvilleHousingData$


 --Populate Property Address Data

 SELECT *
 FROM [Portfolio Project 1]..NashvilleHousingData$
 --WHERE PropertyAddress is null
 ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 1]..NashvilleHousingData$ a
JOIN [Portfolio Project 1]..NashvilleHousingData$ b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <>  b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 1]..NashvilleHousingData$ a
JOIN [Portfolio Project 1]..NashvilleHousingData$ b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <>  b.UniqueID
WHERE a.PropertyAddress IS NULL



--Address into Individual Columns

SELECT PropertyAddress
FROM [Portfolio Project 1]..NashvilleHousingData$
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS CITY

FROM [Portfolio Project 1]..NashvilleHousingData$


ALTER TABLE NashvilleHousingData$
ADD PropertySplitAddress NVARCHAR(255);

 UPDATE NashvilleHousingData$
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

 ALTER TABLE NashvilleHousingData$
ADD PropertySplitCity NVARCHAR(255);

 UPDATE NashvilleHousingData$
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

 SELECT *
 FROM NashvilleHousingData$


 -- Owner Address Split Data
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project 1]..NashvilleHousingData$

ALTER TABLE NashvilleHousingData$
ADD OwnerSplitAddress NVARCHAR(255);

 UPDATE NashvilleHousingData$
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


 ALTER TABLE NashvilleHousingData$
ADD OwnerSplitCity NVARCHAR(255);

 UPDATE NashvilleHousingData$
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


  ALTER TABLE NashvilleHousingData$
ADD OwnerSplitState NVARCHAR(255);

 UPDATE NashvilleHousingData$
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



 --Change Y to "Yes and N to "No"

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM [Portfolio Project 1]..NashvilleHousingData$
 GROUP BY SoldAsVacant
 ORDER BY 2

 SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
 FROM [Portfolio Project 1]..NashvilleHousingData$

 UPDATE NashvilleHousingData$
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--Remove Duplicates

WITH RowNumCTE AS(SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
FROM [Portfolio Project 1]..NashvilleHousingData$
)

SELECT *
FROM RowNumCTE
WHERE row_num >1


--Delete Unused Columns

ALTER TABLE [Portfolio Project 1]..NashvilleHousingData$
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,

SELECT *
FROM [Portfolio Project 1]..NashvilleHousingData$

ALTER TABLE [Portfolio Project 1]..NashvilleHousingData$
DROP COLUMN SaleDate