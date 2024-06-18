/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing





----Standardize Date Format

---step 3 get the table
SELECT 
	SaleDateConverted , CONVERT(Date, SaleDate)
FROM
	PortfolioProject.dbo.NashvilleHousing


---set 1 adding
ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

--step 2 changing the column name
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)






-----Populate Property Adress data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
ORDER BY ParcelID


---Check null in PropertyAddress
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


--Fill null with actual adress
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null





----Breaking out Adress into Individual Columns(Adress, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Adress
		, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress) ) AS City
FROM PortfolioProject.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )





ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress) )



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing




---Separate OwnerAdress

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing




SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing





----Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.NashvilleHousing



UPDATE NashvilleHousing
SET	SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END




----Remove Duplicates


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
--ORDER BY ParcelID
DELETE --SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-----Delete unused columns


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
