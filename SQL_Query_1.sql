/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Project_Mk0.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM Project_Mk0.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)


-- If it doesn't Update properly


ALTER TABLE Project_Mk0.dbo.NashvilleHousing
ADD SaleDateConverted DATE


Update NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT *
FROM Project_Mk0.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT copy1.ParcelID, copy1.PropertyAddress, copy2.ParcelID, copy2.PropertyAddress, 
ISNULL(copy1.PropertyAddress,copy2.PropertyAddress)
FROM Project_Mk0.dbo.NashvilleHousing AS copy1
JOIN Project_Mk0.dbo.NashvilleHousing AS copy2
	ON copy1.ParcelID = copy2.ParcelID
	AND copy1.[UniqueID ] != copy2.[UniqueID ]
WHERE copy1.PropertyAddress IS NULL


Update copy1
SET PropertyAddress = ISNULL(copy1.PropertyAddress,copy2.PropertyAddress)
FROM Project_Mk0.dbo.NashvilleHousing AS copy1
JOIN Project_Mk0.dbo.NashvilleHousing AS copy2
	ON copy1.ParcelID = copy2.ParcelID
	AND copy1.[UniqueID ] != copy2.[UniqueID ]


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM Project_Mk0.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM Project_Mk0.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 ,
									LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Project_Mk0.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
From Project_Mk0.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project_Mk0.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
	    WHEN SoldAsVacant = 'N' THEN 'No'
	    ELSE SoldAsVacant
	    END
FROM Project_Mk0.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
	    WHEN SoldAsVacant = 'N' THEN 'No'
	    ELSE SoldAsVacant
	    END
			   		 	  	  

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) AS row_num
	FROM Project_Mk0.dbo.NashvilleHousing
)


DELETE				--SELECT * FROM RowNumCTE
FROM RowNumCTE		--WHERE row_num > 1
WHERE row_num > 1	--ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM Project_Mk0.dbo.NashvilleHousing


ALTER TABLE Project_Mk0.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
